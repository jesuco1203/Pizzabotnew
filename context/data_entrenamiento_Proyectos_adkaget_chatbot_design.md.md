<!-- path: data_entrenamiento/Proyectos_adkaget/chatbot_design.md -->
```markdown
# Análisis de Requerimientos y Diseño del Sistema para Chatbot de Pedidos

## 1. Requerimientos Funcionales

El chatbot de IA para la gestión de pedidos de restaurante deberá cumplir con las siguientes funcionalidades:

### 1.1. Interacción con el Cliente

*   **Atención de Pedidos:** El chatbot debe ser capaz de recibir y procesar pedidos de los clientes de manera conversacional.
*   **Orientación sobre el Menú:** El chatbot debe poder responder preguntas sobre los elementos del menú, incluyendo descripciones, ingredientes, precios y disponibilidad.
*   **Registro de Clientes Nuevos:** Para clientes que interactúan por primera vez, el chatbot debe guiarlos a través de un proceso de registro que capture la información necesaria para futuras interacciones y entregas.
*   **Confirmación de Pedidos:** Una vez que un pedido esté completo, el chatbot debe confirmar los detalles con el cliente antes de finalizarlo.
*   **Información de Entrega:** El chatbot debe solicitar y registrar la dirección de entrega para los pedidos a domicilio.

### 1.2. Gestión Interna

*   **Registro de Pedidos en Base de Datos:** Todos los pedidos confirmados deben ser registrados en una base de datos, incluyendo los detalles del cliente, los artículos del pedido, la dirección de entrega y el estado del pedido.
*   **Lectura del Menú desde Hoja de Cálculo:** El menú del restaurante (productos, descripciones, precios) debe ser leído dinámicamente desde una hoja de cálculo (por ejemplo, Google Sheets o un archivo Excel) para facilitar su actualización por parte del personal del restaurante.
*   **Sistema Multi-Agente:** El sistema debe estar diseñado con una arquitectura multi-agente, orquestada por un agente raíz (Root Agent), para manejar las diferentes funcionalidades de manera modular y escalable.

## 2. Diseño del Sistema Multi-Agente

El sistema se compondrá de varios agentes especializados, orquestados por un Agente Raíz. A continuación, se detalla la función de cada agente:

### 2.1. Agente Raíz (Root Agent)

El Agente Raíz será el punto de entrada principal para todas las interacciones del cliente. Su función principal será:

*   **Orquestación:** Dirigir las solicitudes del cliente al agente especializado adecuado basándose en la intención del usuario.
*   **Gestión del Flujo Conversacional:** Mantener el contexto de la conversación y asegurar una transición fluida entre los diferentes agentes.
*   **Manejo de Errores:** Gestionar situaciones inesperadas o solicitudes que no puedan ser manejadas por los agentes especializados.

### 2.2. Agentes Especializados

Se proponen los siguientes agentes especializados:

*   **Agente de Menú (Menu Agent):**
    *   **Función:** Responder preguntas sobre el menú, proporcionar descripciones de platos, precios y disponibilidad.
    *   **Interacción:** Consultará la hoja de cálculo del menú para obtener la información más reciente.

*   **Agente de Pedidos (Order Agent):**
    *   **Función:** Procesar los pedidos de los clientes, añadir artículos al carrito, modificar cantidades y confirmar el pedido final.
    *   **Interacción:** Colaborará con el Agente de Menú para validar los artículos y con el Agente de Base de Datos para registrar el pedido.

*   **Agente de Registro de Clientes (Customer Registration Agent):**
    *   **Función:** Guiar a los nuevos clientes a través del proceso de registro, solicitando y validando su información personal y de contacto.
    *   **Interacción:** Almacenará la información del cliente en la base de datos.

*   **Agente de Base de Datos (Database Agent):**
    *   **Función:** Gestionar todas las operaciones de lectura y escritura en la base de datos, incluyendo el registro de clientes, pedidos y direcciones de entrega.
    *   **Interacción:** Será utilizado por otros agentes para persistir y recuperar datos.

*   **Agente de Delivery (Delivery Agent):**
    *   **Función:** Recopilar y validar la dirección de entrega del cliente, y asociarla al pedido.
    *   **Interacción:** Colaborará con el Agente de Base de Datos para almacenar la dirección de entrega.

## 3. Estructura de la Base de Datos (Propuesta)

Se propone una base de datos relacional simple con las siguientes tablas:

*   **Clientes (Customers):**
    *   `id` (PK, INT)
    *   `nombre` (VARCHAR)
    *   `apellido` (VARCHAR)
    *   `telefono` (VARCHAR, UNIQUE)
    *   `email` (VARCHAR, UNIQUE)
    *   `fecha_registro` (DATETIME)

*   **Pedidos (Orders):**
    *   `id` (PK, INT)
    *   `cliente_id` (FK, INT)
    *   `fecha_pedido` (DATETIME)
    *   `estado` (VARCHAR, ej., 'pendiente', 'confirmado', 'en_preparacion', 'en_camino', 'entregado', 'cancelado')
    *   `total` (DECIMAL)
    *   `direccion_entrega_id` (FK, INT, NULLABLE)

*   **Detalle_Pedido (Order_Items):**
    *   `id` (PK, INT)
    *   `pedido_id` (FK, INT)
    *   `item_menu` (VARCHAR) - Nombre del artículo del menú
    *   `cantidad` (INT)
    *   `precio_unitario` (DECIMAL)

*   **Direcciones_Entrega (Delivery_Addresses):**
    *   `id` (PK, INT)
    *   `cliente_id` (FK, INT)
    *   `calle` (VARCHAR)
    *   `numero` (VARCHAR)
    *   `ciudad` (VARCHAR)
    *   `codigo_postal` (VARCHAR)
    *   `referencia` (TEXT, NULLABLE)

## 4. Formato de la Hoja de Cálculo del Menú (Propuesta)

La hoja de cálculo del menú deberá tener al menos las siguientes columnas:

*   **ID_Producto:** Identificador único del producto.
*   **Nombre_Producto:** Nombre del plato o bebida.
*   **Descripción:** Breve descripción del producto.
*   **Precio:** Precio del producto.
*   **Categoría:** Categoría del producto (ej., 'Entradas', 'Platos Principales', 'Bebidas', 'Postres').
*   **Disponibilidad:** 'Sí' o 'No' para indicar si el producto está disponible.

## 5. Flujo de Interacción (Ejemplo)

1.  **Cliente:** 


Hola, quiero hacer un pedido.
2.  **Agente Raíz:** (Detecta la intención de pedido y transfiere al Agente de Pedidos)
3.  **Agente de Pedidos:** ¡Hola! ¿Qué te gustaría pedir hoy? Puedes ver nuestro menú si lo deseas.
4.  **Cliente:** ¿Qué tipo de pizzas tienen?
5.  **Agente de Pedidos:** (Transfiere al Agente de Menú)
6.  **Agente de Menú:** Tenemos pizza de pepperoni, pizza margarita, pizza vegetariana... (proporciona descripciones y precios consultando la hoja de cálculo del menú).
7.  **Cliente:** Quiero una pizza de pepperoni y una bebida de cola.
8.  **Agente de Pedidos:** Entendido. ¿Eres un cliente nuevo o ya has pedido antes?
9.  **Cliente:** Soy nuevo.
10. **Agente de Pedidos:** (Transfiere al Agente de Registro de Clientes)
11. **Agente de Registro de Clientes:** ¡Bienvenido! Para registrarte, por favor, indícame tu nombre completo, número de teléfono y dirección de correo electrónico.
12. **Cliente:** Mi nombre es Juan Pérez, mi teléfono es 123456789 y mi correo es juan.perez@example.com.
13. **Agente de Registro de Clientes:** Gracias, Juan. Te hemos registrado. (Registra en la base de datos)
14. **Agente de Pedidos:** (Retoma el control) Perfecto, Juan. Tu pedido es una pizza de pepperoni y una bebida de cola. ¿Es correcto?
15. **Cliente:** Sí, es correcto.
16. **Agente de Pedidos:** ¿Cuál es la dirección de entrega?
17. **Cliente:** (Proporciona la dirección)
18. **Agente de Pedidos:** (Transfiere al Agente de Delivery para validar y registrar la dirección, luego al Agente de Base de Datos para registrar el pedido completo).
19. **Agente de Pedidos:** ¡Gracias por tu pedido, Juan! Estará contigo en aproximadamente 30 minutos.

## 6. Tecnologías Propuestas

*   **Framework de Agentes:** Google ADK (Agent Development Kit) para Python.
*   **Lenguaje de Programación:** Python.
*   **Base de Datos:** SQLite (para prototipo y desarrollo local) o PostgreSQL/MySQL (para despliegue en producción).
*   **Hoja de Cálculo:** Pandas para la lectura de datos desde archivos Excel/CSV, o Google Sheets API para integración directa con Google Sheets.
*   **Interfaz de Usuario:** Una interfaz de texto simple para la interacción inicial, con potencial para integrar con plataformas de mensajería (ej., Telegram, WhatsApp) en futuras iteraciones.

## 7. Consideraciones de Seguridad y Escalabilidad

*   **Seguridad:** Implementar validación de entrada para prevenir inyecciones SQL y otros ataques. Proteger la información sensible del cliente. Considerar la autenticación y autorización si se extiende a un portal de administración.
*   **Escalabilidad:** El diseño multi-agente de ADK facilita la escalabilidad. Cada agente puede ser desarrollado y desplegado de forma independiente. La elección de la base de datos y la forma de acceder a la hoja de cálculo también influirán en la escalabilidad.

## 8. Próximos Pasos

Con este diseño inicial, el siguiente paso es configurar el entorno de desarrollo e instalar las dependencias necesarias para comenzar la implementación.

```