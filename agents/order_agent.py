from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from google.adk.tools import ToolContext
from tools.order_tools import process_item_request, get_current_order
from tools.size_validation_tool import size_validation_tool
from google.adk.events import Event, EventActions
from google.genai.types import Content, Part

from app.function_calling import handle_model_parts

class OrderAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="OrderAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en gestionar el pedido actual del cliente.",
            # Aislamos al agente del historial para que no se confunda con saludos pasados.
            include_contents='none',
            tools=[process_item_request, get_current_order, size_validation_tool],
            instruction="""
            Eres un agente especializado en procesar pedidos de restaurante.
            Tu función es ayudar a los clientes a agregar elementos a su pedido, modificar cantidades,
            confirmar pedidos y calcular totales.

            Utiliza la herramienta `process_item_request` para añadir o modificar ítems en el carrito.
            Cuando el usuario pida un artículo, intenta añadirlo al carrito usando `process_item_request`.
            Si el usuario especifica un tamaño (ej. "grande", "mediana", "familiar") o una cantidad (ej. "dos", "2")
            junto con el artículo, asegúrate de pasar esos valores a los argumentos `size` y `quantity`
            de `process_item_request` respectivamente.

            Antes de aceptar un tamaño, llama a la tool `SizeValidationTool` para validar y normalizar el valor.
            Si la tool indica que el tamaño no es válido, debes informar al usuario las opciones disponibles.

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
        session_state = ctx.session.state

        if session_state.get("pending_size"):
            # Fuente única y confiable del texto del usuario
            user_message = (ctx.session.state.get("latest_user_text") or "").strip()

            # Fallback defensivo por si en algún flujo faltara (no debería, con el cambio del Coordinator)
            if not user_message:
                # intenta extraer desde el propio invocation si existe
                try:
                    parts = getattr(getattr(ctx, "invocation_id", None), "content", None)
                except Exception:
                    parts = None
                # Si aun así no hay texto, corta amablemente
                if not user_message:
                    yield Event(invocation_id=ctx.invocation_id, author=self.name,
                                content=Content(parts=[Part(text="¿Podrías repetir tu mensaje?")]))
                    return
            # Create a ToolContext object to pass to the size_validation_tool
            tool_context = ToolContext(session=ctx.session)
            validation_result = await size_validation_tool(tool_context, user_message)

            if validation_result.get("is_valid"):
                item_identifier = session_state.get("item_to_clarify", {}).get("Nombre_Base")
                if item_identifier:
                    # Create a ToolContext object to pass to the process_item_request tool
                    tool_context = ToolContext(session=ctx.session)
                    result = await process_item_request(
                        tool_context=tool_context,
                        item_identifier=item_identifier,
                        size=validation_result.get("normalized_size")
                    )
                    # The result of process_item_request is a dictionary with the new state
                    ctx.session.state.update(result)
                    # Yield an event with the bot's response
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        content=Content(parts=[Part(text=result.get("text", ""))]),
                    )
                    return

        # La lógica de manejo de item_to_clarify y el procesamiento de mensajes
        # se delega a la instrucción del LLM y a las herramientas.
        # El LLM, guiado por la instrucción, decidirá cuándo llamar a process_item_request
        # y cómo manejar sus respuestas (incluyendo clarification_needed).
        tool_registry = {tool.__name__: tool for tool in self.tools}
        async for event in super()._run_async_impl(ctx):
            if event.content and getattr(event.content, "parts", None):
                if event.actions and getattr(event.actions, "state_delta", None):
                    ctx.session.state.update(event.actions.state_delta)
                
                reply_text, new_state = await handle_model_parts(
                    parts=event.content.parts,
                    session_state=ctx.session.state,
                    tool_registry=tool_registry
                )
                ctx.session.state.update(new_state)

                if reply_text:
                    event.content = Content(parts=[Part(text=reply_text)])
            yield event
        print(f"DEBUG: OrderAgent: LLM de pedido finalizado. Nuevo estado: {ctx.session.state}")

order_agent = OrderAgent()
