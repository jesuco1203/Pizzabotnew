import re
from typing import Optional


def extract_person_name(text: Optional[str]) -> Optional[str]:
    """Extrae un nombre simple del mensaje del usuario."""
    if not text:
        return None

    text = text.strip()
    match = re.search(r"(?:me llamo|soy|mi nombre es)\s+([A-Za-zÁÉÍÓÚÑáéíóúñ]+)", text, re.IGNORECASE)
    if match:
        return match.group(1).strip().title()

    if text.isalpha() and len(text.split()) == 1:
        return text.title()

    return None
