<!-- path: app/tools_order.py -->
```python
from dataclasses import dataclass
from typing import List, Optional
import yaml
import datetime

from app.state import Item

@dataclass
class Quote:
    subtotal: float
    delivery_fee: float
    discount: float
    total: float
    eta_min: int
    breakdown: dict

def quote_order(items: List[Item], zone: str) -> Quote:
    """Quotes an order.

    Args:
        items: A list of items to order.
        zone: The delivery zone.

    Returns:
        A quote for the order.
    """
    with open("/Users/jesuco1203/Docs_mac/Pizzabotnew/context/menu.yaml", "r") as f:
        menu = yaml.safe_load(f)

    subtotal = 0
    breakdown = {"items": []}

    for item in items:
        for pizza in menu["pizzas"]:
            if pizza["name"].lower() == item.name.lower():
                for s in pizza["sizes"]:
                    if s["size"].lower() == item.size.lower():
                        price = s["price"] * item.qty
                        subtotal += price
                        breakdown["items"].append({"name": item.name, "size": item.size, "qty": item.qty, "price": price})
                        break

    delivery_fee = 0
    for z in menu["delivery_zones"]:
        if z["zone"].lower() == zone.lower():
            delivery_fee = z["fee"]
            break

    discount = 0
    if datetime.datetime.today().weekday() == 1: # Tuesday
        pizzas = [item for item in items if any(p["name"].lower() == item.name.lower() for p in menu["pizzas"])]
        if len(pizzas) >= 2:
            pizzas.sort(key=lambda p: next(s["price"] for s in next(pi for pi in menu["pizzas"] if pi["name"].lower() == p.name.lower())["sizes"] if s["size"].lower() == p.size.lower()))
            discount = pizzas[0].qty * next(s["price"] for s in next(pi for pi in menu["pizzas"] if pi["name"].lower() == pizzas[0].name.lower())["sizes"] if s["size"].lower() == pizzas[0].size.lower())


    total = subtotal + delivery_fee - discount
    eta_min = 30

    return Quote(
        subtotal=subtotal,
        delivery_fee=delivery_fee,
        discount=discount,
        total=total,
        eta_min=eta_min,
        breakdown=breakdown,
    )

def place_order(order: dict) -> dict:
    """Places an order.

    Args:
        order: The order to place.

    Returns:
        A confirmation of the order.
    """
    import json
    import os
    import hashlib
    import time

    DATA_DIR = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data"
    PEDIDOS_FILE = os.path.join(DATA_DIR, "pedidos.json")

    order_hash = hashlib.md5(json.dumps(order, sort_keys=True).encode("utf-8")).hexdigest()

    if os.path.exists(PEDIDOS_FILE):
        with open(PEDIDOS_FILE, "r") as f:
            pedidos = json.load(f)
    else:
        pedidos = []

    for p in pedidos:
        if p.get("hash") == order_hash and time.time() - p.get("timestamp", 0) < 60:
            return {"order_id": p["order_id"], "status": "duplicate"}

    order_id = f"order_{int(time.time())}"
    order["order_id"] = order_id
    order["timestamp"] = time.time()
    order["hash"] = order_hash

    pedidos.append(order)

    with open(PEDIDOS_FILE, "w") as f:
        json.dump(pedidos, f, indent=4)

    return {"order_id": order_id, "status": "created"}
```