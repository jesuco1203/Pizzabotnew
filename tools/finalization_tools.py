
import json
from google.adk.tools import ToolContext
from datetime import datetime

PEDIDOS_DB_PATH = "/Users/jesuco1203/Docs_mac/pizzabotnew/data/pedidos.json"

def finalize_order(tool_context: ToolContext) -> dict:
    """
    Guarda el pedido final en la base de datos de pedidos (pedidos.json)
    y limpia el estado de la sesión para un nuevo pedido.

    Args:
        tool_context (ToolContext): El contexto para acceder al estado de la sesión.

    Returns:
        dict: Un diccionario con el estado de la operación y el ID del nuevo pedido.
    """
    print("DEBUG: finalize_order: Iniciando finalización de pedido.")
    session_state = tool_context.state

    # Recopilar toda la información del estado
    user_name = session_state.get("user_name")
    current_order = session_state.get("current_order")
    delivery_address = session_state.get("delivery_address")

    if not all([user_name, current_order, delivery_address]):
        return {"status": "error", "message": "Falta información para finalizar el pedido (usuario, pedido o dirección)."}

    try:
        with open(PEDIDOS_DB_PATH, "r+") as f:
            try:
                pedidos = json.load(f)
            except json.JSONDecodeError:
                pedidos = [] # Si el archivo está vacío o corrupto, empezar de nuevo
            
            new_order_id = len(pedidos) + 1
            
            new_order = {
                "order_id": new_order_id,
                "customer_name": user_name,
                "order_details": current_order,
                "delivery_address": delivery_address,
                "timestamp": datetime.now().isoformat()
            }
            
            pedidos.append(new_order)
            
            f.seek(0) # Volver al inicio del archivo para sobreescribir
            json.dump(pedidos, f, indent=4)
            f.truncate()

    except FileNotFoundError:
        # Si el archivo no existe, crearlo
        with open(PEDIDOS_DB_PATH, "w") as f:
            new_order_id = 1
            new_order = {
                "order_id": new_order_id,
                "customer_name": user_name,
                "order_details": current_order,
                "delivery_address": delivery_address,
                "timestamp": datetime.now().isoformat()
            }
            json.dump([new_order], f, indent=4)

    # Limpiar el estado de la sesión para el próximo pedido
    session_state["current_order"] = None
    session_state["order_confirmed"] = False
    session_state["address_collected"] = False
    session_state["summary_presented"] = False
    session_state["item_to_clarify"] = None
    # No limpiamos user_identified o user_name para recordar al cliente

    print(f"DEBUG: finalize_order: Pedido {new_order_id} guardado. Estado de sesión limpiado.")
    
    return {"status": "success", "order_id": new_order_id}
