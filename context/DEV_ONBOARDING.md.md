<!-- path: DEV_ONBOARDING.md -->
```markdown
¡Listo! Aquí tienes el paquete de contexto + plan de trabajo para el nuevo dev encargado del Pizzabot V1 con ADK (Agent Development Kit de Google). Copia y pégalo tal cual en el repo como DEV_ONBOARDING.md y úsalo como contrato de trabajo.

0) Contexto rápido (lee esto primero)
•Este proyecto es la V1 del pizzabot construido con ADK (no LangGraph).
•Ya existe un digest del repo en CONTEXT/:
•CONTEXT/FILES_INDEX.md (índice limpio, sin .pyc)
•CONTEXT/SUMMARY.md (con Metrics y Tree (filtrado))
•CONTEXT/chunks/*.md (troceo con metadatos <!-- path: … part:X/Y commit:… -->)
•(Opcional) CONTEXT/REPO_FULL.md si se generó
•En la máquina del usuario, Gemini CLI reporta versión: 0.11.0-preview.0 (verificado localmente con gemini --version).

1) Reglas de oro (no tocar / no romper)
1.Nada de secretos en git. .env, tokens y claves fuera del repo; usa variables de entorno locales.
2.No inventar menú ni precios. Todo debe salir de context/menu.yaml|json o del retriever (RAG) sobre CONTEXT/chunks.
3.Flujo mínimo innegociable: greet → collect_items → collect_address/zone → confirm (total + ETA + promo) → place_order.
4.Confirmación explícita antes de crear pedido. Si falta tamaño/dirección, pregunta, no asumas.
5.Idempotencia en place_order: reintentos no duplican pedidos.
6.Logs trazables: cada decisión del agente debe poder rastrearse (tool + input + output + session_id).

2) Setup del entorno (pasos exactos)

# Recomendado: venv aislada (Python 3.11+)
python -m venv .venv && source .venv/bin/activate

# Instala dependencias del proyecto
pip install -r requirements.txt

# Gemini CLI ya está global (0.11.0-preview.0); si necesitas, comprueba:
gemini --version

# Archivo de entorno local (NO commitear)
cp .env.example .env
# Rellena .env con tus claves / rutas si aplica

Si ADK se usa como paquete Python/Node, fija versiones en requirements.txt / package.json y no mezcles canales “preview” sin necesidad.

3) Estructura esperada (alto nivel)

app/
  agent.py          # POLICY del agente ADK (loop de decisión) + wiring de tools
  tools_menu.py     # Tool: consulta de menú / promos / disponibilidad
  tools_order.py    # Tool: cotiza total, aplica promo, calcula delivery/ETA, place_order
  state.py          # Tipos (dataclasses/pydantic) + validador de stage/slots
  memory.py         # Memoria de sesión (disco/SQLite) con get/set por session_id
context/
  menu.yaml         # Menú, tamaños, extras, promos, horarios, delivery zones/fees
  policies.md       # Reglas duras: confirmación, lenguaje, no-alcohol, horarios
  nlu_intents.yaml  # Intents + slots + ejemplos (few-shots para testing)
CONTEXT/            # Digest de código y docs (RAG)
tests/
  dialogs/          # Casos conversacionales end-to-end (happy & edge cases)
tools/
  repo2md.py        # Generador de CONTEXT
  merge_context.py  # (Opcional) REPO_FULL.md monolítico
data/
  pedidos.json      # Persistencia mínima de pedidos (o SQLite)

4) Entregables por fases (sprints cortos)

Sprint 1 — Agente base + 2 tools

Objetivo: tener conversaciones que coticen, pero aún sin crear pedido.

Tareas
•agent.py: policy ADK con bucle de decisión y guardrails básicos (no inventar ítems; pedir slots faltantes).
•tools_menu.py:
•get_menu(item=None, size=None) -> {available, price, variants, promo?}
•Lee context/menu.yaml|json (no hardcode).
•tools_order.py (parcial):
•quote_order(items, zone) -> {subtotal, delivery_fee, discount, total, eta}
•Aplica promos (2x1_martes, etc.) y tarifas por zona.
•state.py: OrderState con items[], address, zone, stage, total.
•memory.py (mínimo): session-store en disco (dict persistido o SQLite lite).
•Logging estructurado (jsonl por línea): {ts, session_id, step, tool, input, output}.
•3 pruebas de diálogo (tests/dialogs/*.md):
•happy path simple,
•tamaño faltante,
•item inexistente → sugerencia válida.

Definición de Hecho
•Cubre 3 tests end-to-end con total correcto.
•No hay “alucinaciones” de items.
•Logs muestran cada uso de tool.

Sprint 2 — Confirmación + place_order

Tareas
•agent.py: estado confirm que recita desglose (subtotal, promo aplicada, delivery, total, ETA) y pide confirmación explícita.
•tools_order.py:
•place_order(order) -> {order_id} (persistente, idempotente).
•Duplicate protection (hash de {items,address,ts_window}).
•Mensajes obligatorios de cumplimiento (horario, políticas si aplica).
•3 pruebas extra:
•promo válida (martes 2x1),
•zona B (fee distinto),
•reintento tras negativa de confirmación.

Definición de Hecho
•order_id se devuelve sólo tras confirmación.
•Repetir confirm no duplica pedido.

Sprint 3 — RAG + políticas y resiliencia

Tareas
•Retriever a CONTEXT/chunks/*.md para responder preguntas de policies/promos (no menú item-by-item).
•Comando de autogeneración del digest:

python tools/repo2md.py . CONTEXT && python tools/merge_context.py


•Fallbacks: si RAG no halla respuesta, “no sé” + remitir a operador.
•Métricas mínimas: tasa de finalización, tiempo por pedido, reintentos por slot.

Definición de Hecho
•Responde correctamente a “¿qué días aplica 2x1?” desde RAG.
•Sin dependencias de Internet para conocimiento interno.

5) Contratos de Tools (I/O estrictos)

Ejemplo (tools_order.py)

from dataclasses import dataclass
from typing import List, Optional

 @.venv/lib/python3.11/site-packages/pydantic/__pycache__/dataclasses.cpython-311.pyc
class Item:
  name: str
  size: str
  qty: int = 1
  extras: Optional[list] = None

 @.venv/lib/python3.11/site-packages/pydantic/__pycache__/dataclasses.cpython-311.pyc
class Quote:
  subtotal: float
  delivery_fee: float
  discount: float
  total: float
  eta_min: int
  breakdown: dict

def quote_order(items: List[Item], zone: str) -> Quote: ...
def place_order(order: dict) -> dict:  # returns {"order_id": "..."}

•Validar inputs (size válido, item existe, qty>0).
•Nunca modificar precios/menú dentro de la tool; sólo leer de context/menu.yaml|json.

6) Prompts/Policies del agente (extracto)
•“Nunca inventes ítems. Si el cliente pide algo fuera de menú, ofrece alternativas cercanas.”
•“Si falta size o address/zone, pregunta. No asumas.”
•“Antes de crear pedido, recita total + desglose + ETA y solicita confirmación sí/no.”
•“Cita la fuente cuando uses RAG: menciona brevemente ‘según políticas internas’.”

7) Comandos útiles del proyecto

# Generar/actualizar digest (para RAG)
python tools/repo2md.py . CONTEXT
python tools/merge_context.py   # opcional

# Ejecutar test de diálogos (placeholder; implementa tu runner)
pytest -q tests/  # o python -m pytest -q

# Linter/format
ruff check . && ruff format .

8) Checklist de calidad (pre-merge)
•quote_order aplica todas las promos y tarifas (con tests).
•confirm siempre recita desglose, NUNCA omite delivery o promo.
•place_order es idempotente y deja rastro en data/pedidos.json o SQLite.
•Logs trazables (cada tool call con input/output resumidos).
•CONTEXT/ regenerado; sin .pyc / binarios; FILES_INDEX.md correcto.

⸻

Notas para el dev (cosas que suelen fallar en ADK)
•Fijar versiones del SDK/ADK y no mezclar paquetes preview innecesariamente.
•Si usas features de memoria/evals de Vertex, comprueba permisos y cuotas en local primero; no bloquees el flujo por ello.
•Evita “vibe coding”: tipa los I/O de tools y valida entradas.

⸻

¿Dudas? Si necesitas ejemplos concretos (p. ej., plantilla mínima de agent.py con la policy ADK y wiring de tools) dímelo y te dejo los archivos listos para pegar.
```