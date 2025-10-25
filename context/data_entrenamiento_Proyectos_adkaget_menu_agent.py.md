<!-- path: data_entrenamiento/Proyectos_adkaget/menu_agent.py -->
```python
"""
Agente de Menú - Especializado en consultas sobre el menú del restaurante
"""

from google.adk.agents import LlmAgent
from google.adk.sessions import Session
import pandas as pd
import os

class MenuAgent:
    def __init__(self, menu_file_path: str = "menu.csv"):
        self.menu_file_path = menu_file_path
        self.menu_data = None
        self.load_menu()
        
        # Configurar el agente especializado en menú
        self.agent = LlmAgent(
            name="menu_agent",
            model="gemini-2.0-flash",
            instruction=f"""
            Eres un agente especializado en el menú del restaurante.
            Tu función es ayudar a los clientes con consultas sobre:
            - Productos disponibles
            - Precios
            - Descripciones de platos
            - Categorías de comida
            - Disponibilidad de productos
            
            Datos del menú actual:
            {self.get_menu_summary()}
            
            Siempre sé amigable, descriptivo y útil. Si un producto no está disponible,
            sugiere alternativas similares.
            """,
            description="Agente especializado en consultas del menú"
        )
    
    def load_menu(self):
        """Carga el menú desde el archivo CSV"""
        try:
            if os.path.exists(self.menu_file_path):
                self.menu_data = pd.read_csv(self.menu_file_path)
            else:
                # Crear un menú de ejemplo si no existe el archivo
                self.create_sample_menu()
        except Exception as e:
            print(f"Error cargando el menú: {e}")
            self.create_sample_menu()
    
    def create_sample_menu(self):
        """Crea un menú de ejemplo"""
        sample_menu = {
            'ID_Producto': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            'Nombre_Producto': [
                'Pizza Margarita', 'Pizza Pepperoni', 'Hamburguesa Clásica',
                'Ensalada César', 'Pasta Carbonara', 'Coca Cola',
                'Agua Mineral', 'Tiramisu', 'Helado de Vainilla', 'Café Espresso'
            ],
            'Descripción': [
                'Pizza con tomate, mozzarella y albahaca fresca',
                'Pizza con pepperoni y queso mozzarella',
                'Hamburguesa con carne, lechuga, tomate y queso',
                'Ensalada con lechuga romana, crutones y aderezo césar',
                'Pasta con salsa carbonara, huevo y panceta',
                'Bebida gaseosa de cola 350ml',
                'Agua mineral natural 500ml',
                'Postre italiano con café y mascarpone',
                'Helado cremoso de vainilla natural',
                'Café espresso italiano'
            ],
            'Precio': [12.50, 14.00, 10.00, 8.50, 13.00, 2.50, 1.50, 6.00, 4.50, 2.00],
            'Categoría': [
                'Pizzas', 'Pizzas', 'Hamburguesas', 'Ensaladas', 'Pastas',
                'Bebidas', 'Bebidas', 'Postres', 'Postres', 'Bebidas'
            ],
            'Disponibilidad': ['Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí', 'Sí']
        }
        
        self.menu_data = pd.DataFrame(sample_menu)
        self.menu_data.to_csv(self.menu_file_path, index=False)
        print(f"Menú de ejemplo creado en {self.menu_file_path}")
    
    def get_menu_summary(self) -> str:
        """Obtiene un resumen del menú para el contexto del agente"""
        if self.menu_data is None:
            return "No hay datos del menú disponibles"
        
        summary = "MENÚ DISPONIBLE:\n"
        for category in self.menu_data['Categoría'].unique():
            summary += f"\n{category.upper()}:\n"
            category_items = self.menu_data[self.menu_data['Categoría'] == category]
            for _, item in category_items.iterrows():
                availability = "✓" if item['Disponibilidad'] == 'Sí' else "✗"
                summary += f"  {availability} {item['Nombre_Producto']} - ${item['Precio']:.2f}\n"
                summary += f"    {item['Descripción']}\n"
        
        return summary
    
    def search_menu_items(self, query: str) -> list:
        """Busca elementos del menú basado en una consulta"""
        if self.menu_data is None:
            return []
        
        query_lower = query.lower()
        results = []
        
        for _, item in self.menu_data.iterrows():
            if (query_lower in item['Nombre_Producto'].lower() or 
                query_lower in item['Descripción'].lower() or
                query_lower in item['Categoría'].lower()):
                results.append(item.to_dict())
        
        return results
    
    def get_items_by_category(self, category: str) -> list:
        """Obtiene elementos por categoría"""
        if self.menu_data is None:
            return []
        
        category_items = self.menu_data[
            self.menu_data['Categoría'].str.lower() == category.lower()
        ]
        return category_items.to_dict('records')
    
    def get_item_details(self, item_name: str) -> dict:
        """Obtiene detalles específicos de un elemento"""
        if self.menu_data is None:
            return {}
        
        item = self.menu_data[
            self.menu_data['Nombre_Producto'].str.lower() == item_name.lower()
        ]
        
        if not item.empty:
            return item.iloc[0].to_dict()
        return {}
    
    def process_menu_query(self, query: str, session: Session) -> str:
        """Procesa una consulta específica sobre el menú"""
        try:
            # Actualizar el contexto del agente con información específica si es necesario
            query_lower = query.lower()
            
            # Buscar elementos específicos mencionados en la consulta
            search_results = self.search_menu_items(query)
            
            if search_results:
                context_info = "\nElementos relevantes encontrados:\n"
                for item in search_results[:5]:  # Limitar a 5 resultados
                    context_info += f"- {item['Nombre_Producto']}: ${item['Precio']:.2f}\n"
                    context_info += f"  {item['Descripción']}\n"
                    context_info += f"  Disponible: {item['Disponibilidad']}\n\n"
                
                enhanced_query = f"{query}\n\nInformación relevante del menú:{context_info}"
            else:
                enhanced_query = query
            
            response = self.agent.run(enhanced_query, session=session)
            return response.text if hasattr(response, 'text') else str(response)
            
        except Exception as e:
            return f"Lo siento, hubo un problema al consultar el menú. ¿Podrías reformular tu pregunta?"

def main():
    """Función de prueba para el agente de menú"""
    print("=== Agente de Menú - Prueba ===")
    
    menu_agent = MenuAgent()
    session = Session(
        id="menu_test_session",
        appName="restaurant_chatbot",
        userId="test_user"
    )
    
    print("Agente de menú inicializado.")
    print("Escribe 'salir' para terminar.\n")
    
    while True:
        user_input = input("Consulta sobre menú: ")
        
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
        
        response = menu_agent.process_menu_query(user_input, session)
        print(f"Agente de Menú: {response}\n")

if __name__ == "__main__":
    main()

```