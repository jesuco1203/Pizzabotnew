import argparse
import glob
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Any, Dict, Tuple

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

# Allow forcing online mode when explicitly requested.
ONLINE = os.getenv("DIALOG_TEST_ONLINE", "").lower() in {"1", "true", "yes", "on"}
if not ONLINE:
    os.environ.setdefault("OFFLINE_MODE", "1")


def load_steps(path: str) -> list[Dict[str, Any]]:
    steps = []
    for raw in open(path, encoding="utf-8"):
        ln = raw.strip()
        if not ln or ln.startswith('#'):
            continue
        if ln.startswith('- user:'):
            steps.append({'user': ln.split(':', 1)[1].strip().strip('"')})
        elif ln.startswith('- expect_stage:'):
            steps[-1]['expect_stage'] = ln.split(':', 1)[1].strip()
        elif ln.startswith('- expect_requires:'):
            steps[-1]['expect_requires'] = ln.split(':', 1)[1].strip()
        elif ln.startswith('- expect_state:'):
            steps[-1]['expect_state'] = json.loads(ln.split(':', 1)[1].strip())
        elif ln.startswith('- expect_state_contains:'):
            steps[-1]['expect_state_contains'] = json.loads(ln.split(':', 1)[1].strip())
        elif ln.startswith('- expect_say_contains:'):
            steps[-1]['expect_say_contains'] = ln.split(':', 1)[1].strip().strip('"')
        elif ln.startswith('- bot_should:'):
            steps[-1]['bot_should'] = ln.split(':', 1)[1].strip()
    return steps


def check_contains_state(state: Dict[str, Any], fragment: Dict[str, Any]) -> None:
    for key, value in fragment.items():
        if key == 'current_order':
            items = state.get('current_order', {}).get('items', [])
            count_expr = value.get('items_count')
            if count_expr is None:
                continue
            if isinstance(count_expr, str) and count_expr.startswith('>='):
                assert len(items) >= int(count_expr[2:]), f"items_count >= fail: {len(items)}"
            else:
                expected = int(count_expr)
                assert len(items) == expected, f"items_count == fail: {len(items)}"
        else:
            assert state.get(key) == value, f"state[{key}] != {value}, got {state.get(key)}"


from main import run_turn, get_session_state, reset_session  # noqa: E402


def ensure_name_prompt(text: str) -> bool:
    text_lower = text.lower()
    return (
        'como te llamas' in text_lower
        or '¿cómo te llamas' in text_lower
        or 'tu nombre' in text_lower
        or 'tu nombre' in text_lower.replace("ó", "o")
    )


def ensure_size_prompt(text: str) -> bool:
    text_lower = text.lower()
    return 'tamano' in text_lower or 'tamaño' in text_lower


def _session_ids_for_path(path: str) -> Tuple[str, str]:
    slug = Path(path).stem
    session_id = f"test_session_{slug}"
    if "usuario_existente" in slug:
        user_id = "u_ana"
    elif "03_no_avanza_sin_objetivo_completo" in slug:
        user_id = "u_luis"
    elif "04_retoma_y_modifica_orden" in slug:
        user_id = "u_carlos"
    else:
        user_id = f"test_user_{slug}"
    return user_id, session_id


def _purge_test_user(user_id: str) -> None:
    if user_id in {"u_ana", "u_luis", "u_carlos"}:
        return
    clients_path = ROOT_DIR / "data" / "clientes.json"
    if not clients_path.exists():
        return
    try:
        data = json.loads(clients_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return

    def to_mapping(raw: Any) -> Dict[str, Dict[str, Any]]:
        if isinstance(raw, dict):
            return {str(k): v for k, v in raw.items()}
        mapping: Dict[str, Dict[str, Any]] = {}
        if isinstance(raw, list):
            for entry in raw:
                if isinstance(entry, dict) and "id" in entry:
                    uid = str(entry["id"])
                    mapping[uid] = {k: v for k, v in entry.items() if k != "id"}
        return mapping

    mapping = to_mapping(data)
    if user_id not in mapping:
        return
    del mapping[user_id]
    serializable = []
    for uid, attrs in mapping.items():
        entry = {"id": uid}
        entry.update(attrs)
        serializable.append(entry)
    clients_path.write_text(json.dumps(serializable, ensure_ascii=False, indent=2), encoding="utf-8")


def _normalize(text: str) -> str:
    return text.lower().strip()


def _expect_contains(text: str, expected: str) -> bool:
    candidate = _normalize(text)
    if expected.startswith("REGEX:"):
        pattern = expected[len("REGEX:"):]
        return re.search(pattern, candidate) is not None
    if "|" in expected:
        tokens = [token.strip().lower() for token in expected.split("|")]
        return all(token in candidate for token in tokens if token)
    return expected.lower() in candidate


def _run_step_with_retry(user_text: str, user_id: str, session_id: str, use_online: bool) -> str:
    retries = 1 if use_online else 0
    last_error = None
    for attempt in range(retries + 1):
        try:
            return run_turn(user_text, user_id=user_id, session_id=session_id)
        except Exception as exc:  # pragma: no cover - debugging helper
            last_error = exc
            if attempt == retries:
                raise
            time.sleep(1.5)
    raise last_error  # for completeness


def run_dialog_suite(use_online: bool = False) -> None:
    print(f"# Dialog tests starting (online={use_online})")
    for path in sorted(glob.glob('tests/dialogs/*.md')):
        user_id, session_id = _session_ids_for_path(path)
        _purge_test_user(user_id)
        reset_session(user_id=user_id, session_id=session_id)
        steps = load_steps(path)
        print(f"## Running {path} (session={session_id})")
        last_bot = ''
        for step in steps:
            last_bot = _run_step_with_retry(step['user'], user_id, session_id, use_online)
            state = get_session_state(user_id=user_id, session_id=session_id)

            if step.get('expect_say_contains'):
                assert _expect_contains(last_bot, step['expect_say_contains']), (
                    f"bot text missing: {step['expect_say_contains']}\nBOT>> {last_bot}"
                )

            if step.get('expect_stage'):
                expected_stage = step['expect_stage']
                stage = state.get('conversation_phase')
                if '|' in expected_stage:
                    options = expected_stage.split('|')
                    assert stage in options, f"expected one of {options}, got {stage}"
                else:
                    assert stage == expected_stage, f"expected stage {expected_stage}, got {stage}"

            if step.get('expect_requires'):
                requirement = step['expect_requires']
                if requirement == 'user_name':
                    assert state.get('awaiting_user_name', False) is True, 'should await user name'
                if requirement == 'size':
                    if not state.get('pending_size', False):
                        assert ensure_size_prompt(last_bot), 'should mark pending size'

            if step.get('expect_state'):
                for key, value in step['expect_state'].items():
                    assert state.get(key) == value, f'state[{key}] != {value}'

            if step.get('expect_state_contains'):
                check_contains_state(state, step['expect_state_contains'])

            if step.get('bot_should') == 'insistir_nombre':
                assert ensure_name_prompt(last_bot), f"should insist name. BOT>> {last_bot}"

            if step.get('bot_should') == 'reformular_pidiendo_nombre':
                assert (
                    'antes de continuar' in last_bot.lower()
                    or 'necesito tu nombre' in last_bot.lower()
                    or 'tu nombre' in last_bot.lower()
                    or ensure_name_prompt(last_bot)
                ), f"should reformulate asking name. BOT>> {last_bot}"

            if step.get('bot_should') == 'recordar_falta_size':
                assert ensure_size_prompt(last_bot), f"should remind about size. BOT>> {last_bot}"
        print(f"OK {path}")
    print("All dialog tests completed.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run dialog regression tests.")
    parser.add_argument(
        "--online",
        action="store_true",
        help="Run tests against live ADK/Gemini instead of deterministic simulator.",
    )
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    if args.online:
        os.environ["OFFLINE_MODE"] = "0"
    run_dialog_suite(use_online=args.online)
