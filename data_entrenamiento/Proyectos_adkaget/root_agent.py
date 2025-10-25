"""
Agente Root (Orquestador) para el Sistema de Chatbot de Pedidos
Este agente será el punto de entrada principal y orquestará las interacciones
con los agentes especializados.
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import os

class RootAgent:
    def __init__(self):
        # Configurar el agente principal
        self.agent = LlmAgent(
            name="root_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres el agente principal de un sistema de chatbot para un restaurante.
            Tu función es orquestar las interacciones con los clientes y dirigir
            las solicitudes a los agentes especializados apropiados.
            
            Agentes disponibles:
            - menu_agent: Para consultas sobre el menú, precios y disponibilidad
            - order_agent: Para procesar pedidos y gestionar el carrito
            - customer_agent: Para registrar nuevos clientes
            - delivery_agent: Para gestionar direcciones de entrega
            
            Siempre mantén un tono amigable y profesional. Cuando un cliente
            haga una consulta, determina qué agente especializado debe manejarla
            y transfiere la conversación apropiadamente.
            """,
            description="Agente orquestador principal del sistema de pedidos",
        )
        
        # Estado de la conversación
        self.conversation_state = {
            "current_customer": None,
            "current_order": None,
            "active_agent": "root"
        }
    
    def process_message(self, message: str, session: Session = None) -> str:
        """
        Procesa un mensaje del cliente y determina la respuesta apropiada
        """
        if session is None:
            session = Session(
                id="chatbot_session_001",
                appName="restaurant_chatbot",
                userId="customer_001"
            )
        
        # Analizar la intención del mensaje
        intention = self._analyze_intention(message)
        
        # Dirigir al agente apropiado basado en la intención
        if intention == "menu_inquiry":
            return self._transfer_to_menu_agent(message, session)
        elif intention == "place_order":
            return self._transfer_to_order_agent(message, session)
        elif intention == "customer_registration":
            return self._transfer_to_customer_agent(message, session)
        elif intention == "delivery_info":
            return self._transfer_to_delivery_agent(message, session)
        else:
            # Manejar con el agente root
            return self._handle_general_inquiry(message, session)
    
    def _analyze_intention(self, message: str) -> str:
        """
        Analiza la intención del mensaje del cliente
        """
        message_lower = message.lower()
        
        # Palabras clave para diferentes intenciones
        menu_keywords = ["menú", "menu", "carta", "qué tienen", "precios", "platos", "comida"]
        order_keywords = ["pedido", "pedir", "quiero", "ordenar", "comprar"]
        customer_keywords = ["registro", "nuevo cliente", "primera vez", "registrarme"]
        delivery_keywords = ["dirección", "entrega", "delivery", "domicilio"]
        
        if any(keyword in message_lower for keyword in menu_keywords):
            return "menu_inquiry"
        elif any(keyword in message_lower for keyword in order_keywords):
            return "place_order"
        elif any(keyword in message_lower for keyword in customer_keywords):
            return "customer_registration"
        elif any(keyword in message_lower for keyword in delivery_keywords):
            return "delivery_info"
        else:
            return "general"
    
    def _transfer_to_menu_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de menú
        """
        # Por ahora, simularemos la respuesta del agente de menú
        return "Te ayudo con información sobre nuestro menú. ¿Qué te gustaría saber específicamente?"
    
    def _transfer_to_order_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de pedidos
        """
        return "¡Perfecto! Te ayudo a realizar tu pedido. ¿Qué te gustaría pedir hoy?"
    
    def _transfer_to_customer_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de registro de clientes
        """
        return "¡Bienvenido! Te ayudo con el registro. Necesitaré algunos datos básicos para comenzar."
    
    def _transfer_to_delivery_agent(self, message: str, session: Session) -> str:
        """
        Transfiere la conversación al agente de delivery
        """
        return "Te ayudo con la información de entrega. ¿Cuál es tu dirección de entrega?"
    
    def _handle_general_inquiry(self, message: str, session: Session) -> str:
        """
        Maneja consultas generales con el agente root
        """
        try:
            response = self.agent.run(message, session=session)
            return response.text if hasattr(response, 'text') else str(response)
        except Exception as e:
            return f"¡Hola! Soy tu asistente del restaurante. ¿En qué puedo ayudarte hoy? Puedo ayudarte con el menú, tomar tu pedido, registrarte como cliente o gestionar tu entrega."

def main():
    """
    Función principal para probar el agente root
    """
    print("=== Sistema de Chatbot de Pedidos ===")
    print("Iniciando agente root...")
    
    try:
        root_agent = RootAgent()
        session = Session(
            id="chatbot_session_001",
            appName="restaurant_chatbot", 
            userId="customer_001"
        )
        
        print("Agente root inicializado correctamente.")
        print("Escribe 'salir' para terminar la conversación.\n")
        
        while True:
            user_input = input("Cliente: ")
            
            if user_input.lower() in ['salir', 'exit', 'quit']:
                print("¡Gracias por usar nuestro servicio!")
                break
            
            response = root_agent.process_message(user_input, session)
            print(f"Chatbot: {response}\n")
            
    except Exception as e:
        print(f"Error al inicializar el agente root: {e}")
        print("Asegúrate de tener configuradas las credenciales de Google Cloud.")

if __name__ == "__main__":
    main()

