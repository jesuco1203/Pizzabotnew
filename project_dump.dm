===== main.py =====
import sys
from app.agent import Agent

if __name__ == "__main__":
    session_id = sys.argv[1]
    user_input = sys.argv[2]

    agent = Agent(session_id)
    response = agent.run(user_input)
    print(response)

===== requirements.txt =====
annotated-types==0.7.0
anyio==4.9.0
Authlib==1.6.0
cachetools==5.5.2
certifi==2025.7.9
cffi==1.17.1
charset-normalizer==3.4.2
click==8.1.8
cloudpickle==3.1.1
cryptography==45.0.5
docstring_parser==0.16
exceptiongroup==1.3.0
fastapi==0.116.0
thefuzz==0.22.1
python-Levenshtein==0.25.1
google-adk==1.5.0
google-api-core==2.25.1
google-api-python-client==2.176.0
google-auth==2.40.3
google-auth-httplib2==0.2.0
google-cloud-aiplatform==1.102.0
google-cloud-appengine-logging==1.6.2
google-cloud-audit-log==0.3.2
google-cloud-bigquery==3.34.0
google-cloud-core==2.4.3
google-cloud-logging==3.12.1
google-cloud-resource-manager==1.14.2
google-cloud-secret-manager==2.24.0
google-cloud-speech==2.33.0
google-cloud-storage==2.19.0
google-cloud-trace==1.16.2
google-crc32c==1.7.1
google-genai==1.25.0
google-resumable-media==2.7.2
googleapis-common-protos==1.70.0
graphviz==0.21
grpc-google-iam-v1==0.14.2
grpcio==1.73.1
grpcio-status==1.73.1
h11==0.16.0
httpcore==1.0.9
httplib2==0.22.0
httpx==0.28.1
idna==3.10
importlib_metadata==8.7.0
numpy==2.0.2
opentelemetry-api==1.34.1
opentelemetry-exporter-gcp-trace==1.9.0
opentelemetry-resourcedetector-gcp==1.9.0a0
opentelemetry-sdk==1.34.1
opentelemetry-semantic-conventions==0.55b1
packaging==25.0
proto-plus==1.26.1
protobuf==6.31.1
pyasn1==0.6.1
pyasn1_modules==0.4.2
pycparser==2.22
pydantic==2.11.7
pydantic_core==2.33.2
pyparsing==3.2.3
python-dateutil==2.9.0.post0
python-dotenv==1.1.1
PyYAML==6.0.2
requests==2.32.4
rsa==4.9.1
shapely==2.0.7
six==1.17.0
sniffio==1.3.1
SQLAlchemy==2.0.41
starlette==0.46.2
tenacity==8.5.0
typing-inspection==0.4.1
typing_extensions==4.14.1
tzlocal==5.3.1
uritemplate==4.2.0
urllib3==2.5.0
uvicorn==0.35.0
websockets==15.0.1
zipp==3.23.0

===== test_full_flow.py =====



import asyncio
from dotenv import load_dotenv
from google.adk.agents import Agent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai.types import Content, Part
from agents.coordinator_agent import coordinator_agent
import json
import os # Importar os
import time # Importar time

# Cargar variables de entorno desde .env
load_dotenv()

async def run_test_conversation():
    """Runs a predefined conversation flow to test the agent's state management."""
    session_service = InMemorySessionService()
    app_name = "pizzabot_test_app"
    user_id = "test_user_001"
    session_id = "test_session_001"

    # Limpiar archivos de datos al inicio del test
    clientes_path = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/clientes.json"
    pedidos_path = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/pedidos.json"
    if os.path.exists(clientes_path):
        os.remove(clientes_path)
        print(f"DEBUG: Eliminado {clientes_path}")
    if os.path.exists(pedidos_path):
        os.remove(pedidos_path)
        print(f"DEBUG: Eliminado {pedidos_path}")

    await session_service.create_session(
        app_name=app_name,
        user_id=user_id,
        session_id=session_id,
        state={
            "conversation_phase": "TOMANDO_PEDIDO",
            "user_identified": True,
            "user_name": "TesterUser",
            "awaiting_user_name": False,
            "user_checked_db": True,
            "db_check_result": {"exists": True, "name": "TesterUser"}
        }
    )

    runner = Runner(
        agent=coordinator_agent,
        app_name=app_name,
        session_service=session_service
    )

    conversation_flow = [
        "quiero una piza de peperoni",
        "familiar",
        "y una pepsi",
        "500 ml",
        "quiero una pizza hawaiana familiar",
        "muéstrame mi pedido",
        "es todo",
        "sí, confirmo",
        "en calle luna 45, ciudad del sol",
        "listo"
    ]

    print("--- INICIANDO PRUEBA DE FLUJO DE PEDIDOS ---")

    for i, query in enumerate(conversation_flow):
        print(f"\n--- TURNO {i+1}: ENTRADA DEL USUARIO ---")
        print(f">>> Usuario: {query}")

        content = Content(role='user', parts=[Part(text=query)])
        
        final_response_text = "Agente no produjo una respuesta final."
        async for event in runner.run_async(user_id=user_id, session_id=session_id, new_message=content):
            if event.is_final_response() and event.content and event.content.parts:
                final_response_text = event.content.parts[0].text

        print(f"<<< Agente: {final_response_text}")

        # Imprimir el estado de la sesión después de cada turno
        current_session = await session_service.get_session(app_name=app_name, user_id=user_id, session_id=session_id)
        print("--- ESTADO DE LA SESIÓN DESPUÉS DEL TURNO ---")
        print(json.dumps(current_session.state, indent=2))
        print("------------------------------------------")
        time.sleep(5) # Pausa de 5 segundos para respetar la cuota de la API

    print("\n--- PRUEBA DE FLUJO DE PEDIDOS FINALIZADA ---")

if __name__ == "__main__":
    asyncio.run(run_test_conversation())

===== AGENTS.md =====
<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

===== DEV_ONBOARDING.md =====
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

===== PLAN.md =====
# Plan de Desarrollo: Pizzabotnew (Funcionalidad PizzeríaBot)

## 1. Resumen Ejecutivo

Este plan detalla la hoja de ruta para implementar la funcionalidad completa del "PizzeríaBot" en el proyecto actual "Pizzabotnew", adhiriéndose a la arquitectura "Gerente-Empleado" (Ping-Pong) y optimizando las interacciones con la base de datos a solo dos llamadas: una al inicio para verificar el usuario y otra al final para registrar el pedido completo. El `session.state` será el mecanismo principal para mantener el contexto y los datos temporales del pedido.

**Estado Actual:**
Hemos logrado un progreso significativo en la Fase 1 (Gestión de Usuario) y hemos sentado las bases para las fases de pedido y confirmación. El flujo de identificación de usuario está casi completo, y la persistencia del estado de la sesión ha sido un desafío clave que estamos abordando.

## 2. Arquitectura General: Modelo "Gerente-Empleado"

*   **El Gerente (`CoordinatorAgent`):** Actúa como el cerebro central y orquestador silencioso. Su única responsabilidad es gestionar el flujo de la conversación (la máquina de estados) basándose en las "banderas" y datos almacenados en `session.state`. No genera texto directamente al usuario, solo delega.
*   **Los Empleados (Agentes Especializados):** Son `LlmAgent` con instrucciones precisas para tareas específicas (saludar, tomar pedidos, confirmar, etc.). Generan las respuestas al usuario y actualizan `session.state` con los resultados de sus tareas.
*   **Las Manos (Herramientas):** Funciones Python deterministas que encapsulan la lógica de negocio (interacción con "base de datos", manipulación del menú/pedido). Son llamadas por los Empleados.

## 3. Estrategia de Base de Datos (Simulada en Memoria)

Para cumplir con el requisito de solo dos llamadas a la DB, simularemos la base de datos en memoria para las fases intermedias.

*   **Primera Llamada a DB (Inicio):** `check_user_in_db()` (implementado en `tools/user_tools.py` usando `data/clientes.json`).
*   **Segunda Llamada a DB (Final):** `write_order_to_db()` (aún por implementar, usará `data/pedidos.json`).
*   **Datos del Menú:** Se cargarán una vez al inicio del bot y se mantendrán en memoria.
*   **Datos del Pedido:** Se gestionarán completamente en `session.state` hasta la finalización.

## 4. Fases de Desarrollo Detalladas

Dividiremos el desarrollo en fases secuenciales, cada una con objetivos claros y componentes a implementar.

---

### Fase 1: Gestión de Usuario y Saludo Inicial (En Progreso / Casi Completa)

**Objetivo:** Al iniciar la conversación, verificar si el cliente existe en la "base de datos". Si no, pedir su nombre amablemente e insistir si es necesario.

**Componentes Implementados:**

*   **Herramientas (`tools/user_tools.py`):** `check_user_in_db`, `register_new_user`. Ahora usan `data/clientes.json`.
*   **Agente (`agents/user_management_agent.py`):** `UserManagementAgent`.
*   **Modificación `CoordinatorAgent` (`agents/coordinator_agent.py`):** Delega a `UserManagementAgent` en la fase `SALUDO`.
*   **Modificación `main.py`:** Limpieza de sesión al inicio (para depuración) y persistencia de `session.state` entre turnos.
*   **Modificación `greeting_agent.py`:** Simplificado, ya no maneja el saludo inicial.

**Logros:**

*   El bot ahora verifica la existencia del usuario al inicio.
*   Puede registrar nuevos usuarios y saludarlos por su nombre.
*   El `session.state` persiste correctamente los datos del usuario (`user_identified`, `user_name`).
*   El `CoordinatorAgent` transiciona a `TOMANDO_PEDIDO` una vez que el usuario está identificado.
*   El mensaje "Transicionando a toma de pedido." ha sido eliminado de la salida al usuario.

**Problemas Actuales (Fase 1):**

*   **Bucle al pedir el nombre (Agente Disco Rayado):** Si el usuario es nuevo y se le pide el nombre, el bot entra en un bucle repitiendo la pregunta. Esto se debe a que la lógica en `UserManagementAgent` no está manejando correctamente la persistencia de la bandera `awaiting_user_name` y el procesamiento de la entrada del usuario en el mismo turno. El `session.state` muestra que `awaiting_user_name` no se está actualizando correctamente.
*   **Saludo Inconsistente (Agente Loro):** En algunos casos, el `UserManagementAgent` puede aceptar una palabra como "hola" como nombre si el usuario es nuevo y la proporciona en el primer turno, lo que lleva a un saludo incorrecto.

---

### Fase 2: Presentación del Menú y Refinamiento del Pedido (En Progreso)

**Objetivo:** Permitir al usuario solicitar el menú (PDF o texto), y gestionar el pedido con opciones de añadir, modificar cantidad y eliminar ítems.

**Componentes Implementados:**

*   **Herramientas (`tools/menu_tools.py`, `tools/order_tools.py`):** `get_menu`, `add_item_to_order`, `get_current_order`, `remove_item_from_order`. Rutas de `menu.json` corregidas. `add_item_to_order` ahora usa `thefuzz` para búsqueda difusa y maneja la nueva estructura del menú.
*   **Agentes (`agents/menu_agent.py`, `agents/order_agent.py`):** `MenuAgent`, `OrderAgent`.
*   **Modificación `CoordinatorAgent` (`agents/coordinator_agent.py`):** Lógica básica para delegar a `MenuAgent` o `OrderAgent` en la fase `TOMANDO_PEDIDO`.

**Logros:**

*   El bot puede mostrar el menú y procesar la adición/eliminación de ítems al pedido.
*   El `session.state` almacena el `current_order` correctamente *dentro de la herramienta `add_item_to_order`*.
*   La búsqueda de productos ahora es más robusta con `thefuzz`.

**Problemas Actuales (Fase 2):**

*   **`current_order` Persistencia desde `OrderAgent` a `session.state`:** El `OrderAgent` no está correctamente señalizando los cambios en `current_order` al `Runner` a través de `EventActions(state_delta=...)` después de que `add_item_to_order` es llamada. Esto lleva a que el `ConfirmationAgent` vea un carrito vacío.
*   **Flujo de Cantidad/Tamaño en `OrderAgent`:** La `instruction` y la lógica del `OrderAgent` no son robustas para manejar el flujo de dos pasos (encontrar producto, luego preguntar por cantidad/tamaño si es necesario). A veces pregunta por la cantidad antes de confirmar el producto, o pregunta por el tamaño cuando no es necesario.
*   **"es todo" detección:** La detección de "es todo" en `CoordinatorAgent` no está consistentemente llevando a la fase `CONFIRMANDO_PEDIDO`. A veces cae en respuestas genéricas o `MenuAgent`.

---

### Fase 3: Resumen y Confirmación del Pedido (Iniciada)

**Objetivo:** Presentar un resumen detallado del pedido y pedir confirmación. Permitir volver a la fase de pedido para modificaciones.

**Componentes Implementados:**

*   **Agente (`agents/confirmation_agent.py`):** `ConfirmationAgent` creado y accede directamente a `session.state['current_order']`.
*   **Modificación `CoordinatorAgent` (`agents/coordinator_agent.py`):** Importa `confirmation_agent` y lo añade a `sub_agents`. Lógica básica para la fase `CONFIRMANDO_PEDIDO`.

**Problemas Actuales (Fase 3):**

*   **Activación:** No consistentemente activado después de "es todo" (vinculado al problema de Fase 2).
*   **Lógica de `ConfirmationAgent`:** Necesita ser probada y refinada una vez que la transición de fase funcione.

---

### Fase 4: Recolección de Dirección (Pendiente)

**Objetivo:** Solicitar la dirección de envío del pedido.

**Componentes:**

*   Nuevo Agente (`agents/address_agent.py`).
*   Modificación `CoordinatorAgent` (`agents/coordinator_agent.py`).

---

### Fase 5: Finalización del Pedido y Despedida (Pendiente)

**Objetivo:** Escribir todos los datos del pedido y del cliente en la "base de datos" y despedir al cliente.

**Componentes:**

*   Nueva Herramienta (`tools/finalization_tools.py`).
*   Nuevo Agente (`agents/finalization_agent.py`).
*   Modificación `CoordinatorAgent` (`agents/coordinator_agent.py`).

---

## 5. Plan de Acción Detallado (Próximos Pasos)

**Prioridad #1: Resolver `current_order` Persistencia desde `OrderAgent` (Fase 2)**

*   **Tarea:** Asegurar que `OrderAgent` correctamente emita `EventActions(state_delta={"current_order": ...})` después de `add_item_to_order` es exitoso.
*   **Acción:**
    *   Revisar `agents/order_agent.py` para asegurar que el `yield Event` después de una adición exitosa incluya `actions=EventActions(state_delta={"current_order": ctx.session.state.get("current_order")})`.
    *   Asegurarse de que el `OrderAgent` no esté sobrescribiendo el `current_order` con un valor vacío en algún punto.

**Prioridad #2: Refinar `OrderAgent`'s Product/Quantity/Size Flow (Fase 2)**

*   **Tarea:** Hacer `OrderAgent` más inteligente sobre cómo identificar productos, preguntar por cantidad/tamaño solo cuando sea necesario, y manejar productos inválidos.
*   **Acción:**
    *   Revisar la `instruction` del `OrderAgent` para guiar al LLM a un flujo de dos pasos:
        1.  Llamar a `add_item_to_order` con `quantity=0` para validar el producto y obtener `product_details`.
        2.  Si `product_details` indica que el producto tiene tamaños y no se especificó, preguntar por el tamaño.
        3.  Si la cantidad no está clara, preguntar por la cantidad.
        4.  Luego, llamar a `add_item_to_order` con la cantidad y el tamaño reales.
    *   Asegurar que el `OrderAgent` maneje los `status: "error"` de `add_item_to_order` de forma clara.

**Prioridad #3: Mejorar "es todo" Transition in `CoordinatorAgent` (Fase 2)**

*   **Tarea:** Asegurar que `CoordinatorAgent` confiablemente transicione a `CONFIRMANDO_PEDIDO` cuando "es todo" es detectado.
*   **Acción:** Re-examinar la condición `if any(keyword in user_message_text.lower() for keyword in ["es todo", ...])` y el subsiguiente `yield Event(...)` y `continue` en `coordinator_agent.py`.

**Prioridad #4: Resolver el Bucle de Identificación de Usuario (Fase 1)**

*   **Tarea:** Depurar `UserManagementAgent` para asegurar que la bandera `awaiting_user_name` se maneje correctamente y que el agente procese la entrada del usuario de forma robusta para extraer el nombre.
*   **Acción:** Revisar la lógica de `UserManagementAgent` para asegurar que el `session.state` se actualice correctamente con `awaiting_user_name = False` una vez que el nombre es capturado, y que la validación del nombre sea más estricta para evitar que "hola" sea aceptado como nombre.

**Prioridad #5: Implementar Fases Restantes (Fases 4 y 5)**

*   **Tarea:** Desarrollar `AddressCollectionAgent` y `FinalizationAgent` con sus herramientas.
*   **Acción:** Seguir el `PLAN.md` para estas fases una vez que las anteriores estén estables.

## 6. Consideraciones Adicionales

*   **Manejo de Errores:** Continuar fortaleciendo el manejo de errores en agentes y herramientas.
*   **Refinamiento de Instrucciones:** Iterar y ajustar las instrucciones de los agentes para optimizar su comportamiento.
*   **Pruebas:** Realizar pruebas exhaustivas en cada etapa del desarrollo.

===== app/agent.py =====
from app.tools_menu import get_menu
from app.tools_order import quote_order
from app.memory import get_session, save_session
from app.state import OrderState, Item

class Agent:
    def __init__(self, session_id: str):
        self.session_id = session_id
        self.state = OrderState(**get_session(session_id))

    def __del__(self):
        save_session(self.session_id, self.state.__dict__)

    def _log_step(self, tool_name, tool_input, tool_output):
        # To be implemented
        print(f"Tool: {tool_name}, Input: {tool_input}, Output: {tool_output}")

    def run(self, user_input: str):
        """Runs the agent.

        Args:
            user_input: The user's input.

        Returns:
            The agent's response.
        """
        if self.state.stage is None:
            self.state.stage = "greeting"
            return "Hello! I'm Pizzabot. What can I get for you today?"

        if self.state.stage == "greeting":
            # This is a very simple NLU, we will improve it later
            if "menu" in user_input.lower():
                menu = get_menu()
                self._log_step("get_menu", {}, menu)
                return f"Here is our menu: {menu}"
            else:
                # Assume the user is ordering something
                # This is a very simple implementation, we will improve it later
                # For now, we assume the user says something like "a pepperoni pizza size large"
                parts = user_input.lower().split()
                try:
                    size_index = parts.index("size")
                    size = parts[size_index + 1]
                    name = " ".join(parts[:size_index-1])
                    name = name.replace("a ", "").replace("an ", "")
                    item = Item(name=name, size=size)
                    self.state.items.append(item)
                    self.state.stage = "collecting_address"
                    return f"I've added a {size} {name} to your order. What is your address zone?"
                except ValueError:
                    return "I'm sorry, I didn't understand. Please specify the size of the pizza."

        if self.state.stage == "collecting_address":
            self.state.zone = user_input
            quote = quote_order(self.state.items, self.state.zone)
            self.state.total = quote.total
            self.state.stage = "confirmation"
            self._log_step("quote_order", {"items": self.state.items, "zone": self.state.zone}, quote)
            return f"""Here is a breakdown of your order:
Subtotal: ${quote.subtotal:.2f}
Delivery Fee: ${quote.delivery_fee:.2f}
Discount: ${quote.discount:.2f}
Total: ${quote.total:.2f}
ETA: {quote.eta_min} minutes

Does that sound right?"""

        if self.state.stage == "confirmation":
            if "yes" in user_input.lower():
                from app.tools_order import place_order
                order_result = place_order(self.state.__dict__)
                self._log_step("place_order", {"order": self.state.__dict__}, order_result)
                if order_result["status"] == "created":
                    return f"Great! Your order has been placed. Your order ID is {order_result['order_id']}."
                else:
                    return f"It looks like you already placed this order. Your order ID is {order_result['order_id']}."
            else:
                self.state.stage = "greeting"
                self.state.items = []
                return "I've cancelled your order. What would you like to do?"

        return "I'm sorry, I don't know how to handle that yet."

===== app/memory.py =====
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

===== app/state.py =====
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

===== app/tools_menu.py =====
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

===== app/tools_order.py =====
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

===== agents/__init__.py =====


===== agents/address_agent.py =====
from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext # Importar InvocationContext
from tools.user_tools import save_address

class AddressAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="AddressAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en recoger la dirección del cliente.",
            instruction="""Eres el agente de dirección. Tu única tarea es pedir y recoger la dirección del cliente.
            Cuando el usuario te proporcione una dirección completa (ej. "Calle Luna 123, Ciudad del Sol"),
            debes usar la herramienta `save_address` para guardarla. Asegúrate de pasar la dirección completa
            como el argumento `address` a la herramienta `save_address`.
            Después de guardar la dirección, confirma al usuario que la dirección ha sido guardada y que el pedido está siendo finalizado.
            Si el usuario no proporciona una dirección clara o completa, pídele que la especifique.
            """,
            tools=[save_address],
            **kwargs
        )

    async def _run_async_impl(self, ctx: InvocationContext):
        user_message_text = ""
        if ctx.user_content and ctx.user_content.parts:
            for part in ctx.user_content.parts:
                if part.text:
                    user_message_text += part.text
        
        print(f"DEBUG: AddressAgent: Mensaje usuario: {user_message_text}")

        async for event in super()._run_async_impl(ctx):
            yield event

address_agent = AddressAgent()

===== agents/confirmation_agent.py =====
from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions

from tools.order_tools import get_current_order # Reutilizamos esta herramienta

class ConfirmationAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="ConfirmationAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en presentar el resumen del pedido y gestionar la confirmación o modificación.",
            instruction="""Eres el agente de confirmación. Tu tarea es:
            1. **Si `session.state['summary_presented']` es `False`:**
               - Utiliza la herramienta `get_current_order` para obtener el resumen del pedido.
               - Presenta al cliente un resumen claro de su pedido actual.
               - Pregunta al cliente si confirma el pedido.
               - Responde con un mensaje que incluya la frase "RESUMEN_PRESENTADO".
            2. **Si `session.state['summary_presented']` es `True`:**
               - **Basado en la respuesta del usuario, determina la intención:**
                   - Si el usuario confirma (ej. "sí", "confirmo", "adelante", "ok"), responde con "PEDIDO_CONFIRMADO: ¡Perfecto! Pedido confirmado. Ahora, ¿a qué dirección te lo enviamos?".
                   - Si el usuario indica que quiere modificar algo (ej. "modificar", "cambiar", "quitar", "agregar"), responde con "SOLICITUD_MODIFICACION: De acuerdo. Volviendo al menú de pedidos para que puedas hacer cambios.". 
                   - Si no entiendes la respuesta o no es una confirmación/modificación clara, vuelve a preguntar "No entendí tu respuesta. ¿Confirmas el pedido o deseas modificarlo?".
            """,
            tools=[get_current_order],
            **kwargs
        )

    async def _run_async_impl(self, ctx: InvocationContext):
        print(f"DEBUG: ConfirmationAgent: Iniciando _run_async_impl. Estado: {ctx.session.state}")
        # Dejar que el LLM maneje la lógica basándose en su instrucción y el estado de la sesión.
        # El LLM decidirá cuándo llamar a get_current_order y qué respuesta de texto generar.
        async for event in super()._run_async_impl(ctx):
            yield event
        print(f"DEBUG: ConfirmationAgent: LLM de confirmación finalizado. Nuevo estado: {ctx.session.state}")

confirmation_agent = ConfirmationAgent()

===== agents/coordinator_agent.py =====
from google.adk.agents import BaseAgent, Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions

# Importar agentes especializados
from agents.menu_agent import menu_agent
from agents.order_agent import order_agent
from agents.greeting_agent import greeting_agent
from agents.user_management_agent import UserManagementAgent
from agents.confirmation_agent import confirmation_agent
from agents.address_agent import address_agent
from agents.finalization_agent import finalization_agent

# Definición de las fases conversacionales
class ConversationPhase:
    SALUDO = "SALUDO"
    TOMANDO_PEDIDO = "TOMANDO_PEDIDO"
    CONFIRMANDO_PEDIDO = "CONFIRMANDO_PEDIDO"
    RECOGIENDO_DIRECCION = "RECOGIENDO_DIRECCION"
    PAGO = "PAGO"
    FINALIZACION = "FINALIZACION"

class CoordinatorAgent(BaseAgent):

    def _analyze_intention(self, message: str, ctx: InvocationContext) -> str:
        """Analiza la intención del mensaje del usuario para delegar correctamente.
        Esta función es una simplificación y debería ser manejada por un IntentClassifierAgent
        o un LLM más robusto en un entorno de producción.
        """
        message_lower = message.lower()
        current_phase = ctx.session.state.get("conversation_phase", ConversationPhase.SALUDO)

        # Priorizar la fase actual de la conversación
        if current_phase == ConversationPhase.SALUDO:
            # Si estamos en la fase de saludo y esperando nombre, cualquier entrada es para UserManagementAgent
            if ctx.session.state.get("awaiting_user_name"):
                return "customer_registration"
            # Si no, es una conversación general o un intento de iniciar pedido/menú
            if any(keyword in message_lower for keyword in ["hola", "saludos", "hi", "buenas"]):
                return "general_conversation"
            return "initial_inquiry" # Para cualquier otra cosa en la fase de saludo

        elif current_phase == ConversationPhase.TOMANDO_PEDIDO:
            # Si hay un ítem pendiente de clarificación, la intención es de orden
            if ctx.session.state.get("item_to_clarify"):
                return "order_action"
            # Palabras clave para finalizar pedido
            finalize_order_keywords = ["es todo", "terminar pedido", "finalizar pedido", "listo con mi pedido", "confirmar mi pedido"]
            if any(keyword in message_lower for keyword in finalize_order_keywords):
                return "finalize_order"
            # Palabras clave para consultas de menú
            menu_query_categories = ['menú', 'carta', 'platos', 'bebidas', 'postres', 'tienes', 'mostrar', 'que hay', 'opciones', 'pizas', 'lasañas']
            if any(keyword in message_lower for keyword in menu_query_categories):
                return "menu_query"
            # Por defecto, si estamos tomando pedido, cualquier otra cosa es una acción de pedido
            return "order_action"

        elif current_phase == ConversationPhase.CONFIRMANDO_PEDIDO:
            # En esta fase, esperamos confirmación o modificación
            confirmation_keywords = ["sí", "si", "confirmo", "adelante", "ok", "vale", "correcto", "es correcto"]
            modification_keywords = ["modificar", "cambiar", "quitar", "agregar", "añadir", "no es correcto"]
            if any(keyword in message_lower for keyword in confirmation_keywords):
                return "confirm_order"
            if any(keyword in message_lower for keyword in modification_keywords):
                return "modify_order"
            return "clarification_needed" # Si no es confirmación ni modificación

        elif current_phase == ConversationPhase.RECOGIENDO_DIRECCION:
            # En esta fase, cualquier entrada es para el AddressAgent
            return "delivery_info"

        elif current_phase == ConversationPhase.FINALIZACION:
            # En esta fase, el bot ya debería estar despidiéndose o esperando un nuevo inicio
            return "general_conversation"

        # Fallback para intenciones generales si no hay fase específica
        return "general_conversation"

    async def _run_async_impl(self, ctx: InvocationContext):
        print(f"DEBUG: CoordinatorAgent: Iniciando _run_async_impl para el turno. Fase actual: {ctx.session.state.get('conversation_phase', 'N/A')}")
        # Buscar la instancia de UserManagementAgent entre los sub_agents
        user_management_agent_instance = None
        confirmation_agent_instance = None
        order_agent_instance = None
        menu_agent_instance = None
        address_agent_instance = None
        finalization_agent_instance = None

        for agent in self.sub_agents:
            if agent.name == "UserManagementAgent":
                user_management_agent_instance = agent
            elif agent.name == "ConfirmationAgent":
                confirmation_agent_instance = agent
            elif agent.name == "OrderAgent":
                order_agent_instance = agent
            elif agent.name == "MenuAgent":
                menu_agent_instance = agent
            elif agent.name == "AddressAgent":
                address_agent_instance = agent
            elif agent.name == "FinalizationAgent":
                finalization_agent_instance = agent
        
        if not user_management_agent_instance:
            raise ValueError("UserManagementAgent no encontrado en la lista de sub_agents.")
        if not confirmation_agent_instance:
            raise ValueError("ConfirmationAgent no encontrado en la lista de sub_agents.")
        if not order_agent_instance:
            raise ValueError("OrderAgent no encontrado en la lista de sub_agents.")
        if not menu_agent_instance:
            raise ValueError("MenuAgent no encontrado en la lista de sub_agents.")
        if not address_agent_instance:
            raise ValueError("AddressAgent no encontrado en la lista de sub_agents.")
        if not finalization_agent_instance:
            raise ValueError("FinalizationAgent no encontrado en la lista de sub_agents.")

        # Initial user message text capture (only once per turn)
        user_message_text = ""
        if ctx.user_content and ctx.user_content.parts:
            for part in ctx.user_content.parts:
                if part.text:
                    user_message_text += part.text
        print(f"DEBUG: CoordinatorAgent: Mensaje de usuario: {user_message_text}")

        while True: # Loop to re-evaluate phase in the same turn
            current_phase = ctx.session.state.get("conversation_phase", ConversationPhase.SALUDO)
            print(f"DEBUG: CoordinatorAgent: Evaluando fase: {current_phase}")

            if current_phase == ConversationPhase.SALUDO:
                print("DEBUG: CoordinatorAgent: Delegando a UserManagementAgent.")
                async for event in user_management_agent_instance.run_async(ctx):
                    yield event
                
                if ctx.session.state.get("user_identified"):
                    print("DEBUG: CoordinatorAgent: Usuario identificado. Transicionando a TOMANDO_PEDIDO.")
                    # Emitir un evento para persistir el cambio de fase
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.TOMANDO_PEDIDO
                        }),
                        content=Content(parts=[Part(text="")]) # No generar texto, la respuesta ya la dio UserManagementAgent
                    )
                    break # Romper el bucle para que el turno termine y el OrderAgent se active en el siguiente turno del usuario
                else:
                    print("DEBUG: CoordinatorAgent: Usuario no identificado. Permaneciendo en SALUDO.")
                    # Si el usuario no está identificado, permanecer en la fase SALUDO
                    break # Romper el bucle, esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.TOMANDO_PEDIDO:
                print("DEBUG: CoordinatorAgent: En fase TOMANDO_PEDIDO.")
                # Lógica para la fase TOMANDO_PEDIDO
                # Primero, verificar si el usuario quiere finalizar el pedido con la nueva intención específica.
                intention = self._analyze_intention(user_message_text, ctx)
                print(f"DEBUG: CoordinatorAgent: Intención detectada en TOMANDO_PEDIDO: {intention}")

                if intention == "finalize_order":
                    print("DEBUG: CoordinatorAgent: Intención finalize_order. Transicionando a CONFIRMANDO_PEDIDO.")
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.CONFIRMANDO_PEDIDO
                        })
                    )
                    continue  # Re-evaluar en la nueva fase de confirmación

                # Si no es finalizar, analizar la intención para delegar.
                else:
                    if intention == "menu_query":
                        print("DEBUG: CoordinatorAgent: Delegando a MenuAgent.")
                        async for event in menu_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "order_action":
                        print("DEBUG: CoordinatorAgent: Delegando a OrderAgent.")
                        async for event in order_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "general_conversation":
                        print("DEBUG: CoordinatorAgent: Delegando a GreetingAgent (general_conversation).")
                        async for event in greeting_agent.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "customer_registration": # NUEVA LÓGICA: Delegar a UserManagementAgent
                        print("DEBUG: CoordinatorAgent: Delegando a UserManagementAgent (customer_registration).")
                        async for event in user_management_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    else:
                        # Si la intención no es clara, delegar al OrderAgent por defecto o dar un mensaje genérico
                        print("DEBUG: CoordinatorAgent: Intención no clara, delegando a OrderAgent por defecto.")
                        async for event in order_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.CONFIRMANDO_PEDIDO:
                print("DEBUG: CoordinatorAgent: En fase CONFIRMANDO_PEDIDO. Delegando a ConfirmationAgent.")
                # Delegar al ConfirmationAgent
                async for event in confirmation_agent_instance.run_async(ctx):
                    # Interceptar la respuesta del ConfirmationAgent para interpretar los prefijos
                    if event.is_final_response() and event.content and event.content.parts:
                        response_text = event.content.parts[0].text
                        print(f"DEBUG: CoordinatorAgent: Respuesta de ConfirmationAgent: {response_text[:50]}...")
                        if response_text.startswith("PEDIDO_CONFIRMADO:"):
                            print("DEBUG: CoordinatorAgent: Pedido confirmado. Transicionando a RECOGIENDO_DIRECCION.")
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("PEDIDO_CONFIRMADO:", "").strip())]),
                                actions=EventActions(state_delta={
                                    "order_confirmed": True,
                                    "summary_presented": False, # Reset para futuras confirmaciones
                                    "conversation_phase": ConversationPhase.RECOGIENDO_DIRECCION # Transición de fase
                                })
                            )
                            return # Terminar el turno del Coordinator
                        elif response_text.startswith("SOLICITUD_MODIFICACION:"):
                            print("DEBUG: CoordinatorAgent: Solicitud de modificación. Transicionando a TOMANDO_PEDIDO.")
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("SOLICITUD_MODIFICACION:", "").strip())]),
                                actions=EventActions(state_delta={
                                    "modification_requested": True,
                                    "summary_presented": False, # Reset
                                    "conversation_phase": ConversationPhase.TOMANDO_PEDIDO # Transición de fase
                                })
                            )
                            return # Terminar el turno del Coordinator
                        elif response_text.startswith("RESUMEN_PRESENTADO:"):
                            print("DEBUG: CoordinatorAgent: Resumen presentado. Actualizando estado.")
                            # Solo actualizar el estado, no cambiar de fase
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("RESUMEN_PRESENTADO:", "").strip())]),
                                actions=EventActions(state_delta={"summary_presented": True})
                            )
                            return # Terminar el turno del Coordinator
                    yield event # Re-yield cualquier otro evento del ConfirmationAgent
                break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.RECOGIENDO_DIRECCION:
                print("DEBUG: CoordinatorAgent: En fase RECOGIENDO_DIRECCION. Delegando a AddressAgent.")
                async for event in address_agent_instance.run_async(ctx):
                    yield event
                
                # Después de que AddressAgent se ejecute, verificar si la dirección fue recolectada
                if ctx.session.state.get("address_collected"):
                    print("DEBUG: CoordinatorAgent: Dirección recolectada. Transicionando a FINALIZACION.")
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.FINALIZACION
                        })
                    )
                    continue # Re-evaluar en la nueva fase
                else:
                    print("DEBUG: CoordinatorAgent: Dirección no recolectada. Permaneciendo en RECOGIENDO_DIRECCION.")
                    break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.FINALIZACION:
                print("DEBUG: CoordinatorAgent: En fase FINALIZACION. Delegando a FinalizationAgent.")
                async for event in finalization_agent_instance.run_async(ctx):
                    yield event
                print("DEBUG: CoordinatorAgent: Finalización completada. Terminando el turno.")
                # La conversación termina después de la despedida del agente finalizador.
                break

            # ... other phases will be added here ...
            # If no phase matches or a phase completes without a transition, break the loop
            else: # This 'else' corresponds to the 'if current_phase == ...' chain
                print(f"DEBUG: CoordinatorAgent: Fase desconocida o sin transición: {current_phase}")
                yield Event(
                    invocation_id=ctx.invocation_id,
                    author=self.name,
                    content=Content(parts=[Part(text="Lo siento, no entiendo esa fase de la conversación.")])
                )
                break # Break the while loop, wait for next user input

# Instancia del coordinador
user_management_agent_instance = UserManagementAgent()

# Instancia del coordinador
coordinator_agent = CoordinatorAgent(
    name="PizzabotCoordinator",
    description="Orquesta el flujo conversacional del Pizzabot.",
    sub_agents=[menu_agent, order_agent, user_management_agent_instance, confirmation_agent, address_agent, finalization_agent]
)

===== agents/finalization_agent.py =====
from google.adk.agents import Agent
from tools.finalization_tools import finalize_order

class FinalizationAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="FinalizationAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en guardar el pedido final y despedirse.",
            instruction="""Tu única tarea es finalizar el pedido del cliente.
            Llama a la herramienta `finalize_order` para guardar el pedido en la base de datos.
            Una vez guardado, informa al cliente que su pedido ha sido recibido y está en camino, y agradécele por su compra.
            """,
            tools=[finalize_order],
            **kwargs
        )

finalization_agent = FinalizationAgent()

===== agents/greeting_agent.py =====
from google.adk.agents import Agent

greeting_agent = Agent(
    name="GreetingAgent",
    model="gemini-2.0-flash",
    description="Agente especializado en saludar y dar la bienvenida a los clientes.",
    instruction="""Eres un asistente amigable de pizzería. Tu tarea es proporcionar saludos amables y respuestas de bienvenida cuando se te solicite.
    """,
    tools=[] # Este agente no necesita herramientas por ahora, solo genera texto.
)

===== agents/menu_agent.py =====
from google.adk.agents import Agent
from tools.menu_tools import get_menu

menu_agent = Agent(
    name="MenuAgent",
    model="gemini-2.0-flash",
    description="Agente especializado en responder preguntas sobre el menú.",
    instruction="""Eres un experto en el menú de la pizzería.
    Cuando un usuario te pida el menú, utiliza la herramienta `get_menu` para obtenerlo y presentárselo de forma clara y atractiva.
    """,
    tools=[get_menu]
)

===== agents/order_agent.py =====
from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from tools.order_tools import process_item_request, get_current_order
from google.adk.events import Event, EventActions
from google.genai.types import Content, Part

class OrderAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="OrderAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en gestionar el pedido actual del cliente.",
            # Aislamos al agente del historial para que no se confunda con saludos pasados.
            include_contents='none',
            tools=[process_item_request, get_current_order],
            instruction="""
            Eres un agente especializado en procesar pedidos de restaurante.
            Tu función es ayudar a los clientes a agregar elementos a su pedido, modificar cantidades,
            confirmar pedidos y calcular totales.

            Utiliza la herramienta `process_item_request` para añadir o modificar ítems en el carrito.
            Cuando el usuario pida un artículo, intenta añadirlo al carrito usando `process_item_request`.
            Si el usuario especifica un tamaño (ej. "grande", "mediana", "familiar") o una cantidad (ej. "dos", "2")
            junto con el artículo, asegúrate de pasar esos valores a los argumentos `size` y `quantity`
            de `process_item_request` respectivamente.

            Si `process_item_request` devuelve un estado `clarification_needed` (porque el producto tiene
            múltiples tamaños y no se especificó uno), **DEBES** preguntar al usuario qué tamaño desea (por ejemplo,
            "¿Qué tamaño de pizza deseas: grande, mediana o familiar?").
            Una vez que el usuario proporcione el tamaño, **DEBES** llamar a `process_item_request` de nuevo con el
            `item_identifier` original (que **DEBES** obtener de `tool_context.state['item_to_clarify']['Nombre_Base']`)
            y el `size` especificado por el usuario. Si el usuario no especifica un tamaño válido, informa
            al usuario sobre los tamaños disponibles.

            Si el usuario solo proporciona un tamaño o una cantidad sin un artículo claro, **DEBES** intentar
            asociarlo con el `item_to_clarify` que pueda estar en el estado de la sesión.
            Si el usuario solo dice una cantidad (ej. "dos") y no hay un `item_to_clarify` pendiente,
            **DEBES** pedirle que especifique el artículo al que se refiere.

            Utiliza la herramienta `get_current_order` para mostrar el resumen del pedido actual.

            Siempre confirma cada elemento agregado y mantén al cliente informado sobre el estado de su pedido.
            Sé claro sobre precios y cantidades.

            Cuando el cliente termine de agregar elementos (por ejemplo, diga "es todo", "terminé", "finalizar pedido"),
            pregunta si desea confirmar el pedido y proceder con la información de entrega.
            """,
            **kwargs
        )

    async def _run_async_impl(self, ctx: InvocationContext):
        print(f"DEBUG: OrderAgent: Iniciando _run_async_impl. Estado: {ctx.session.state}")
        # La lógica de manejo de item_to_clarify y el procesamiento de mensajes
        # se delega a la instrucción del LLM y a las herramientas.
        # El LLM, guiado por la instrucción, decidirá cuándo llamar a process_item_request
        # y cómo manejar sus respuestas (incluyendo clarification_needed).
        async for event in super()._run_async_impl(ctx):
            yield event
        print(f"DEBUG: OrderAgent: LLM de pedido finalizado. Nuevo estado: {ctx.session.state}")

order_agent = OrderAgent()

===== agents/user_management_agent.py =====
from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions

from tools.user_tools import check_user_in_db, extract_and_register_name

class UserManagementAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="UserManagementAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en la gestión inicial de usuarios, verificando su existencia y registrando nuevos usuarios.",
            instruction="""Eres el agente de gestión de usuarios. Tu tarea es verificar si un usuario existe en la base de datos.
            Si el usuario es nuevo, debes pedir su nombre amablemente. Si el usuario no proporciona un nombre válido o evade la pregunta,
            debes insistir educadamente hasta obtener un nombre claro. Una vez que tengas el nombre, regístralo.
            Utiliza la herramienta `check_user_in_db` para verificar si el usuario ya existe.
            Si el usuario no existe, utiliza la herramienta `extract_and_register_name` para extraer el nombre del mensaje del usuario y registrarlo.
            Si `extract_and_register_name` devuelve `clarification_needed`, significa que no se pudo extraer un nombre válido, y debes volver a pedirlo.
            Al finalizar, asegúrate de que `session.state['user_identified']` sea `True` y `session.state['user_name']` contenga el nombre del usuario.
            """,
            tools=[check_user_in_db, extract_and_register_name],
            **kwargs
        )

    async def _run_async_impl(self, ctx: InvocationContext):
        print(f"DEBUG: UserManagementAgent: Iniciando _run_async_impl. Estado: {ctx.session.state}")
        session_state = ctx.session.state

        # 1. Si el usuario ya está identificado, solo confirmar y retornar.
        if session_state.get("user_identified"):
            print(f"DEBUG: UserManagementAgent: Usuario ya identificado: {session_state.get('user_name', 'N/A')}")
            yield Event(
                invocation_id=ctx.invocation_id,
                author=self.name,
                content=Content(parts=[Part(text=f"¡Hola de nuevo, {session_state['user_name']}! ¿En qué puedo ayudarte hoy?")]),
            )
            return

        # 2. Si el usuario no ha sido verificado en la DB o no se ha obtenido su nombre
        if not session_state.get("user_checked_db") or session_state.get("awaiting_user_name"):
            print("DEBUG: UserManagementAgent: Delegando a LLM para identificación/registro.")
            async for event in super()._run_async_impl(ctx):
                yield event
            print(f"DEBUG: UserManagementAgent: LLM de identificación/registro finalizado. Nuevo estado: {ctx.session.state}")
            return

        # Si llegamos aquí, significa que el usuario ya fue verificado en la DB
        # pero no fue identificado (es nuevo y no se le ha preguntado el nombre aún).
        # Esto debería ser manejado por la instrucción del LLM en el turno anterior.
        # Si por alguna razón el flujo llega aquí sin que el LLM haya actuado,
        # podemos emitir un mensaje genérico o una instrucción para el LLM.
        print("DEBUG: UserManagementAgent: Flujo inesperado. Emitiendo mensaje genérico.")
        yield Event(
            invocation_id=ctx.invocation_id,
            author=self.name,
            content=Content(parts=[Part(text="¡Hola! ¿En qué puedo ayudarte hoy?")]),
        )

===== tools/__init__.py =====


===== tools/finalization_tools.py =====

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

===== tools/menu_tools.py =====
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

===== tools/order_tools.py =====
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

===== tools/repo2md.py =====
#!/usr/bin/env python3
import os, re, sys, json, hashlib, subprocess, time
from datetime import datetime
from pathlib import Path

# -------- Config --------
ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
OUT  = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("CONTEXT")
MAX_CHARS = 6000            # ~1500-2000 tokens aprox. (ajusta si quieres)
INCLUDE_EXT = {
  ".py",".ts",".tsx",".js",".jsx",".json",".yaml",".yml",".toml",".md",".sql",
  ".env.example",".sh",".ini",".cfg",".graphql",".proto",".java",".go"
}
EXCLUDE_DIRS = {".git","node_modules",".venv","venv",".next",".cache","dist","build","out",".idea",".vscode", "CONTEXT", "__pycache__"}
EXCLUDE_EXT = {".pyc", ".pyo", ".pyd", ".so", ".dll", ".exe", ".dylib", ".DS_Store"}
BINARY_RE = re.compile(r'\.(png|jpg|jpeg|gif|webp|ico|pdf|mp4|mp3|ogg|wav|ttf|otf|woff2?|zip|tar|gz|7z)$', re.I)
SECRET_RE = re.compile(r'(api[_-]?key|secret|token|password|passwd|pwd|bearer|authorization)\s*[:=]\s*.+', re.I)

# Check if we are in a git repository
IS_GIT = (ROOT / ".git").exists()

# -------- Helpers --------
def is_binary(p: Path) -> bool:
    return bool(BINARY_RE.search(p.suffix))

def should_skip(p: Path) -> bool:
    parts = set(p.parts)
    if parts & EXCLUDE_DIRS: return True
    if p.suffix.lower() in EXCLUDE_EXT: return True
    if is_binary(p): return True
    if p.name in EXCLUDE_DIRS: return True # This is redundant with parts & EXCLUDE_DIRS but harmless
    if p.suffix and (p.suffix.lower() in INCLUDE_EXT or p.name.endswith(".env.example")):
        return False
    return p.suffix == ""  # skip files sin extensión por defecto

def git_last_commit(path: Path) -> str:
    if not IS_GIT: return "-"
    try:
        out = subprocess.check_output(["git","log","-1","--format=%cs %h","--",str(path)], cwd=ROOT, stderr=subprocess.DEVNULL).decode().strip()
        return out or "-"
    except Exception:
        return "" # Return empty string if git fails

def sha1(txt: str) -> str:
    return hashlib.sha1(txt.encode("utf-8", errors="ignore")).hexdigest()

def sanitize_secrets(text: str) -> str:
    lines = []
    for line in text.splitlines():
        if SECRET_RE.search(line):
            # conserva la clave pero enmascara el valor
            k = line.split(":",1)[0] if ":" in line else line.split("=",1)[0]
            lines.append(f'{k}: ***REDACTED***')
        else:
            lines.append(line)
    return "\n".join(lines)

def chunk(text: str, max_chars=MAX_CHARS):
    blocks, buf = [], []
    total = 0
    for ln in text.splitlines(True):
        if total + len(ln) > max_chars and buf:
            blocks.append("".join(buf)); buf, total = [], 0
        buf.append(ln); total += len(ln)
    if buf: blocks.append("".join(buf))
    return blocks or [""]

def detect_lang(path: Path) -> str:
    ext = path.suffix.lower()
    return {
      ".py":"python",".ts":"typescript",".tsx":"tsx",".js":"javascript",".jsx":"jsx",
      ".json":"json",".yaml":"yaml",".yml":"yaml",".toml":"toml",".md":"md",
      ".sql":"sql",".sh":"bash",".ini":"ini",".cfg":"ini",".graphql":"application/graphql",".proto":"text/x-protobuf",".java":"text/x-java-source",".go":"text/x-go"
    }.get(ext,"")

def guess_mime(p: Path) -> str:
    return {
        ".py":"text/x-python",
        ".md":"text/markdown",
        ".json":"application/json",
        ".txt":"text/plain",
        ".ts":"text/typescript",
        ".tsx":"text/typescript",
        ".js":"text/javascript",
        ".jsx":"text/javascript",
        ".yaml":"text/yaml",
        ".yml":"text/yaml",
        ".toml":"text/toml",
        ".sql":"text/sql",
        ".sh":"application/x-sh",
        ".ini":"text/ini",
        ".cfg":"text/ini",
        ".graphql":"application/graphql",
        ".proto":"text/x-protobuf",
        ".java":"text/x-java-source",
        ".go":"text/x-go"
    }.get(p.suffix.lower(),"text/plain")

def count_loc(txt: str) -> int:
    return sum(1 for _ in txt.splitlines())

def get_script_git_sha() -> str:
    if not IS_GIT: return "unknown"
    try:
        script_path = Path(__file__).resolve()
        return subprocess.check_output(["git", "rev-parse", "--short", "HEAD", "--", str(script_path)], cwd=ROOT, stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return "unknown"

# -------- Main --------
def main():
    OUT.mkdir(parents=True, exist_ok=True)
    chunks_dir = OUT / "chunks"
    chunks_dir.mkdir(exist_ok=True)

    files_meta = []
    for path in ROOT.rglob("*"):
        if path.is_dir():
            continue
        rel = path.relative_to(ROOT)
        if should_skip(rel): continue
        try:
            txt = path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        txt = sanitize_secrets(txt)
        parts = chunk(txt)
        lm = git_last_commit(rel)
        
        file_loc = count_loc(txt)
        file_mime = guess_mime(rel)

        for i, part in enumerate(parts):
            h = sha1(str(rel)+"#"+str(i)+"#"+str(len(part)))
            lang = detect_lang(rel)
            outf = chunks_dir / f'{rel.as_posix().replace("/","__")}__p{i+1}_{h[:8]}.md'
            outf.parent.mkdir(parents=True, exist_ok=True)
            with outf.open("w", encoding="utf-8") as f:
                f.write(f'<!-- path:{rel} part:{i+1}/{len(parts)} commit:{lm} -->\n')
                if lang and lang!="md": f.write(f'```{lang}\n{part}\n```\n')
                else: f.write(part if part.endswith("\n") else part+"\n")
            files_meta.append({
                "path": rel.as_posix(),
                "part": i+1,
                "parts": len(parts),
                "chars": len(part),
                "loc": file_loc,
                "mime": file_mime,
                "hash": h,
                "commit": lm,
                "chunk_file": outf.relative_to(OUT).as_posix()
            })

    # Índices
    (OUT / "FILES_INDEX.md").write_text(
        f"""# Archivos indexados

| path | parts | chars | loc | mime | commit | chunk_file |
|---|---:|---:|---:|---:|---|---|
""" +
        "\n".join(f"| `{m['path']}` | {m['parts']} | {m['chars']} | {m['loc']} | {m['mime']} | {m['commit']} | `{m['chunk_file']}` |"
                 for m in dedup_by_path(files_meta)),
        encoding="utf-8"
    )
    with (OUT / "search.jsonl").open("w", encoding="utf-8") as w:
        for m in files_meta: w.write(json.dumps(m, ensure_ascii=False)+"\n")

    # SUMMARY con árbol
    tree_lines = render_tree(ROOT)
    tree = "\n".join(tree_lines)
    total_files = len(dedup_by_path(files_meta))
    total_chunks = len(files_meta)
    total_chars = sum(m['chars'] for m in files_meta)
    
    # Top 5 files by characters
    top_5_files = sorted(dedup_by_path(files_meta), key=lambda x: x['chars'], reverse=True)[:5]
    top_5_files_str = "\n".join(f"- `{f['path']}`: {f['chars']} chars" for f in top_5_files)

    script_version = get_script_git_sha()

    (OUT / "SUMMARY.md").write_text(
        f"""# Repo digest

- root: `{ROOT.resolve()}`
- generated: {datetime.utcnow().isoformat()}Z
- script_version: repo2md.py@{script_version}

## Metrics

- Total files: {total_files}
- Total chunks: {total_chunks}
- Total characters: {total_chars}

### Top 5 files by characters

{top_5_files_str}

## Tree (filtrado)

```
{tree}
```

Ver `FILES_INDEX.md` y carpeta `chunks/`.""", encoding="utf-8"
    )
    print(f"✅ Digest listo en {OUT}")

def dedup_by_path(meta):
    seen, out = set(), []
    for m in meta:
        if m["path"] in seen: continue
        seen.add(m["path"]); out.append(m)
    return out

def render_tree(root_path: Path):
    lines = []
    # Store all valid paths first
    all_paths = []
    for path in root_path.rglob("*"):
        rel_path = path.relative_to(root_path)
        if not should_skip(rel_path):
            all_paths.append(path)
    
    # Sort paths for consistent output
    all_paths.sort()

    # Build the tree structure
    tree_map = {}
    for path in all_paths:
        parts = path.relative_to(root_path).parts
        current_level = tree_map
        for part in parts:
            if part not in current_level:
                current_level[part] = {}
            current_level = current_level[part]

    def _render_node(node, prefix="", is_last_sibling=True): # is_last_sibling is not used
        nonlocal lines
        keys = sorted(node.keys())
        for i, key in enumerate(keys):
            is_last = (i == len(keys) - 1)
            connector = "└── " if is_last else "├── "
            
            lines.append(f"{prefix}{connector}{key}{'/' if node[key] else ''}")
            
            if node[key]: # If it's a directory
                new_prefix = prefix + ("    " if is_last else "│   ")
                _render_node(node[key], new_prefix, is_last) # Pass is_last to maintain correct prefix

    _render_node(tree_map)
    return lines

if __name__ == "__main__":
    main()

===== tools/user_tools.py =====
import json
import re
from google.adk.tools import ToolContext
from datetime import datetime

# Rutas a los archivos de datos
CLIENTES_FILE = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/clientes.json"

def _load_clientes():
    try:
        with open(CLIENTES_FILE, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}

def _save_clientes(clientes):
    with open(CLIENTES_FILE, "w") as f:
        json.dump(clientes, f, indent=2)

async def check_user_in_db(tool_context: ToolContext, user_id: str) -> dict:
    clientes = _load_clientes()
    if user_id in clientes:
        return {"exists": True, "name": clientes[user_id]["name"], "message": f"Usuario {clientes[user_id]['name']} encontrado."}
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

===== tests/dialogs/happy_path.md =====
# Happy Path

## User
Hello

## Agent
Hello! I'm Pizzabot. What can I get for you today?

## User
a pepperoni pizza size large

## Agent
I've added a large pepperoni pizza to your order. What is your address zone?

## User
A

## Agent
Your order comes to $12.99. Does that sound right?

## User
yes

## Agent
Great! I'm placing your order now.

===== tests/dialogs/invalid_item.md =====
# Invalid Item

## User
Hello

## Agent
Hello! I'm Pizzabot. What can I get for you today?

## User
a pineapple pizza

## Agent
I'm sorry, I didn't understand. Please specify the size of the pizza.

===== tests/dialogs/missing_size.md =====
# Missing Size

## User
Hello

## Agent
Hello! I'm Pizzabot. What can I get for you today?

## User
a pepperoni pizza

## Agent
I'm sorry, I didn't understand. Please specify the size of the pizza.

===== data/happy_path_test.json =====
{
    "items": [
        {
            "name": "pepperoni",
            "size": "large",
            "qty": 1,
            "extras": []
        }
    ],
    "address": null,
    "zone": "A",
    "stage": "placing_order",
    "total": 16.990000000000002
}

===== data/menu.json =====
{
  "PIZ001": {
    "Nombre_Base": "Pizza de Jamón",
    "Alias": "pizza jamon, piza de jamon",
    "Descripcion_Plato": "Una de las más sencillas y preferidas de todos.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Jamón", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ001-G", "Precio": 24.0 },
      "Familiar": { "ID_SKU": "PIZ001-F", "Precio": 32.0 }
    }
  },
  "PIZ002": {
    "Nombre_Base": "Pizza Americana",
    "Alias": "americana, piza americana",
    "Descripcion_Plato": "Nuestra combinación del mejor jamón, queso mozzarella, aceitunas y pimentón.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Jamón", "Queso Mozzarella", "Aceitunas", "Pimentón"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ002-G", "Precio": 25.0 },
      "Familiar": { "ID_SKU": "PIZ002-F", "Precio": 33.0 }
    }
  },
  "PIZ003": {
    "Nombre_Base": "Pizza Hawaiana",
    "Alias": "hawaiana, pizza con piña",
    "Descripcion_Plato": "Pizza paradisíaca hecha a mano con salsa de tomate natural, queso 100% mozzarella, el mejor Jamón y jugosa piña golden en almíbar.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Salsa de Tomate", "Queso Mozzarella", "Jamón", "Piña Golden"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ003-G", "Precio": 26.0 },
      "Familiar": { "ID_SKU": "PIZ003-F", "Precio": 34.0 }
    }
  },
  "PIZ004": {
    "Nombre_Base": "Pizza Vegetariana",
    "Alias": "vegetariana, veggie, pizza de vegetales",
    "Descripcion_Plato": "Deliciosa pizza con tus vegetales favoritos: pimentones, cebolla roja, champiñones, aceitunas y tomates.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Pimentones", "Cebolla Roja", "Champiñones", "Aceitunas", "Tomates", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ004-G", "Precio": 25.0 },
      "Familiar": { "ID_SKU": "PIZ004-F", "Precio": 33.0 }
    }
  },
  "PIZ005": {
    "Nombre_Base": "Pizza de Pepperoni",
    "Alias": "pepperoni, peperoni",
    "Descripcion_Plato": "Pizza clásica de Pepperoni, con irresistible queso 100% mozzarella.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Pepperoni", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ005-G", "Precio": 26.0 },
      "Familiar": { "ID_SKU": "PIZ005-F", "Precio": 34.0 }
    }
  },
  "LAS001": {
    "Nombre_Base": "Lasagna Bolognesa",
    "Alias": "lasaña boloñesa, lasana bolognesa, lasaña de carne",
    "Descripcion_Plato": "Deliciosa combinación de salsa boloñesa (500GR.) elaborada con puro tomate fresco, carne de res y salsa bechamel a base de leche y queso 100% mozzarella.",
    "Categoria": "Lasagnas (lasaña)",
    "Ingredientes": ["Salsa Bolognesa", "Carne de Res", "Salsa Bechamel", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Personal": { "ID_SKU": "LAS001", "Precio": 21.0 }
    }
  },
  "LAS002": {
    "Nombre_Base": "Lasagna Alfredo",
    "Alias": "lasaña alfredo, lasana alfredo, lasaña de jamon",
    "Descripcion_Plato": "Deliciosa salsa bechamel a base de leche, el mejor jamón y queso 100% mozzarella (500GR.).",
    "Categoria": "Lasagnas (lasaña)",
    "Ingredientes": ["Salsa Bechamel", "Jamón", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Personal": { "ID_SKU": "LAS002", "Precio": 21.0 }
    }
  },
  "BEB001": {
    "Nombre_Base": "Gaseosa Pepsi",
    "Alias": "pepsi, gaseosa",
    "Descripcion_Plato": "Bebida gaseosa refrescante.",
    "Categoria": "Bebidas",
    "Ingredientes": [],
    "Disponible": "Sí",
    "Tamaños": {
      "500 ML": { "ID_SKU": "BEB001", "Precio": 2.5, "Alias": "medio litro, media litro, pequeña" },
      "1.5 LT": { "ID_SKU": "BEB002", "Precio": 5.0, "Alias": "litro y medio, grande" }
    }
  },
  "BEB002": {
    "Nombre_Base": "Agua Mineral",
    "Alias": "agua, agua sin gas, agua con gas",
    "Descripcion_Plato": "Agua mineral natural.",
    "Categoria": "Bebidas",
    "Ingredientes": [],
    "Disponible": "Sí",
    "Tamaños": {
      "500 ML": { "ID_SKU": "BEB003", "Precio": 2.0, "Alias": "botella pequeña" },
      "1 LT": { "ID_SKU": "BEB004", "Precio": 3.5, "Alias": "botella grande" }
    }
  },
  "PIZ006": {
    "Nombre_Base": "Pizza Diabla",
    "Alias": "diabla, diabolica, piza diabla, piza diabolica, picante",
    "Descripcion_Plato": "Nuestra pizza más picante, con pepperoni, jalapeños y un toque de chile.",
    "Categoria": "Pizzas",
    "Ingredientes": ["Pepperoni", "Jalapeños", "Chile", "Queso Mozzarella"],
    "Disponible": "Sí",
    "Tamaños": {
      "Grande": { "ID_SKU": "PIZ006-G", "Precio": 28.0 },
      "Familiar": { "ID_SKU": "PIZ006-F", "Precio": 36.0 }
    }
  }
}

===== data/pedidos.json =====
[
    {
        "order_id": 1,
        "customer_name": "TesterUser",
        "order_details": {
            "items": [
                {
                    "id": "PIZ003-F",
                    "name": "Pizza Hawaiana",
                    "quantity": 1,
                    "price": 34.0,
                    "size": "Familiar"
                }
            ],
            "total": 34.0
        },
        "delivery_address": "calle luna 45, ciudad del sol",
        "timestamp": "2025-07-14T02:24:51.450454"
    }
]

===== data/users.json =====
{
    "user_123": {
        "name": "hola"
    }
}

===== data_entrenamiento/Proyectos_adkaget/README - Sistema de Chatbot Multi-Agente para Restaurante.md =====
# README - Sistema de Chatbot Multi-Agente para Restaurante

## 🍕 Descripción del Proyecto

Este proyecto implementa un sistema de chatbot multi-agente para la gestión de pedidos de restaurante utilizando Google Agent Development Kit (ADK). El sistema integra múltiples agentes especializados que trabajan coordinadamente para proporcionar una experiencia completa de atención al cliente.

## 🚀 Características Principales

- **Arquitectura Multi-Agente**: Agentes especializados para menú, pedidos, registro de clientes y delivery
- **Gestión de Menú Dinámico**: Lectura de menú desde archivos CSV para fácil actualización
- **Base de Datos Integrada**: Persistencia de clientes, pedidos y direcciones
- **Procesamiento de Lenguaje Natural**: Análisis de intenciones y extracción de información
- **Flujo Completo de Pedidos**: Desde consulta hasta confirmación y entrega

## 📁 Estructura del Proyecto

```
chatbot-restaurante/
├── root_agent.py              # Agente orquestador principal
├── menu_agent.py              # Agente especializado en consultas de menú
├── order_agent.py             # Agente de gestión de pedidos
├── customer_agent.py          # Agente de registro de clientes
├── delivery_agent.py          # Agente de gestión de entregas
├── database_manager.py        # Gestor de base de datos
├── integrated_chatbot.py      # Sistema integrado completo
├── test_system.py             # Suite de pruebas
├── menu.csv                   # Datos del menú (generado automáticamente)
├── restaurant_chatbot.db      # Base de datos SQLite
└── README.md                  # Este archivo
```

## 🛠️ Instalación y Configuración

### Prerrequisitos

- Python 3.11 o superior
- pip (gestor de paquetes de Python)

### Instalación

1. **Clonar o descargar los archivos del proyecto**

2. **Crear un entorno virtual**:
```bash
python3 -m venv chatbot_env
source chatbot_env/bin/activate  # En Linux/Mac
# o
chatbot_env\Scripts\activate     # En Windows
```

3. **Instalar dependencias**:
```bash
pip install google-adk pandas
```

### Configuración (Opcional)

Para funcionalidad completa con modelos de IA, configura las credenciales de Google Cloud:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/credentials.json"
```

## 🎯 Uso del Sistema

### Ejecución del Sistema Completo

```bash
python integrated_chatbot.py
```

### Ejecución de Componentes Individuales

**Agente de Menú**:
```bash
python menu_agent.py
```

**Agente de Pedidos**:
```bash
python order_agent.py
```

**Agente de Registro**:
```bash
python customer_agent.py
```

**Agente de Delivery**:
```bash
python delivery_agent.py
```

### Pruebas del Sistema

```bash
python test_system.py
```

## 💬 Ejemplos de Interacción

### Consulta de Menú
```
Usuario: ¿Qué pizzas tienen?
Bot: Tenemos pizza margarita por $12.50, pizza pepperoni por $14.00...
```

### Registro de Cliente
```
Usuario: Soy nuevo, me llamo Juan Pérez, teléfono 123456789, email juan@email.com
Bot: ¡Bienvenido Juan! Te hemos registrado exitosamente...
```

### Realizar Pedido
```
Usuario: Quiero una pizza margarita y una coca cola
Bot: Perfecto, he agregado a tu pedido: Pizza Margarita ($12.50) y Coca Cola ($2.50)...
```

### Información de Entrega
```
Usuario: Mi dirección es Calle Principal 123, Madrid
Bot: Dirección registrada. Tiempo estimado de entrega: 30-45 minutos...
```

## 🏗️ Arquitectura del Sistema

### Agentes Especializados

1. **Agente Raíz (Root Agent)**: Orquestador principal que analiza intenciones y dirige solicitudes
2. **Agente de Menú**: Maneja consultas sobre productos, precios y disponibilidad
3. **Agente de Pedidos**: Gestiona el carrito de compras y procesamiento de pedidos
4. **Agente de Registro**: Facilita el registro de nuevos clientes
5. **Agente de Delivery**: Gestiona información de direcciones de entrega

### Base de Datos

- **Clientes**: Información personal y de contacto
- **Pedidos**: Detalles de pedidos y estado
- **Elementos de Pedido**: Productos individuales en cada pedido
- **Direcciones de Entrega**: Información de ubicación para delivery

## 🧪 Pruebas y Validación

El sistema incluye pruebas automatizadas para:

- ✅ Operaciones de base de datos
- ✅ Funcionalidad de agentes individuales
- ✅ Flujo completo de interacción
- ✅ Integración entre componentes

### Ejecutar Pruebas

```bash
python test_system.py
```

## 📊 Datos de Ejemplo

El sistema genera automáticamente un menú de ejemplo con:

- **Pizzas**: Margarita, Pepperoni
- **Hamburguesas**: Clásica
- **Ensaladas**: César
- **Pastas**: Carbonara
- **Bebidas**: Coca Cola, Agua Mineral
- **Postres**: Tiramisu, Helado de Vainilla

## 🔧 Personalización

### Modificar el Menú

Edita el archivo `menu.csv` con las siguientes columnas:
- ID_Producto
- Nombre_Producto
- Descripción
- Precio
- Categoría
- Disponibilidad

### Agregar Nuevos Agentes

1. Crea una nueva clase que herede de las clases base de ADK
2. Implementa la lógica específica del dominio
3. Integra el agente en `integrated_chatbot.py`

### Configurar Base de Datos

Modifica `database_manager.py` para cambiar el esquema o tipo de base de datos.

## 🚨 Limitaciones Conocidas

- Requiere credenciales de Google Cloud para funcionalidad completa de IA
- Base de datos SQLite limitada para uso en producción
- Análisis de intenciones basado en palabras clave (no ML avanzado)
- Sin interfaz gráfica de usuario

## 🔮 Mejoras Futuras

- [ ] Interfaz web interactiva
- [ ] Integración con sistemas de pago
- [ ] Análisis avanzado de datos y reportes
- [ ] Soporte para múltiples idiomas
- [ ] Integración con APIs de delivery
- [ ] Sistema de notificaciones en tiempo real

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia Apache 2.0.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Soporte

Para preguntas o problemas:

1. Revisa la documentación en `proyecto_final_documentacion.md`
2. Ejecuta las pruebas para verificar la configuración
3. Consulta los logs de error para diagnóstico

## 🙏 Agradecimientos

- Google por el Agent Development Kit (ADK)
- Comunidad de Python por las librerías utilizadas
- Contribuidores y testers del proyecto

---

**Desarrollado con ❤️ usando Google ADK y Python**


===== data_entrenamiento/Proyectos_adkaget/Sistema de Chatbot Multi-Agente para Restaurante.md =====
# Sistema de Chatbot Multi-Agente para Restaurante

**Autor:** Manus AI  
**Fecha:** 12 de Junio, 2025  
**Versión:** 1.0

## Resumen Ejecutivo

Este documento presenta el desarrollo completo de un sistema de chatbot multi-agente para la gestión de pedidos de restaurante, implementado utilizando la librería Google Agent Development Kit (ADK) para Python. El sistema integra múltiples agentes especializados que trabajan de manera coordinada para proporcionar una experiencia completa de atención al cliente, desde la consulta del menú hasta la confirmación y entrega de pedidos.

El proyecto abarca desde la investigación inicial de la tecnología ADK hasta la implementación de un sistema funcional que incluye registro de clientes, gestión de menús dinámicos, procesamiento de pedidos y coordinación de entregas. La arquitectura multi-agente permite una escalabilidad y mantenibilidad superiores comparadas con sistemas monolíticos tradicionales.

## 1. Introducción

### 1.1 Contexto del Proyecto

La industria de la restauración ha experimentado una transformación digital acelerada, especialmente en los últimos años. Los sistemas de pedidos automatizados se han convertido en una necesidad fundamental para mantener la competitividad y satisfacer las expectativas de los clientes modernos. En este contexto, los chatbots inteligentes representan una solución eficaz para automatizar la atención al cliente mientras se mantiene un nivel de servicio personalizado.

El desarrollo de sistemas de chatbot tradicionalmente ha enfrentado desafíos relacionados con la complejidad de manejar múltiples tipos de consultas, la integración con sistemas de backend y la escalabilidad del código. Los enfoques monolíticos tienden a volverse difíciles de mantener a medida que crecen en funcionalidad, mientras que los sistemas distribuidos pueden introducir complejidades de coordinación.

### 1.2 Objetivos del Proyecto

El objetivo principal de este proyecto es desarrollar un sistema de chatbot multi-agente que demuestre las capacidades de la librería Google ADK para crear soluciones modulares y escalables. Los objetivos específicos incluyen:

**Objetivos Técnicos:**
- Implementar una arquitectura multi-agente utilizando Google ADK
- Desarrollar agentes especializados para diferentes aspectos del negocio
- Integrar el sistema con bases de datos relacionales
- Crear un sistema de gestión de menús dinámico basado en hojas de cálculo
- Implementar un flujo completo de pedidos desde la consulta hasta la confirmación

**Objetivos Funcionales:**
- Proporcionar atención automatizada para consultas de menú
- Facilitar el registro de nuevos clientes
- Gestionar pedidos de manera eficiente
- Coordinar información de entrega
- Mantener persistencia de datos para seguimiento de pedidos

**Objetivos de Negocio:**
- Reducir la carga de trabajo del personal de atención al cliente
- Mejorar la experiencia del usuario mediante respuestas rápidas y precisas
- Facilitar la escalabilidad del negocio
- Proporcionar datos estructurados para análisis de negocio

### 1.3 Alcance del Documento

Este documento proporciona una descripción completa del proceso de desarrollo, desde la investigación inicial hasta la implementación final. Incluye análisis técnico de la librería ADK, diseño de la arquitectura del sistema, detalles de implementación, resultados de pruebas y recomendaciones para futuras mejoras.

El documento está dirigido a desarrolladores, arquitectos de software y tomadores de decisiones técnicas que busquen comprender tanto las capacidades de Google ADK como los patrones de diseño para sistemas multi-agente en aplicaciones comerciales.

## 2. Investigación y Análisis de Google ADK

### 2.1 Introducción a Google Agent Development Kit

Google Agent Development Kit (ADK) representa un avance significativo en el desarrollo de sistemas de agentes de inteligencia artificial. Lanzado como una herramienta de código abierto, ADK está diseñado para hacer que el desarrollo de agentes se sienta más como el desarrollo de software tradicional, proporcionando un framework flexible y modular para crear, desplegar y orquestar arquitecturas de agentes que van desde tareas simples hasta flujos de trabajo complejos.

La filosofía de diseño de ADK se centra en varios principios fundamentales. Primero, la flexibilidad: aunque está optimizado para Gemini y el ecosistema de Google, ADK es agnóstico al modelo y al despliegue, permitiendo integración con otros frameworks y modelos de IA. Segundo, la modularidad: el framework permite la composición de múltiples agentes especializados en jerarquías complejas, facilitando la separación de responsabilidades y la reutilización de código.

### 2.2 Arquitectura y Componentes Principales

La arquitectura de ADK se basa en varios componentes clave que trabajan en conjunto para proporcionar un entorno de desarrollo robusto para agentes de IA.

**Agentes (Agents):** En ADK, un agente es una unidad de ejecución autocontenida diseñada para actuar de forma autónoma para lograr objetivos específicos. Los agentes pueden realizar tareas, tomar decisiones y comunicarse con otros agentes. La clase base `Agent` proporciona la funcionalidad fundamental, mientras que especializaciones como `LlmAgent` ofrecen capacidades específicas para modelos de lenguaje.

**Herramientas (Tools):** Las herramientas representan las capacidades que un agente puede utilizar para interactuar con el mundo exterior. ADK incluye herramientas preconstruidas como búsqueda web y ejecución de código, pero también permite la creación de herramientas personalizadas y la integración con bibliotecas de terceros como LangChain y CrewAI.

**Sesiones (Sessions):** Las sesiones proporcionan un contexto persistente para las interacciones con los agentes. Permiten mantener el estado de la conversación a través de múltiples intercambios y facilitan la gestión de memoria y contexto.

**Orquestación:** ADK ofrece múltiples patrones de orquestación, desde flujos de trabajo predecibles usando agentes de flujo de trabajo (`Sequential`, `Parallel`, `Loop`) hasta enrutamiento dinámico impulsado por LLM para comportamiento adaptativo.

### 2.3 Ventajas de la Arquitectura Multi-Agente

La adopción de una arquitectura multi-agente en ADK ofrece ventajas significativas sobre enfoques monolíticos tradicionales.

**Separación de Responsabilidades:** Cada agente puede especializarse en un dominio específico del problema, lo que resulta en código más limpio, mantenible y testeable. En el contexto de un restaurante, por ejemplo, un agente puede especializarse en consultas de menú mientras otro se enfoca en procesamiento de pedidos.

**Escalabilidad:** Los agentes individuales pueden ser desarrollados, desplegados y escalados de forma independiente. Esto permite optimizar recursos según las demandas específicas de cada funcionalidad.

**Reutilización:** Los agentes especializados pueden ser reutilizados en diferentes contextos y aplicaciones, reduciendo el tiempo de desarrollo para nuevos proyectos.

**Tolerancia a Fallos:** Si un agente específico falla, otros agentes pueden continuar funcionando, proporcionando degradación elegante del servicio.

**Facilidad de Mantenimiento:** Los cambios en la lógica de un dominio específico solo requieren modificaciones en el agente correspondiente, reduciendo el riesgo de efectos secundarios no deseados.

### 2.4 Instalación y Configuración

La instalación de Google ADK es straightforward y sigue las mejores prácticas de Python para gestión de dependencias. El paquete está disponible en PyPI y puede instalarse usando pip:

```bash
pip install google-adk
```

Para proyectos en desarrollo, también es posible instalar directamente desde el repositorio de GitHub para acceder a las características más recientes:

```bash
pip install git+https://github.com/google/adk-python.git@main
```

La configuración inicial requiere la creación de sesiones con parámetros específicos. Una sesión típica requiere un identificador único, el nombre de la aplicación y un identificador de usuario:

```python
from google.adk.sessions import Session

session = Session(
    id="unique_session_id",
    appName="application_name",
    userId="user_identifier"
)
```

### 2.5 Patrones de Diseño en ADK

ADK promueve varios patrones de diseño que facilitan el desarrollo de sistemas robustos y escalables.

**Patrón de Agente Coordinador:** Un agente principal actúa como coordinador, dirigiendo las solicitudes a agentes especializados basándose en el análisis de intención. Este patrón es particularmente útil para sistemas con múltiples dominios de funcionalidad.

**Patrón de Pipeline:** Los agentes pueden organizarse en pipelines donde la salida de un agente se convierte en la entrada del siguiente. Esto es útil para procesos que requieren múltiples etapas de procesamiento.

**Patrón de Delegación Jerárquica:** Los agentes pueden tener sub-agentes que manejan aspectos específicos de su responsabilidad, creando jerarquías naturales que reflejan la estructura del dominio del problema.

## 3. Diseño del Sistema

### 3.1 Análisis de Requerimientos

El desarrollo del sistema de chatbot para restaurante comenzó con un análisis exhaustivo de los requerimientos funcionales y no funcionales.

**Requerimientos Funcionales Principales:**

El sistema debe ser capaz de manejar interacciones conversacionales naturales con clientes, proporcionando respuestas apropiadas a consultas sobre el menú del restaurante. Esto incluye la capacidad de responder preguntas sobre productos disponibles, precios, descripciones detalladas de platos, categorías de comida y disponibilidad en tiempo real.

La funcionalidad de registro de clientes debe guiar a los usuarios nuevos a través de un proceso de captura de información que incluya datos personales básicos como nombre completo, número de teléfono y dirección de correo electrónico. El sistema debe validar esta información y manejar casos de duplicación de manera elegante.

El procesamiento de pedidos debe permitir a los clientes agregar elementos a su carrito, modificar cantidades, revisar su pedido y confirmar la compra. El sistema debe mantener el estado del pedido a lo largo de la conversación y proporcionar confirmaciones claras en cada paso.

La gestión de información de entrega debe capturar direcciones completas, incluyendo referencias adicionales que faciliten la localización. El sistema debe validar la completitud de la información y proporcionar estimaciones de tiempo de entrega.

**Requerimientos No Funcionales:**

El sistema debe ser escalable para manejar múltiples conversaciones simultáneas sin degradación del rendimiento. La arquitectura debe permitir la adición de nuevos agentes especializados sin modificar el código existente.

La persistencia de datos debe garantizar que la información de clientes, pedidos y direcciones se mantenga de manera segura y esté disponible para consultas futuras. El sistema debe manejar fallos de manera elegante, proporcionando mensajes de error informativos sin exponer detalles técnicos internos.

La modularidad del código debe facilitar el mantenimiento y la extensión del sistema. Cada componente debe tener responsabilidades claramente definidas y interfaces bien documentadas.

### 3.2 Arquitectura del Sistema

La arquitectura del sistema se diseñó siguiendo principios de separación de responsabilidades y modularidad, aprovechando las capacidades de ADK para crear un sistema multi-agente cohesivo.

**Componente Central - Agente Raíz:**

El Agente Raíz actúa como el punto de entrada principal para todas las interacciones del cliente. Su responsabilidad principal es analizar las intenciones de los mensajes entrantes y dirigir las solicitudes al agente especializado apropiado. Este agente mantiene el contexto global de la conversación y gestiona las transiciones entre diferentes agentes especializados.

El análisis de intención se basa en el procesamiento de lenguaje natural para identificar palabras clave y patrones que indican el tipo de solicitud del usuario. Por ejemplo, palabras como "menú", "carta", "precios" indican una consulta de menú, mientras que "pedido", "quiero", "ordenar" sugieren una intención de realizar un pedido.

**Agentes Especializados:**

El Agente de Menú se especializa en responder consultas relacionadas con los productos del restaurante. Tiene acceso directo a los datos del menú almacenados en formato CSV y puede realizar búsquedas, filtros y proporcionar información detallada sobre productos específicos. Este agente también maneja la lógica de disponibilidad de productos y puede sugerir alternativas cuando un elemento no está disponible.

El Agente de Pedidos gestiona todo el ciclo de vida de un pedido, desde la adición inicial de elementos hasta la confirmación final. Mantiene el estado del carrito de compras, calcula totales, maneja modificaciones de cantidad y proporciona resúmenes detallados del pedido. Este agente colabora estrechamente con el Agente de Menú para validar productos y precios.

El Agente de Registro de Clientes guía a los usuarios nuevos a través del proceso de registro, solicitando y validando información personal. Implementa lógica de validación para formatos de email y teléfono, y maneja la detección de información duplicada. Una vez completado el registro, este agente coordina con el sistema de base de datos para persistir la información del cliente.

El Agente de Delivery se especializa en la captura y validación de información de entrega. Utiliza técnicas de procesamiento de texto para extraer componentes de direcciones de mensajes en lenguaje natural y valida la completitud de la información. También proporciona estimaciones de tiempo de entrega basadas en la ubicación.

**Capa de Persistencia:**

El Gestor de Base de Datos proporciona una abstracción sobre las operaciones de base de datos, implementando un patrón de repositorio que aísla la lógica de negocio de los detalles de persistencia. Utiliza SQLite para desarrollo y pruebas, pero está diseñado para ser fácilmente migrable a sistemas de base de datos más robustos como PostgreSQL para producción.

La base de datos incluye tablas para clientes, pedidos, elementos de pedido y direcciones de entrega, con relaciones apropiadas para mantener la integridad referencial. El diseño de esquema sigue principios de normalización para evitar redundancia de datos mientras mantiene eficiencia en las consultas.

### 3.3 Flujo de Interacción

El flujo de interacción del sistema está diseñado para proporcionar una experiencia natural y eficiente para el usuario.

**Fase de Saludo e Identificación:**

Cuando un usuario inicia una conversación, el Agente Raíz proporciona un saludo amigable y presenta las opciones disponibles. Si el usuario es nuevo, el sistema lo guía hacia el proceso de registro. Si es un cliente existente, puede proceder directamente con consultas de menú o pedidos.

**Fase de Consulta de Menú:**

Durante las consultas de menú, el Agente de Menú proporciona información detallada sobre productos, incluyendo descripciones, precios y disponibilidad. El agente puede manejar consultas específicas ("¿cuánto cuesta la pizza margarita?") así como consultas generales ("¿qué pizzas tienen?").

**Fase de Construcción de Pedido:**

El proceso de pedido permite a los usuarios agregar elementos de manera conversacional. El Agente de Pedidos mantiene un resumen actualizado del carrito y proporciona confirmaciones después de cada adición. Los usuarios pueden modificar cantidades o eliminar elementos usando lenguaje natural.

**Fase de Información de Entrega:**

Una vez que el pedido está completo, el Agente de Delivery solicita información de entrega. Puede extraer direcciones de mensajes en formato libre y solicitar aclaraciones para información faltante o ambigua.

**Fase de Confirmación:**

La confirmación final incluye un resumen completo del pedido, información del cliente, dirección de entrega y tiempo estimado de entrega. Una vez confirmado, el pedido se registra en la base de datos y se asigna un número de seguimiento.

### 3.4 Gestión de Estado y Contexto

La gestión de estado es crucial para mantener la coherencia a lo largo de conversaciones multi-turno. El sistema implementa varios niveles de estado:

**Estado de Sesión:** Cada sesión mantiene información sobre el usuario actual, el agente activo y el estado general de la conversación. Esto permite al sistema recordar el contexto incluso cuando la conversación se transfiere entre diferentes agentes.

**Estado de Agente:** Cada agente especializado mantiene su propio estado relacionado con su dominio específico. Por ejemplo, el Agente de Pedidos mantiene el estado del carrito actual, mientras que el Agente de Registro mantiene el progreso del proceso de registro.

**Estado Persistente:** La información crítica como datos de clientes, pedidos confirmados y direcciones se persiste en la base de datos para acceso futuro y análisis.

## 4. Implementación

### 4.1 Desarrollo del Agente Raíz

La implementación del Agente Raíz comenzó con la definición de la clase `RootAgent` que encapsula la lógica de orquestación principal. Este agente utiliza la clase `LlmAgent` de ADK como base, configurada con instrucciones específicas que definen su rol como coordinador.

```python
self.agent = LlmAgent(
    name="root_agent",
    model="gemini-2.0-flash",
    instruction="""
    Eres el agente principal de un sistema de chatbot para un restaurante.
    Tu función es orquestar las interacciones con los clientes y dirigir
    las solicitudes a los agentes especializados apropiados.
    """,
    description="Agente orquestador principal del sistema de pedidos",
)
```

La lógica de análisis de intención se implementó usando técnicas de procesamiento de texto basadas en palabras clave. Aunque este enfoque es más simple que técnicas avanzadas de NLP, proporciona resultados efectivos para el dominio específico del restaurante y es fácil de mantener y extender.

El método `_analyze_intention` examina el mensaje del usuario en busca de patrones específicos que indican diferentes tipos de solicitudes. La implementación utiliza listas de palabras clave organizadas por categoría de intención, permitiendo una clasificación rápida y precisa de la mayoría de las consultas de usuarios.

### 4.2 Implementación de Agentes Especializados

**Agente de Menú:**

El Agente de Menú se implementó con capacidades de lectura y procesamiento de datos de menú desde archivos CSV. La elección de CSV como formato de almacenamiento facilita la actualización del menú por parte del personal del restaurante sin requerir conocimientos técnicos.

La clase `MenuAgent` incluye funcionalidad para cargar datos del menú, crear un menú de ejemplo si no existe un archivo, y proporcionar búsquedas y filtros sobre los datos del menú. El agente puede responder tanto a consultas específicas sobre productos individuales como a consultas generales sobre categorías de productos.

```python
def get_menu_summary(self) -> str:
    """Obtiene un resumen del menú para el contexto del agente"""
    summary = "MENÚ DISPONIBLE:\n"
    for category in self.menu_data['Categoría'].unique():
        summary += f"\n{category.upper()}:\n"
        category_items = self.menu_data[self.menu_data['Categoría'] == category]
        for _, item in category_items.iterrows():
            availability = "✓" if item['Disponibilidad'] == 'Sí' else "✗"
            summary += f"  {availability} {item['Nombre_Producto']} - ${item['Precio']:.2f}\n"
    return summary
```

**Agente de Pedidos:**

La implementación del Agente de Pedidos incluye un sistema de gestión de carrito de compras en memoria que mantiene el estado del pedido durante la sesión. El agente puede agregar elementos, modificar cantidades, calcular totales y proporcionar resúmenes detallados.

La estructura de datos del pedido se diseñó para ser simple pero completa, incluyendo información sobre cada elemento (nombre, cantidad, precio unitario, subtotal) y metadatos del pedido (cliente, total, estado, timestamps).

**Agente de Registro de Clientes:**

El Agente de Registro implementa lógica de extracción de información usando expresiones regulares para identificar emails, números de teléfono y nombres en mensajes de texto libre. Esta aproximación permite a los usuarios proporcionar su información de manera natural sin seguir un formato específico.

La validación de datos incluye verificación de formato de email usando patrones regex estándar y validación de números de teléfono basada en longitud y contenido numérico. El agente también maneja la detección de información incompleta y solicita aclaraciones cuando es necesario.

**Agente de Delivery:**

La implementación del Agente de Delivery incluye lógica sofisticada de extracción de direcciones que puede manejar múltiples formatos de entrada. El agente utiliza expresiones regulares para identificar componentes de direcciones como calles, números, ciudades y códigos postales.

```python
def extract_address_info(self, message: str) -> dict:
    """Extrae información de dirección del mensaje"""
    info = {}
    
    # Buscar código postal (4-6 dígitos)
    postal_pattern = r'\b\d{4,6}\b'
    postal_match = re.search(postal_pattern, message)
    if postal_match:
        info['codigo_postal'] = postal_match.group()
    
    # Buscar patrones de calle y número
    street_number_pattern = r'\b(\d+)\s*(?:calle|avenida|av)\s+([a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+)'
    street_match = re.search(street_number_pattern, message, re.IGNORECASE)
    if street_match:
        info['numero'] = street_match.group(1)
        info['calle'] = street_match.group(2).strip()
    
    return info
```

### 4.3 Integración con Base de Datos

La capa de persistencia se implementó usando SQLite para simplicidad en desarrollo y pruebas, con un diseño que facilita la migración a sistemas de base de datos más robustos para producción.

El esquema de base de datos incluye cuatro tablas principales: `customers` para información de clientes, `delivery_addresses` para direcciones de entrega, `orders` para pedidos y `order_items` para elementos individuales de pedidos. Las relaciones entre tablas se establecieron usando claves foráneas para mantener integridad referencial.

```sql
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

La clase `DatabaseManager` proporciona una interfaz de alto nivel para todas las operaciones de base de datos, implementando métodos para registro de clientes, creación de pedidos, gestión de direcciones y consultas de datos. Esta abstracción permite cambiar la implementación de base de datos sin afectar la lógica de negocio de los agentes.

### 4.4 Sistema Integrado

La integración de todos los componentes se realizó a través de la clase `IntegratedChatbotSystem` que actúa como fachada para el sistema completo. Esta clase coordina las interacciones entre agentes, gestiona el estado de sesiones y proporciona una interfaz unificada para el procesamiento de mensajes.

El sistema integrado implementa lógica de coordinación que determina cuándo transferir control entre agentes y cómo mantener el contexto durante estas transferencias. También maneja la persistencia automática de datos cuando se completan procesos como registro de clientes o confirmación de pedidos.

```python
def process_message(self, message: str, session: Session) -> str:
    """Procesa un mensaje del usuario y coordina la respuesta entre agentes"""
    session_id = session.id
    intention = self.analyze_message_intention(message)
    
    if intention == "menu_inquiry":
        return self._handle_menu_inquiry(message, session)
    elif intention == "place_order":
        return self._handle_order_request(message, session)
    # ... más lógica de enrutamiento
```

## 5. Resultados y Evaluación

### 5.1 Pruebas del Sistema

La evaluación del sistema se realizó a través de un conjunto comprensivo de pruebas que validaron tanto componentes individuales como el flujo completo de interacción.

**Pruebas de Componentes Individuales:**

Las pruebas de la capa de base de datos validaron todas las operaciones CRUD (Create, Read, Update, Delete) para cada entidad del sistema. Estas pruebas confirmaron que el registro de clientes, creación de pedidos, gestión de direcciones y consultas de datos funcionan correctamente. Los resultados mostraron que todas las operaciones de base de datos se ejecutan sin errores y mantienen la integridad de los datos.

Las pruebas de agentes individuales validaron que cada agente especializado puede procesar solicitudes dentro de su dominio. Sin embargo, se identificaron limitaciones en la integración con el modelo de lenguaje Gemini, que requiere configuración de credenciales de Google Cloud para funcionar completamente.

**Pruebas de Integración:**

Las pruebas del sistema integrado evaluaron el flujo completo de interacción desde el saludo inicial hasta la confirmación de pedidos. Los resultados mostraron que el sistema puede manejar conversaciones básicas y dirigir solicitudes a los agentes apropiados, aunque con limitaciones en la funcionalidad de los agentes que dependen del modelo de lenguaje.

**Resultados de Pruebas:**

De las cuatro categorías principales de pruebas ejecutadas, tres pasaron exitosamente:
- ✅ Operaciones de Base de Datos: PASÓ
- ✅ Consultas de Menú: PASÓ (con limitaciones)
- ❌ Registro de Clientes: FALLÓ (debido a configuración de modelo)
- ✅ Flujo de Pedido: PASÓ (con limitaciones)

### 5.2 Análisis de Limitaciones

**Dependencia de Credenciales de Google Cloud:**

La principal limitación identificada es la dependencia de credenciales válidas de Google Cloud para el funcionamiento completo de los agentes basados en LLM. Sin estas credenciales, los agentes pueden inicializarse pero no pueden procesar solicitudes que requieren capacidades de lenguaje natural avanzadas.

**Manejo de Errores:**

El sistema actual implementa manejo básico de errores, pero podría beneficiarse de estrategias más sofisticadas para degradación elegante cuando los servicios de IA no están disponibles.

**Escalabilidad de Estado:**

El almacenamiento de estado en memoria funciona para pruebas y desarrollo, pero requeriría migración a soluciones de almacenamiento distribuido para entornos de producción con múltiples instancias.

### 5.3 Métricas de Rendimiento

**Tiempo de Respuesta:**

En las pruebas locales, el sistema demostró tiempos de respuesta rápidos para operaciones que no requieren procesamiento de LLM. Las operaciones de base de datos se completaron en menos de 100ms, y la lógica de enrutamiento de agentes se ejecutó instantáneamente.

**Uso de Memoria:**

El sistema mantiene un footprint de memoria razonable, con el estado de sesión y datos de menú ocupando menos de 10MB para configuraciones típicas de restaurante.

**Throughput:**

Las pruebas de carga básicas indicaron que el sistema puede manejar múltiples sesiones concurrentes sin degradación significativa del rendimiento, limitado principalmente por la capacidad de la base de datos SQLite.

## 6. Conclusiones y Recomendaciones

### 6.1 Logros del Proyecto

El proyecto logró exitosamente demostrar las capacidades de Google ADK para crear sistemas multi-agente modulares y escalables. La arquitectura desarrollada proporciona una base sólida para sistemas de chatbot comerciales, con separación clara de responsabilidades y facilidad de extensión.

La implementación de la capa de persistencia y la integración con datos de menú dinámicos demuestran cómo los sistemas basados en ADK pueden integrarse con infraestructura empresarial existente. El diseño modular facilita el mantenimiento y permite la adición de nuevas funcionalidades sin modificar código existente.

### 6.2 Lecciones Aprendidas

**Importancia de la Configuración del Entorno:**

El desarrollo con ADK requiere configuración cuidadosa del entorno, especialmente para credenciales de Google Cloud. Los proyectos futuros deberían incluir documentación detallada de configuración y scripts de automatización para simplificar el setup inicial.

**Valor de la Arquitectura Multi-Agente:**

La separación de funcionalidades en agentes especializados demostró ventajas claras en términos de mantenibilidad y testabilidad. Cada agente puede desarrollarse y probarse independientemente, facilitando el desarrollo en equipo y la depuración.

**Necesidad de Estrategias de Fallback:**

Los sistemas que dependen de servicios externos de IA requieren estrategias robustas de fallback para mantener funcionalidad básica cuando estos servicios no están disponibles.

### 6.3 Recomendaciones para Futuras Mejoras

**Implementación de Autenticación y Autorización:**

Para despliegue en producción, el sistema requiere implementación de autenticación de usuarios y autorización basada en roles para proteger datos sensibles de clientes.

**Integración con Sistemas de Pago:**

La adición de capacidades de procesamiento de pagos convertiría el sistema en una solución completa de e-commerce para restaurantes.

**Análisis y Reportes:**

La implementación de capacidades de análisis de datos permitiría a los restaurantes obtener insights sobre patrones de pedidos, productos populares y comportamiento de clientes.

**Interfaz de Usuario Web:**

Aunque el sistema actual funciona a través de interfaz de texto, una interfaz web proporcionaría una experiencia de usuario más rica y accesible.

**Integración con Sistemas de Gestión de Restaurantes:**

La integración con sistemas POS (Point of Sale) y de gestión de inventario existentes proporcionaría una solución más completa para operaciones de restaurante.

### 6.4 Consideraciones de Despliegue

**Infraestructura de Producción:**

Para despliegue en producción, se recomienda migrar de SQLite a PostgreSQL o MySQL para mejor rendimiento y capacidades de concurrencia. La implementación de Redis para gestión de sesiones mejoraría la escalabilidad horizontal.

**Monitoreo y Logging:**

La implementación de sistemas de monitoreo y logging detallado es crucial para mantener la calidad del servicio en producción y facilitar la depuración de problemas.

**Seguridad:**

Las consideraciones de seguridad incluyen encriptación de datos sensibles, validación robusta de entrada, y implementación de rate limiting para prevenir abuso del sistema.

### 6.5 Impacto Potencial

El sistema desarrollado demuestra el potencial de las tecnologías de IA conversacional para transformar la industria de servicios. La automatización de tareas rutinarias como toma de pedidos y registro de clientes puede liberar al personal humano para enfocarse en aspectos más valiosos del servicio al cliente.

La arquitectura modular y escalable proporciona una base para expansión a otros dominios de negocio más allá de restaurantes, incluyendo retail, servicios de salud y educación.

## 7. Referencias y Recursos

[1] Google Agent Development Kit Documentation - https://google.github.io/adk-docs/

[2] Google ADK Python Repository - https://github.com/google/adk-python

[3] Agent Development Kit Samples - https://github.com/google/adk-samples

[4] Google Cloud AI Platform Documentation - https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit/quickstart

[5] Multi-Agent Systems: A Modern Approach to Distributed Artificial Intelligence - Gerhard Weiss

[6] Building Chatbots with Python: Using Natural Language Processing and Machine Learning - Sumit Raj

[7] Microservices Patterns: With Examples in Java - Chris Richardson

[8] Database Design for Mere Mortals: A Hands-On Guide to Relational Database Design - Michael J. Hernandez

---

**Nota:** Este documento representa el estado del proyecto al 12 de Junio de 2025. Las tecnologías y mejores prácticas pueden evolucionar, y se recomienda consultar la documentación más reciente de Google ADK para implementaciones futuras.


===== data_entrenamiento/Proyectos_adkaget/adk_research.md =====
# Investigación y aprendizaje de adk google agents

## ¿Qué es el Agent Development Kit (ADK)?

El Agent Development Kit (ADK) es un framework flexible y modular para el desarrollo y despliegue de agentes de IA. Está optimizado para Gemini y el ecosistema de Google, pero es agnóstico al modelo y al despliegue, y está construido para ser compatible con otros frameworks. ADK fue diseñado para que el desarrollo de agentes se parezca más al desarrollo de software, facilitando a los desarrolladores la creación, el despliegue y la orquestación de arquitecturas de agentes que van desde tareas simples hasta flujos de trabajo complejos.

### Características clave:

*   **Orquestación flexible:** Define flujos de trabajo utilizando agentes de flujo de trabajo (`Sequential`, `Parallel`, `Loop`) para pipelines predecibles, o aprovecha el enrutamiento dinámico impulsado por LLM (`LlmAgent` transfer) para un comportamiento adaptativo.
*   **Arquitectura multi-agente:** Construye aplicaciones modulares y escalables componiendo múltiples agentes especializados en una jerarquía. Permite una coordinación y delegación complejas.
*   **Ecosistema de herramientas enriquecido:** Equipa a los agentes con diversas capacidades: utiliza herramientas preconstruidas (Búsqueda, Ejecución de código), crea funciones personalizadas, integra bibliotecas de terceros (LangChain, CrewAI), o incluso utiliza otros agentes como herramientas.
*   **Listo para el despliegue:** Conteneriza y despliega tus agentes en cualquier lugar: ejecútalos localmente, escala con Vertex AI Agent Engine, o intégralos en una infraestructura personalizada utilizando Cloud Run o Docker.
*   **Evaluación incorporada:** Evalúa sistemáticamente el rendimiento del agente evaluando tanto la calidad de la respuesta final como la trayectoria de ejecución paso a paso contra casos de prueba predefinidos.
*   **Construcción de agentes seguros:** Aprende a construir agentes potentes y confiables implementando patrones y mejores prácticas de seguridad en el diseño de tu agente.




## Instalación de ADK Google Agents (Python)

La versión estable más reciente de ADK se puede instalar usando `pip`:

```bash
pip install google-adk
```

La cadencia de lanzamiento es semanal. Esta versión se recomienda para la mayoría de los usuarios, ya que representa la versión oficial más reciente.

Si necesitas acceder a cambios que aún no se han incluido en una versión oficial de PyPI, puedes instalar directamente desde la rama principal:

```bash
pip install git+https://github.com/google/adk-python.git@main
```

**Nota:** La versión de desarrollo se construye directamente a partir de los últimos commits de código. Si bien incluye las correcciones y características más recientes, también puede contener cambios experimentales o errores no presentes en la versión estable. Úsala principalmente para probar los próximos cambios o acceder a correcciones críticas antes de su lanzamiento oficial.

## Conceptos clave de ADK

### Agentes

En el Agent Development Kit (ADK), un Agente es una unidad de ejecución autocontenida diseñada para actuar de forma autónoma para lograr objetivos específicos. Los agentes pueden realizar tareas, tomar decisiones y comunicarse con otros agentes.

### Herramientas

Las herramientas son las capacidades que un agente puede utilizar para interactuar con el mundo exterior. Pueden ser funciones preconstruidas (como la búsqueda web), funciones personalizadas o integraciones con bibliotecas de terceros.

### Orquestación Multi-Agente

ADK permite construir sistemas multi-agente modulares y escalables, donde múltiples agentes especializados trabajan juntos en una jerarquía para lograr tareas complejas. Esto permite una coordinación y delegación complejas.

### Ejemplo de Agente Raíz (Root Agent)

Un agente raíz puede orquestar otros agentes. Por ejemplo, un `LlmAgent` puede tener `sub_agents` que se encargan de tareas específicas.

```python
from google.adk.agents import Agent
from google.adk.tools import google_search

root_agent = Agent(
    name="search_assistant",
    model="gemini-2.0-flash", # O tu modelo Gemini preferido
    instruction="You are a helpful assistant. Answer user questions using Google Search when needed.",
    description="An assistant that can search the web.",
    tools=[google_search]
)
```

### Ejemplo de Sistema Multi-Agente

```python
from google.adk.agents import LlmAgent, BaseAgent

# Define agentes individuales
greeter = LlmAgent(name="greeter", model="gemini-2.0-flash", ...)
task_executor = LlmAgent(name="task_executor", model="gemini-2.0-flash", ...)

# Crea el agente padre y asigna los hijos a través de sub_agents
coordinator = LlmAgent(
    name="Coordinator",
    model="gemini-2.0-flash",
    description="I coordinate greetings and tasks.",
    sub_agents=[ # Asigna sub_agents aquí
        greeter,
        task_executor
    ]
)
```

## Próximos pasos

Ahora que tengo una comprensión básica de la librería ADK, procederé a la fase de análisis de requerimientos y diseño del sistema para el chatbot.


===== data_entrenamiento/Proyectos_adkaget/chatbot_design.md =====
# Análisis de Requerimientos y Diseño del Sistema para Chatbot de Pedidos

## 1. Requerimientos Funcionales

El chatbot de IA para la gestión de pedidos de restaurante deberá cumplir con las siguientes funcionalidades:

### 1.1. Interacción con el Cliente

*   **Atención de Pedidos:** El chatbot debe ser capaz de recibir y procesar pedidos de los clientes de manera conversacional.
*   **Orientación sobre el Menú:** El chatbot debe poder responder preguntas sobre los elementos del menú, incluyendo descripciones, ingredientes, precios y disponibilidad.
*   **Registro de Clientes Nuevos:** Para clientes que interactúan por primera vez, el chatbot debe guiarlos a través de un proceso de registro que capture la información necesaria para futuras interacciones y entregas.
*   **Confirmación de Pedidos:** Una vez que un pedido esté completo, el chatbot debe confirmar los detalles con el cliente antes de finalizarlo.
*   **Información de Entrega:** El chatbot debe solicitar y registrar la dirección de entrega para los pedidos a domicilio.

### 1.2. Gestión Interna

*   **Registro de Pedidos en Base de Datos:** Todos los pedidos confirmados deben ser registrados en una base de datos, incluyendo los detalles del cliente, los artículos del pedido, la dirección de entrega y el estado del pedido.
*   **Lectura del Menú desde Hoja de Cálculo:** El menú del restaurante (productos, descripciones, precios) debe ser leído dinámicamente desde una hoja de cálculo (por ejemplo, Google Sheets o un archivo Excel) para facilitar su actualización por parte del personal del restaurante.
*   **Sistema Multi-Agente:** El sistema debe estar diseñado con una arquitectura multi-agente, orquestada por un agente raíz (Root Agent), para manejar las diferentes funcionalidades de manera modular y escalable.

## 2. Diseño del Sistema Multi-Agente

El sistema se compondrá de varios agentes especializados, orquestados por un Agente Raíz. A continuación, se detalla la función de cada agente:

### 2.1. Agente Raíz (Root Agent)

El Agente Raíz será el punto de entrada principal para todas las interacciones del cliente. Su función principal será:

*   **Orquestación:** Dirigir las solicitudes del cliente al agente especializado adecuado basándose en la intención del usuario.
*   **Gestión del Flujo Conversacional:** Mantener el contexto de la conversación y asegurar una transición fluida entre los diferentes agentes.
*   **Manejo de Errores:** Gestionar situaciones inesperadas o solicitudes que no puedan ser manejadas por los agentes especializados.

### 2.2. Agentes Especializados

Se proponen los siguientes agentes especializados:

*   **Agente de Menú (Menu Agent):**
    *   **Función:** Responder preguntas sobre el menú, proporcionar descripciones de platos, precios y disponibilidad.
    *   **Interacción:** Consultará la hoja de cálculo del menú para obtener la información más reciente.

*   **Agente de Pedidos (Order Agent):**
    *   **Función:** Procesar los pedidos de los clientes, añadir artículos al carrito, modificar cantidades y confirmar el pedido final.
    *   **Interacción:** Colaborará con el Agente de Menú para validar los artículos y con el Agente de Base de Datos para registrar el pedido.

*   **Agente de Registro de Clientes (Customer Registration Agent):**
    *   **Función:** Guiar a los nuevos clientes a través del proceso de registro, solicitando y validando su información personal y de contacto.
    *   **Interacción:** Almacenará la información del cliente en la base de datos.

*   **Agente de Base de Datos (Database Agent):**
    *   **Función:** Gestionar todas las operaciones de lectura y escritura en la base de datos, incluyendo el registro de clientes, pedidos y direcciones de entrega.
    *   **Interacción:** Será utilizado por otros agentes para persistir y recuperar datos.

*   **Agente de Delivery (Delivery Agent):**
    *   **Función:** Recopilar y validar la dirección de entrega del cliente, y asociarla al pedido.
    *   **Interacción:** Colaborará con el Agente de Base de Datos para almacenar la dirección de entrega.

## 3. Estructura de la Base de Datos (Propuesta)

Se propone una base de datos relacional simple con las siguientes tablas:

*   **Clientes (Customers):**
    *   `id` (PK, INT)
    *   `nombre` (VARCHAR)
    *   `apellido` (VARCHAR)
    *   `telefono` (VARCHAR, UNIQUE)
    *   `email` (VARCHAR, UNIQUE)
    *   `fecha_registro` (DATETIME)

*   **Pedidos (Orders):**
    *   `id` (PK, INT)
    *   `cliente_id` (FK, INT)
    *   `fecha_pedido` (DATETIME)
    *   `estado` (VARCHAR, ej., 'pendiente', 'confirmado', 'en_preparacion', 'en_camino', 'entregado', 'cancelado')
    *   `total` (DECIMAL)
    *   `direccion_entrega_id` (FK, INT, NULLABLE)

*   **Detalle_Pedido (Order_Items):**
    *   `id` (PK, INT)
    *   `pedido_id` (FK, INT)
    *   `item_menu` (VARCHAR) - Nombre del artículo del menú
    *   `cantidad` (INT)
    *   `precio_unitario` (DECIMAL)

*   **Direcciones_Entrega (Delivery_Addresses):**
    *   `id` (PK, INT)
    *   `cliente_id` (FK, INT)
    *   `calle` (VARCHAR)
    *   `numero` (VARCHAR)
    *   `ciudad` (VARCHAR)
    *   `codigo_postal` (VARCHAR)
    *   `referencia` (TEXT, NULLABLE)

## 4. Formato de la Hoja de Cálculo del Menú (Propuesta)

La hoja de cálculo del menú deberá tener al menos las siguientes columnas:

*   **ID_Producto:** Identificador único del producto.
*   **Nombre_Producto:** Nombre del plato o bebida.
*   **Descripción:** Breve descripción del producto.
*   **Precio:** Precio del producto.
*   **Categoría:** Categoría del producto (ej., 'Entradas', 'Platos Principales', 'Bebidas', 'Postres').
*   **Disponibilidad:** 'Sí' o 'No' para indicar si el producto está disponible.

## 5. Flujo de Interacción (Ejemplo)

1.  **Cliente:** 


Hola, quiero hacer un pedido.
2.  **Agente Raíz:** (Detecta la intención de pedido y transfiere al Agente de Pedidos)
3.  **Agente de Pedidos:** ¡Hola! ¿Qué te gustaría pedir hoy? Puedes ver nuestro menú si lo deseas.
4.  **Cliente:** ¿Qué tipo de pizzas tienen?
5.  **Agente de Pedidos:** (Transfiere al Agente de Menú)
6.  **Agente de Menú:** Tenemos pizza de pepperoni, pizza margarita, pizza vegetariana... (proporciona descripciones y precios consultando la hoja de cálculo del menú).
7.  **Cliente:** Quiero una pizza de pepperoni y una bebida de cola.
8.  **Agente de Pedidos:** Entendido. ¿Eres un cliente nuevo o ya has pedido antes?
9.  **Cliente:** Soy nuevo.
10. **Agente de Pedidos:** (Transfiere al Agente de Registro de Clientes)
11. **Agente de Registro de Clientes:** ¡Bienvenido! Para registrarte, por favor, indícame tu nombre completo, número de teléfono y dirección de correo electrónico.
12. **Cliente:** Mi nombre es Juan Pérez, mi teléfono es 123456789 y mi correo es juan.perez@example.com.
13. **Agente de Registro de Clientes:** Gracias, Juan. Te hemos registrado. (Registra en la base de datos)
14. **Agente de Pedidos:** (Retoma el control) Perfecto, Juan. Tu pedido es una pizza de pepperoni y una bebida de cola. ¿Es correcto?
15. **Cliente:** Sí, es correcto.
16. **Agente de Pedidos:** ¿Cuál es la dirección de entrega?
17. **Cliente:** (Proporciona la dirección)
18. **Agente de Pedidos:** (Transfiere al Agente de Delivery para validar y registrar la dirección, luego al Agente de Base de Datos para registrar el pedido completo).
19. **Agente de Pedidos:** ¡Gracias por tu pedido, Juan! Estará contigo en aproximadamente 30 minutos.

## 6. Tecnologías Propuestas

*   **Framework de Agentes:** Google ADK (Agent Development Kit) para Python.
*   **Lenguaje de Programación:** Python.
*   **Base de Datos:** SQLite (para prototipo y desarrollo local) o PostgreSQL/MySQL (para despliegue en producción).
*   **Hoja de Cálculo:** Pandas para la lectura de datos desde archivos Excel/CSV, o Google Sheets API para integración directa con Google Sheets.
*   **Interfaz de Usuario:** Una interfaz de texto simple para la interacción inicial, con potencial para integrar con plataformas de mensajería (ej., Telegram, WhatsApp) en futuras iteraciones.

## 7. Consideraciones de Seguridad y Escalabilidad

*   **Seguridad:** Implementar validación de entrada para prevenir inyecciones SQL y otros ataques. Proteger la información sensible del cliente. Considerar la autenticación y autorización si se extiende a un portal de administración.
*   **Escalabilidad:** El diseño multi-agente de ADK facilita la escalabilidad. Cada agente puede ser desarrollado y desplegado de forma independiente. La elección de la base de datos y la forma de acceder a la hoja de cálculo también influirán en la escalabilidad.

## 8. Próximos Pasos

Con este diseño inicial, el siguiente paso es configurar el entorno de desarrollo e instalar las dependencias necesarias para comenzar la implementación.


===== data_entrenamiento/Proyectos_adkaget/customer_agent.py =====
"""
Agente de Registro de Clientes - Especializado en registrar nuevos clientes
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import re
from datetime import datetime

class CustomerRegistrationAgent:
    def __init__(self):
        self.registration_data = {}  # Almacena datos de registro en progreso
        
        # Configurar el agente especializado en registro
        self.agent = LlmAgent(
            name="customer_registration_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en el registro de nuevos clientes.
            Tu función es:
            - Guiar a los clientes a través del proceso de registro
            - Solicitar información necesaria: nombre, apellido, teléfono, email
            - Validar que la información esté completa y sea correcta
            - Confirmar el registro exitoso
            
            Sé amigable y paciente. Solicita la información paso a paso si es necesario.
            Valida que el email tenga formato correcto y que el teléfono sea válido.
            
            Información requerida:
            - Nombre completo (nombre y apellido)
            - Número de teléfono
            - Dirección de correo electrónico
            """,
            description="Agente especializado en registro de clientes"
        )
    
    def initialize_registration(self, session_id: str):
        """Inicializa un nuevo proceso de registro"""
        if session_id not in self.registration_data:
            self.registration_data[session_id] = {
                'nombre': None,
                'apellido': None,
                'telefono': None,
                'email': None,
                'status': 'in_progress',
                'started_at': datetime.now().isoformat()
            }
    
    def validate_email(self, email: str) -> bool:
        """Valida el formato del email"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None
    
    def validate_phone(self, phone: str) -> bool:
        """Valida el formato del teléfono"""
        # Remover espacios y caracteres especiales
        clean_phone = re.sub(r'[^\d]', '', phone)
        # Verificar que tenga entre 7 y 15 dígitos
        return 7 <= len(clean_phone) <= 15
    
    def extract_customer_info(self, message: str) -> dict:
        """Extrae información del cliente del mensaje"""
        info = {}
        
        # Buscar email
        email_pattern = r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'
        email_match = re.search(email_pattern, message)
        if email_match:
            info['email'] = email_match.group()
        
        # Buscar teléfono (números de 7-15 dígitos)
        phone_pattern = r'\b\d{7,15}\b'
        phone_match = re.search(phone_pattern, message)
        if phone_match:
            info['telefono'] = phone_match.group()
        
        # Buscar nombres (palabras que empiecen con mayúscula)
        name_pattern = r'\b[A-Z][a-z]+\b'
        names = re.findall(name_pattern, message)
        if len(names) >= 2:
            info['nombre'] = names[0]
            info['apellido'] = ' '.join(names[1:])
        elif len(names) == 1:
            info['nombre'] = names[0]
        
        return info
    
    def update_registration_data(self, session_id: str, new_info: dict):
        """Actualiza los datos de registro con nueva información"""
        self.initialize_registration(session_id)
        
        for key, value in new_info.items():
            if key in self.registration_data[session_id] and value:
                self.registration_data[session_id][key] = value
    
    def get_registration_status(self, session_id: str) -> dict:
        """Obtiene el estado actual del registro"""
        if session_id not in self.registration_data:
            return {}
        
        data = self.registration_data[session_id]
        missing_fields = []
        
        if not data['nombre']:
            missing_fields.append('nombre')
        if not data['apellido']:
            missing_fields.append('apellido')
        if not data['telefono']:
            missing_fields.append('teléfono')
        if not data['email']:
            missing_fields.append('email')
        
        return {
            'data': data,
            'missing_fields': missing_fields,
            'is_complete': len(missing_fields) == 0
        }
    
    def validate_registration_data(self, session_id: str) -> dict:
        """Valida los datos de registro"""
        status = self.get_registration_status(session_id)
        
        if not status['is_complete']:
            return {
                'valid': False,
                'errors': [f"Falta información: {', '.join(status['missing_fields'])}"]
            }
        
        errors = []
        data = status['data']
        
        if data['email'] and not self.validate_email(data['email']):
            errors.append("El formato del email no es válido")
        
        if data['telefono'] and not self.validate_phone(data['telefono']):
            errors.append("El formato del teléfono no es válido")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors
        }
    
    def complete_registration(self, session_id: str) -> dict:
        """Completa el registro del cliente"""
        validation = self.validate_registration_data(session_id)
        
        if validation['valid']:
            self.registration_data[session_id]['status'] = 'completed'
            self.registration_data[session_id]['completed_at'] = datetime.now().isoformat()
            return self.registration_data[session_id].copy()
        
        return {}
    
    def process_registration_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud de registro"""
        try:
            session_id = session.id
            
            # Extraer información del mensaje
            extracted_info = self.extract_customer_info(message)
            
            # Actualizar datos de registro
            if extracted_info:
                self.update_registration_data(session_id, extracted_info)
            
            # Obtener estado actual
            status = self.get_registration_status(session_id)
            
            # Crear contexto para el agente
            context = f"Mensaje del cliente: {message}\n\n"
            
            if status:
                context += "Estado actual del registro:\n"
                data = status['data']
                context += f"- Nombre: {'✓' if data['nombre'] else '✗'} {data['nombre'] or 'Pendiente'}\n"
                context += f"- Apellido: {'✓' if data['apellido'] else '✗'} {data['apellido'] or 'Pendiente'}\n"
                context += f"- Teléfono: {'✓' if data['telefono'] else '✗'} {data['telefono'] or 'Pendiente'}\n"
                context += f"- Email: {'✓' if data['email'] else '✗'} {data['email'] or 'Pendiente'}\n"
                
                if status['missing_fields']:
                    context += f"\nInformación faltante: {', '.join(status['missing_fields'])}\n"
                else:
                    # Validar datos completos
                    validation = self.validate_registration_data(session_id)
                    if validation['valid']:
                        context += "\n¡Registro completo y válido! Listo para confirmar.\n"
                    else:
                        context += f"\nErrores de validación: {', '.join(validation['errors'])}\n"
            
            response = self.agent.run(context, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema con el registro. ¿Podrías proporcionar tu información nuevamente?"

def main():
    """Función de prueba para el agente de registro"""
    print("=== Agente de Registro de Clientes - Prueba ===")
    
    registration_agent = CustomerRegistrationAgent()
    session = Session(
        id="registration_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de registro inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Información de registro: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = registration_agent.process_registration_request(user_input, session)
        print(f"Agente de Registro: {response}\n")
        
        # Mostrar estado actual
        status = registration_agent.get_registration_status("registration_test_session")
        if status:
            print("Estado actual del registro:")
            data = status['data']
            print(f"  Nombre: {data['nombre'] or 'Pendiente'}")
            print(f"  Apellido: {data['apellido'] or 'Pendiente'}")
            print(f"  Teléfono: {data['telefono'] or 'Pendiente'}")
            print(f"  Email: {data['email'] or 'Pendiente'}")
            print()

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/database_manager.py =====
"""
Gestor de Base de Datos - Maneja todas las operaciones de base de datos
"""

import sqlite3
import pandas as pd
from datetime import datetime
import os

class DatabaseManager:
    def __init__(self, db_path: str = "restaurant_chatbot.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializa la base de datos y crea las tablas necesarias"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Tabla de clientes
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre VARCHAR(100) NOT NULL,
                apellido VARCHAR(100) NOT NULL,
                telefono VARCHAR(20) UNIQUE NOT NULL,
                email VARCHAR(255) UNIQUE NOT NULL,
                fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabla de direcciones de entrega
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS delivery_addresses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cliente_id INTEGER NOT NULL,
                calle VARCHAR(255) NOT NULL,
                numero VARCHAR(10),
                ciudad VARCHAR(100) NOT NULL,
                codigo_postal VARCHAR(10),
                referencia TEXT,
                direccion_completa TEXT,
                FOREIGN KEY (cliente_id) REFERENCES customers (id)
            )
        ''')
        
        # Tabla de pedidos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cliente_id INTEGER NOT NULL,
                fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
                estado VARCHAR(50) DEFAULT 'pendiente',
                total DECIMAL(10,2) NOT NULL,
                direccion_entrega_id INTEGER,
                FOREIGN KEY (cliente_id) REFERENCES customers (id),
                FOREIGN KEY (direccion_entrega_id) REFERENCES delivery_addresses (id)
            )
        ''')
        
        # Tabla de detalles de pedido
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pedido_id INTEGER NOT NULL,
                item_menu VARCHAR(255) NOT NULL,
                cantidad INTEGER NOT NULL,
                precio_unitario DECIMAL(10,2) NOT NULL,
                subtotal DECIMAL(10,2) NOT NULL,
                FOREIGN KEY (pedido_id) REFERENCES orders (id)
            )
        ''')
        
        conn.commit()
        conn.close()
        print(f"Base de datos inicializada en {self.db_path}")
    
    def register_customer(self, customer_data: dict) -> int:
        """Registra un nuevo cliente y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO customers (nombre, apellido, telefono, email)
                VALUES (?, ?, ?, ?)
            ''', (
                customer_data['nombre'],
                customer_data['apellido'],
                customer_data['telefono'],
                customer_data['email']
            ))
            
            customer_id = cursor.lastrowid
            conn.commit()
            return customer_id
            
        except sqlite3.IntegrityError as e:
            if 'telefono' in str(e):
                raise ValueError("El número de teléfono ya está registrado")
            elif 'email' in str(e):
                raise ValueError("El email ya está registrado")
            else:
                raise ValueError("Error al registrar cliente")
        finally:
            conn.close()
    
    def get_customer_by_phone(self, phone: str) -> dict:
        """Busca un cliente por número de teléfono"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, nombre, apellido, telefono, email, fecha_registro
            FROM customers WHERE telefono = ?
        ''', (phone,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {
                'id': result[0],
                'nombre': result[1],
                'apellido': result[2],
                'telefono': result[3],
                'email': result[4],
                'fecha_registro': result[5]
            }
        return None
    
    def get_customer_by_email(self, email: str) -> dict:
        """Busca un cliente por email"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, nombre, apellido, telefono, email, fecha_registro
            FROM customers WHERE email = ?
        ''', (email,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {
                'id': result[0],
                'nombre': result[1],
                'apellido': result[2],
                'telefono': result[3],
                'email': result[4],
                'fecha_registro': result[5]
            }
        return None
    
    def save_delivery_address(self, address_data: dict) -> int:
        """Guarda una dirección de entrega y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO delivery_addresses 
            (cliente_id, calle, numero, ciudad, codigo_postal, referencia, direccion_completa)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            address_data['cliente_id'],
            address_data['calle'],
            address_data.get('numero'),
            address_data['ciudad'],
            address_data.get('codigo_postal'),
            address_data.get('referencia'),
            address_data.get('direccion_completa')
        ))
        
        address_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return address_id
    
    def create_order(self, order_data: dict) -> int:
        """Crea un nuevo pedido y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO orders (cliente_id, total, direccion_entrega_id, estado)
            VALUES (?, ?, ?, ?)
        ''', (
            order_data['cliente_id'],
            order_data['total'],
            order_data.get('direccion_entrega_id'),
            order_data.get('estado', 'pendiente')
        ))
        
        order_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return order_id
    
    def add_order_items(self, order_id: int, items: list):
        """Agrega elementos a un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for item in items:
            cursor.execute('''
                INSERT INTO order_items (pedido_id, item_menu, cantidad, precio_unitario, subtotal)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                order_id,
                item['name'],
                item['quantity'],
                item['price'],
                item['subtotal']
            ))
        
        conn.commit()
        conn.close()
    
    def get_order_details(self, order_id: int) -> dict:
        """Obtiene los detalles completos de un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Obtener información del pedido
        cursor.execute('''
            SELECT o.id, o.fecha_pedido, o.estado, o.total,
                   c.nombre, c.apellido, c.telefono, c.email,
                   da.direccion_completa
            FROM orders o
            JOIN customers c ON o.cliente_id = c.id
            LEFT JOIN delivery_addresses da ON o.direccion_entrega_id = da.id
            WHERE o.id = ?
        ''', (order_id,))
        
        order_info = cursor.fetchone()
        
        if not order_info:
            conn.close()
            return None
        
        # Obtener elementos del pedido
        cursor.execute('''
            SELECT item_menu, cantidad, precio_unitario, subtotal
            FROM order_items
            WHERE pedido_id = ?
        ''', (order_id,))
        
        items = cursor.fetchall()
        conn.close()
        
        return {
            'id': order_info[0],
            'fecha_pedido': order_info[1],
            'estado': order_info[2],
            'total': order_info[3],
            'cliente': {
                'nombre': order_info[4],
                'apellido': order_info[5],
                'telefono': order_info[6],
                'email': order_info[7]
            },
            'direccion_entrega': order_info[8],
            'items': [
                {
                    'item_menu': item[0],
                    'cantidad': item[1],
                    'precio_unitario': item[2],
                    'subtotal': item[3]
                }
                for item in items
            ]
        }
    
    def update_order_status(self, order_id: int, new_status: str):
        """Actualiza el estado de un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE orders SET estado = ? WHERE id = ?
        ''', (new_status, order_id))
        
        conn.commit()
        conn.close()
    
    def get_customer_orders(self, customer_id: int) -> list:
        """Obtiene todos los pedidos de un cliente"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, fecha_pedido, estado, total
            FROM orders
            WHERE cliente_id = ?
            ORDER BY fecha_pedido DESC
        ''', (customer_id,))
        
        orders = cursor.fetchall()
        conn.close()
        
        return [
            {
                'id': order[0],
                'fecha_pedido': order[1],
                'estado': order[2],
                'total': order[3]
            }
            for order in orders
        ]

def main():
    """Función de prueba para el gestor de base de datos"""
    print("=== Gestor de Base de Datos - Prueba ===")
    
    # Inicializar base de datos
    db_manager = DatabaseManager()
    
    # Probar registro de cliente
    try:
        customer_data = {
            'nombre': 'Juan',
            'apellido': 'Pérez',
            'telefono': '123456789',
            'email': 'juan.perez@example.com'
        }
        
        customer_id = db_manager.register_customer(customer_data)
        print(f"Cliente registrado con ID: {customer_id}")
        
        # Buscar cliente
        found_customer = db_manager.get_customer_by_phone('123456789')
        print(f"Cliente encontrado: {found_customer}")
        
        # Crear dirección de entrega
        address_data = {
            'cliente_id': customer_id,
            'calle': 'Calle Principal',
            'numero': '123',
            'ciudad': 'Ciudad Ejemplo',
            'codigo_postal': '12345',
            'referencia': 'Casa azul con portón blanco',
            'direccion_completa': 'Calle Principal 123, Ciudad Ejemplo, CP: 12345'
        }
        
        address_id = db_manager.save_delivery_address(address_data)
        print(f"Dirección guardada con ID: {address_id}")
        
        # Crear pedido
        order_data = {
            'cliente_id': customer_id,
            'total': 25.00,
            'direccion_entrega_id': address_id
        }
        
        order_id = db_manager.create_order(order_data)
        print(f"Pedido creado con ID: {order_id}")
        
        # Agregar elementos al pedido
        items = [
            {'name': 'Pizza Margarita', 'quantity': 1, 'price': 12.50, 'subtotal': 12.50},
            {'name': 'Coca Cola', 'quantity': 2, 'price': 2.50, 'subtotal': 5.00},
            {'name': 'Tiramisu', 'quantity': 1, 'price': 6.00, 'subtotal': 6.00}
        ]
        
        db_manager.add_order_items(order_id, items)
        print("Elementos agregados al pedido")
        
        # Obtener detalles del pedido
        order_details = db_manager.get_order_details(order_id)
        print(f"Detalles del pedido: {order_details}")
        
    except Exception as e:
        print(f"Error en la prueba: {e}")

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/delivery_agent.py =====
"""
Agente de Delivery - Especializado en gestionar direcciones de entrega
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import re
from datetime import datetime

class DeliveryAgent:
    def __init__(self):
        self.delivery_data = {}  # Almacena datos de entrega en progreso
        
        # Configurar el agente especializado en delivery
        self.agent = LlmAgent(
            name="delivery_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en gestionar información de entrega.
            Tu función es:
            - Solicitar y validar direcciones de entrega
            - Confirmar detalles de la dirección
            - Proporcionar información sobre tiempos de entrega
            - Gestionar referencias adicionales para encontrar la dirección
            
            Información requerida para la entrega:
            - Calle y número
            - Ciudad
            - Código postal (opcional)
            - Referencias adicionales (opcional pero recomendado)
            
            Sé claro y específico al solicitar la información. Confirma siempre
            los detalles antes de finalizar.
            """,
            description="Agente especializado en gestión de entregas"
        )
    
    def initialize_delivery(self, session_id: str):
        """Inicializa un nuevo proceso de entrega"""
        if session_id not in self.delivery_data:
            self.delivery_data[session_id] = {
                'calle': None,
                'numero': None,
                'ciudad': None,
                'codigo_postal': None,
                'referencia': None,
                'direccion_completa': None,
                'status': 'in_progress',
                'started_at': datetime.now().isoformat()
            }
    
    def extract_address_info(self, message: str) -> dict:
        """Extrae información de dirección del mensaje"""
        info = {}
        
        # Buscar código postal (4-6 dígitos)
        postal_pattern = r'\b\d{4,6}\b'
        postal_match = re.search(postal_pattern, message)
        if postal_match:
            info['codigo_postal'] = postal_match.group()
        
        # Buscar número de calle (números seguidos de palabras como "calle", "avenida", etc.)
        street_number_pattern = r'\b(\d+)\s*(?:calle|avenida|av|street|st|boulevard|blvd|pasaje|pje)\s+([a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+)'
        street_match = re.search(street_number_pattern, message, re.IGNORECASE)
        if street_match:
            info['numero'] = street_match.group(1)
            info['calle'] = street_match.group(2).strip()
        
        # Buscar patrones de dirección más generales
        if not info.get('calle'):
            # Buscar "calle/avenida + nombre"
            street_pattern = r'(?:calle|avenida|av|street|st|boulevard|blvd|pasaje|pje)\s+([a-zA-ZáéíóúÁÉÍÓÚñÑ\s\d]+)'
            street_match = re.search(street_pattern, message, re.IGNORECASE)
            if street_match:
                info['calle'] = street_match.group(1).strip()
        
        # Buscar ciudades (palabras capitalizadas que podrían ser ciudades)
        city_keywords = ['ciudad', 'municipio', 'comuna', 'distrito']
        for keyword in city_keywords:
            city_pattern = f'{keyword}\\s+([A-ZáéíóúÁÉÍÓÚñÑ][a-záéíóúÁÉÍÓÚñÑ\\s]+)'
            city_match = re.search(city_pattern, message, re.IGNORECASE)
            if city_match:
                info['ciudad'] = city_match.group(1).strip()
                break
        
        # Si no se encontró ciudad con palabras clave, buscar palabras capitalizadas
        if not info.get('ciudad'):
            capitalized_words = re.findall(r'\b[A-ZáéíóúÁÉÍÓÚñÑ][a-záéíóúÁÉÍÓÚñÑ]+\b', message)
            if capitalized_words:
                # Tomar la última palabra capitalizada como posible ciudad
                info['ciudad'] = capitalized_words[-1]
        
        return info
    
    def update_delivery_data(self, session_id: str, new_info: dict):
        """Actualiza los datos de entrega con nueva información"""
        self.initialize_delivery(session_id)
        
        for key, value in new_info.items():
            if key in self.delivery_data[session_id] and value:
                self.delivery_data[session_id][key] = value
        
        # Construir dirección completa si hay suficiente información
        self.build_complete_address(session_id)
    
    def build_complete_address(self, session_id: str):
        """Construye la dirección completa a partir de los componentes"""
        if session_id not in self.delivery_data:
            return
        
        data = self.delivery_data[session_id]
        address_parts = []
        
        if data['calle']:
            if data['numero']:
                address_parts.append(f"{data['calle']} {data['numero']}")
            else:
                address_parts.append(data['calle'])
        
        if data['ciudad']:
            address_parts.append(data['ciudad'])
        
        if data['codigo_postal']:
            address_parts.append(f"CP: {data['codigo_postal']}")
        
        if address_parts:
            self.delivery_data[session_id]['direccion_completa'] = ', '.join(address_parts)
    
    def get_delivery_status(self, session_id: str) -> dict:
        """Obtiene el estado actual de la información de entrega"""
        if session_id not in self.delivery_data:
            return {}
        
        data = self.delivery_data[session_id]
        missing_fields = []
        
        if not data['calle']:
            missing_fields.append('calle')
        if not data['ciudad']:
            missing_fields.append('ciudad')
        
        # Número es opcional si está incluido en la calle
        if not data['numero'] and data['calle'] and not re.search(r'\d+', data['calle']):
            missing_fields.append('número')
        
        return {
            'data': data,
            'missing_fields': missing_fields,
            'is_complete': len(missing_fields) == 0
        }
    
    def estimate_delivery_time(self, session_id: str) -> str:
        """Estima el tiempo de entrega basado en la dirección"""
        status = self.get_delivery_status(session_id)
        
        if not status['is_complete']:
            return "No se puede estimar el tiempo sin dirección completa"
        
        # Simulación simple de tiempo de entrega
        return "30-45 minutos"
    
    def complete_delivery_info(self, session_id: str) -> dict:
        """Completa la información de entrega"""
        status = self.get_delivery_status(session_id)
        
        if status['is_complete']:
            self.delivery_data[session_id]['status'] = 'completed'
            self.delivery_data[session_id]['completed_at'] = datetime.now().isoformat()
            self.delivery_data[session_id]['estimated_time'] = self.estimate_delivery_time(session_id)
            return self.delivery_data[session_id].copy()
        
        return {}
    
    def process_delivery_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud relacionada con entrega"""
        try:
            session_id = session.id
            
            # Extraer información de dirección del mensaje
            extracted_info = self.extract_address_info(message)
            
            # Actualizar datos de entrega
            if extracted_info:
                self.update_delivery_data(session_id, extracted_info)
            
            # Si el mensaje contiene "referencia" o información adicional
            if 'referencia' in message.lower() or 'cerca de' in message.lower():
                self.delivery_data[session_id]['referencia'] = message
            
            # Obtener estado actual
            status = self.get_delivery_status(session_id)
            
            # Crear contexto para el agente
            context = f"Mensaje del cliente: {message}\n\n"
            
            if status:
                context += "Estado actual de la información de entrega:\n"
                data = status['data']
                context += f"- Calle: {'✓' if data['calle'] else '✗'} {data['calle'] or 'Pendiente'}\n"
                context += f"- Número: {'✓' if data['numero'] else '✗'} {data['numero'] or 'Pendiente'}\n"
                context += f"- Ciudad: {'✓' if data['ciudad'] else '✗'} {data['ciudad'] or 'Pendiente'}\n"
                context += f"- Código Postal: {data['codigo_postal'] or 'No especificado'}\n"
                context += f"- Referencia: {data['referencia'] or 'No especificada'}\n"
                
                if data['direccion_completa']:
                    context += f"- Dirección completa: {data['direccion_completa']}\n"
                
                if status['missing_fields']:
                    context += f"\nInformación faltante: {', '.join(status['missing_fields'])}\n"
                else:
                    estimated_time = self.estimate_delivery_time(session_id)
                    context += f"\n¡Dirección completa! Tiempo estimado de entrega: {estimated_time}\n"
            
            response = self.agent.run(context, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema procesando la información de entrega. ¿Podrías proporcionar tu dirección nuevamente?"

def main():
    """Función de prueba para el agente de delivery"""
    print("=== Agente de Delivery - Prueba ===")
    
    delivery_agent = DeliveryAgent()
    session = Session(
        id="delivery_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de delivery inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Información de entrega: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = delivery_agent.process_delivery_request(user_input, session)
        print(f"Agente de Delivery: {response}\n")
        
        # Mostrar estado actual
        status = delivery_agent.get_delivery_status("delivery_test_session")
        if status:
            print("Estado actual de la entrega:")
            data = status['data']
            print(f"  Calle: {data['calle'] or 'Pendiente'}")
            print(f"  Número: {data['numero'] or 'Pendiente'}")
            print(f"  Ciudad: {data['ciudad'] or 'Pendiente'}")
            print(f"  Código Postal: {data['codigo_postal'] or 'No especificado'}")
            if data['direccion_completa']:
                print(f"  Dirección completa: {data['direccion_completa']}")
            print()

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/integrated_chatbot.py =====
"""
Sistema Integrado de Chatbot Multi-Agente para Restaurante
Integra todos los agentes especializados con la base de datos y el menú
"""

from google.adk.sessions import Session
from menu_agent import MenuAgent
from order_agent import OrderAgent
from customer_agent import CustomerRegistrationAgent
from delivery_agent import DeliveryAgent
from database_manager import DatabaseManager
import json
from datetime import datetime

class IntegratedChatbotSystem:
    def __init__(self, menu_file: str = "menu.csv", db_file: str = "restaurant_chatbot.db"):
        # Inicializar componentes
        self.menu_agent = MenuAgent(menu_file)
        self.order_agent = OrderAgent()
        self.customer_agent = CustomerRegistrationAgent()
        self.delivery_agent = DeliveryAgent()
        self.db_manager = DatabaseManager(db_file)
        
        # Estado del sistema
        self.active_sessions = {}
        
        print("Sistema integrado de chatbot inicializado correctamente")
    
    def create_session(self, user_id: str = None) -> Session:
        """Crea una nueva sesión para un usuario"""
        if not user_id:
            user_id = f"user_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        session = Session(
            id=f"session_{user_id}",
            appName="restaurant_chatbot",
            userId=user_id
        )
        
        # Inicializar estado de la sesión
        self.active_sessions[session.id] = {
            'user_id': user_id,
            'current_agent': 'root',
            'customer_id': None,
            'conversation_state': 'greeting',
            'created_at': datetime.now().isoformat()
        }
        
        return session
    
    def analyze_message_intention(self, message: str) -> str:
        """Analiza la intención del mensaje del usuario"""
        message_lower = message.lower()
        
        # Palabras clave para diferentes intenciones
        menu_keywords = ["menú", "menu", "carta", "qué tienen", "precios", "platos", "comida", "pizzas", "hamburguesas", "bebidas", "postres"]
        order_keywords = ["pedido", "pedir", "quiero", "ordenar", "comprar", "agregar", "añadir"]
        customer_keywords = ["registro", "nuevo cliente", "primera vez", "registrarme", "soy nuevo"]
        delivery_keywords = ["dirección", "entrega", "delivery", "domicilio", "envío"]
        confirmation_keywords = ["confirmar", "sí", "si", "correcto", "está bien", "ok", "vale"]
        
        if any(keyword in message_lower for keyword in menu_keywords):
            return "menu_inquiry"
        elif any(keyword in message_lower for keyword in order_keywords):
            return "place_order"
        elif any(keyword in message_lower for keyword in customer_keywords):
            return "customer_registration"
        elif any(keyword in message_lower for keyword in delivery_keywords):
            return "delivery_info"
        elif any(keyword in message_lower for keyword in confirmation_keywords):
            return "confirmation"
        else:
            return "general"
    
    def process_message(self, message: str, session: Session) -> str:
        """Procesa un mensaje del usuario y coordina la respuesta entre agentes"""
        try:
            session_id = session.id
            
            # Verificar si la sesión existe
            if session_id not in self.active_sessions:
                self.active_sessions[session_id] = {
                    'user_id': session.userId,
                    'current_agent': 'root',
                    'customer_id': None,
                    'conversation_state': 'greeting'
                }
            
            session_state = self.active_sessions[session_id]
            intention = self.analyze_message_intention(message)
            
            # Manejar según la intención y el estado actual
            if intention == "menu_inquiry":
                return self._handle_menu_inquiry(message, session)
            
            elif intention == "place_order":
                return self._handle_order_request(message, session)
            
            elif intention == "customer_registration":
                return self._handle_customer_registration(message, session)
            
            elif intention == "delivery_info":
                return self._handle_delivery_request(message, session)
            
            elif intention == "confirmation":
                return self._handle_confirmation(message, session)
            
            else:
                return self._handle_general_inquiry(message, session)
                
        except Exception as e:
            return f"Lo siento, hubo un problema procesando tu mensaje. ¿Podrías intentar de nuevo?"
    
    def _handle_menu_inquiry(self, message: str, session: Session) -> str:
        """Maneja consultas sobre el menú"""
        self.active_sessions[session.id]['current_agent'] = 'menu'
        return self.menu_agent.process_menu_query(message, session)
    
    def _handle_order_request(self, message: str, session: Session) -> str:
        """Maneja solicitudes de pedidos"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'order'
        
        # Verificar si el cliente está registrado
        if not self.active_sessions[session_id]['customer_id']:
            return "Para realizar un pedido, primero necesito que te registres. ¿Eres un cliente nuevo o ya tienes cuenta con nosotros? Si eres nuevo, por favor proporciona tu nombre completo, teléfono y email."
        
        return self.order_agent.process_order_request(message, session)
    
    def _handle_customer_registration(self, message: str, session: Session) -> str:
        """Maneja el registro de clientes"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'customer'
        
        response = self.customer_agent.process_registration_request(message, session)
        
        # Verificar si el registro está completo
        registration_status = self.customer_agent.get_registration_status(session_id)
        if registration_status and registration_status['is_complete']:
            validation = self.customer_agent.validate_registration_data(session_id)
            if validation['valid']:
                # Guardar cliente en la base de datos
                try:
                    customer_data = registration_status['data']
                    customer_id = self.db_manager.register_customer({
                        'nombre': customer_data['nombre'],
                        'apellido': customer_data['apellido'],
                        'telefono': customer_data['telefono'],
                        'email': customer_data['email']
                    })
                    
                    self.active_sessions[session_id]['customer_id'] = customer_id
                    self.customer_agent.complete_registration(session_id)
                    
                    response += f"\n\n¡Registro completado exitosamente! Ahora puedes realizar tu pedido."
                    
                except ValueError as e:
                    response += f"\n\nError en el registro: {e}. ¿Podrías verificar tu información?"
        
        return response
    
    def _handle_delivery_request(self, message: str, session: Session) -> str:
        """Maneja solicitudes de información de entrega"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'delivery'
        
        response = self.delivery_agent.process_delivery_request(message, session)
        
        # Verificar si la información de entrega está completa
        delivery_status = self.delivery_agent.get_delivery_status(session_id)
        if delivery_status and delivery_status['is_complete']:
            # Guardar dirección en la base de datos si hay un cliente registrado
            customer_id = self.active_sessions[session_id].get('customer_id')
            if customer_id:
                try:
                    delivery_data = delivery_status['data']
                    address_id = self.db_manager.save_delivery_address({
                        'cliente_id': customer_id,
                        'calle': delivery_data['calle'],
                        'numero': delivery_data['numero'],
                        'ciudad': delivery_data['ciudad'],
                        'codigo_postal': delivery_data['codigo_postal'],
                        'referencia': delivery_data['referencia'],
                        'direccion_completa': delivery_data['direccion_completa']
                    })
                    
                    self.active_sessions[session_id]['address_id'] = address_id
                    response += f"\n\nDirección guardada correctamente. ¿Hay algo más en lo que pueda ayudarte?"
                    
                except Exception as e:
                    response += f"\n\nHubo un problema guardando la dirección. Por favor, inténtalo de nuevo."
        
        return response
    
    def _handle_confirmation(self, message: str, session: Session) -> str:
        """Maneja confirmaciones del usuario"""
        session_id = session.id
        current_agent = self.active_sessions[session_id]['current_agent']
        
        if current_agent == 'order':
            # Confirmar pedido
            return self._confirm_order(session)
        else:
            return "¿Qué te gustaría confirmar? Puedo ayudarte con tu pedido, registro o información de entrega."
    
    def _confirm_order(self, session: Session) -> str:
        """Confirma y procesa un pedido completo"""
        session_id = session.id
        customer_id = self.active_sessions[session_id].get('customer_id')
        
        if not customer_id:
            return "Para confirmar el pedido, primero necesitas registrarte como cliente."
        
        # Obtener pedido actual
        if session_id in self.order_agent.current_orders:
            order_data = self.order_agent.current_orders[session_id]
            
            if not order_data['items']:
                return "No tienes elementos en tu pedido. ¿Qué te gustaría pedir?"
            
            try:
                # Crear pedido en la base de datos
                address_id = self.active_sessions[session_id].get('address_id')
                
                db_order_id = self.db_manager.create_order({
                    'cliente_id': customer_id,
                    'total': order_data['total'],
                    'direccion_entrega_id': address_id,
                    'estado': 'confirmado'
                })
                
                # Agregar elementos del pedido
                self.db_manager.add_order_items(db_order_id, order_data['items'])
                
                # Confirmar en el agente de pedidos
                self.order_agent.confirm_order(session_id)
                
                # Generar resumen final
                order_summary = self.order_agent.get_order_summary(session_id)
                
                response = f"¡Pedido confirmado exitosamente!\n\n"
                response += f"Número de pedido: {db_order_id}\n"
                response += f"{order_summary}\n\n"
                response += f"Tu pedido estará listo en aproximadamente 30-45 minutos.\n"
                response += f"¡Gracias por tu preferencia!"
                
                # Limpiar el pedido de la sesión
                self.order_agent.clear_order(session_id)
                
                return response
                
            except Exception as e:
                return f"Hubo un problema confirmando tu pedido. Por favor, inténtalo de nuevo."
        
        return "No tienes un pedido activo para confirmar."
    
    def _handle_general_inquiry(self, message: str, session: Session) -> str:
        """Maneja consultas generales"""
        return """¡Hola! Soy tu asistente del restaurante. Puedo ayudarte con:

🍕 Consultar nuestro menú y precios
🛒 Realizar pedidos
👤 Registrarte como cliente
🚚 Gestionar información de entrega

¿En qué puedo ayudarte hoy?"""
    
    def get_session_state(self, session_id: str) -> dict:
        """Obtiene el estado actual de una sesión"""
        return self.active_sessions.get(session_id, {})

def main():
    """Función principal para probar el sistema integrado"""
    print("=== Sistema Integrado de Chatbot Multi-Agente ===")
    print("Inicializando sistema...")
    
    try:
        chatbot_system = IntegratedChatbotSystem()
        session = chatbot_system.create_session("test_user")
        
        print("Sistema inicializado correctamente.")
        print("Escribe 'salir' para terminar la conversación.\n")
        
        while True:
            user_input = input("Cliente: ")
            
            if user_input.lower() in ['salir', 'exit', 'quit']:
                print("¡Gracias por usar nuestro servicio!")
                break
            
            response = chatbot_system.process_message(user_input, session)
            print(f"Chatbot: {response}\n")
            
    except Exception as e:
        print(f"Error al inicializar el sistema: {e}")

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/menu_agent.py =====
"""
Agente de Menú - Especializado en consultas sobre el menú del restaurante
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import pandas as pd
import os

class MenuAgent:
    def __init__(self, menu_file_path: str = "menu.csv"):
        self.menu_file_path = menu_file_path
        self.menu_data = None
        self.load_menu()
        
        # Configurar el agente especializado en menú
        self.agent = LlmAgent(
            name="menu_agent",
            model="gemini-2.0-flash",
            instruction=f"""
            Eres un agente especializado en el menú del restaurante.
            Tu función es ayudar a los clientes con consultas sobre:
            - Productos disponibles
            - Precios
            - Descripciones de platos
            - Categorías de comida
            - Disponibilidad de productos
            
            Datos del menú actual:
            {self.get_menu_summary()}
            
            Siempre sé amigable, descriptivo y útil. Si un producto no está disponible,
            sugiere alternativas similares.
            """,
            description="Agente especializado en consultas del menú"
        )
    
    def load_menu(self):
        """Carga el menú desde el archivo CSV"""
        try:
            if os.path.exists(self.menu_file_path):
                self.menu_data = pd.read_csv(self.menu_file_path)
            else:
                # Crear un menú de ejemplo si no existe el archivo
                self.create_sample_menu()
        except Exception as e:
            print(f"Error cargando el menú: {e}")
            self.create_sample_menu()
    
    def create_sample_menu(self):
        """Crea un menú de ejemplo"""
        sample_menu = {
            'ID_Producto': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            'Nombre_Producto': [
                'Pizza Margarita', 'Pizza Pepperoni', 'Hamburguesa Clásica',
                'Ensalada César', 'Pasta Carbonara', 'Coca Cola',
                'Agua Mineral', 'Tiramisu', 'Helado de Vainilla', 'Café Espresso'
            ],
            'Descripción': [
                'Pizza con tomate, mozzarella y albahaca fresca',
                'Pizza con pepperoni y queso mozzarella',
                'Hamburguesa con carne, lechuga, tomate y queso',
                'Ensalada con lechuga romana, crutones y aderezo césar',
                'Pasta con salsa carbonara, huevo y panceta',
                'Bebida gaseosa de cola 350ml',
                'Agua mineral natural 500ml',
                'Postre italiano con café y mascarpone',
                'Helado cremoso de vainilla natural',
                'Café espresso italiano'
            ],
            'Precio': [12.50, 14.00, 10.00, 8.50, 13.00, 2.50, 1.50, 6.00, 4.50, 2.00],
            'Categoría': [
                'Pizzas', 'Pizzas', 'Hamburguesas', 'Ensaladas', 'Pastas',
                'Bebidas', 'Bebidas', 'Postres', 'Postres', 'Bebidas'
            ],
            'Disponibilidad': ['Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí']
        }
        
        self.menu_data = pd.DataFrame(sample_menu)
        self.menu_data.to_csv(self.menu_file_path, index=False)
        print(f"Menú de ejemplo creado en {self.menu_file_path}")
    
    def get_menu_summary(self) -> str:
        """Obtiene un resumen del menú para el contexto del agente"""
        if self.menu_data is None:
            return "No hay datos del menú disponibles"
        
        summary = "MENÚ DISPONIBLE:\n"
        for category in self.menu_data['Categoría'].unique():
            summary += f"\n{category.upper()}:\n"
            category_items = self.menu_data[self.menu_data['Categoría'] == category]
            for _, item in category_items.iterrows():
                availability = "✓" if item['Disponibilidad'] == 'Sí' else "✗"
                summary += f"  {availability} {item['Nombre_Producto']} - ${item['Precio']:.2f}\n"
                summary += f"    {item['Descripción']}\n"
        
        return summary
    
    def search_menu_items(self, query: str) -> list:
        """Busca elementos del menú basado en una consulta"""
        if self.menu_data is None:
            return []
        
        query_lower = query.lower()
        results = []
        
        for _, item in self.menu_data.iterrows():
            if (query_lower in item['Nombre_Producto'].lower() or 
                query_lower in item['Descripción'].lower() or
                query_lower in item['Categoría'].lower()):
                results.append(item.to_dict())
        
        return results
    
    def get_items_by_category(self, category: str) -> list:
        """Obtiene elementos por categoría"""
        if self.menu_data is None:
            return []
        
        category_items = self.menu_data[
            self.menu_data['Categoría'].str.lower() == category.lower()
        ]
        return category_items.to_dict('records')
    
    def get_item_details(self, item_name: str) -> dict:
        """Obtiene detalles específicos de un elemento"""
        if self.menu_data is None:
            return {}
        
        item = self.menu_data[
            self.menu_data['Nombre_Producto'].str.lower() == item_name.lower()
        ]
        
        if not item.empty:
            return item.iloc[0].to_dict()
        return {}
    
    def process_menu_query(self, query: str, session: Session) -> str:
        """Procesa una consulta específica sobre el menú"""
        try:
            # Actualizar el contexto del agente con información específica si es necesario
            query_lower = query.lower()
            
            # Buscar elementos específicos mencionados en la consulta
            search_results = self.search_menu_items(query)
            
            if search_results:
                context_info = "\nElementos relevantes encontrados:\n"
                for item in search_results[:5]:  # Limitar a 5 resultados
                    context_info += f"- {item['Nombre_Producto']}: ${item['Precio']:.2f}\n"
                    context_info += f"  {item['Descripción']}\n"
                    context_info += f"  Disponible: {item['Disponibilidad']}\n\n"
                
                enhanced_query = f"{query}\n\nInformación relevante del menú:{context_info}"
            else:
                enhanced_query = query
            
            response = self.agent.run(enhanced_query, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return f"Lo siento, hubo un problema al consultar el menú. ¿Podrías reformular tu pregunta?"

def main():
    """Función de prueba para el agente de menú"""
    print("=== Agente de Menú - Prueba ===")
    
    menu_agent = MenuAgent()
    session = Session(
        id="menu_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de menú inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Consulta sobre menú: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = menu_agent.process_menu_query(user_input, session)
        print(f"Agente de Menú: {response}\n")

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/order_agent.py =====
"""
Agente de Pedidos - Especializado en procesar y gestionar pedidos de clientes
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import json
from datetime import datetime

class OrderAgent:
    def __init__(self):
        self.current_orders = {}  # Almacena pedidos en progreso por sesión
        
        # Configurar el agente especializado en pedidos
        self.agent = LlmAgent(
            name="order_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en procesar pedidos de restaurante.
            Tu función es:
            - Ayudar a los clientes a agregar elementos a su pedido
            - Modificar cantidades de productos
            - Confirmar pedidos
            - Calcular totales
            - Gestionar el carrito de compras
            
            Siempre confirma cada elemento agregado y mantén al cliente informado
            sobre el estado de su pedido. Sé claro sobre precios y cantidades.
            
            Cuando el cliente termine de agregar elementos, pregunta si desea
            confirmar el pedido y proceder con la información de entrega.
            """,
            description="Agente especializado en gestión de pedidos"
        )
    
    def initialize_order(self, session_id: str, customer_id: str = None):
        """Inicializa un nuevo pedido para una sesión"""
        if session_id not in self.current_orders:
            self.current_orders[session_id] = {
                'customer_id': customer_id,
                'items': [],
                'total': 0.0,
                'status': 'in_progress',
                'created_at': datetime.now().isoformat()
            }
    
    def add_item_to_order(self, session_id: str, item_name: str, quantity: int = 1, price: float = 0.0):
        """Agrega un elemento al pedido"""
        self.initialize_order(session_id)
        
        # Buscar si el elemento ya existe en el pedido
        existing_item = None
        for item in self.current_orders[session_id]['items']:
            if item['name'].lower() == item_name.lower():
                existing_item = item
                break
        
        if existing_item:
            # Actualizar cantidad si ya existe
            existing_item['quantity'] += quantity
            existing_item['subtotal'] = existing_item['quantity'] * existing_item['price']
        else:
            # Agregar nuevo elemento
            new_item = {
                'name': item_name,
                'quantity': quantity,
                'price': price,
                'subtotal': quantity * price
            }
            self.current_orders[session_id]['items'].append(new_item)
        
        # Recalcular total
        self.calculate_total(session_id)
    
    def remove_item_from_order(self, session_id: str, item_name: str):
        """Remueve un elemento del pedido"""
        if session_id in self.current_orders:
            self.current_orders[session_id]['items'] = [
                item for item in self.current_orders[session_id]['items']
                if item['name'].lower() != item_name.lower()
            ]
            self.calculate_total(session_id)
    
    def update_item_quantity(self, session_id: str, item_name: str, new_quantity: int):
        """Actualiza la cantidad de un elemento"""
        if session_id in self.current_orders:
            for item in self.current_orders[session_id]['items']:
                if item['name'].lower() == item_name.lower():
                    if new_quantity <= 0:
                        self.remove_item_from_order(session_id, item_name)
                    else:
                        item['quantity'] = new_quantity
                        item['subtotal'] = item['quantity'] * item['price']
                    break
            self.calculate_total(session_id)
    
    def calculate_total(self, session_id: str):
        """Calcula el total del pedido"""
        if session_id in self.current_orders:
            total = sum(item['subtotal'] for item in self.current_orders[session_id]['items'])
            self.current_orders[session_id]['total'] = total
    
    def get_order_summary(self, session_id: str) -> str:
        """Obtiene un resumen del pedido actual"""
        if session_id not in self.current_orders or not self.current_orders[session_id]['items']:
            return "Tu carrito está vacío."
        
        order = self.current_orders[session_id]
        summary = "RESUMEN DE TU PEDIDO:\n"
        summary += "=" * 30 + "\n"
        
        for item in order['items']:
            summary += f"{item['name']} x{item['quantity']} - ${item['subtotal']:.2f}\n"
        
        summary += "=" * 30 + "\n"
        summary += f"TOTAL: ${order['total']:.2f}"
        
        return summary
    
    def confirm_order(self, session_id: str) -> dict:
        """Confirma el pedido y lo marca como listo para procesar"""
        if session_id in self.current_orders:
            self.current_orders[session_id]['status'] = 'confirmed'
            self.current_orders[session_id]['confirmed_at'] = datetime.now().isoformat()
            return self.current_orders[session_id].copy()
        return {}
    
    def clear_order(self, session_id: str):
        """Limpia el pedido actual"""
        if session_id in self.current_orders:
            del self.current_orders[session_id]
    
    def process_order_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud relacionada con pedidos"""
        try:
            session_id = session.id
            
            # Inicializar pedido si no existe
            self.initialize_order(session_id)
            
            # Agregar contexto del pedido actual al mensaje
            current_order_summary = self.get_order_summary(session_id)
            enhanced_message = f"{message}\n\nPedido actual:\n{current_order_summary}"
            
            response = self.agent.run(enhanced_message, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema procesando tu pedido. ¿Podrías intentar de nuevo?"

def main():
    """Función de prueba para el agente de pedidos"""
    print("=== Agente de Pedidos - Prueba ===")
    
    order_agent = OrderAgent()
    session = Session(
        id="order_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    # Simular algunos elementos agregados al pedido
    order_agent.add_item_to_order("order_test_session", "Pizza Margarita", 1, 12.50)
    order_agent.add_item_to_order("order_test_session", "Coca Cola", 2, 2.50)
    
    print("Agente de pedidos inicializado con algunos elementos de prueba.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Solicitud de pedido: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = order_agent.process_order_request(user_input, session)
        print(f"Agente de Pedidos: {response}\n")
        
        # Mostrar resumen actual
        print(f"Estado actual: {order_agent.get_order_summary('order_test_session')}\n")

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/root_agent.py =====
"""
Agente Root (Orquestador) para el Sistema de Chatbot de Pedidos
Este agente será el punto de entrada principal y orquestará las interacciones
con los agentes especializados.
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import os

class RootAgent:
    def __init__(self):
        # Configurar el agente principal
        self.agent = LlmAgent(
            name="root_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres el agente principal de un sistema de chatbot para un restaurante.
            Tu función es orquestar las interacciones con los clientes y dirigir
            las solicitudes a los agentes especializados apropiados.
            
            Agentes disponibles:
            - menu_agent: Para consultas sobre el menú, precios y disponibilidad
            - order_agent: Para procesar pedidos y gestionar el carrito
            - customer_agent: Para registrar nuevos clientes
            - delivery_agent: Para gestionar direcciones de entrega
            
            Siempre mantén un tono amigable y profesional. Cuando un cliente
            haga una consulta, determina qué agente especializado debe manejarla
            y transfiere la conversación apropiadamente.
            """,
            description="Agente orquestador principal del sistema de pedidos",
        )
        
        # Estado de la conversación
        self.conversation_state = {
            "current_customer": None,
            "current_order": None,
            "active_agent": "root"
        }
    
    def process_message(self, message: str, session: Session = None) -> str:
        """
        Procesa un mensaje del cliente y determina la respuesta apropiada
        """
        if session is None:
            session = Session(
                id="chatbot_session_001",
                appName="restaurant_chatbot",
                userId="customer_001"
            )
        
        # Analizar la intención del mensaje
        intention = self._analyze_intention(message)
        
        # Dirigir al agente apropiado basado en la intención
        if intention == "menu_inquiry":
            return self._transfer_to_menu_agent(message, session)
        elif intention == "place_order":
            return self._transfer_to_order_agent(message, session)
        elif intention == "customer_registration":
            return self._transfer_to_customer_agent(message, session)
        elif intention == "delivery_info":
            return self._transfer_to_delivery_agent(message, session)
        else:
            # Manejar con el agente root
            return self._handle_general_inquiry(message, session)
    
    def _analyze_intention(self, message: str) -> str:
        """
        Analiza la intención del mensaje del cliente
        """
        message_lower = message.lower()
        
        # Palabras clave para diferentes intenciones
        menu_keywords = ["menú", "menu", "carta", "qué tienen", "precios", "platos", "comida"]
        order_keywords = ["pedido", "pedir", "quiero", "ordenar", "comprar"]
        customer_keywords = ["registro", "nuevo cliente", "primera vez", "registrarme"]
        delivery_keywords = ["dirección", "entrega", "delivery", "domicilio"]
        
        if any(keyword in message_lower for keyword in menu_keywords):
            return "menu_inquiry"
        elif any(keyword in message_lower for keyword in order_keywords):
            return "place_order"
        elif any(keyword in message_lower for keyword in customer_keywords):
            return "customer_registration"
        elif any(keyword in message_lower for keyword in delivery_keywords):
            return "delivery_info"
        else:
            return "general"
    
    def _transfer_to_menu_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de menú
        """
        # Por ahora, simularemos la respuesta del agente de menú
        return "Te ayudo con información sobre nuestro menú. ¿Qué te gustaría saber específicamente?"
    
    def _transfer_to_order_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de pedidos
        """
        return "¡Perfecto! Te ayudo a realizar tu pedido. ¿Qué te gustaría pedir hoy?"
    
    def _transfer_to_customer_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de registro de clientes
        """
        return "¡Bienvenido! Te ayudo con el registro. Necesitaré algunos datos básicos para comenzar."
    
    def _transfer_to_delivery_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de delivery
        """
        return "Te ayudo con la información de entrega. ¿Cuál es tu dirección de entrega?"
    
    def _handle_general_inquiry(self, message: str, session: Session) -> str:
        """
        Maneja consultas generales con el agente root
        """
        try:
            response = self.agent.run(message, session=session)
            return response.text if hasattr(response, 'text') else str(response)
        except Exception as e:
            return f"¡Hola! Soy tu asistente del restaurante. ¿En qué puedo ayudarte hoy? Puedo ayudarte con el menú, tomar tu pedido, registrarte como cliente o gestionar tu entrega."

def main():
    """
    Función principal para probar el agente root
    """
    print("=== Sistema de Chatbot de Pedidos ===")
    print("Iniciando agente root...")
    
    try:
        root_agent = RootAgent()
        session = Session(
            id="chatbot_session_001",
            appName="restaurant_chatbot", 
            userId="customer_001"
        )
        
        print("Agente root inicializado correctamente.")
        print("Escribe 'salir' para terminar la conversación.\n")
        
        while True:
            user_input = input("Cliente: ")
            
            if user_input.lower() in ['salir', 'exit', 'quit']:
                print("¡Gracias por usar nuestro servicio!")
                break
            
            response = root_agent.process_message(user_input, session)
            print(f"Chatbot: {response}\n")
            
    except Exception as e:
        print(f"Error al inicializar el agente root: {e}")
        print("Asegúrate de tener configuradas las credenciales de Google Cloud.")

if __name__ == "__main__":
    main()


===== data_entrenamiento/Proyectos_adkaget/test_system.py =====
"""
Script de pruebas para validar el funcionamiento del sistema de chatbot
"""

from integrated_chatbot import IntegratedChatbotSystem
import time

def test_customer_registration():
    """Prueba el registro de clientes"""
    print("=== Prueba de Registro de Clientes ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_registration")
    
    # Simular registro de cliente
    messages = [
        "Hola, soy nuevo cliente",
        "Mi nombre es Carlos Rodríguez, teléfono 555123456 y email carlos@test.com"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    # Verificar estado de la sesión
    session_state = chatbot.get_session_state(session.id)
    print(f"Estado de la sesión: {session_state}")
    
    return session_state.get('customer_id') is not None

def test_menu_inquiry():
    """Prueba las consultas de menú"""
    print("=== Prueba de Consultas de Menú ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_menu")
    
    # Simular consultas de menú
    messages = [
        "¿Qué pizzas tienen?",
        "¿Cuánto cuesta la pizza margarita?",
        "¿Tienen bebidas?"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    return True

def test_order_flow():
    """Prueba el flujo completo de pedido"""
    print("=== Prueba de Flujo de Pedido ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_order")
    
    # Simular flujo completo
    messages = [
        "Hola",
        "Soy Ana López, teléfono 666777888, email ana@test.com",
        "Quiero hacer un pedido",
        "Mi dirección es Calle Real 456, Madrid, CP 28001"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    return True

def test_database_operations():
    """Prueba las operaciones de base de datos"""
    print("=== Prueba de Operaciones de Base de Datos ===")
    
    from database_manager import DatabaseManager
    
    db = DatabaseManager("test_db.db")
    
    # Probar registro de cliente
    try:
        customer_id = db.register_customer({
            'nombre': 'Test',
            'apellido': 'User',
            'telefono': '111222333',
            'email': 'test@example.com'
        })
        print(f"Cliente registrado con ID: {customer_id}")
        
        # Buscar cliente
        customer = db.get_customer_by_phone('111222333')
        print(f"Cliente encontrado: {customer}")
        
        # Crear dirección
        address_id = db.save_delivery_address({
            'cliente_id': customer_id,
            'calle': 'Test Street',
            'numero': '123',
            'ciudad': 'Test City',
            'direccion_completa': 'Test Street 123, Test City'
        })
        print(f"Dirección creada con ID: {address_id}")
        
        # Crear pedido
        order_id = db.create_order({
            'cliente_id': customer_id,
            'total': 15.50,
            'direccion_entrega_id': address_id
        })
        print(f"Pedido creado con ID: {order_id}")
        
        # Agregar elementos
        items = [
            {'name': 'Test Pizza', 'quantity': 1, 'price': 12.00, 'subtotal': 12.00},
            {'name': 'Test Drink', 'quantity': 1, 'price': 3.50, 'subtotal': 3.50}
        ]
        db.add_order_items(order_id, items)
        print("Elementos agregados al pedido")
        
        # Obtener detalles
        order_details = db.get_order_details(order_id)
        print(f"Detalles del pedido: {order_details}")
        
        return True
        
    except Exception as e:
        print(f"Error en prueba de base de datos: {e}")
        return False

def run_all_tests():
    """Ejecuta todas las pruebas"""
    print("=== EJECUTANDO TODAS LAS PRUEBAS ===\n")
    
    tests = [
        ("Operaciones de Base de Datos", test_database_operations),
        ("Consultas de Menú", test_menu_inquiry),
        ("Registro de Clientes", test_customer_registration),
        ("Flujo de Pedido", test_order_flow)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        print(f"\n{'='*50}")
        print(f"Ejecutando: {test_name}")
        print('='*50)
        
        try:
            result = test_func()
            results[test_name] = "PASÓ" if result else "FALLÓ"
            print(f"Resultado: {results[test_name]}")
        except Exception as e:
            results[test_name] = f"ERROR: {e}"
            print(f"Resultado: {results[test_name]}")
        
        time.sleep(2)
    
    # Resumen final
    print(f"\n{'='*50}")
    print("RESUMEN DE PRUEBAS")
    print('='*50)
    
    for test_name, result in results.items():
        status_icon = "✅" if result == "PASÓ" else "❌"
        print(f"{status_icon} {test_name}: {result}")
    
    passed_tests = sum(1 for result in results.values() if result == "PASÓ")
    total_tests = len(results)
    
    print(f"\nPruebas pasadas: {passed_tests}/{total_tests}")
    
    if passed_tests == total_tests:
        print("🎉 ¡Todas las pruebas pasaron exitosamente!")
    else:
        print("⚠️  Algunas pruebas fallaron. Revisar los errores arriba.")

if __name__ == "__main__":
    run_all_tests()


