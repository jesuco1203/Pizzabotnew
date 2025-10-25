<!-- path: agents/user_management_agent.py -->
```python
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
```