<!-- path: PLAN.md -->
```markdown
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
```