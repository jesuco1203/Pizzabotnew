<!-- path: app/tools_menu.py -->
```python
import yaml
from typing import Optional

def get_menu(item: Optional[str] = None, size: Optional[str] = None):
    """Gets the menu, or a specific item from the menu.

    Args:
        item: The name of the item to get.
        size: The size of the item to get.

    Returns:
        The menu, or the specific item.
    """
    with open("/Users/jesuco1203/Docs_mac/Pizzabotnew/context/menu.yaml", "r") as f:
        menu = yaml.safe_load(f)

    if item:
        for pizza in menu["pizzas"]:
            if pizza["name"].lower() == item.lower():
                if size:
                    for s in pizza["sizes"]:
                        if s["size"].lower() == size.lower():
                            return s
                    return {"error": "Size not found"}
                return pizza
        return {"error": "Item not found"}

    return menu
```