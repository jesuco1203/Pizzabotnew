<!-- path: agents/finalization_agent.py -->
```python
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
```