<!-- path: data_entrenamiento/Proyectos_adkaget/database_manager.py -->
```python
"""
Gestor de Base de Datos - Maneja todas las operaciones de base de datos
"""

import sqlite3
import pandas as pd
from datetime import datetime
import os

class DatabaseManager:
    def __init__(self, db_path: str = "restaurant_chatbot.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializa la base de datos y crea las tablas necesarias"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Tabla de clientes
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre VARCHAR(100) NOT NULL,
                apellido VARCHAR(100) NOT NULL,
                telefono VARCHAR(20) UNIQUE NOT NULL,
                email VARCHAR(255) UNIQUE NOT NULL,
                fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabla de direcciones de entrega
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS delivery_addresses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cliente_id INTEGER NOT NULL,
                calle VARCHAR(255) NOT NULL,
                numero VARCHAR(10),
                ciudad VARCHAR(100) NOT NULL,
                codigo_postal VARCHAR(10),
                referencia TEXT,
                direccion_completa TEXT,
                FOREIGN KEY (cliente_id) REFERENCES customers (id)
            )
        ''')
        
        # Tabla de pedidos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cliente_id INTEGER NOT NULL,
                fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
                estado VARCHAR(50) DEFAULT 'pendiente',
                total DECIMAL(10,2) NOT NULL,
                direccion_entrega_id INTEGER,
                FOREIGN KEY (cliente_id) REFERENCES customers (id),
                FOREIGN KEY (direccion_entrega_id) REFERENCES delivery_addresses (id)
            )
        ''')
        
        # Tabla de detalles de pedido
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pedido_id INTEGER NOT NULL,
                item_menu VARCHAR(255) NOT NULL,
                cantidad INTEGER NOT NULL,
                precio_unitario DECIMAL(10,2) NOT NULL,
                subtotal DECIMAL(10,2) NOT NULL,
                FOREIGN KEY (pedido_id) REFERENCES orders (id)
            )
        ''')
        
        conn.commit()
        conn.close()
        print(f"Base de datos inicializada en {self.db_path}")
    
    def register_customer(self, customer_data: dict) -> int:
        """Registra un nuevo cliente y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO customers (nombre, apellido, telefono, email)
                VALUES (?, ?, ?, ?)
            ''', (
                customer_data['nombre'],
                customer_data['apellido'],
                customer_data['telefono'],
                customer_data['email']
            ))
            
            customer_id = cursor.lastrowid
            conn.commit()
            return customer_id
            
        except sqlite3.IntegrityError as e:
            if 'telefono' in str(e):
                raise ValueError("El número de teléfono ya está registrado")
            elif 'email' in str(e):
                raise ValueError("El email ya está registrado")
            else:
                raise ValueError("Error al registrar cliente")
        finally:
            conn.close()
    
    def get_customer_by_phone(self, phone: str) -> dict:
        """Busca un cliente por número de teléfono"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, nombre, apellido, telefono, email, fecha_registro
            FROM customers WHERE telefono = ?
        ''', (phone,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {
                'id': result[0],
                'nombre': result[1],
                'apellido': result[2],
                'telefono': result[3],
                'email': result[4],
                'fecha_registro': result[5]
            }
        return None
    
    def get_customer_by_email(self, email: str) -> dict:
        """Busca un cliente por email"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, nombre, apellido, telefono, email, fecha_registro
            FROM customers WHERE email = ?
        ''', (email,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {
                'id': result[0],
                'nombre': result[1],
                'apellido': result[2],
                'telefono': result[3],
                'email': result[4],
                'fecha_registro': result[5]
            }
        return None
    
    def save_delivery_address(self, address_data: dict) -> int:
        """Guarda una dirección de entrega y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO delivery_addresses 
            (cliente_id, calle, numero, ciudad, codigo_postal, referencia, direccion_completa)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            address_data['cliente_id'],
            address_data['calle'],
            address_data.get('numero'),
            address_data['ciudad'],
            address_data.get('codigo_postal'),
            address_data.get('referencia'),
            address_data.get('direccion_completa')
        ))
        
        address_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return address_id
    
    def create_order(self, order_data: dict) -> int:
        """Crea un nuevo pedido y retorna su ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO orders (cliente_id, total, direccion_entrega_id, estado)
            VALUES (?, ?, ?, ?)
        ''', (
            order_data['cliente_id'],
            order_data['total'],
            order_data.get('direccion_entrega_id'),
            order_data.get('estado', 'pendiente')
        ))
        
        order_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return order_id
    
    def add_order_items(self, order_id: int, items: list):
        """Agrega elementos a un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for item in items:
            cursor.execute('''
                INSERT INTO order_items (pedido_id, item_menu, cantidad, precio_unitario, subtotal)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                order_id,
                item['name'],
                item['quantity'],
                item['price'],
                item['subtotal']
            ))
        
        conn.commit()
        conn.close()
    
    def get_order_details(self, order_id: int) -> dict:
        """Obtiene los detalles completos de un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Obtener información del pedido
        cursor.execute('''
            SELECT o.id, o.fecha_pedido, o.estado, o.total,
                   c.nombre, c.apellido, c.telefono, c.email,
                   da.direccion_completa
            FROM orders o
            JOIN customers c ON o.cliente_id = c.id
            LEFT JOIN delivery_addresses da ON o.direccion_entrega_id = da.id
            WHERE o.id = ?
        ''', (order_id,))
        
        order_info = cursor.fetchone()
        
        if not order_info:
            conn.close()
            return None
        
        # Obtener elementos del pedido
        cursor.execute('''
            SELECT item_menu, cantidad, precio_unitario, subtotal
            FROM order_items
            WHERE pedido_id = ?
        ''', (order_id,))
        
        items = cursor.fetchall()
        conn.close()
        
        return {
            'id': order_info[0],
            'fecha_pedido': order_info[1],
            'estado': order_info[2],
            'total': order_info[3],
            'cliente': {
                'nombre': order_info[4],
                'apellido': order_info[5],
                'telefono': order_info[6],
                'email': order_info[7]
            },
            'direccion_entrega': order_info[8],
            'items': [
                {
                    'item_menu': item[0],
                    'cantidad': item[1],
                    'precio_unitario': item[2],
                    'subtotal': item[3]
                }
                for item in items
            ]
        }
    
    def update_order_status(self, order_id: int, new_status: str):
        """Actualiza el estado de un pedido"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE orders SET estado = ? WHERE id = ?
        ''', (new_status, order_id))
        
        conn.commit()
        conn.close()
    
    def get_customer_orders(self, customer_id: int) -> list:
        """Obtiene todos los pedidos de un cliente"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, fecha_pedido, estado, total
            FROM orders
            WHERE cliente_id = ?
            ORDER BY fecha_pedido DESC
        ''', (customer_id,))
        
        orders = cursor.fetchall()
        conn.close()
        
        return [
            {
                'id': order[0],
                'fecha_pedido': order[1],
                'estado': order[2],
                'total': order[3]
            }
            for order in orders
        ]

def main():
    """Función de prueba para el gestor de base de datos"""
    print("=== Gestor de Base de Datos - Prueba ===")
    
    # Inicializar base de datos
    db_manager = DatabaseManager()
    
    # Probar registro de cliente
    try:
        customer_data = {
            'nombre': 'Juan',
            'apellido': 'Pérez',
            'telefono': '123456789',
            'email': 'juan.perez@example.com'
        }
        
        customer_id = db_manager.register_customer(customer_data)
        print(f"Cliente registrado con ID: {customer_id}")
        
        # Buscar cliente
        found_customer = db_manager.get_customer_by_phone('123456789')
        print(f"Cliente encontrado: {found_customer}")
        
        # Crear dirección de entrega
        address_data = {
            'cliente_id': customer_id,
            'calle': 'Calle Principal',
            'numero': '123',
            'ciudad': 'Ciudad Ejemplo',
            'codigo_postal': '12345',
            'referencia': 'Casa azul con portón blanco',
            'direccion_completa': 'Calle Principal 123, Ciudad Ejemplo, CP: 12345'
        }
        
        address_id = db_manager.save_delivery_address(address_data)
        print(f"Dirección guardada con ID: {address_id}")
        
        # Crear pedido
        order_data = {
            'cliente_id': customer_id,
            'total': 25.00,
            'direccion_entrega_id': address_id
        }
        
        order_id = db_manager.create_order(order_data)
        print(f"Pedido creado con ID: {order_id}")
        
        # Agregar elementos al pedido
        items = [
            {'name': 'Pizza Margarita', 'quantity': 1, 'price': 12.50, 'subtotal': 12.50},
            {'name': 'Coca Cola', 'quantity': 2, 'price': 2.50, 'subtotal': 5.00},
            {'name': 'Tiramisu', 'quantity': 1, 'price': 6.00, 'subtotal': 6.00}
        ]
        
        db_manager.add_order_items(order_id, items)
        print("Elementos agregados al pedido")
        
        # Obtener detalles del pedido
        order_details = db_manager.get_order_details(order_id)
        print(f"Detalles del pedido: {order_details}")
        
    except Exception as e:
        print(f"Error en la prueba: {e}")

if __name__ == "__main__":
    main()

```