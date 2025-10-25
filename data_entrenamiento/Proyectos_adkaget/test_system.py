"""
Script de pruebas para validar el funcionamiento del sistema de chatbot
"""

from integrated_chatbot import IntegratedChatbotSystem
import time

def test_customer_registration():
    """Prueba el registro de clientes"""
    print("=== Prueba de Registro de Clientes ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_registration")
    
    # Simular registro de cliente
    messages = [
        "Hola, soy nuevo cliente",
        "Mi nombre es Carlos Rodríguez, teléfono 555123456 y email carlos@test.com"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    # Verificar estado de la sesión
    session_state = chatbot.get_session_state(session.id)
    print(f"Estado de la sesión: {session_state}")
    
    return session_state.get('customer_id') is not None

def test_menu_inquiry():
    """Prueba las consultas de menú"""
    print("=== Prueba de Consultas de Menú ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_menu")
    
    # Simular consultas de menú
    messages = [
        "¿Qué pizzas tienen?",
        "¿Cuánto cuesta la pizza margarita?",
        "¿Tienen bebidas?"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    return True

def test_order_flow():
    """Prueba el flujo completo de pedido"""
    print("=== Prueba de Flujo de Pedido ===")
    
    chatbot = IntegratedChatbotSystem()
    session = chatbot.create_session("test_order")
    
    # Simular flujo completo
    messages = [
        "Hola",
        "Soy Ana López, teléfono 666777888, email ana@test.com",
        "Quiero hacer un pedido",
        "Mi dirección es Calle Real 456, Madrid, CP 28001"
    ]
    
    for message in messages:
        print(f"Usuario: {message}")
        response = chatbot.process_message(message, session)
        print(f"Bot: {response}\n")
        time.sleep(1)
    
    return True

def test_database_operations():
    """Prueba las operaciones de base de datos"""
    print("=== Prueba de Operaciones de Base de Datos ===")
    
    from database_manager import DatabaseManager
    
    db = DatabaseManager("test_db.db")
    
    # Probar registro de cliente
    try:
        customer_id = db.register_customer({
            'nombre': 'Test',
            'apellido': 'User',
            'telefono': '111222333',
            'email': 'test@example.com'
        })
        print(f"Cliente registrado con ID: {customer_id}")
        
        # Buscar cliente
        customer = db.get_customer_by_phone('111222333')
        print(f"Cliente encontrado: {customer}")
        
        # Crear dirección
        address_id = db.save_delivery_address({
            'cliente_id': customer_id,
            'calle': 'Test Street',
            'numero': '123',
            'ciudad': 'Test City',
            'direccion_completa': 'Test Street 123, Test City'
        })
        print(f"Dirección creada con ID: {address_id}")
        
        # Crear pedido
        order_id = db.create_order({
            'cliente_id': customer_id,
            'total': 15.50,
            'direccion_entrega_id': address_id
        })
        print(f"Pedido creado con ID: {order_id}")
        
        # Agregar elementos
        items = [
            {'name': 'Test Pizza', 'quantity': 1, 'price': 12.00, 'subtotal': 12.00},
            {'name': 'Test Drink', 'quantity': 1, 'price': 3.50, 'subtotal': 3.50}
        ]
        db.add_order_items(order_id, items)
        print("Elementos agregados al pedido")
        
        # Obtener detalles
        order_details = db.get_order_details(order_id)
        print(f"Detalles del pedido: {order_details}")
        
        return True
        
    except Exception as e:
        print(f"Error en prueba de base de datos: {e}")
        return False

def run_all_tests():
    """Ejecuta todas las pruebas"""
    print("=== EJECUTANDO TODAS LAS PRUEBAS ===\n")
    
    tests = [
        ("Operaciones de Base de Datos", test_database_operations),
        ("Consultas de Menú", test_menu_inquiry),
        ("Registro de Clientes", test_customer_registration),
        ("Flujo de Pedido", test_order_flow)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        print(f"\n{'='*50}")
        print(f"Ejecutando: {test_name}")
        print('='*50)
        
        try:
            result = test_func()
            results[test_name] = "PASÓ" if result else "FALLÓ"
            print(f"Resultado: {results[test_name]}")
        except Exception as e:
            results[test_name] = f"ERROR: {e}"
            print(f"Resultado: {results[test_name]}")
        
        time.sleep(2)
    
    # Resumen final
    print(f"\n{'='*50}")
    print("RESUMEN DE PRUEBAS")
    print('='*50)
    
    for test_name, result in results.items():
        status_icon = "✅" if result == "PASÓ" else "❌"
        print(f"{status_icon} {test_name}: {result}")
    
    passed_tests = sum(1 for result in results.values() if result == "PASÓ")
    total_tests = len(results)
    
    print(f"\nPruebas pasadas: {passed_tests}/{total_tests}")
    
    if passed_tests == total_tests:
        print("🎉 ¡Todas las pruebas pasaron exitosamente!")
    else:
        print("⚠️  Algunas pruebas fallaron. Revisar los errores arriba.")

if __name__ == "__main__":
    run_all_tests()

