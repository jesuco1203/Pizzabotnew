"""
Sistema Integrado de Chatbot Multi-Agente para Restaurante
Integra todos los agentes especializados con la base de datos y el menú
"""

from google.adk.sessions import Session
from menu_agent import MenuAgent
from order_agent import OrderAgent
from customer_agent import CustomerRegistrationAgent
from delivery_agent import DeliveryAgent
from database_manager import DatabaseManager
import json
from datetime import datetime

class IntegratedChatbotSystem:
    def __init__(self, menu_file: str = "menu.csv", db_file: str = "restaurant_chatbot.db"):
        # Inicializar componentes
        self.menu_agent = MenuAgent(menu_file)
        self.order_agent = OrderAgent()
        self.customer_agent = CustomerRegistrationAgent()
        self.delivery_agent = DeliveryAgent()
        self.db_manager = DatabaseManager(db_file)
        
        # Estado del sistema
        self.active_sessions = {}
        
        print("Sistema integrado de chatbot inicializado correctamente")
    
    def create_session(self, user_id: str = None) -> Session:
        """Crea una nueva sesión para un usuario"""
        if not user_id:
            user_id = f"user_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        session = Session(
            id=f"session_{user_id}",
            appName="restaurant_chatbot",
            userId=user_id
        )
        
        # Inicializar estado de la sesión
        self.active_sessions[session.id] = {
            'user_id': user_id,
            'current_agent': 'root',
            'customer_id': None,
            'conversation_state': 'greeting',
            'created_at': datetime.now().isoformat()
        }
        
        return session
    
    def analyze_message_intention(self, message: str) -> str:
        """Analiza la intención del mensaje del usuario"""
        message_lower = message.lower()
        
        # Palabras clave para diferentes intenciones
        menu_keywords = ["menú", "menu", "carta", "qué tienen", "precios", "platos", "comida", "pizzas", "hamburguesas", "bebidas", "postres"]
        order_keywords = ["pedido", "pedir", "quiero", "ordenar", "comprar", "agregar", "añadir"]
        customer_keywords = ["registro", "nuevo cliente", "primera vez", "registrarme", "soy nuevo"]
        delivery_keywords = ["dirección", "entrega", "delivery", "domicilio", "envío"]
        confirmation_keywords = ["confirmar", "sí", "si", "correcto", "está bien", "ok", "vale"]
        
        if any(keyword in message_lower for keyword in menu_keywords):
            return "menu_inquiry"
        elif any(keyword in message_lower for keyword in order_keywords):
            return "place_order"
        elif any(keyword in message_lower for keyword in customer_keywords):
            return "customer_registration"
        elif any(keyword in message_lower for keyword in delivery_keywords):
            return "delivery_info"
        elif any(keyword in message_lower for keyword in confirmation_keywords):
            return "confirmation"
        else:
            return "general"
    
    def process_message(self, message: str, session: Session) -> str:
        """Procesa un mensaje del usuario y coordina la respuesta entre agentes"""
        try:
            session_id = session.id
            
            # Verificar si la sesión existe
            if session_id not in self.active_sessions:
                self.active_sessions[session_id] = {
                    'user_id': session.userId,
                    'current_agent': 'root',
                    'customer_id': None,
                    'conversation_state': 'greeting'
                }
            
            session_state = self.active_sessions[session_id]
            intention = self.analyze_message_intention(message)
            
            # Manejar según la intención y el estado actual
            if intention == "menu_inquiry":
                return self._handle_menu_inquiry(message, session)
            
            elif intention == "place_order":
                return self._handle_order_request(message, session)
            
            elif intention == "customer_registration":
                return self._handle_customer_registration(message, session)
            
            elif intention == "delivery_info":
                return self._handle_delivery_request(message, session)
            
            elif intention == "confirmation":
                return self._handle_confirmation(message, session)
            
            else:
                return self._handle_general_inquiry(message, session)
                
        except Exception as e:
            return f"Lo siento, hubo un problema procesando tu mensaje. ¿Podrías intentar de nuevo?"
    
    def _handle_menu_inquiry(self, message: str, session: Session) -> str:
        """Maneja consultas sobre el menú"""
        self.active_sessions[session.id]['current_agent'] = 'menu'
        return self.menu_agent.process_menu_query(message, session)
    
    def _handle_order_request(self, message: str, session: Session) -> str:
        """Maneja solicitudes de pedidos"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'order'
        
        # Verificar si el cliente está registrado
        if not self.active_sessions[session_id]['customer_id']:
            return "Para realizar un pedido, primero necesito que te registres. ¿Eres un cliente nuevo o ya tienes cuenta con nosotros? Si eres nuevo, por favor proporciona tu nombre completo, teléfono y email."
        
        return self.order_agent.process_order_request(message, session)
    
    def _handle_customer_registration(self, message: str, session: Session) -> str:
        """Maneja el registro de clientes"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'customer'
        
        response = self.customer_agent.process_registration_request(message, session)
        
        # Verificar si el registro está completo
        registration_status = self.customer_agent.get_registration_status(session_id)
        if registration_status and registration_status['is_complete']:
            validation = self.customer_agent.validate_registration_data(session_id)
            if validation['valid']:
                # Guardar cliente en la base de datos
                try:
                    customer_data = registration_status['data']
                    customer_id = self.db_manager.register_customer({
                        'nombre': customer_data['nombre'],
                        'apellido': customer_data['apellido'],
                        'telefono': customer_data['telefono'],
                        'email': customer_data['email']
                    })
                    
                    self.active_sessions[session_id]['customer_id'] = customer_id
                    self.customer_agent.complete_registration(session_id)
                    
                    response += f"\n\n¡Registro completado exitosamente! Ahora puedes realizar tu pedido."
                    
                except ValueError as e:
                    response += f"\n\nError en el registro: {e}. ¿Podrías verificar tu información?"
        
        return response
    
    def _handle_delivery_request(self, message: str, session: Session) -> str:
        """Maneja solicitudes de información de entrega"""
        session_id = session.id
        self.active_sessions[session_id]['current_agent'] = 'delivery'
        
        response = self.delivery_agent.process_delivery_request(message, session)
        
        # Verificar si la información de entrega está completa
        delivery_status = self.delivery_agent.get_delivery_status(session_id)
        if delivery_status and delivery_status['is_complete']:
            # Guardar dirección en la base de datos si hay un cliente registrado
            customer_id = self.active_sessions[session_id].get('customer_id')
            if customer_id:
                try:
                    delivery_data = delivery_status['data']
                    address_id = self.db_manager.save_delivery_address({
                        'cliente_id': customer_id,
                        'calle': delivery_data['calle'],
                        'numero': delivery_data['numero'],
                        'ciudad': delivery_data['ciudad'],
                        'codigo_postal': delivery_data['codigo_postal'],
                        'referencia': delivery_data['referencia'],
                        'direccion_completa': delivery_data['direccion_completa']
                    })
                    
                    self.active_sessions[session_id]['address_id'] = address_id
                    response += f"\n\nDirección guardada correctamente. ¿Hay algo más en lo que pueda ayudarte?"
                    
                except Exception as e:
                    response += f"\n\nHubo un problema guardando la dirección. Por favor, inténtalo de nuevo."
        
        return response
    
    def _handle_confirmation(self, message: str, session: Session) -> str:
        """Maneja confirmaciones del usuario"""
        session_id = session.id
        current_agent = self.active_sessions[session_id]['current_agent']
        
        if current_agent == 'order':
            # Confirmar pedido
            return self._confirm_order(session)
        else:
            return "¿Qué te gustaría confirmar? Puedo ayudarte con tu pedido, registro o información de entrega."
    
    def _confirm_order(self, session: Session) -> str:
        """Confirma y procesa un pedido completo"""
        session_id = session.id
        customer_id = self.active_sessions[session_id].get('customer_id')
        
        if not customer_id:
            return "Para confirmar el pedido, primero necesitas registrarte como cliente."
        
        # Obtener pedido actual
        if session_id in self.order_agent.current_orders:
            order_data = self.order_agent.current_orders[session_id]
            
            if not order_data['items']:
                return "No tienes elementos en tu pedido. ¿Qué te gustaría pedir?"
            
            try:
                # Crear pedido en la base de datos
                address_id = self.active_sessions[session_id].get('address_id')
                
                db_order_id = self.db_manager.create_order({
                    'cliente_id': customer_id,
                    'total': order_data['total'],
                    'direccion_entrega_id': address_id,
                    'estado': 'confirmado'
                })
                
                # Agregar elementos del pedido
                self.db_manager.add_order_items(db_order_id, order_data['items'])
                
                # Confirmar en el agente de pedidos
                self.order_agent.confirm_order(session_id)
                
                # Generar resumen final
                order_summary = self.order_agent.get_order_summary(session_id)
                
                response = f"¡Pedido confirmado exitosamente!\n\n"
                response += f"Número de pedido: {db_order_id}\n"
                response += f"{order_summary}\n\n"
                response += f"Tu pedido estará listo en aproximadamente 30-45 minutos.\n"
                response += f"¡Gracias por tu preferencia!"
                
                # Limpiar el pedido de la sesión
                self.order_agent.clear_order(session_id)
                
                return response
                
            except Exception as e:
                return f"Hubo un problema confirmando tu pedido. Por favor, inténtalo de nuevo."
        
        return "No tienes un pedido activo para confirmar."
    
    def _handle_general_inquiry(self, message: str, session: Session) -> str:
        """Maneja consultas generales"""
        return """¡Hola! Soy tu asistente del restaurante. Puedo ayudarte con:

🍕 Consultar nuestro menú y precios
🛒 Realizar pedidos
👤 Registrarte como cliente
🚚 Gestionar información de entrega

¿En qué puedo ayudarte hoy?"""
    
    def get_session_state(self, session_id: str) -> dict:
        """Obtiene el estado actual de una sesión"""
        return self.active_sessions.get(session_id, {})

def main():
    """Función principal para probar el sistema integrado"""
    print("=== Sistema Integrado de Chatbot Multi-Agente ===")
    print("Inicializando sistema...")
    
    try:
        chatbot_system = IntegratedChatbotSystem()
        session = chatbot_system.create_session("test_user")
        
        print("Sistema inicializado correctamente.")
        print("Escribe 'salir' para terminar la conversación.\n")
        
        while True:
            user_input = input("Cliente: ")
            
            if user_input.lower() in ['salir', 'exit', 'quit']:
                print("¡Gracias por usar nuestro servicio!")
                break
            
            response = chatbot_system.process_message(user_input, session)
            print(f"Chatbot: {response}\n")
            
    except Exception as e:
        print(f"Error al inicializar el sistema: {e}")

if __name__ == "__main__":
    main()

