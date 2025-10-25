from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions

from app.function_calling import handle_model_parts
from tools.order_tools import get_current_order  # Reutilizamos esta herramienta

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
            if event.content and getattr(event.content, "parts", None):
                if event.actions and getattr(event.actions, "state_delta", None):
                    ctx.session.state.update(event.actions.state_delta)
                reply_text = handle_model_parts(event.content.parts)
                if reply_text:
                    event.content = Content(parts=[Part(text=reply_text)])
            yield event
        print(f"DEBUG: ConfirmationAgent: LLM de confirmación finalizado. Nuevo estado: {ctx.session.state}")

confirmation_agent = ConfirmationAgent()
