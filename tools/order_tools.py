import json
import copy
from typing import Any, Dict, Optional # Importar Optional y Any, Dict
from google.adk.tools import ToolContext
from thefuzz import fuzz
from thefuzz import process

# Función auxiliar para no repetir la carga del menú
def _load_menu():
    """Carga el menú desde el archivo JSON."""
    try:
        with open("/Users/jesuco1203/Docs_mac/pizzabotnew/data/menu.json", "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return None

async def process_item_request(tool_context: ToolContext, item_identifier: str, quantity: int, size: Optional[str]) -> Dict[str, Any]:
    """Busca un artículo, lo añade al carrito si no hay ambigüedad, o pide clarificación.

    Args:
        item_identifier (str): El ID o nombre del producto a buscar.
        quantity (int): La cantidad a añadir.
        size (str, optional): El tamaño específico del producto si ya se conoce.
        tool_context (ToolContext): El contexto de la herramienta para acceder al estado.

    Returns:
        dict: Un diccionario indicando el resultado.
    """
    menu_data = _load_menu()
    if not menu_data:
        return {"status": "error", "message": "No se pudo cargar el menú."}

    item_to_add = None
    all_menu_items = []
    for item_id, item_details in menu_data.items():
        all_menu_items.append(item_details)

    # 1. Intentar coincidencia exacta por ID_SKU
    for item in all_menu_items:
        if "Tamaños" in item:
            for size_name, size_details in item["Tamaños"].items():
                if size_details.get("ID_SKU") == item_identifier:
                    item_to_add = item
                    item_to_add["selected_size"] = size_name
                    item_to_add["selected_price"] = size_details["Precio"]
                    break
            if item_to_add: break

    # 2. Si no hay coincidencia por ID, intentar búsqueda difusa por Nombre_Base o Alias
    if not item_to_add:
        choices = []
        item_map = {}
        for item in all_menu_items:
            name_base = item.get("Nombre_Base")
            if name_base:
                choices.append(name_base)
                item_map[name_base.lower()] = item
            aliases = item.get("Alias")
            if aliases:
                for alias in aliases.split(', '):
                    alias_stripped = alias.strip()
                    choices.append(alias_stripped)
                    item_map[alias_stripped.lower()] = item

        if choices:
            match = process.extractOne(item_identifier, choices, scorer=fuzz.token_set_ratio, score_cutoff=85)
            if match:
                best_match_name = match[0]
                item_to_add = item_map.get(best_match_name.lower())

    if not item_to_add:
        return {"status": "error", "message": f"El artículo '{item_identifier}' no fue encontrado en el menú."}

    # --- Lógica de clarificación de tamaño ---
    # Si el producto tiene múltiples tamaños y no se ha especificado uno
    if "Tamaños" in item_to_add and len(item_to_add["Tamaños"]) > 1 and not size and "selected_size" not in item_to_add:
        tool_context.state["item_to_clarify"] = item_to_add
        return {"status": "clarification_needed", "message": f"El producto '{item_to_add['Nombre_Base']}' tiene múltiples tamaños. Por favor, especifica uno: {', '.join(item_to_add['Tamaños'].keys())}.", "product_details": item_to_add}
    
    # Si solo hay un tamaño, seleccionarlo automáticamente
    if "Tamaños" in item_to_add and len(item_to_add["Tamaños"]) == 1 and "selected_size" not in item_to_add:
        size_key = list(item_to_add["Tamaños"].keys())[0]
        item_to_add["selected_size"] = size_key
        item_to_add["selected_price"] = item_to_add["Tamaños"][size_key]["Precio"]
        tool_context.state["item_to_clarify"] = None # Limpiar si se resuelve automáticamente

    # --- Lógica de clarificación de tamaño (con corrección y debug prints) ---
    if "Tamaños" in item_to_add and len(item_to_add["Tamaños"]) > 1:
        if size:
            size_choices = []
            size_map = {}
            for s_name, s_details in item_to_add["Tamaños"].items():
                size_choices.append(s_name)
                size_map[s_name.lower()] = s_name
                if "Alias" in s_details:
                    for alias in s_details["Alias"].split(', '):
                        alias_stripped = alias.strip()
                        size_choices.append(alias_stripped) # Corrected line
                        size_map[alias_stripped.lower()] = s_name
            
            # print(f"DEBUG: size_choices: {size_choices}") # Eliminado
            # print(f"DEBUG: size_map: {size_map}") # Eliminado
            # print(f"DEBUG: size.lower(): {size.lower()}") # Eliminado

            matched_size_key = None
            if size.lower() in size_map:
                matched_size_key = size_map[size.lower()]
                # print(f"DEBUG: Coincidencia exacta de tamaño: {matched_size_key}") # Eliminado
            else:
                size_match = process.extractOne(size, size_choices, scorer=fuzz.token_set_ratio, score_cutoff=80)
                # print(f"DEBUG: Resultado de búsqueda difusa de tamaño: {size_match}") # Eliminado
                if size_match:
                    matched_size_key = size_map.get(size_match[0].lower())
                    # print(f"DEBUG: Coincidencia difusa de tamaño: {matched_size_key}") # Eliminado
            
            if matched_size_key:
                item_to_add["selected_size"] = matched_size_key
                item_to_add["selected_price"] = item_to_add["Tamaños"][matched_size_key]["Precio"]
                tool_context.state["item_to_clarify"] = None # Clear item_to_clarify after successful resolution
            else:
                return {"status": "error", "message": f"El tamaño '{size}' no es válido para '{item_to_add['Nombre_Base']}'. Tamaños disponibles: {', '.join(item_to_add['Tamaños'].keys())}."}

    # --- Asignación final de precio ---
    if "selected_size" in item_to_add:
        item_to_add["selected_price"] = item_to_add["Tamaños"][item_to_add["selected_size"]]["Precio"]
    elif "Precio" in item_to_add:
        item_to_add["selected_price"] = item_to_add["Precio"]
    else:
        return {"status": "error", "message": f"No se pudo determinar el precio para '{item_to_add['Nombre_Base']}'."}

    # --- LÓGICA DE ADICIÓN DIRECTA ---
    # Si llegamos aquí, el ítem está listo para ser añadido.
    current_order = copy.deepcopy(tool_context.state.get("current_order", {"items": [], "total": 0.0}))
    current_order["items"].append({
        "id": item_to_add["Tamaños"][item_to_add["selected_size"]]["ID_SKU"] if "Tamaños" in item_to_add else item_to_add["ID_SKU"],
        "name": item_to_add["Nombre_Base"],
        "quantity": quantity,
        "price": item_to_add["selected_price"],
        "size": item_to_add.get("selected_size", "N/A")
    })
    current_order["total"] += item_to_add["selected_price"] * quantity
    tool_context.state["current_order"] = current_order
    # print(f"DEBUG: process_item_request: current_order actualizado: {tool_context.state.get('current_order')}") # Eliminado

    return {"status": "success", "message": f"Añadí {quantity} x {item_to_add['Nombre_Base']} ({item_to_add.get('selected_size', '')}) al carrito."}


def get_current_order(tool_context: ToolContext) -> dict:
    # print(f"DEBUG: get_current_order: tool_context.state recibido: {tool_context.state}") # Eliminado
    """Obtiene el estado actual del pedido desde la sesión.

    Args:
        tool_context (ToolContext): El contexto de la herramienta para acceder al estado.

    Returns:
        dict: Un diccionario con el estado del pedido actual.
    """
    current_order = tool_context.state.get("current_order")

    if not current_order or not current_order["items"]:
        # print("DEBUG: get_current_order: Carrito vacío o no encontrado.") # Eliminado
        return {"status": "success", "order": "El carrito está vacío."}

    # Formatear la salida para el usuario
    items_list = []
    for item in current_order["items"]:
        item_name = item["name"]
        item_qty = item["quantity"]
        item_price = item["price"]
        item_size = item.get("size", "")
        if item_size and item_size != "N/A":
            items_list.append(f"{item_qty} x {item_name} ({item_size}) - {item_price}€ cada una")
        else:
            items_list.append(f"{item_qty} x {item_name} - {item_price}€ cada una")

    total_price = current_order["total"]
    # print(f"DEBUG: get_current_order: Carrito encontrado: {current_order}") # Eliminado

    return {"status": "success", "order": {"items_formatted": items_list, "total": total_price}}
