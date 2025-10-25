import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

MENU_PATH = Path("data/menu.json")
_MENU_CACHE: Optional[Dict[str, dict]] = None

_SIZE_ALIASES = {
    "grande": "grande",
    "familiar": "familiar",
    "mediana": "grande",
    "personal": "grande",
    "pequeña": "grande",
    "pequena": "grande",
    "chica": "grande",
    "xl": "familiar",
    "xxl": "familiar",
}


def _load_menu() -> Dict[str, dict]:
    global _MENU_CACHE
    if _MENU_CACHE is None:
        _MENU_CACHE = json.loads(MENU_PATH.read_text(encoding="utf-8"))
    return _MENU_CACHE


def find_item(text: str) -> Optional[Tuple[str, dict]]:
    """Devuelve (item_id, item_data) si el texto menciona la pizza."""
    if not text:
        return None
    text = text.lower()
    menu = _load_menu()
    for item_id, info in menu.items():
        name = info.get("Nombre_Base", "").lower()
        if name and name in text:
            return item_id, info
        aliases = info.get("Alias", "")
        if aliases:
            for alias in aliases.split(","):
                if alias.strip().lower() in text:
                    return item_id, info
    return None


def size_options(item_info: dict) -> List[str]:
    sizes = item_info.get("Tamaños") or {}
    return [key.lower() for key in sizes.keys()]


def normalize_size(size_text: str) -> Optional[str]:
    if not size_text:
        return None
    raw = size_text.lower().strip()
    return _SIZE_ALIASES.get(raw, raw)


def detect_size(text: str) -> Optional[str]:
    if not text:
        return None
    for token in re.split(r"\\W+", text.lower()):
        if not token:
            continue
        normalized = normalize_size(token)
        if normalized in _SIZE_ALIASES.values():
            return normalized
    return None


def item_price(item_info: dict, size: str) -> Optional[float]:
    sizes = item_info.get("Tamaños") or {}
    data = sizes.get(size.title())
    if not data:
        return None
    return data.get("Precio")


def get_item(item_id: str) -> Optional[dict]:
    return _load_menu().get(item_id)
