import json
import re
from datetime import datetime
from typing import Dict, Any

from google.adk.tools import ToolContext

# Rutas a los archivos de datos
CLIENTES_FILE = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/clientes.json"


def _ensure_mapping(data: Any) -> Dict[str, Dict[str, Any]]:
    """Normaliza el archivo de clientes a un diccionario indexado por user_id."""
    if isinstance(data, dict):
        return {str(k): v for k, v in data.items()}
    if isinstance(data, list):
        mapping: Dict[str, Dict[str, Any]] = {}
        for entry in data:
            if isinstance(entry, dict) and "id" in entry:
                mapping[str(entry["id"])] = {k: v for k, v in entry.items() if k != "id"}
        return mapping
    return {}


def _load_clientes() -> Dict[str, Dict[str, Any]]:
    try:
        with open(CLIENTES_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}
    return _ensure_mapping(data)


def _save_clientes(clientes: Dict[str, Dict[str, Any]]) -> None:
    serializable = []
    for user_id, attrs in clientes.items():
        entry = {"id": user_id}
        entry.update(attrs)
        serializable.append(entry)
    with open(CLIENTES_FILE, "w", encoding="utf-8") as f:
        json.dump(serializable, f, ensure_ascii=False, indent=2)


async def check_user_in_db(tool_context: ToolContext, user_id: str) -> dict:
    clientes = _load_clientes()
    if user_id in clientes:
        name = clientes[user_id].get("name")
        return {"exists": True, "name": name, "message": f"Usuario {name} encontrado."}
    return {"exists": False, "message": "Usuario no encontrado."}


async def register_new_user(tool_context: ToolContext, user_id: str, name: str) -> dict:
    clientes = _load_clientes()
    if user_id in clientes:
        return {"success": False, "message": "Usuario ya registrado."}

    clientes[user_id] = {"name": name, "registered_at": datetime.now().isoformat()}
    _save_clientes(clientes)
    return {"success": True, "message": f"Usuario {name} registrado exitosamente."}

async def extract_and_register_name(tool_context: ToolContext, user_id: str, user_message: str) -> dict:
    """Extrae el nombre del usuario del mensaje y lo registra si es válido.

    Args:
        user_id (str): El ID único del usuario.
        user_message (str): El mensaje completo del usuario.
        tool_context (ToolContext): El contexto de la herramienta para acceder al estado.

    Returns:
        dict: Un diccionario con el estado de la operación (success, error, clarification_needed) y un mensaje.
    """
    session_state = tool_context.state

    # Lógica de extracción y validación de nombre más estricta
    potential_name = None

    # 1. Intentar extraer nombre con frases explícitas ("mi nombre es", "soy")
    match_explicit = re.search(r"(?:mi nombre es|soy)\s+([A-Za-zÀ-ÿ\s]+)", user_message, re.IGNORECASE)
    if match_explicit:
        potential_name = match_explicit.group(1).strip()
    else:
        # 2. Si no hay frase explícita, considerar el mensaje completo como nombre solo si es muy corto y no es una frase común
        words = user_message.split()
        if 1 <= len(words) <= 3: # Nombres de 1 a 3 palabras
            # Excluir frases comunes y palabras clave de intención
            common_phrases_and_keywords = [
                "hola", "hi", "hello", "que tal", "como estas",
                "mi nombre", "cual es mi nombre", "quien eres",
                "pizza", "lasagna", "menu", "quiero", "pedir", "ordenar",
                "gracias", "ok", "si", "no", "adios", "bye",
                "no te importa", "no importa", "no quiero decirte"
            ]
            if not any(keyword in user_message.lower() for keyword in common_phrases_and_keywords):
                potential_name = user_message.strip()

    is_valid_name = False
    if potential_name and len(potential_name) > 1 and not any(char.isdigit() for char in potential_name): # Nombre de al menos 2 caracteres y sin dígitos
        is_valid_name = True

    if is_valid_name:
        register_result = await register_new_user(tool_context, user_id, potential_name)
        if register_result["success"]:
            session_state["user_identified"] = True
            session_state["user_name"] = potential_name
            session_state["awaiting_user_name"] = False
            return {"status": "success", "message": f"¡Encantado, {potential_name}!"}
        else:
            return {"status": "error", "message": "Lo siento, no pude registrar tu nombre. ¿Podrías intentarlo de nuevo?"}
    else:
        session_state["awaiting_user_name"] = True # Asegurar que la bandera se mantenga
        return {"status": "clarification_needed", "message": "No entendí tu nombre. Por favor, ¿podrías decirme tu nombre?"}

def save_address(address: str, tool_context: ToolContext) -> dict:
    """
    Guarda la dirección de entrega en el estado de la sesión.

    Args:
        address (str): La dirección proporcionada por el usuario.
        tool_context (ToolContext): El contexto para acceder al estado de la sesión.

    Returns:
        dict: Un diccionario indicando el resultado de la operación.
    """
    tool_context.state['delivery_address'] = address
    tool_context.state['address_collected'] = True
    return {"status": "success", "message": "Dirección guardada correctamente."}
