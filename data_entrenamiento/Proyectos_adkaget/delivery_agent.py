"""
Agente de Delivery - Especializado en gestionar direcciones de entrega
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import re
from datetime import datetime

class DeliveryAgent:
    def __init__(self):
        self.delivery_data = {}  # Almacena datos de entrega en progreso
        
        # Configurar el agente especializado en delivery
        self.agent = LlmAgent(
            name="delivery_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en gestionar información de entrega.
            Tu función es:
            - Solicitar y validar direcciones de entrega
            - Confirmar detalles de la dirección
            - Proporcionar información sobre tiempos de entrega
            - Gestionar referencias adicionales para encontrar la dirección
            
            Información requerida para la entrega:
            - Calle y número
            - Ciudad
            - Código postal (opcional)
            - Referencias adicionales (opcional pero recomendado)
            
            Sé claro y específico al solicitar la información. Confirma siempre
            los detalles antes de finalizar.
            """,
            description="Agente especializado en gestión de entregas"
        )
    
    def initialize_delivery(self, session_id: str):
        """Inicializa un nuevo proceso de entrega"""
        if session_id not in self.delivery_data:
            self.delivery_data[session_id] = {
                'calle': None,
                'numero': None,
                'ciudad': None,
                'codigo_postal': None,
                'referencia': None,
                'direccion_completa': None,
                'status': 'in_progress',
                'started_at': datetime.now().isoformat()
            }
    
    def extract_address_info(self, message: str) -> dict:
        """Extrae información de dirección del mensaje"""
        info = {}
        
        # Buscar código postal (4-6 dígitos)
        postal_pattern = r'\b\d{4,6}\b'
        postal_match = re.search(postal_pattern, message)
        if postal_match:
            info['codigo_postal'] = postal_match.group()
        
        # Buscar número de calle (números seguidos de palabras como "calle", "avenida", etc.)
        street_number_pattern = r'\b(\d+)\s*(?:calle|avenida|av|street|st|boulevard|blvd|pasaje|pje)\s+([a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+)'
        street_match = re.search(street_number_pattern, message, re.IGNORECASE)
        if street_match:
            info['numero'] = street_match.group(1)
            info['calle'] = street_match.group(2).strip()
        
        # Buscar patrones de dirección más generales
        if not info.get('calle'):
            # Buscar "calle/avenida + nombre"
            street_pattern = r'(?:calle|avenida|av|street|st|boulevard|blvd|pasaje|pje)\s+([a-zA-ZáéíóúÁÉÍÓÚñÑ\s\d]+)'
            street_match = re.search(street_pattern, message, re.IGNORECASE)
            if street_match:
                info['calle'] = street_match.group(1).strip()
        
        # Buscar ciudades (palabras capitalizadas que podrían ser ciudades)
        city_keywords = ['ciudad', 'municipio', 'comuna', 'distrito']
        for keyword in city_keywords:
            city_pattern = f'{keyword}\\s+([A-ZáéíóúÁÉÍÓÚñÑ][a-záéíóúÁÉÍÓÚñÑ\\s]+)'
            city_match = re.search(city_pattern, message, re.IGNORECASE)
            if city_match:
                info['ciudad'] = city_match.group(1).strip()
                break
        
        # Si no se encontró ciudad con palabras clave, buscar palabras capitalizadas
        if not info.get('ciudad'):
            capitalized_words = re.findall(r'\b[A-ZáéíóúÁÉÍÓÚñÑ][a-záéíóúÁÉÍÓÚñÑ]+\b', message)
            if capitalized_words:
                # Tomar la última palabra capitalizada como posible ciudad
                info['ciudad'] = capitalized_words[-1]
        
        return info
    
    def update_delivery_data(self, session_id: str, new_info: dict):
        """Actualiza los datos de entrega con nueva información"""
        self.initialize_delivery(session_id)
        
        for key, value in new_info.items():
            if key in self.delivery_data[session_id] and value:
                self.delivery_data[session_id][key] = value
        
        # Construir dirección completa si hay suficiente información
        self.build_complete_address(session_id)
    
    def build_complete_address(self, session_id: str):
        """Construye la dirección completa a partir de los componentes"""
        if session_id not in self.delivery_data:
            return
        
        data = self.delivery_data[session_id]
        address_parts = []
        
        if data['calle']:
            if data['numero']:
                address_parts.append(f"{data['calle']} {data['numero']}")
            else:
                address_parts.append(data['calle'])
        
        if data['ciudad']:
            address_parts.append(data['ciudad'])
        
        if data['codigo_postal']:
            address_parts.append(f"CP: {data['codigo_postal']}")
        
        if address_parts:
            self.delivery_data[session_id]['direccion_completa'] = ', '.join(address_parts)
    
    def get_delivery_status(self, session_id: str) -> dict:
        """Obtiene el estado actual de la información de entrega"""
        if session_id not in self.delivery_data:
            return {}
        
        data = self.delivery_data[session_id]
        missing_fields = []
        
        if not data['calle']:
            missing_fields.append('calle')
        if not data['ciudad']:
            missing_fields.append('ciudad')
        
        # Número es opcional si está incluido en la calle
        if not data['numero'] and data['calle'] and not re.search(r'\d+', data['calle']):
            missing_fields.append('número')
        
        return {
            'data': data,
            'missing_fields': missing_fields,
            'is_complete': len(missing_fields) == 0
        }
    
    def estimate_delivery_time(self, session_id: str) -> str:
        """Estima el tiempo de entrega basado en la dirección"""
        status = self.get_delivery_status(session_id)
        
        if not status['is_complete']:
            return "No se puede estimar el tiempo sin dirección completa"
        
        # Simulación simple de tiempo de entrega
        return "30-45 minutos"
    
    def complete_delivery_info(self, session_id: str) -> dict:
        """Completa la información de entrega"""
        status = self.get_delivery_status(session_id)
        
        if status['is_complete']:
            self.delivery_data[session_id]['status'] = 'completed'
            self.delivery_data[session_id]['completed_at'] = datetime.now().isoformat()
            self.delivery_data[session_id]['estimated_time'] = self.estimate_delivery_time(session_id)
            return self.delivery_data[session_id].copy()
        
        return {}
    
    def process_delivery_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud relacionada con entrega"""
        try:
            session_id = session.id
            
            # Extraer información de dirección del mensaje
            extracted_info = self.extract_address_info(message)
            
            # Actualizar datos de entrega
            if extracted_info:
                self.update_delivery_data(session_id, extracted_info)
            
            # Si el mensaje contiene "referencia" o información adicional
            if 'referencia' in message.lower() or 'cerca de' in message.lower():
                self.delivery_data[session_id]['referencia'] = message
            
            # Obtener estado actual
            status = self.get_delivery_status(session_id)
            
            # Crear contexto para el agente
            context = f"Mensaje del cliente: {message}\n\n"
            
            if status:
                context += "Estado actual de la información de entrega:\n"
                data = status['data']
                context += f"- Calle: {'✓' if data['calle'] else '✗'} {data['calle'] or 'Pendiente'}\n"
                context += f"- Número: {'✓' if data['numero'] else '✗'} {data['numero'] or 'Pendiente'}\n"
                context += f"- Ciudad: {'✓' if data['ciudad'] else '✗'} {data['ciudad'] or 'Pendiente'}\n"
                context += f"- Código Postal: {data['codigo_postal'] or 'No especificado'}\n"
                context += f"- Referencia: {data['referencia'] or 'No especificada'}\n"
                
                if data['direccion_completa']:
                    context += f"- Dirección completa: {data['direccion_completa']}\n"
                
                if status['missing_fields']:
                    context += f"\nInformación faltante: {', '.join(status['missing_fields'])}\n"
                else:
                    estimated_time = self.estimate_delivery_time(session_id)
                    context += f"\n¡Dirección completa! Tiempo estimado de entrega: {estimated_time}\n"
            
            response = self.agent.run(context, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema procesando la información de entrega. ¿Podrías proporcionar tu dirección nuevamente?"

def main():
    """Función de prueba para el agente de delivery"""
    print("=== Agente de Delivery - Prueba ===")
    
    delivery_agent = DeliveryAgent()
    session = Session(
        id="delivery_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de delivery inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Información de entrega: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = delivery_agent.process_delivery_request(user_input, session)
        print(f"Agente de Delivery: {response}\n")
        
        # Mostrar estado actual
        status = delivery_agent.get_delivery_status("delivery_test_session")
        if status:
            print("Estado actual de la entrega:")
            data = status['data']
            print(f"  Calle: {data['calle'] or 'Pendiente'}")
            print(f"  Número: {data['numero'] or 'Pendiente'}")
            print(f"  Ciudad: {data['ciudad'] or 'Pendiente'}")
            print(f"  Código Postal: {data['codigo_postal'] or 'No especificado'}")
            if data['direccion_completa']:
                print(f"  Dirección completa: {data['direccion_completa']}")
            print()

if __name__ == "__main__":
    main()

