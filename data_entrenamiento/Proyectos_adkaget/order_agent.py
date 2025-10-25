"""
Agente de Pedidos - Especializado en procesar y gestionar pedidos de clientes
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import json
from datetime import datetime

class OrderAgent:
    def __init__(self):
        self.current_orders = {}  # Almacena pedidos en progreso por sesión
        
        # Configurar el agente especializado en pedidos
        self.agent = LlmAgent(
            name="order_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en procesar pedidos de restaurante.
            Tu función es:
            - Ayudar a los clientes a agregar elementos a su pedido
            - Modificar cantidades de productos
            - Confirmar pedidos
            - Calcular totales
            - Gestionar el carrito de compras
            
            Siempre confirma cada elemento agregado y mantén al cliente informado
            sobre el estado de su pedido. Sé claro sobre precios y cantidades.
            
            Cuando el cliente termine de agregar elementos, pregunta si desea
            confirmar el pedido y proceder con la información de entrega.
            """,
            description="Agente especializado en gestión de pedidos"
        )
    
    def initialize_order(self, session_id: str, customer_id: str = None):
        """Inicializa un nuevo pedido para una sesión"""
        if session_id not in self.current_orders:
            self.current_orders[session_id] = {
                'customer_id': customer_id,
                'items': [],
                'total': 0.0,
                'status': 'in_progress',
                'created_at': datetime.now().isoformat()
            }
    
    def add_item_to_order(self, session_id: str, item_name: str, quantity: int = 1, price: float = 0.0):
        """Agrega un elemento al pedido"""
        self.initialize_order(session_id)
        
        # Buscar si el elemento ya existe en el pedido
        existing_item = None
        for item in self.current_orders[session_id]['items']:
            if item['name'].lower() == item_name.lower():
                existing_item = item
                break
        
        if existing_item:
            # Actualizar cantidad si ya existe
            existing_item['quantity'] += quantity
            existing_item['subtotal'] = existing_item['quantity'] * existing_item['price']
        else:
            # Agregar nuevo elemento
            new_item = {
                'name': item_name,
                'quantity': quantity,
                'price': price,
                'subtotal': quantity * price
            }
            self.current_orders[session_id]['items'].append(new_item)
        
        # Recalcular total
        self.calculate_total(session_id)
    
    def remove_item_from_order(self, session_id: str, item_name: str):
        """Remueve un elemento del pedido"""
        if session_id in self.current_orders:
            self.current_orders[session_id]['items'] = [
                item for item in self.current_orders[session_id]['items']
                if item['name'].lower() != item_name.lower()
            ]
            self.calculate_total(session_id)
    
    def update_item_quantity(self, session_id: str, item_name: str, new_quantity: int):
        """Actualiza la cantidad de un elemento"""
        if session_id in self.current_orders:
            for item in self.current_orders[session_id]['items']:
                if item['name'].lower() == item_name.lower():
                    if new_quantity <= 0:
                        self.remove_item_from_order(session_id, item_name)
                    else:
                        item['quantity'] = new_quantity
                        item['subtotal'] = item['quantity'] * item['price']
                    break
            self.calculate_total(session_id)
    
    def calculate_total(self, session_id: str):
        """Calcula el total del pedido"""
        if session_id in self.current_orders:
            total = sum(item['subtotal'] for item in self.current_orders[session_id]['items'])
            self.current_orders[session_id]['total'] = total
    
    def get_order_summary(self, session_id: str) -> str:
        """Obtiene un resumen del pedido actual"""
        if session_id not in self.current_orders or not self.current_orders[session_id]['items']:
            return "Tu carrito está vacío."
        
        order = self.current_orders[session_id]
        summary = "RESUMEN DE TU PEDIDO:\n"
        summary += "=" * 30 + "\n"
        
        for item in order['items']:
            summary += f"{item['name']} x{item['quantity']} - ${item['subtotal']:.2f}\n"
        
        summary += "=" * 30 + "\n"
        summary += f"TOTAL: ${order['total']:.2f}"
        
        return summary
    
    def confirm_order(self, session_id: str) -> dict:
        """Confirma el pedido y lo marca como listo para procesar"""
        if session_id in self.current_orders:
            self.current_orders[session_id]['status'] = 'confirmed'
            self.current_orders[session_id]['confirmed_at'] = datetime.now().isoformat()
            return self.current_orders[session_id].copy()
        return {}
    
    def clear_order(self, session_id: str):
        """Limpia el pedido actual"""
        if session_id in self.current_orders:
            del self.current_orders[session_id]
    
    def process_order_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud relacionada con pedidos"""
        try:
            session_id = session.id
            
            # Inicializar pedido si no existe
            self.initialize_order(session_id)
            
            # Agregar contexto del pedido actual al mensaje
            current_order_summary = self.get_order_summary(session_id)
            enhanced_message = f"{message}\n\nPedido actual:\n{current_order_summary}"
            
            response = self.agent.run(enhanced_message, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema procesando tu pedido. ¿Podrías intentar de nuevo?"

def main():
    """Función de prueba para el agente de pedidos"""
    print("=== Agente de Pedidos - Prueba ===")
    
    order_agent = OrderAgent()
    session = Session(
        id="order_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    # Simular algunos elementos agregados al pedido
    order_agent.add_item_to_order("order_test_session", "Pizza Margarita", 1, 12.50)
    order_agent.add_item_to_order("order_test_session", "Coca Cola", 2, 2.50)
    
    print("Agente de pedidos inicializado con algunos elementos de prueba.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Solicitud de pedido: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = order_agent.process_order_request(user_input, session)
        print(f"Agente de Pedidos: {response}\n")
        
        # Mostrar resumen actual
        print(f"Estado actual: {order_agent.get_order_summary('order_test_session')}\n")

if __name__ == "__main__":
    main()

