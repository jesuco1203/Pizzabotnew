<!-- path: data_entrenamiento/README - Sistema de Chatbot Multi-Agente para Restaurante.md -->
```markdown
# README - Sistema de Chatbot Multi-Agente para Restaurante

## 🍕 Descripción del Proyecto

Este proyecto implementa un sistema de chatbot multi-agente para la gestión de pedidos de restaurante utilizando Google Agent Development Kit (ADK). El sistema integra múltiples agentes especializados que trabajan coordinadamente para proporcionar una experiencia completa de atención al cliente.

## 🚀 Características Principales

- **Arquitectura Multi-Agente**: Agentes especializados para menú, pedidos, registro de clientes y delivery
- **Gestión de Menú Dinámico**: Lectura de menú desde archivos CSV para fácil actualización
- **Base de Datos Integrada**: Persistencia de clientes, pedidos y direcciones
- **Procesamiento de Lenguaje Natural**: Análisis de intenciones y extracción de información
- **Flujo Completo de Pedidos**: Desde consulta hasta confirmación y entrega

## 📁 Estructura del Proyecto

```
chatbot-restaurante/
├── root_agent.py              # Agente orquestador principal
├── menu_agent.py              # Agente especializado en consultas de menú
├── order_agent.py             # Agente de gestión de pedidos
├── customer_agent.py          # Agente de registro de clientes
├── delivery_agent.py          # Agente de gestión de entregas
├── database_manager.py        # Gestor de base de datos
├── integrated_chatbot.py      # Sistema integrado completo
├── test_system.py             # Suite de pruebas
├── menu.csv                   # Datos del menú (generado automáticamente)
├── restaurant_chatbot.db      # Base de datos SQLite
└── README.md                  # Este archivo
```

## 🛠️ Instalación y Configuración

### Prerrequisitos

- Python 3.11 o superior
- pip (gestor de paquetes de Python)

### Instalación

1. **Clonar o descargar los archivos del proyecto**

2. **Crear un entorno virtual**:
```bash
python3 -m venv chatbot_env
source chatbot_env/bin/activate  # En Linux/Mac
# o
chatbot_env\Scripts\activate     # En Windows
```

3. **Instalar dependencias**:
```bash
pip install google-adk pandas
```

### Configuración (Opcional)

Para funcionalidad completa con modelos de IA, configura las credenciales de Google Cloud:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/credentials.json"
```

## 🎯 Uso del Sistema

### Ejecución del Sistema Completo

```bash
python integrated_chatbot.py
```

### Ejecución de Componentes Individuales

**Agente de Menú**:
```bash
python menu_agent.py
```

**Agente de Pedidos**:
```bash
python order_agent.py
```

**Agente de Registro**:
```bash
python customer_agent.py
```

**Agente de Delivery**:
```bash
python delivery_agent.py
```

### Pruebas del Sistema

```bash
python test_system.py
```

## 💬 Ejemplos de Interacción

### Consulta de Menú
```
Usuario: ¿Qué pizzas tienen?
Bot: Tenemos pizza margarita por $12.50, pizza pepperoni por $14.00...
```

### Registro de Cliente
```
Usuario: Soy nuevo, me llamo Juan Pérez, teléfono 123456789, email juan@email.com
Bot: ¡Bienvenido Juan! Te hemos registrado exitosamente...
```

### Realizar Pedido
```
Usuario: Quiero una pizza margarita y una coca cola
Bot: Perfecto, he agregado a tu pedido: Pizza Margarita ($12.50) y Coca Cola ($2.50)....
```

### Información de Entrega
```
Usuario: Mi dirección es Calle Principal 123, Madrid
Bot: Dirección registrada. Tiempo estimado de entrega: 30-45 minutos...
```

## 🏗️ Arquitectura del Sistema

### Agentes Especializados

1. **Agente Raíz (Root Agent)**: Orquestador principal que analiza intenciones y dirige solicitudes
2. **Agente de Menú**: Maneja consultas sobre productos, precios y disponibilidad
3. **Agente de Pedidos**: Gestiona el carrito de compras y procesamiento de pedidos
4. **Agente de Registro**: Facilita el registro de nuevos clientes
5. **Agente de Delivery**: Gestiona información de direcciones de entrega

### Base de Datos

- **Clientes**: Información personal y de contacto
- **Pedidos**: Detalles de pedidos y estado
- **Elementos de Pedido**: Productos individuales en cada pedido
- **Direcciones de Entrega**: Información de ubicación para delivery

## 🧪 Pruebas y Validación

El sistema incluye pruebas automatizadas para:

- ✅ Operaciones de base de datos
- ✅ Funcionalidad de agentes individuales
- ✅ Flujo completo de interacción
- ✅ Integración entre componentes

### Ejecutar Pruebas

```bash
python test_system.py
```

## 📊 Datos de Ejemplo

El sistema genera automáticamente un menú de ejemplo con:

- **Pizzas**: Margarita, Pepperoni
- **Hamburguesas**: Clásica
- **Ensaladas**: César
- **Pastas**: Carbonara
- **Bebidas**: Coca Cola, Agua Mineral
- **Postres**: Tiramisu, Helado de Vainilla

## 🔧 Personalización

### Modificar el Menú

Edita el archivo `menu.csv` con las siguientes columnas:
- ID_Producto
- Nombre_Producto
- Descripción
- Precio
- Categoría
- Disponibilidad

### Agregar Nuevos Agentes

1. Crea una nueva clase que herede de las clases base de ADK
2. Implementa la lógica específica del dominio
3. Integra el agente en `integrated_chatbot.py`

### Configurar Base de Datos

Modifica `database_manager.py` para cambiar el esquema o tipo de base de datos.

## 🚨 Limitaciones Conocidas

- Requiere credenciales de Google Cloud para funcionalidad completa de IA
- Base de datos SQLite limitada para uso en producción
- Análisis de intenciones basado en palabras clave (no ML avanzado)
- Sin interfaz gráfica de usuario

## 🔮 Mejoras Futuras

- [ ] Interfaz web interactiva
- [ ] Integración con sistemas de pago
- [ ] Análisis avanzado de datos y reportes
- [ ] Soporte para múltiples idiomas
- [ ] Integración con APIs de delivery
- [ ] Sistema de notificaciones en tiempo real

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia Apache 2.0.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Soporte

Para preguntas o problemas:

1. Revisa la documentación en `proyecto_final_documentacion.md`
2. Ejecuta las pruebas para verificar la configuración
3. Consulta los logs de error para diagnóstico

## 🙏 Agradecimientos

- Google por el Agent Development Kit (ADK)
- Comunidad de Python por las librerías utilizadas
- Contribuidores y testers del proyecto

---

**Desarrollado con ❤️ usando Google ADK y Python**
```