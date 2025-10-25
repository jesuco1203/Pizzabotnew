from dataclasses import dataclass, field
from typing import List, Optional

@dataclass
class Item:
    name: str
    size: str
    qty: int = 1
    extras: Optional[List[str]] = field(default_factory=list)

@dataclass
class OrderState:
    items: List[Item] = field(default_factory=list)
    address: Optional[str] = None
    zone: Optional[str] = None
    stage: Optional[str] = None
    total: Optional[float] = None
