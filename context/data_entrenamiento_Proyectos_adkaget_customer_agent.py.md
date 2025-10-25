<!-- path: data_entrenamiento/Proyectos_adkaget/customer_agent.py -->
```python
"""
Agente de Registro de Clientes - Especializado en registrar nuevos clientes
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import re
from datetime import datetime

class CustomerRegistrationAgent:
    def __init__(self):
        self.registration_data = {}  # Almacena datos de registro en progreso
        
        # Configurar el agente especializado en registro
        self.agent = LlmAgent(
            name="customer_registration_agent",
            model="gemini-2.0-flash",
            instruction="""
            Eres un agente especializado en el registro de nuevos clientes.
            Tu función es:
            - Guiar a los clientes a través del proceso de registro
            - Solicitar información necesaria: nombre, apellido, teléfono, email
            - Validar que la información esté completa y sea correcta
            - Confirmar el registro exitoso
            
            Sé amigable y paciente. Solicita la información paso a paso si es necesario.
            Valida que el email tenga formato correcto y que el teléfono sea válido.
            
            Información requerida:
            - Nombre completo (nombre y apellido)
            - Número de teléfono
            - Dirección de correo electrónico
            """,
            description="Agente especializado en registro de clientes"
        )
    
    def initialize_registration(self, session_id: str):
        """Inicializa un nuevo proceso de registro"""
        if session_id not in self.registration_data:
            self.registration_data[session_id] = {
                'nombre': None,
                'apellido': None,
                'telefono': None,
                'email': None,
                'status': 'in_progress',
                'started_at': datetime.now().isoformat()
            }
    
    def validate_email(self, email: str) -> bool:
        """Valida el formato del email"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None
    
    def validate_phone(self, phone: str) -> bool:
        """Valida el formato del teléfono"""
        # Remover espacios y caracteres especiales
        clean_phone = re.sub(r'[^\d]', '', phone)
        # Verificar que tenga entre 7 y 15 dígitos
        return 7 <= len(clean_phone) <= 15
    
    def extract_customer_info(self, message: str) -> dict:
        """Extrae información del cliente del mensaje"""
        info = {}
        
        # Buscar email
        email_pattern = r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'
        email_match = re.search(email_pattern, message)
        if email_match:
            info['email'] = email_match.group()
        
        # Buscar teléfono (números de 7-15 dígitos)
        phone_pattern = r'\b\d{7,15}\b'
        phone_match = re.search(phone_pattern, message)
        if phone_match:
            info['telefono'] = phone_match.group()
        
        # Buscar nombres (palabras que empiecen con mayúscula)
        name_pattern = r'\b[A-Z][a-z]+\b'
        names = re.findall(name_pattern, message)
        if len(names) >= 2:
            info['nombre'] = names[0]
            info['apellido'] = ' '.join(names[1:])
        elif len(names) == 1:
            info['nombre'] = names[0]
        
        return info
    
    def update_registration_data(self, session_id: str, new_info: dict):
        """Actualiza los datos de registro con nueva información"""
        self.initialize_registration(session_id)
        
        for key, value in new_info.items():
            if key in self.registration_data[session_id] and value:
                self.registration_data[session_id][key] = value
    
    def get_registration_status(self, session_id: str) -> dict:
        """Obtiene el estado actual del registro"""
        if session_id not in self.registration_data:
            return {}
        
        data = self.registration_data[session_id]
        missing_fields = []
        
        if not data['nombre']:
            missing_fields.append('nombre')
        if not data['apellido']:
            missing_fields.append('apellido')
        if not data['telefono']:
            missing_fields.append('teléfono')
        if not data['email']:
            missing_fields.append('email')
        
        return {
            'data': data,
            'missing_fields': missing_fields,
            'is_complete': len(missing_fields) == 0
        }
    
    def validate_registration_data(self, session_id: str) -> dict:
        """Valida los datos de registro"""
        status = self.get_registration_status(session_id)
        
        if not status['is_complete']:
            return {
                'valid': False,
                'errors': [f"Falta información: {', '.join(status['missing_fields'])}"]
            }
        
        errors = []
        data = status['data']
        
        if data['email'] and not self.validate_email(data['email']):
            errors.append("El formato del email no es válido")
        
        if data['telefono'] and not self.validate_phone(data['telefono']):
            errors.append("El formato del teléfono no es válido")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors
        }
    
    def complete_registration(self, session_id: str) -> dict:
        """Completa el registro del cliente"""
        validation = self.validate_registration_data(session_id)
        
        if validation['valid']:
            self.registration_data[session_id]['status'] = 'completed'
            self.registration_data[session_id]['completed_at'] = datetime.now().isoformat()
            return self.registration_data[session_id].copy()
        
        return {}
    
    def process_registration_request(self, message: str, session: Session) -> str:
        """Procesa una solicitud de registro"""
        try:
            session_id = session.id
            
            # Extraer información del mensaje
            extracted_info = self.extract_customer_info(message)
            
            # Actualizar datos de registro
            if extracted_info:
                self.update_registration_data(session_id, extracted_info)
            
            # Obtener estado actual
            status = self.get_registration_status(session_id)
            
            # Crear contexto para el agente
            context = f"Mensaje del cliente: {message}\n\n"
            
            if status:
                context += "Estado actual del registro:\n"
                data = status['data']
                context += f"- Nombre: {'✓' if data['nombre'] else '✗'} {data['nombre'] or 'Pendiente'}\n"
                context += f"- Apellido: {'✓' if data['apellido'] else '✗'} {data['apellido'] or 'Pendiente'}\n"
                context += f"- Teléfono: {'✓' if data['telefono'] else '✗'} {data['telefono'] or 'Pendiente'}\n"
                context += f"- Email: {'✓' if data['email'] else '✗'} {data['email'] or 'Pendiente'}\n"
                
                if status['missing_fields']:
                    context += f"\nInformación faltante: {', '.join(status['missing_fields'])}\n"
                else:
                    # Validar datos completos
                    validation = self.validate_registration_data(session_id)
                    if validation['valid']:
                        context += "\n¡Registro completo y válido! Listo para confirmar.\n"
                    else:
                        context += f"\nErrores de validación: {', '.join(validation['errors'])}\n"
            
            response = self.agent.run(context, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return "Lo siento, hubo un problema con el registro. ¿Podrías proporcionar tu información nuevamente?"

def main():
    """Función de prueba para el agente de registro"""
    print("=== Agente de Registro de Clientes - Prueba ===")
    
    registration_agent = CustomerRegistrationAgent()
    session = Session(
        id="registration_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de registro inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Información de registro: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = registration_agent.process_registration_request(user_input, session)
        print(f"Agente de Registro: {response}\n")
        
        # Mostrar estado actual
        status = registration_agent.get_registration_status("registration_test_session")
        if status:
            print("Estado actual del registro:")
            data = status['data']
            print(f"  Nombre: {data['nombre'] or 'Pendiente'}")
            print(f"  Apellido: {data['apellido'] or 'Pendiente'}")
            print(f"  Teléfono: {data['telefono'] or 'Pendiente'}")
            print(f"  Email: {data['email'] or 'Pendiente'}")
            print()

if __name__ == "__main__":
    main()

```