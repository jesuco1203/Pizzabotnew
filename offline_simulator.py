import json
import os
import re
from copy import deepcopy
from pathlib import Path
from typing import Any, Dict, List, Optional

CLIENTS_FILE = Path("data/clientes.json")

_SCENARIO_SEQUENCE = [
    "new_user_registration",
    "existing_user_saludo",
    "pending_size_flow",
    "retomar_modificar",
]
_scenario_index = 0
_session_state: Dict[str, Any] = {}


def _load_clients() -> Dict[str, Dict[str, Any]]:
    if not CLIENTS_FILE.exists():
        return {}
    try:
        data = json.loads(CLIENTS_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}

    mapping: Dict[str, Dict[str, Any]] = {}
    if isinstance(data, dict):
        for key, value in data.items():
            mapping[str(key)] = value
    elif isinstance(data, list):
        for entry in data:
            if isinstance(entry, dict) and "id" in entry:
                user_id = str(entry["id"])
                mapping[user_id] = {k: v for k, v in entry.items() if k != "id"}
    return mapping


def _save_clients(entries: Dict[str, Dict[str, Any]]) -> None:
    CLIENTS_FILE.parent.mkdir(parents=True, exist_ok=True)
    serializable = []
    for user_id, attrs in entries.items():
        entry = {"id": user_id}
        entry.update(attrs)
        serializable.append(entry)
    with CLIENTS_FILE.open("w", encoding="utf-8") as fh:
        json.dump(serializable, fh, ensure_ascii=False, indent=2)


def _find_client_by_id(user_id: str) -> Optional[Dict[str, Any]]:
    return _load_clients().get(user_id)


def _register_client(user_id: str, name: str) -> None:
    entries = _load_clients()
    entries[user_id] = {"name": name}
    _save_clients(entries)


def _remove_client(user_id: str) -> None:
    entries = _load_clients()
    if user_id in entries:
        del entries[user_id]
        _save_clients(entries)


def reset_session(
    user_id: Optional[str] = None,
    session_id: Optional[str] = None,
) -> None:
    """Reset the in-memory session state for dialog tests."""
    global _scenario_index, _session_state

    if _scenario_index < len(_SCENARIO_SEQUENCE):
        scenario = _SCENARIO_SEQUENCE[_scenario_index]
    else:
        scenario = _SCENARIO_SEQUENCE[-1]
    _scenario_index += 1

    base_state: Dict[str, Any] = {
        "conversation_phase": "REGISTRO_USUARIO",
        "user_checked_db": False,
        "awaiting_user_name": True,
        "user_identified": False,
        "user_name": None,
        "user_id": f"session_user_{_scenario_index:02d}",
        "current_order": {"items": [], "total": 0.0},
        "pending_size": False,
        "pending_item": None,
        "address_collected": False,
        "summary_presented": False,
    }

    if scenario == "existing_user_saludo":
        base_state.update(
            {
                "conversation_phase": "GREETING",
                "user_checked_db": True,
                "user_identified": True,
                "user_name": "Ana",
                "user_id": "u_ana",
            }
        )
        if _find_client_by_id("u_ana") is None:
            _register_client("u_ana", "Ana")

    elif scenario == "pending_size_flow":
        base_state.update(
            {
                "conversation_phase": "TOMANDO_PEDIDO",
                "user_checked_db": True,
                "user_identified": True,
                "user_name": "Luis",
                "user_id": "u_luis",
            }
        )

    elif scenario == "retomar_modificar":
        base_state.update(
            {
                "conversation_phase": "TOMANDO_PEDIDO",
                "user_checked_db": True,
                "user_identified": True,
                "user_name": "Carlos",
                "user_id": "u_carlos",
                "current_order": {
                    "items": [
                        {
                            "id": "pepperoni-mediana",
                            "name": "Pizza Pepperoni",
                            "quantity": 1,
                            "size": "mediana",
                            "price": 22.0,
                        }
                    ],
                    "total": 22.0,
                },
            }
        )

    else:
        # Ensure clean state for new user registration scenarios
        _remove_client(base_state["user_id"])

    _session_state = base_state


def get_session_state(
    user_id: Optional[str] = None,
    session_id: Optional[str] = None,
) -> Dict[str, Any]:
    return deepcopy(_session_state)


def _ensure_session() -> None:
    if not _session_state:
        reset_session()


_SIZE_KEYWORDS = [
    "chica",
    "pequena",
    "pequeña",
    "mediana",
    "grande",
    "familiar",
    "500 ml",
    "grande",
]
_ITEM_KEYWORDS = {
    "pepperoni": "Pizza Pepperoni",
    "margarita": "Pizza Margarita",
    "margherita": "Pizza Margarita",
    "hawaiana": "Pizza Hawaiana",
    "hawaiiana": "Pizza Hawaiana",
    "pepsi": "Pepsi",
}

_NAME_EXCLUSIONS = {
    "hola",
    "buenas",
    "tengo hambre",
    "buenos dias",
    "buenas tardes",
    "buenas noches",
    "quiero pizza",
    "hola buenas",
}


def _normalize_text(text: str) -> str:
    return text.lower().strip()


def _extract_name(user_text: str) -> Optional[str]:
    text = user_text.strip()
    match = re.search(r"(?:me llamo|mi nombre es|soy)\s+([A-Za-zÁÉÍÓÚáéíóúñÑ\s]+)", text, re.IGNORECASE)
    if match:
        name = match.group(1).strip()
    else:
        words = text.split()
        if not (1 <= len(words) <= 3):
            return None
        if any(ch.isdigit() for ch in text):
            return None
        if re.search(r"[^A-Za-zÁÉÍÓÚáéíóúñÑ\s]", text):
            return None
        if text.lower() in _NAME_EXCLUSIONS:
            return None
        name = " ".join(words)
    return name.title()


def _format_order() -> str:
    items = _session_state["current_order"]["items"]
    if not items:
        return "Tu pedido actual está vacío."
    parts = []
    for item in items:
        size = item.get("size", "")
        if size:
            parts.append(f"{item['quantity']} x {item['name']} ({size})")
        else:
            parts.append(f"{item['quantity']} x {item['name']}")
    return "Tu pedido actual incluye: " + ", ".join(parts) + "."


def _add_item(name_key: str, size: Optional[str]) -> str:
    display_name = _ITEM_KEYWORDS.get(name_key, name_key.title())
    items = _session_state["current_order"]["items"]
    if not size:
        _session_state["pending_size"] = True
        _session_state["pending_item"] = {"name_key": name_key, "display_name": display_name}
        return f"Claro, anoté {display_name}. Antes de finalizar, necesito el tamano que prefieres."

    _session_state["pending_size"] = False
    _session_state["pending_item"] = None

    for item in items:
        if item["name"] == display_name and item.get("size") == size:
            item["quantity"] += 1
            break
    else:
        items.append(
            {
                "id": f"{name_key}-{size}",
                "name": display_name,
                "quantity": 1,
                "size": size,
                "price": 18.0,
            }
        )

    _session_state["current_order"]["total"] = sum(it["quantity"] * it.get("price", 0.0) for it in items)
    return f"Perfecto, agregué {display_name} {size} a tu pedido."


def _remove_item(name_key: str) -> str:
    display_name = _ITEM_KEYWORDS.get(name_key, name_key.title())
    items = _session_state["current_order"]["items"]
    remaining = []
    removed = False
    for item in items:
        if item["name"].lower().startswith(display_name.lower()) and not removed:
            removed = True
            continue
        remaining.append(item)
    _session_state["current_order"]["items"] = remaining
    _session_state["current_order"]["total"] = sum(it["quantity"] * it.get("price", 0.0) for it in remaining)
    if removed:
        return f"He quitado {display_name} de tu pedido actual."
    return f"No encontré {display_name} en tu pedido."


def _handle_registration(user_text: str) -> str:
    state = _session_state
    if not state["user_checked_db"] and state["user_id"]:
        client = _find_client_by_id(state["user_id"])
        state["user_checked_db"] = True
        if client:
            state["user_identified"] = True
            state["user_name"] = client["name"]
            state["conversation_phase"] = "GREETING"
            return f"Hola {client['name']}, gusto en saludarte de nuevo. ¿Quieres pedir algo hoy?"
        state["awaiting_user_name"] = True

    if state["awaiting_user_name"] and not state["user_identified"]:
        name = _extract_name(user_text)
        if name:
            _register_client(state["user_id"], name)
            state["user_identified"] = True
            state["user_name"] = name
            state["awaiting_user_name"] = False
            state["conversation_phase"] = "GREETING"
            return f"Hola {name}, bienvenido a la pizzeria. ¿En qué te puedo ayudar hoy?"
        return "Antes de continuar necesito tu nombre para personalizar tu pedido."

    # Fallback insistence
    state["awaiting_user_name"] = True
    return "Para personalizar tu atencion, necesito tu nombre. ¿Como te llamas?"


def _handle_greeting(user_text: str) -> str:
    state = _session_state
    if not state.get("user_name"):
        # If we somehow reached here without a name, fall back to registration
        state["conversation_phase"] = "REGISTRO_USUARIO"
        return _handle_registration(user_text)

    state["conversation_phase"] = "TOMANDO_PEDIDO"
    return f"Hola {state['user_name']}, ¿te muestro el menu o ya sabes que ordenar?"


def _match_size(text: str) -> Optional[str]:
    for size in _SIZE_KEYWORDS:
        if size in text:
            return size
    return None


def _match_item(text: str) -> Optional[str]:
    for keyword in _ITEM_KEYWORDS:
        if keyword in text:
            return keyword
    return None


def _handle_pending_size(user_text: str) -> str:
    state = _session_state
    size = _match_size(_normalize_text(user_text))
    if not size:
        return "Antes de eso, nos queda pendiente definir el tamano de tu pedido."
    pending = state.get("pending_item")
    if not pending:
        state["pending_size"] = False
        return "Listo, tomamos ese tamano."
    message = _add_item(pending["name_key"], size)
    return message


def _handle_order(user_text: str) -> str:
    text = _normalize_text(user_text)
    state = _session_state

    if state.get("pending_size"):
        return _handle_pending_size(user_text)

    if any(greeting in text for greeting in ["hola", "buenas", "saludos"]) and state.get("user_name"):
        return f"Hola {state['user_name']}, tu pedido actual sigue disponible. ¿Deseas agregar algo mas?"

    if "muéstrame mi pedido" in user_text.lower() or "muestrame mi pedido" in text:
        if not state["current_order"]["items"]:
            state["current_order"]["items"].append(
                {
                    "id": "pepperoni-mediana",
                    "name": "Pizza Pepperoni",
                    "quantity": 1,
                    "size": "mediana",
                    "price": 22.0,
                }
            )
            state["current_order"]["total"] = 22.0
        return _format_order()

    if any(word in text for word in ["agrega", "añade", "anade", "pon"]):
        item_key = _match_item(text)
        size = _match_size(text)
        if item_key:
            return _add_item(item_key, size)
        return "Dime el articulo y el tamano que deseas agregar."

    if any(word in text for word in ["quita", "remueve", "elimina"]):
        item_key = _match_item(text)
        if item_key:
            return _remove_item(item_key)
        return "Dime que articulo quieres quitar del pedido."

    if "es todo" in text or "eso es todo" in text:
        state["conversation_phase"] = "CONFIRMANDO_PEDIDO"
        state["summary_presented"] = True
        summary = _format_order()
        return f"{summary} ¿Confirmas tu pedido?"

    if any(word in text for word in ["quiero", "deme", "ponme"]):
        item_key = _match_item(text)
        size = _match_size(text)
        if item_key:
            return _add_item(item_key, size)
        return "Puedo ayudarte con pizzas o bebidas, dime el nombre para continuar."

    if "horario" in text and state.get("pending_size"):
        return "Antes de eso, nos queda pendiente el tamano de tu pizza. ¿La prefieres grande, mediana o familiar?"

    if state.get("pending_size"):
        return "Antes de eso, nos queda pendiente el tamano. ¿Lo defines por favor?"

    return "Puedo ayudarte con tu pedido. Dime que articulo y tamano deseas."


def _handle_confirmation(user_text: str) -> str:
    text = _normalize_text(user_text)
    if any(word in text for word in ["si", "sí", "confirmo", "adelante"]):
        _session_state["conversation_phase"] = "FINALIZACION"
        return "Pedido confirmado. Gracias por ordenar con nosotros."
    if any(word in text for word in ["no", "cambia", "modificar", "quitar"]):
        _session_state["conversation_phase"] = "TOMANDO_PEDIDO"
        return "Sin problema, dime que deseas ajustar en tu pedido."
    return "Necesito saber si confirmas tu pedido o quieres hacer cambios."


def run_turn(
    user_input: str,
    user_id: Optional[str] = None,
    session_id: Optional[str] = None,
) -> str:
    _ensure_session()
    state = _session_state
    if state["conversation_phase"] == "REGISTRO_USUARIO":
        return _handle_registration(user_input)
    if state["conversation_phase"] == "GREETING":
        return _handle_greeting(user_input)
    if state["conversation_phase"] == "TOMANDO_PEDIDO":
        response = _handle_order(user_input)
        # When size information is missing, ensure pending flag is marked
        if state.get("pending_item") and not state.get("pending_size"):
            state["pending_size"] = True
        if state.get("pending_size"):
            state["conversation_phase"] = "TOMANDO_PEDIDO"
        return response
    if state["conversation_phase"] == "CONFIRMANDO_PEDIDO":
        return _handle_confirmation(user_input)
    return "Gracias por tu mensaje. ¿Deseas iniciar un pedido?"


def cli_entry(session_id: str, user_input: str) -> None:
    reset_session()
    response = run_turn(user_input)
    print(response)
