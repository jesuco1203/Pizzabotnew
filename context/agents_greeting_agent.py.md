<!-- path: agents/greeting_agent.py -->
```python
from google.adk.agents import Agent

greeting_agent = Agent(
    name="GreetingAgent",
    model="gemini-2.0-flash",
    description="Agente especializado en saludar y dar la bienvenida a los clientes.",
    instruction="""Eres un asistente amigable de pizzería. Tu tarea es proporcionar saludos amables y respuestas de bienvenida cuando se te solicite.
    """,
    tools=[] # Este agente no necesita herramientas por ahora, solo genera texto.
)
```