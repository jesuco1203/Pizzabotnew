


import asyncio
from dotenv import load_dotenv
from google.adk.agents import Agent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai.types import Content, Part
from agents.coordinator_agent import coordinator_agent
import json
import os # Importar os
import time # Importar time

# Cargar variables de entorno desde .env
load_dotenv()

async def run_test_conversation():
    """Runs a predefined conversation flow to test the agent's state management."""
    session_service = InMemorySessionService()
    app_name = "pizzabot_test_app"
    user_id = "test_user_001"
    session_id = "test_session_001"

    # Limpiar archivos de datos al inicio del test
    clientes_path = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/clientes.json"
    pedidos_path = "/Users/jesuco1203/Docs_mac/Pizzabotnew/data/pedidos.json"
    if os.path.exists(clientes_path):
        os.remove(clientes_path)
        print(f"DEBUG: Eliminado {clientes_path}")
    if os.path.exists(pedidos_path):
        os.remove(pedidos_path)
        print(f"DEBUG: Eliminado {pedidos_path}")

    await session_service.create_session(
        app_name=app_name,
        user_id=user_id,
        session_id=session_id,
        state={
            "conversation_phase": "TOMANDO_PEDIDO",
            "user_identified": True,
            "user_name": "TesterUser",
            "awaiting_user_name": False,
            "user_checked_db": True,
            "db_check_result": {"exists": True, "name": "TesterUser"}
        }
    )

    runner = Runner(
        agent=coordinator_agent,
        app_name=app_name,
        session_service=session_service
    )

    conversation_flow = [
        "quiero una piza de peperoni",
        "familiar",
        "y una pepsi",
        "500 ml",
        "quiero una pizza hawaiana familiar",
        "muéstrame mi pedido",
        "es todo",
        "sí, confirmo",
        "en calle luna 45, ciudad del sol",
        "listo"
    ]

    print("--- INICIANDO PRUEBA DE FLUJO DE PEDIDOS ---")

    for i, query in enumerate(conversation_flow):
        print(f"\n--- TURNO {i+1}: ENTRADA DEL USUARIO ---")
        print(f">>> Usuario: {query}")

        content = Content(role='user', parts=[Part(text=query)])
        
        final_response_text = "Agente no produjo una respuesta final."
        async for event in runner.run_async(user_id=user_id, session_id=session_id, new_message=content):
            if event.is_final_response() and event.content and event.content.parts:
                final_response_text = event.content.parts[0].text

        print(f"<<< Agente: {final_response_text}")

        # Imprimir el estado de la sesión después de cada turno
        current_session = await session_service.get_session(app_name=app_name, user_id=user_id, session_id=session_id)
        print("--- ESTADO DE LA SESIÓN DESPUÉS DEL TURNO ---")
        print(json.dumps(current_session.state, indent=2))
        print("------------------------------------------")
        time.sleep(5) # Pausa de 5 segundos para respetar la cuota de la API

    print("\n--- PRUEBA DE FLUJO DE PEDIDOS FINALIZADA ---")

if __name__ == "__main__":
    asyncio.run(run_test_conversation())
