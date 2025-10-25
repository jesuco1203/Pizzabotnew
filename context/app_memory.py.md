<!-- path: app/memory.py -->
```python
import json
import os
from typing import Dict, Any
from app.state import Item, OrderState

DATA_DIR = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data"

class CustomEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, (Item, OrderState)):
            return o.__dict__
        return super().default(o)

def get_session(session_id: str) -> Dict[str, Any]:
    """Gets a session from the file system.

    Args:
        session_id: The ID of the session to get.

    Returns:
        The session, or an empty dictionary if the session does not exist.
    """
    filepath = os.path.join(DATA_DIR, f"{session_id}.json")
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            data = json.load(f)
            items = [Item(**item) for item in data.get("items", [])]
            data["items"] = items
            return data
    return {}

def save_session(session_id: str, session: Dict[str, Any]) -> None:
    """Saves a session to the file system.

    Args:
        session_id: The ID of the session to save.
        session: The session to save.
    """
    if not os.path.exists(DATA_DIR):
        os.makedirs(DATA_DIR)
    filepath = os.path.join(DATA_DIR, f"{session_id}.json")
    with open(filepath, "w") as f:
        json.dump(session, f, indent=4, cls=CustomEncoder)
```