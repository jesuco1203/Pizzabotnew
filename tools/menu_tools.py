import json

def get_menu() -> dict:
    """Carga y devuelve el menú completo desde el archivo menu.json."""
    try:
        with open("/Users/jesuco1203/Docs_mac/pizzabotnew/data/menu.json", "r") as f:
            menu = json.load(f)
        return {"status": "success", "menu": menu}
    except FileNotFoundError:
        return {"status": "error", "message": "El archivo del menú no se encontró."}
    except json.JSONDecodeError:
        return {"status": "error", "message": "Error al decodificar el archivo del menú."}
