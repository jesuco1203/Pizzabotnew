import json
from pathlib import Path
from typing import Any, Dict, List, Optional

from google.adk.tools import ToolContext

_MENU_CACHE: Optional[Dict[str, Any]] = None


def _menu() -> Dict[str, Any]:
    global _MENU_CACHE
    if _MENU_CACHE is None:
        _MENU_CACHE = json.loads(Path("data/menu.json").read_text(encoding="utf-8"))
    return _MENU_CACHE


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


def _valid_sizes() -> List[str]:
    sizes = set()
    for pizza in _menu().get("pizzas", []):
        pizza_sizes = pizza.get("sizes") or {}
        if isinstance(pizza_sizes, dict):
            sizes.update(name.lower().strip() for name in pizza_sizes.keys())
    return sorted(sizes)


def valid_sizes() -> List[str]:
    return list(_valid_sizes())


async def size_validation_tool(
    tool_context: ToolContext,
    item: Optional[str] = None,
    size: Optional[str] = None,
) -> Dict[str, Any]:
    return _evaluate(tool_context, item, size)


def run(item: Optional[str] = None, size: Optional[str] = None) -> Dict[str, Any]:
    return _evaluate(None, item, size)


def _evaluate(
    tool_context: Optional[ToolContext],
    item: Optional[str],
    size: Optional[str],
) -> Dict[str, Any]:
    options = _valid_sizes()
    if not size:
        delta = {
            "pending_size": True,
            "pending_item": item,
            "pending_size_options": options,
            "normalized_size": None,
        }
        if tool_context is not None:
            tool_context.state.update(delta)
        return {"state_delta": delta}

    raw = size.lower().strip()
    normalized = _SIZE_ALIASES.get(raw, raw)

    if normalized in options:
        delta = {
            "pending_size": False,
            "normalized_size": normalized,
        }
        if normalized != raw:
            delta["last_redirect_note"] = (
                f"Se normalizó '{raw}' al tamaño disponible '{normalized}'."
            )
            delta["size_redirected_to"] = normalized
        if tool_context is not None:
            tool_context.state.update(delta)
        return {"state_delta": delta}

    delta = {
        "pending_size": True,
        "pending_item": item,
        "pending_size_options": options,
        "normalized_size": None,
    }
    text = "Ese tamaño no está en el menú. Tamaños disponibles: " + ", ".join(options)
    if tool_context is not None:
        tool_context.state.update(delta)
    return {"state_delta": delta, "text": text}
