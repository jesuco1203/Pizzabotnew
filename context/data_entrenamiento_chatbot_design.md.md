<!-- path: data_entrenamiento/chatbot_design.md -->
```markdown
# Diseño del Sistema de Chatbot Multi-Agente para Pizzería

## 1. Visión General y Arquitectura

El sistema se diseñará siguiendo una arquitectura de **orquestación multi-agente**, donde un agente coordinador (el "gerente") dirige el flujo de la conversación y delega tareas a agentes especializados (los "empleados"). Esta arquitectura modular y jerárquica permitirá una clara separación de responsabilidades, facilitando el desarrollo, la depuración y la escalabilidad.

**Componentes Principales:**

1.  **Agente Coordinador (Gerente):** Un `BaseAgent` que no interactúa directamente con el usuario. Su única función es actuar como una máquina de estados, analizando el estado actual de la conversación (`session.state`) y delegando la tarea al agente especializado apropiado.
2.  **Agentes Especializados (Empleados):** Varios `LlmAgent`, cada uno con una `instruction` y un conjunto de `tools` muy específicos para una fase de la conversación (saludar, tomar el pedido, confirmar, etc.).
3.  **Herramientas (Tools):** Funciones Python deterministas que interactúan con los "sistemas externos" (en este caso, archivos JSON que simulan bases de datos de clientes, menú y pedidos).
4.  **Estado de la Sesión (`session.state`):** Un diccionario que actúa como la memoria a corto plazo de la conversación, manteniendo toda la información relevante (fase de la conversación, datos del usuario, pedido actual, etc.).

## 2. Flujo de la Conversación (Máquina de Estados)

El `CoordinatorAgent` gestionará las transiciones entre las siguientes fases:

1.  **`SALUDO` (Inicial):**
    *   **Agente Responsable:** `UserManagementAgent`.
    *   **Objetivo:** Identificar al cliente.
    *   **Lógica:**
        1.  Llamar a la herramienta `check_user_in_db()`.
        2.  Si el usuario existe, saludarlo por su nombre y pasar a la fase `TOMANDO_PEDIDO`.
        3.  Si el usuario no existe, pedirle su nombre.
        4.  Una vez que el usuario proporciona su nombre, llamar a `register_new_user()` y luego pasar a `TOMANDO_PEDIDO`.

2.  **`TOMANDO_PEDIDO`:**
    *   **Agente Responsable:** `OrderAgent` y `MenuAgent`.
    *   **Objetivo:** Construir el pedido del cliente.
    *   **Lógica del Coordinador:**
        *   Analizar la intención del usuario. Si la intención es sobre el menú (ej. "¿qué pizzas tienes?"), delegar a `MenuAgent`.
        *   Si la intención es agregar/quitar/modificar un ítem, delegar a `OrderAgent`.
        *   Si el usuario dice "eso es todo" o similar, cambiar la fase a `CONFIRMANDO_PEDIDO`.

3.  **`CONFIRMANDO_PEDIDO`:**
    *   **Agente Responsable:** `ConfirmationAgent`.
    *   **Objetivo:** Mostrar el resumen del pedido y obtener la confirmación del cliente.
    *   **Lógica:**
        1.  Llamar a la herramienta `get_current_order()`.
        2.  Presentar el resumen (ítems, total, etc.).
        3.  Si el usuario confirma, pasar a la fase `RECOGIENDO_DIRECCION`.
        4.  Si el usuario quiere modificar, volver a la fase `TOMANDO_PEDIDO`.

4.  **`RECOGIENDO_DIRECCION`:**
    *   **Agente Responsable:** `AddressAgent`.
    *   **Objetivo:** Obtener la dirección de entrega.
    *   **Lógica:**
        1.  Pedir la dirección al usuario.
        2.  Llamar a la herramienta `save_address()`.
        3.  Pasar a la fase `FINALIZACION`.

5.  **`FINALIZACION`:**
    *   **Agente Responsable:** `FinalizationAgent`.
    *   **Objetivo:** Guardar el pedido final y despedirse.
    *   **Lógica:**
        1.  Llamar a la herramienta `finalize_order()` para escribir en la "base de datos" de pedidos.
        2.  Agradecer al cliente y dar un mensaje de despedida.
        3.  Finalizar la conversación.

## 3. Diseño Detallado de Agentes y Herramientas

### Agentes

1.  **`CoordinatorAgent` (`BaseAgent`):**
    *   **Lógica Principal:** `_run_async_impl` contendrá la máquina de estados (un `if/elif/else` o un diccionario de fases) que delega al sub-agente correspondiente según `ctx.session.state['conversation_phase']`.

2.  **`UserManagementAgent` (`LlmAgent`):**
    *   **Instruction:** "Eres el agente de bienvenida. Verifica si el usuario existe con `check_user_in_db`. Si no, pide su nombre y regístralo con `extract_and_register_name`. Saluda al usuario por su nombre."
    *   **Tools:** `[check_user_in_db, extract_and_register_name]`

3.  **`MenuAgent` (`LlmAgent`):**
    *   **Instruction:** "Eres un experto en el menú. Usa `get_menu` para responder preguntas sobre los platos disponibles."
    *   **Tools:** `[get_menu]`

4.  **`OrderAgent` (`LlmAgent`):**
    *   **Instruction:** "Ayuda al cliente a gestionar su pedido. Usa `add_item_to_order`, `remove_item_from_order`, etc. Si un producto no está claro, pide clarificación."
    *   **Tools:** `[add_item_to_order, remove_item_from_order, get_current_order]`

5.  **`ConfirmationAgent` (`LlmAgent`):**
    *   **Instruction:** "Presenta el resumen del pedido usando `get_current_order` y pregunta por la confirmación. Si el usuario confirma, responde con la palabra clave 'PEDIDO_CONFIRMADO'. Si quiere cambiar algo, responde con 'MODIFICAR_PEDIDO'."
    *   **Tools:** `[get_current_order]`

6.  **`AddressAgent` (`LlmAgent`):**
    *   **Instruction:** "Pide la dirección de entrega al usuario y guárdala usando la herramienta `save_address`."
    *   **Tools:** `[save_address]`

7.  **`FinalizationAgent` (`LlmAgent`):**
    *   **Instruction:** "Guarda el pedido final con `finalize_order` y despídete amablemente."
    *   **Tools:** `[finalize_order]`

### Herramientas (Tools)

*   **`tools/user_tools.py`**
    *   `check_user_in_db(user_id)`: Lee `clientes.json`.
    *   `extract_and_register_name(user_message)`: Procesa el texto para extraer un nombre y lo guarda en `clientes.json`.
    *   `save_address(address)`: Guarda la dirección en `session.state`.
*   **`tools/menu_tools.py`**
    *   `get_menu()`: Lee `menu.json` y lo devuelve formateado.
*   **`tools/order_tools.py`**
    *   `add_item_to_order(item, quantity, size)`: Añade/modifica un ítem en `session.state['current_order']`.
    *   `remove_item_from_order(item)`: Elimina un ítem.
    *   `get_current_order()`: Devuelve el contenido de `session.state['current_order']`.
*   **`tools/finalization_tools.py`**
    *   `finalize_order()`: Lee los datos de la sesión (`user_name`, `current_order`, `address`) y los escribe en `pedidos.json`.

## 4. Gestión del Estado (`session.state`)

El `session.state` será el pilar de la comunicación entre agentes. Contendrá, como mínimo:

```json
{
  "conversation_phase": "SALUDO",
  "user_id": "...",
  "user_identified": false,
  "user_name": null,
  "awaiting_user_name": false,
  "current_order": {
    "items": [],
    "total": 0.0
  },
  "address": null,
  "order_confirmed": false
}
```

Cada agente especializado será responsable de leer el estado que necesita y, crucialmente, el `CoordinatorAgent` será responsable de actualizar la `conversation_phase` para dirigir el flujo.

## 5. Siguientes Pasos

1.  **Implementar la estructura de carpetas y archivos vacíos.**
2.  **Desarrollar las herramientas (Tools) con su lógica determinista.**
3.  **Crear cada Agente Especializado con sus `instructions` y `tools` correspondientes.**
4.  **Implementar el `CoordinatorAgent` con la máquina de estados.**
5.  **Crear un `main.py` o un script de prueba para ejecutar el `CoordinatorAgent` y simular una conversación.**

Este diseño proporciona una base sólida y modular para construir un chatbot robusto y fácil de mantener.
```