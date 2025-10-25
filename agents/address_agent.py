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
