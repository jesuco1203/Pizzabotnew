#!/usr/bin/env python3
import os, re, sys, json, hashlib, subprocess, time
from datetime import datetime
from pathlib import Path

# -------- Config --------
ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
OUT  = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("CONTEXT")
MAX_CHARS = 6000            # ~1500-2000 tokens aprox. (ajusta si quieres)
INCLUDE_EXT = {
  ".py",".ts",".tsx",".js",".jsx",".json",".yaml",".yml",".toml",".md",".sql",
  ".env.example",".sh",".ini",".cfg",".graphql",".proto",".java",".go"
}
EXCLUDE_DIRS = {".git","node_modules",".venv","venv",".next",".cache","dist","build","out",".idea",".vscode", "CONTEXT", "__pycache__"}
EXCLUDE_EXT = {".pyc", ".pyo", ".pyd", ".so", ".dll", ".exe", ".dylib", ".DS_Store"}
BINARY_RE = re.compile(r'\.(png|jpg|jpeg|gif|webp|ico|pdf|mp4|mp3|ogg|wav|ttf|otf|woff2?|zip|tar|gz|7z)$', re.I)
SECRET_RE = re.compile(r'(api[_-]?key|secret|token|password|passwd|pwd|bearer|authorization)\s*[:=]\s*.+', re.I)

# Check if we are in a git repository
IS_GIT = (ROOT / ".git").exists()

# -------- Helpers --------
def is_binary(p: Path) -> bool:
    return bool(BINARY_RE.search(p.suffix))

def should_skip(p: Path) -> bool:
    parts = set(p.parts)
    if parts & EXCLUDE_DIRS: return True
    if p.suffix.lower() in EXCLUDE_EXT: return True
    if is_binary(p): return True
    if p.name in EXCLUDE_DIRS: return True # This is redundant with parts & EXCLUDE_DIRS but harmless
    if p.suffix and (p.suffix.lower() in INCLUDE_EXT or p.name.endswith(".env.example")):
        return False
    return p.suffix == ""  # skip files sin extensión por defecto

def git_last_commit(path: Path) -> str:
    if not IS_GIT: return "-"
    try:
        out = subprocess.check_output(["git","log","-1","--format=%cs %h","--",str(path)], cwd=ROOT, stderr=subprocess.DEVNULL).decode().strip()
        return out or "-"
    except Exception:
        return "" # Return empty string if git fails

def sha1(txt: str) -> str:
    return hashlib.sha1(txt.encode("utf-8", errors="ignore")).hexdigest()

def sanitize_secrets(text: str) -> str:
    lines = []
    for line in text.splitlines():
        if SECRET_RE.search(line):
            # conserva la clave pero enmascara el valor
            k = line.split(":",1)[0] if ":" in line else line.split("=",1)[0]
            lines.append(f'{k}: ***REDACTED***')
        else:
            lines.append(line)
    return "\n".join(lines)

def chunk(text: str, max_chars=MAX_CHARS):
    blocks, buf = [], []
    total = 0
    for ln in text.splitlines(True):
        if total + len(ln) > max_chars and buf:
            blocks.append("".join(buf)); buf, total = [], 0
        buf.append(ln); total += len(ln)
    if buf: blocks.append("".join(buf))
    return blocks or [""]

def detect_lang(path: Path) -> str:
    ext = path.suffix.lower()
    return {
      ".py":"python",".ts":"typescript",".tsx":"tsx",".js":"javascript",".jsx":"jsx",
      ".json":"json",".yaml":"yaml",".yml":"yaml",".toml":"toml",".md":"md",
      ".sql":"sql",".sh":"bash",".ini":"ini",".cfg":"ini",".graphql":"application/graphql",".proto":"text/x-protobuf",".java":"text/x-java-source",".go":"text/x-go"
    }.get(ext,"")

def guess_mime(p: Path) -> str:
    return {
        ".py":"text/x-python",
        ".md":"text/markdown",
        ".json":"application/json",
        ".txt":"text/plain",
        ".ts":"text/typescript",
        ".tsx":"text/typescript",
        ".js":"text/javascript",
        ".jsx":"text/javascript",
        ".yaml":"text/yaml",
        ".yml":"text/yaml",
        ".toml":"text/toml",
        ".sql":"text/sql",
        ".sh":"application/x-sh",
        ".ini":"text/ini",
        ".cfg":"text/ini",
        ".graphql":"application/graphql",
        ".proto":"text/x-protobuf",
        ".java":"text/x-java-source",
        ".go":"text/x-go"
    }.get(p.suffix.lower(),"text/plain")

def count_loc(txt: str) -> int:
    return sum(1 for _ in txt.splitlines())

def get_script_git_sha() -> str:
    if not IS_GIT: return "unknown"
    try:
        script_path = Path(__file__).resolve()
        return subprocess.check_output(["git", "rev-parse", "--short", "HEAD", "--", str(script_path)], cwd=ROOT, stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return "unknown"

# -------- Main --------
def main():
    OUT.mkdir(parents=True, exist_ok=True)
    chunks_dir = OUT / "chunks"
    chunks_dir.mkdir(exist_ok=True)

    files_meta = []
    for path in ROOT.rglob("*"):
        if path.is_dir():
            continue
        rel = path.relative_to(ROOT)
        if should_skip(rel): continue
        try:
            txt = path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        txt = sanitize_secrets(txt)
        parts = chunk(txt)
        lm = git_last_commit(rel)
        
        file_loc = count_loc(txt)
        file_mime = guess_mime(rel)

        for i, part in enumerate(parts):
            h = sha1(str(rel)+"#"+str(i)+"#"+str(len(part)))
            lang = detect_lang(rel)
            outf = chunks_dir / f'{rel.as_posix().replace("/","__")}__p{i+1}_{h[:8]}.md'
            outf.parent.mkdir(parents=True, exist_ok=True)
            with outf.open("w", encoding="utf-8") as f:
                f.write(f'<!-- path:{rel} part:{i+1}/{len(parts)} commit:{lm} -->\n')
                if lang and lang!="md": f.write(f'```{lang}\n{part}\n```\n')
                else: f.write(part if part.endswith("\n") else part+"\n")
            files_meta.append({
                "path": rel.as_posix(),
                "part": i+1,
                "parts": len(parts),
                "chars": len(part),
                "loc": file_loc,
                "mime": file_mime,
                "hash": h,
                "commit": lm,
                "chunk_file": outf.relative_to(OUT).as_posix()
            })

    # Índices
    (OUT / "FILES_INDEX.md").write_text(
        f"""# Archivos indexados

| path | parts | chars | loc | mime | commit | chunk_file |
|---|---:|---:|---:|---:|---|---|
""" +
        "\n".join(f"| `{m['path']}` | {m['parts']} | {m['chars']} | {m['loc']} | {m['mime']} | {m['commit']} | `{m['chunk_file']}` |"
                 for m in dedup_by_path(files_meta)),
        encoding="utf-8"
    )
    with (OUT / "search.jsonl").open("w", encoding="utf-8") as w:
        for m in files_meta: w.write(json.dumps(m, ensure_ascii=False)+"\n")

    # SUMMARY con árbol
    tree_lines = render_tree(ROOT)
    tree = "\n".join(tree_lines)
    total_files = len(dedup_by_path(files_meta))
    total_chunks = len(files_meta)
    total_chars = sum(m['chars'] for m in files_meta)
    
    # Top 5 files by characters
    top_5_files = sorted(dedup_by_path(files_meta), key=lambda x: x['chars'], reverse=True)[:5]
    top_5_files_str = "\n".join(f"- `{f['path']}`: {f['chars']} chars" for f in top_5_files)

    script_version = get_script_git_sha()

    (OUT / "SUMMARY.md").write_text(
        f"""# Repo digest

- root: `{ROOT.resolve()}`
- generated: {datetime.utcnow().isoformat()}Z
- script_version: repo2md.py@{script_version}

## Metrics

- Total files: {total_files}
- Total chunks: {total_chunks}
- Total characters: {total_chars}

### Top 5 files by characters

{top_5_files_str}

## Tree (filtrado)

```
{tree}
```

Ver `FILES_INDEX.md` y carpeta `chunks/`.""", encoding="utf-8"
    )
    print(f"✅ Digest listo en {OUT}")

def dedup_by_path(meta):
    seen, out = set(), []
    for m in meta:
        if m["path"] in seen: continue
        seen.add(m["path"]); out.append(m)
    return out

def render_tree(root_path: Path):
    lines = []
    # Store all valid paths first
    all_paths = []
    for path in root_path.rglob("*"):
        rel_path = path.relative_to(root_path)
        if not should_skip(rel_path):
            all_paths.append(path)
    
    # Sort paths for consistent output
    all_paths.sort()

    # Build the tree structure
    tree_map = {}
    for path in all_paths:
        parts = path.relative_to(root_path).parts
        current_level = tree_map
        for part in parts:
            if part not in current_level:
                current_level[part] = {}
            current_level = current_level[part]

    def _render_node(node, prefix="", is_last_sibling=True): # is_last_sibling is not used
        nonlocal lines
        keys = sorted(node.keys())
        for i, key in enumerate(keys):
            is_last = (i == len(keys) - 1)
            connector = "└── " if is_last else "├── "
            
            lines.append(f"{prefix}{connector}{key}{'/' if node[key] else ''}")
            
            if node[key]: # If it's a directory
                new_prefix = prefix + ("    " if is_last else "│   ")
                _render_node(node[key], new_prefix, is_last) # Pass is_last to maintain correct prefix

    _render_node(tree_map)
    return lines

if __name__ == "__main__":
    main()