import re

from google.adk.agents import Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions

from app.function_calling import handle_model_parts
from tools.user_tools import check_user_in_db, extract_and_register_name
from app.utils import extract_person_name


def _normalize_name(raw: str | None) -> str | None:
    if not raw:
        return None
    name = extract_person_name(raw)
    if name:
        return name
    return raw.strip().title()

class UserManagementAgent(Agent):
    def __init__(self, **kwargs):
        super().__init__(
            name="UserManagementAgent",
            model="gemini-2.0-flash",
            description="Agente especializado en la gestión inicial de usuarios, verificando su existencia y registrando nuevos usuarios.",
            instruction="""Eres el agente de gestión de usuarios. Tu tarea es verificar si un usuario existe en la base de datos.
            Siempre debes comenzar llamando a la herramienta `check_user_in_db` para saber si el usuario ya está registrado.
            Si la base no tiene su nombre (exists = False), DEBES responder exclusivamente con una pregunta directa solicitando el nombre.
            La pregunta debe contener literalmente la frase "¿Cómo te llamas?" y NO debes incluir un nombre en tu respuesta.
            Está PROHIBIDO inventar, deducir o repetir un nombre que aparezca en el mensaje del usuario mientras `user_identified` sea False.
            Si el usuario no proporciona un nombre válido o evade la pregunta, insiste educadamente. Cada turno sin nombre debe terminar en "¿Cómo te llamas?".
            Una vez que tengas el nombre, regístralo con la herramienta `extract_and_register_name`.
            Si `extract_and_register_name` devuelve `clarification_needed`, significa que no se pudo extraer un nombre válido y debes volver a pedirlo.
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
                if event.content and getattr(event.content, "parts", None):
                    if event.actions and getattr(event.actions, "state_delta", None):
                        ctx.session.state.update(event.actions.state_delta)
                    reply_text = handle_model_parts(event.content.parts)
                    user_name = _normalize_name(ctx.session.state.get("user_name"))
                    if user_name:
                        ctx.session.state["user_name"] = user_name
                    if ctx.session.state.get("user_identified") and ctx.session.state.get("user_name"):
                        if not reply_text or "¿cómo te llamas?" in reply_text.lower():
                            reply_text = f"Hola {ctx.session.state['user_name']}, bienvenido. ¿En qué puedo ayudarte?"
                    if reply_text:
                        event.content = Content(parts=[Part(text=reply_text)])
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
