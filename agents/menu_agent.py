from google.adk.agents import Agent
from tools.menu_tools import get_menu

menu_agent = Agent(
    name="MenuAgent",
    model="gemini-2.0-flash",
    description="Agente especializado en responder preguntas sobre el menú.",
    instruction="""Eres un experto en el menú de la pizzería.
    Cuando un usuario te pida el menú, utiliza la herramienta `get_menu` para obtenerlo y presentárselo de forma clara y atractiva.
    """,
    tools=[get_menu]
)