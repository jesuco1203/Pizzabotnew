<!-- path: agents/order_agent.py -->
```python
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
```