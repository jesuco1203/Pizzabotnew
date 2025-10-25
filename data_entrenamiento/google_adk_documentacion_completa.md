# Google Agent Development Kit (ADK) - Documentación Técnica Completa

## Tabla de Contenidos
1. [¿Qué es Google ADK Agent?](#1-qué-es-google-adk-agent)
2. [Guía de Instalación y Configuración](#2-guía-de-instalación-y-configuración)
3. [Arquitectura y Componentes Principales](#3-arquitectura-y-componentes-principales)
4. [Ejemplos de Código y Casos de Uso](#4-ejemplos-de-código-y-casos-de-uso)
5. [Capacidades y Características](#5-capacidades-y-características)
6. [Limitaciones y Consideraciones](#6-limitaciones-y-consideraciones)
7. [Comparación con Otras Librerías](#7-comparación-con-otras-librerías)
8. [Aplicación para Chatbots de Restaurante](#8-aplicación-para-chatbots-de-restaurante)
9. [Despliegue en Producción](#9-despliegue-en-producción)
10. [Recursos Oficiales y Aprendizaje](#10-recursos-oficiales-y-aprendizaje)

---

## 1. ¿Qué es Google ADK Agent?

### Definición

El **Agent Development Kit (ADK)** es un framework de Python de código abierto desarrollado por Google, presentado en Google Cloud NEXT 2025 (abril 2025). Está diseñado para simplificar el desarrollo completo de agentes de inteligencia artificial y sistemas multi-agente sofisticados.

### Características Principales

- **Framework Modular y Flexible**: Permite crear desde agentes simples hasta arquitecturas multi-agente complejas
- **Code-First Development**: Define la lógica del agente, herramientas y orquestación directamente en Python
- **Agnóstico al Modelo**: Funciona con Gemini, Vertex AI Model Garden, y otros modelos via LiteLLM
- **Optimizado para Google Cloud**: Aunque funciona en cualquier lugar, está optimizado para el ecosistema de Google
- **Multi-lenguaje**: Disponible en Python (v1.2.1) y Java (v1.2.1)

### Propósito

ADK busca que el desarrollo de agentes se sienta como desarrollo de software tradicional, proporcionando herramientas potentes para crear aplicaciones agénticas listas para producción con mayor flexibilidad y control preciso.

---

## 2. Guía de Instalación y Configuración

### Requisitos del Sistema

**Python:**
- Python 3.9+ (recomendado 3.10+)
- Sistema operativo: Windows, macOS, Linux

**Java:**
- Java 17+
- Maven o Gradle

### Instalación Python

#### Paso 1: Crear Entorno Virtual (Recomendado)
```bash
# Crear entorno virtual
python -m venv .venv

# Activar entorno virtual
# macOS/Linux:
source .venv/bin/activate

# Windows CMD:
.venv\Scripts\activate.bat

# Windows PowerShell:
.venv\Scripts\Activate.ps1
```

#### Paso 2: Instalar ADK
```bash
pip install google-adk
```

#### Paso 3: Verificar Instalación
```bash
pip show google-adk
```

### Instalación Java

#### Maven
```xml
<dependencies>
  <!-- The ADK Core dependency -->
  <dependency>
    <groupId>com.google.adk</groupId>
    <artifactId>google-adk</artifactId>
    <version>1.2.1</version>
  </dependency>
  <!-- The ADK Dev Web UI to debug your agent (Optional) -->
  <dependency>
    <groupId>com.google.adk</groupId>
    <artifactId>google-adk-dev</artifactId>
    <version>1.2.1</version>
  </dependency>
</dependencies>
```

#### Gradle
```gradle
dependencies {
    implementation 'com.google.adk:google-adk:1.2.1'
    implementation 'com.google.adk:google-adk-dev:1.2.1'
}
```

### Configuración de Modelos

#### Opción 1: Google AI Studio (Gemini)
1. Obtener clave API de [Google AI Studio](https://aistudio.google.com/apikey)
2. Crear archivo `.env`:
```bash
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=TU_CLAVE_API_AQUI
```

#### Opción 2: Google Cloud Vertex AI
1. Configurar proyecto Google Cloud
2. Habilitar [API de Vertex AI](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com)
3. Autenticarse: `gcloud auth login`
4. Crear archivo `.env`:
```bash
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=TU_PROJECT_ID
GOOGLE_CLOUD_LOCATION=us-central1
```

---

## 3. Arquitectura y Componentes Principales

### Arquitectura General

```
┌─────────────────────────────────────────────┐
│                 ADK Framework               │
├─────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐          │
│  │   Agents    │  │   Tools     │          │
│  │             │  │             │          │
│  │ • LlmAgent  │  │ • Built-in  │          │
│  │ • Workflow  │  │ • Custom    │          │
│  │ • Custom    │  │ • MCP       │          │
│  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐          │
│  │  Sessions   │  │   Events    │          │
│  │             │  │             │          │
│  │ • Memory    │  │ • Tracking  │          │
│  │ • State     │  │ • Callbacks │          │
│  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────┤
│              Runners                        │
│  • InMemoryRunner                           │
│  • API Server                               │
│  • Web UI                                   │
└─────────────────────────────────────────────┘
```

### Componentes Principales

#### 1. Agentes (Agents)

**Clase Base: `BaseAgent`**
- Fundamento para todos los agentes en ADK
- Unidad de ejecución autocontenida
- Diseñada para actuar autónomamente

**Tipos de Agentes:**

1. **LLM Agents (`LlmAgent` / `Agent`)**
   - Motor principal: Large Language Model
   - Función: Razonamiento, generación, uso de herramientas
   - Determinismo: No determinista (flexible)
   - Uso: Tareas de lenguaje, decisiones dinámicas

2. **Workflow Agents**
   - `SequentialAgent`: Ejecución secuencial
   - `ParallelAgent`: Ejecución paralela
   - `LoopAgent`: Ejecución en bucle
   - Motor principal: Lógica predefinida
   - Determinismo: Determinista (predecible)
   - Uso: Procesos estructurados, orquestación

3. **Custom Agents**
   - Extienden `BaseAgent` directamente
   - Implementan lógica operacional única
   - Determinismo: Basado en implementación

#### 2. Herramientas (Tools)

**Tipos de Herramientas:**
- **Preconstruidas**: Search, Code Execution
- **Personalizadas**: Funciones Python con docstrings
- **MCP (Model Context Protocol)**: Herramientas estándar de la industria
- **Integración de terceros**: LangChain, LlamaIndex
- **Otros agentes**: Como herramientas

#### 3. Runners

**InMemoryRunner**
- Ejecución local de agentes
- Ideal para desarrollo y pruebas

**API Server**
- Servidor FastAPI para pruebas locales
- Permite requests cURL

**Web UI**
- Interfaz visual para desarrollo
- Debugging paso a paso

#### 4. Sesiones y Estado

**Sessions**
- Manejo de conversaciones persistentes
- Gestión de memoria y contexto

**Events**
- Sistema de tracking de eventos
- Callbacks para seguridad y logging

---

## 4. Ejemplos de Código y Casos de Uso

### Ejemplo Básico: Agente de Clima y Hora

```python
import datetime
from zoneinfo import ZoneInfo
from google.adk.agents import Agent

def get_weather(city: str) -> dict:
    """Retrieves the current weather report for a specified city.
    
    Args:
        city (str): The name of the city for which to retrieve the weather report.
        
    Returns:
        dict: status and result or error msg.
    """
    if city.lower() == "new york":
        return {
            "status": "success",
            "report": (
                "The weather in New York is sunny with a temperature of 25 degrees"
                " Celsius (77 degrees Fahrenheit)."
            ),
        }
    else:
        return {
            "status": "error",
            "error_message": f"Weather information for '{city}' is not available.",
        }

def get_current_time(city: str) -> dict:
    """Returns the current time in a specified city.
    
    Args:
        city (str): The name of the city for which to retrieve the current time.
        
    Returns:
        dict: status and result or error msg.
    """
    if city.lower() == "new york":
        tz_identifier = "America/New_York"
    else:
        return {
            "status": "error",
            "error_message": (
                f"Sorry, I don't have timezone information for {city}."
            ),
        }
    
    tz = ZoneInfo(tz_identifier)
    now = datetime.datetime.now(tz)
    report = (
        f'The current time in {city} is {now.strftime("%Y-%m-%d %H:%M:%S %Z%z")}'
    )
    return {"status": "success", "report": report}

# Crear el agente
root_agent = Agent(
    name="weather_time_agent",
    model="gemini-2.0-flash",
    description="Agent to answer questions about the time and weather in a city.",
    instruction=(
        "You are a helpful agent who can answer user questions about the time and weather in a city."
    ),
    tools=[get_weather, get_current_time],
)
```

### Ejemplo Multi-Agente: Sistema de Atención al Cliente

```python
from google.adk.agents import Agent, SequentialAgent

# Agente especializado en pedidos
def check_order_status(order_id: str) -> dict:
    """Check the status of an order."""
    # Simulación de consulta a base de datos
    orders_db = {
        "12345": {"status": "shipped", "tracking": "1Z999AA1234567890"},
        "67890": {"status": "processing", "estimated_delivery": "2-3 days"}
    }
    
    if order_id in orders_db:
        return {"status": "success", "order_info": orders_db[order_id]}
    else:
        return {"status": "error", "message": "Order not found"}

order_agent = Agent(
    name="order_specialist",
    model="gemini-2.0-flash",
    description="Specialist in handling order inquiries",
    instruction="You handle order status checks and shipping information.",
    tools=[check_order_status]
)

# Agente especializado en productos
def get_product_info(product_name: str) -> dict:
    """Get information about a product."""
    products_db = {
        "pizza margherita": {
            "price": "$12.99",
            "ingredients": "tomato sauce, mozzarella, basil",
            "available": True
        },
        "caesar salad": {
            "price": "$8.99", 
            "ingredients": "romaine lettuce, parmesan, croutons, caesar dressing",
            "available": True
        }
    }
    
    product_key = product_name.lower()
    if product_key in products_db:
        return {"status": "success", "product": products_db[product_key]}
    else:
        return {"status": "error", "message": "Product not found"}

product_agent = Agent(
    name="product_specialist",
    model="gemini-2.0-flash", 
    description="Specialist in product information",
    instruction="You provide detailed product information and pricing.",
    tools=[get_product_info]
)

# Agente coordinador principal
coordinator_agent = Agent(
    name="customer_service_coordinator",
    model="gemini-2.0-flash",
    description="Main customer service coordinator",
    instruction="""
    You are the main customer service agent. Route customer inquiries to appropriate specialists:
    - Use order_specialist for order status, shipping, and delivery questions
    - Use product_specialist for product information, pricing, and availability
    - Handle general greetings and farewell yourself
    """,
    tools=[order_agent, product_agent]
)
```

### Ejemplo de Flujo de Trabajo Secuencial

```python
from google.adk.agents import SequentialAgent

# Agente de procesamiento de pedidos
def validate_order(order_data: dict) -> dict:
    """Validate order data."""
    required_fields = ["items", "customer_info", "payment_method"]
    
    for field in required_fields:
        if field not in order_data:
            return {"status": "error", "message": f"Missing {field}"}
    
    return {"status": "success", "message": "Order validated"}

validation_agent = Agent(
    name="order_validator",
    model="gemini-2.0-flash",
    description="Validates order information",
    tools=[validate_order]
)

def process_payment(payment_info: dict) -> dict:
    """Process payment for order."""
    # Simulación de procesamiento de pago
    if payment_info.get("method") == "credit_card":
        return {"status": "success", "transaction_id": "TXN123456"}
    else:
        return {"status": "error", "message": "Invalid payment method"}

payment_agent = Agent(
    name="payment_processor", 
    model="gemini-2.0-flash",
    description="Processes payments",
    tools=[process_payment]
)

def send_confirmation(order_details: dict) -> dict:
    """Send order confirmation to customer."""
    # Simulación de envío de confirmación
    return {
        "status": "success", 
        "message": "Confirmation sent",
        "order_id": "ORD789012"
    }

confirmation_agent = Agent(
    name="confirmation_sender",
    model="gemini-2.0-flash", 
    description="Sends order confirmations",
    tools=[send_confirmation]
)

# Flujo secuencial de procesamiento de pedidos
order_processing_workflow = SequentialAgent(
    name="order_processing_pipeline",
    agents=[validation_agent, payment_agent, confirmation_agent],
    description="Complete order processing pipeline"
)
```

### Ejecución de Agentes

#### Método 1: Interfaz Web de Desarrollo
```bash
# Ejecutar desde el directorio padre del proyecto
adk web
```

#### Método 2: Terminal
```bash
adk run nombre_del_agente
```

#### Método 3: Programáticamente
```python
from google.adk.runner import InMemoryRunner
from google.adk.sessions import Session

# Crear runner
runner = InMemoryRunner(root_agent)

# Crear sesión
session = runner.session_service().create_session(
    agent_name="weather_time_agent",
    user_id="user123"
).blocking_get()

# Ejecutar consulta
from google.genai.types import Content, Part

user_input = "What's the weather in New York?"
user_msg = Content.from_parts(Part.from_text(user_input))

events = runner.run_async("user123", session.id(), user_msg)
events.blocking_for_each(lambda event: print(event.stringify_content()))
```

---

## 5. Capacidades y Características

### Capacidades Principales

#### 1. **Multi-Agent por Diseño**
- Construcción de aplicaciones modulares y escalables
- Composición de múltiples agentes especializados en jerarquías
- Coordinación y delegación complejas

#### 2. **Ecosistema Rico de Modelos**
- **Google Gemini**: Integración nativa optimizada
- **Vertex AI Model Garden**: Acceso a múltiples modelos
- **LiteLLM**: Compatibilidad con Anthropic, Meta, Mistral AI, AI21 Labs, OpenAI

#### 3. **Ecosistema Rico de Herramientas**
- **Herramientas Preconstruidas**: Search, Code Execution
- **Model Context Protocol (MCP)**: Estándar de la industria
- **Integración de Terceros**: LangChain, LlamaIndex
- **Agentes como Herramientas**: LangGraph, CrewAI

#### 4. **Streaming Integrado**
- Streaming bidireccional de audio y video
- Interacciones naturales similares a conversaciones humanas
- Capacidades multimodales avanzadas

#### 5. **Orquestación Flexible**
- **Flujos de Trabajo Deterministas**: Sequential, Parallel, Loop
- **Enrutamiento Dinámico**: Transferencia LlmAgent
- **Comportamiento Adaptativo**: Basado en contexto

#### 6. **Experiencia de Desarrollador Integrada**
- **CLI Potente**: Desarrollo, pruebas y depuración local
- **Interfaz Web Visual**: Inspección paso a paso
- **Debugging Avanzado**: Eventos, estado y ejecución del agente

#### 7. **Evaluación Integrada**
- Evaluación sistemática del rendimiento
- Calidad de respuesta final y trayectoria de ejecución
- Casos de prueba predefinidos (evaluation.test.json)

#### 8. **Despliegue Sencillo**
- Contenerización automática
- Despliegue en cualquier runtime de contenedor
- Integración con Vertex AI Agent Engine

### Características Técnicas Avanzadas

#### **Callbacks y Seguridad**
```python
def security_callback(event):
    """Callback para implementar verificaciones de seguridad."""
    if "sensitive_data" in event.content:
        return {"blocked": True, "reason": "Sensitive data detected"}
    return {"blocked": False}

agent = Agent(
    name="secure_agent",
    model="gemini-2.0-flash",
    callbacks=[security_callback]
)
```

#### **Gestión de Estado y Memoria**
```python
from google.adk.sessions import SessionState

# Estado persistente entre conversaciones
session_state = SessionState()
session_state.set("user_preferences", {"language": "es", "cuisine": "italian"})

agent = Agent(
    name="stateful_agent",
    model="gemini-2.0-flash",
    session_state=session_state
)
```

#### **Integración con MCP**
```python
# Conexión con servidores MCP
from google.adk.tools import MCPTool

mcp_tool = MCPTool(
    server_url="ws://localhost:8080/mcp",
    tools=["database_query", "file_operations"]
)

agent = Agent(
    name="mcp_enabled_agent",
    model="gemini-2.0-flash",
    tools=[mcp_tool]
)
```

---

## 6. Limitaciones y Consideraciones

### Limitaciones Técnicas

#### 1. **Estructura de Carpetas Rígida**
- La configuración de carpetas y archivos es estricta
- Los nombres deben coincidir exactamente
- Mensajes de error poco informativos en caso de fallos

#### 2. **Limitaciones de Herramientas Integradas**
- Solo funcionan con modelos Gemini
- Una herramienta integrada por agente
- No se pueden combinar herramientas integradas con personalizadas
- Restricciones en sub-agentes

#### 3. **Herramientas Personalizadas**
- No pueden tener valores por defecto en parámetros
- El esquema de entrada debe coincidir exactamente
- Fallo del agente si no coincide el esquema

#### 4. **Comportamiento Multi-Agente Básico**
- Configuraciones básicas basadas en delegación
- No hay interacción continua por defecto
- Requiere configuración especial para razonamiento cooperativo

#### 5. **Configuración Manual Requerida**
- Sin la interfaz web (`adk web`), requiere configuración manual
- Necesidad de configurar sesiones, variables de entorno y runners
- Complejidad adicional para integración en aplicaciones personalizadas

#### 6. **Callbacks Requieren Precaución**
- Potentes pero pueden fallar silenciosamente
- Comportamiento impredecible si se manejan incorrectamente
- Necesidad de tipos correctos en valores de retorno

### Consideraciones de Desarrollo

#### **Curva de Aprendizaje**
- Requiere familiarización con conceptos de agentes
- Documentación puede tener pasos innecesarios
- Mejor experiencia con conocimiento previo de Python/Java

#### **Rendimiento**
- Problemas de rendimiento reportados en arquitecturas multi-agente complejas
- Optimización necesaria para casos de uso intensivos
- Gestión cuidadosa de recursos en despliegues grandes

#### **Madurez del Framework**
- Relativamente nuevo (abril 2025)
- Menos adopción comparado con frameworks establecidos
- Comunidad en crecimiento

### Mejores Prácticas

#### **Diseño de Agentes**
```python
# ✅ Buena práctica: Instrucciones específicas
agent = Agent(
    name="restaurant_assistant",
    model="gemini-2.0-flash",
    description="Restaurant order assistant specialized in taking orders",
    instruction="""
    You are a friendly restaurant assistant. Follow these guidelines:
    1. Always greet customers warmly
    2. Ask about allergies before taking orders
    3. Suggest popular items when customers are unsure
    4. Confirm orders before processing
    5. Provide estimated wait times
    """,
    tools=[menu_tools, order_tools]
)

# ❌ Mala práctica: Instrucciones vagas
agent = Agent(
    name="helper",
    model="gemini-2.0-flash", 
    description="Helps with stuff",
    instruction="Be helpful",
    tools=[some_tools]
)
```

#### **Gestión de Errores**
```python
def safe_tool_function(param: str) -> dict:
    """Herramienta con manejo de errores robusto."""
    try:
        # Validación de entrada
        if not param or not isinstance(param, str):
            return {"status": "error", "message": "Invalid parameter"}
        
        # Lógica de la herramienta
        result = process_parameter(param)
        
        return {"status": "success", "data": result}
        
    except Exception as e:
        return {"status": "error", "message": f"Tool error: {str(e)}"}
```

---

## 7. Comparación con Otras Librerías

### Matriz Comparativa

| Característica | Google ADK | LangChain | CrewAI | AutoGen |
|----------------|------------|-----------|---------|---------|
| **Facilidad de Uso** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Multi-Agente** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Flexibilidad** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Documentación** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Comunidad** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Despliegue** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Integración GCP** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

### Análisis Detallado

#### **Google ADK vs LangChain**

**Ventajas de ADK:**
- Mejor para sistemas multi-agente
- Integración nativa con Google Cloud
- Herramientas de desarrollo integradas
- Despliegue simplificado

**Ventajas de LangChain:**
- Ecosistema más maduro y extenso
- Mayor flexibilidad en integraciones
- Comunidad más grande
- Más documentación y tutoriales

#### **Google ADK vs CrewAI**

**Ventajas de ADK:**
- Soporte oficial de Google
- Mejor integración con Vertex AI
- Herramientas de debugging avanzadas
- Streaming bidireccional integrado

**Ventajas de CrewAI:**
- Más fácil de aprender
- Sintaxis más intuitiva para multi-agente
- Mejores abstracciones para roles de agente
- Comunidad activa

#### **Google ADK vs AutoGen**

**Ventajas de ADK:**
- Mejor experiencia de desarrollo
- Herramientas visuales integradas
- Deployment más robusto
- Integración con MCP

**Ventajas de AutoGen:**
- Más maduro y estable
- Mejor rendimiento para conversaciones largas
- Más patrones de interacción pre-definidos
- Mayor flexibilidad en configuración

### Recomendaciones de Uso

#### **Usa Google ADK cuando:**
- Necesites integración fuerte con Google Cloud
- Requieras herramientas de desarrollo visual
- Busques deployment simplificado
- Trabajes con sistemas multi-agente complejos
- Necesites streaming multimedia

#### **Usa LangChain cuando:**
- Requieras máxima flexibilidad
- Necesites integración con múltiples proveedores
- Tengas un equipo experimentado en Python
- Busques la comunidad más grande

#### **Usa CrewAI cuando:**
- Seas nuevo en desarrollo de agentes
- Necesites prototipos rápidos
- Trabajes con equipos de agentes simples
- Priorices facilidad de uso

#### **Usa AutoGen cuando:**
- Necesites conversaciones multi-agente complejas
- Requieras rendimiento optimizado
- Trabajes con casos de uso académicos
- Busques estabilidad probada

---

## 8. Aplicación para Chatbots de Restaurante

### Caso de Uso: Sistema de Pedidos de Restaurante

#### Arquitectura Recomendada

```
┌─────────────────────────────────────────────┐
│           Restaurant Bot System             │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐    ┌─────────────────┐ │
│  │  Greeting Agent │    │   Menu Agent    │ │
│  │                 │    │                 │ │
│  │ • Welcome       │    │ • Show Menu     │ │
│  │ • Identify User │    │ • Explain Items │ │
│  │ • Set Language  │    │ • Check Allergies│ │
│  └─────────────────┘    └─────────────────┘ │
│                                             │
│  ┌─────────────────┐    ┌─────────────────┐ │
│  │  Order Agent    │    │ Payment Agent   │ │
│  │                 │    │                 │ │
│  │ • Take Orders   │    │ • Process Payment│ │
│  │ • Modify Orders │    │ • Generate Receipt│ │
│  │ • Calculate Total│    │ • Send Confirmation│ │
│  └─────────────────┘    └─────────────────┘ │
│                                             │
│  ┌─────────────────┐    ┌─────────────────┐ │
│  │  Status Agent   │    │ Coordinator     │ │
│  │                 │    │ Agent           │ │
│  │ • Order Status  │    │                 │ │
│  │ • Wait Times    │    │ • Route Requests│ │
│  │ • Delivery Info │    │ • Handle Context│ │
│  └─────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────┘
```

#### Implementación Práctica

```python
from google.adk.agents import Agent
import json
from datetime import datetime, timedelta

# Base de datos simulada del restaurante
MENU_DATABASE = {
    "pizzas": {
        "margherita": {
            "name": "Pizza Margherita",
            "price": 12.99,
            "ingredients": ["salsa de tomate", "mozzarella", "albahaca"],
            "allergens": ["gluten", "lactosa"],
            "preparation_time": 15
        },
        "pepperoni": {
            "name": "Pizza Pepperoni", 
            "price": 15.99,
            "ingredients": ["salsa de tomate", "mozzarella", "pepperoni"],
            "allergens": ["gluten", "lactosa"],
            "preparation_time": 15
        }
    },
    "bebidas": {
        "coca_cola": {
            "name": "Coca Cola",
            "price": 2.50,
            "size": "330ml",
            "allergens": [],
            "preparation_time": 1
        },
        "agua": {
            "name": "Agua Mineral",
            "price": 1.50, 
            "size": "500ml",
            "allergens": [],
            "preparation_time": 1
        }
    },
    "postres": {
        "tiramisu": {
            "name": "Tiramisú",
            "price": 6.99,
            "ingredients": ["mascarpone", "café", "cacao", "huevo"],
            "allergens": ["lactosa", "huevo", "gluten"],
            "preparation_time": 5
        }
    }
}

ORDERS_DATABASE = {}

# 1. Agente de Saludo y Bienvenida
def identify_user_language(message: str) -> dict:
    """Identifica el idioma del usuario basado en su mensaje."""
    spanish_keywords = ["hola", "buenas", "gracias", "por favor", "menu"]
    english_keywords = ["hello", "hi", "thanks", "please", "menu"]
    
    message_lower = message.lower()
    
    spanish_count = sum(1 for word in spanish_keywords if word in message_lower)
    english_count = sum(1 for word in english_keywords if word in message_lower)
    
    if spanish_count > english_count:
        return {"language": "spanish", "confidence": "high"}
    elif english_count > spanish_count:
        return {"language": "english", "confidence": "high"}
    else:
        return {"language": "spanish", "confidence": "medium"}  # Default español

greeting_agent = Agent(
    name="greeting_assistant",
    model="gemini-2.0-flash",
    description="Agente especializado en saludar y dar la bienvenida a clientes",
    instruction="""
    Eres un asistente amigable de restaurante. Tu trabajo es:
    
    1. Saludar calurosamente a los clientes
    2. Identificar su idioma preferido
    3. Dar una breve introducción al restaurante
    4. Preguntar cómo puedes ayudarles
    5. Dirigirlos al agente apropiado
    
    Mantén un tono amigable y profesional. Si detectas que hablan inglés, responde en inglés.
    """,
    tools=[identify_user_language]
)

# 2. Agente del Menú
def get_menu_section(section: str) -> dict:
    """Obtiene una sección específica del menú."""
    if section.lower() in MENU_DATABASE:
        return {
            "status": "success",
            "section": section,
            "items": MENU_DATABASE[section.lower()]
        }
    else:
        available_sections = list(MENU_DATABASE.keys())
        return {
            "status": "error",
            "message": f"Sección no encontrada. Secciones disponibles: {available_sections}"
        }

def search_menu_item(item_name: str) -> dict:
    """Busca un elemento específico en todo el menú."""
    item_name_lower = item_name.lower().replace(" ", "_")
    
    for section, items in MENU_DATABASE.items():
        if item_name_lower in items:
            item = items[item_name_lower]
            return {
                "status": "success",
                "item": item,
                "section": section
            }
    
    return {
        "status": "error", 
        "message": f"Elemento '{item_name}' no encontrado en el menú"
    }

def check_allergens(item_name: str, user_allergies: list) -> dict:
    """Verifica si un elemento contiene alérgenos específicos."""
    search_result = search_menu_item(item_name)
    
    if search_result["status"] == "error":
        return search_result
    
    item_allergens = search_result["item"].get("allergens", [])
    conflicts = [allergen for allergen in user_allergies if allergen in item_allergens]
    
    if conflicts:
        return {
            "status": "warning",
            "message": f"⚠️ ADVERTENCIA: {item_name} contiene {conflicts} que están en tu lista de alergias",
            "safe": False,
            "conflicts": conflicts
        }
    else:
        return {
            "status": "success",
            "message": f"✅ {item_name} es seguro para tus alergias",
            "safe": True
        }

menu_agent = Agent(
    name="menu_specialist",
    model="gemini-2.0-flash",
    description="Especialista en el menú del restaurante",
    instruction="""
    Eres un experto en nuestro menú. Tu trabajo es:
    
    1. Mostrar elementos del menú con precios y descripciones
    2. Responder preguntas sobre ingredientes
    3. Verificar alérgenos y restricciones dietéticas
    4. Hacer recomendaciones basadas en preferencias
    5. Explicar tiempos de preparación
    
    Siempre pregunta sobre alergias antes de hacer recomendaciones.
    Presenta la información de manera clara y atractiva.
    """,
    tools=[get_menu_section, search_menu_item, check_allergens]
)

# 3. Agente de Pedidos
def add_item_to_order(order_id: str, item_name: str, quantity: int = 1, special_requests: str = "") -> dict:
    """Añade un elemento al pedido."""
    # Verificar que el elemento existe
    search_result = search_menu_item(item_name)
    if search_result["status"] == "error":
        return search_result
    
    item = search_result["item"]
    
    # Crear o actualizar pedido
    if order_id not in ORDERS_DATABASE:
        ORDERS_DATABASE[order_id] = {
            "items": [],
            "total": 0.0,
            "status": "building",
            "created_at": datetime.now().isoformat(),
            "special_requests": []
        }
    
    # Añadir elemento
    order_item = {
        "name": item["name"],
        "price": item["price"],
        "quantity": quantity,
        "subtotal": item["price"] * quantity,
        "special_requests": special_requests,
        "preparation_time": item.get("preparation_time", 10)
    }
    
    ORDERS_DATABASE[order_id]["items"].append(order_item)
    ORDERS_DATABASE[order_id]["total"] += order_item["subtotal"]
    
    if special_requests:
        ORDERS_DATABASE[order_id]["special_requests"].append(special_requests)
    
    return {
        "status": "success",
        "message": f"Añadido {quantity}x {item['name']} al pedido",
        "order_item": order_item,
        "current_total": ORDERS_DATABASE[order_id]["total"]
    }

def get_order_summary(order_id: str) -> dict:
    """Obtiene un resumen del pedido actual."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    order = ORDERS_DATABASE[order_id]
    total_prep_time = max([item["preparation_time"] for item in order["items"]] + [0])
    
    return {
        "status": "success",
        "order": order,
        "estimated_time": total_prep_time,
        "item_count": len(order["items"])
    }

def remove_item_from_order(order_id: str, item_index: int) -> dict:
    """Elimina un elemento del pedido por índice."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    order = ORDERS_DATABASE[order_id]
    
    if item_index < 0 or item_index >= len(order["items"]):
        return {"status": "error", "message": "Índice de elemento inválido"}
    
    removed_item = order["items"].pop(item_index)
    order["total"] -= removed_item["subtotal"]
    
    return {
        "status": "success",
        "message": f"Eliminado {removed_item['name']} del pedido",
        "removed_item": removed_item,
        "new_total": order["total"]
    }

order_agent = Agent(
    name="order_specialist", 
    model="gemini-2.0-flash",
    description="Especialista en tomar y gestionar pedidos",
    instruction="""
    Eres un experto en tomar pedidos de restaurante. Tu trabajo es:
    
    1. Ayudar a los clientes a construir su pedido
    2. Añadir elementos con cantidades correctas
    3. Manejar modificaciones y solicitudes especiales
    4. Proporcionar resúmenes de pedido claros
    5. Calcular totales y tiempos de preparación
    6. Confirmar pedidos antes del pago
    
    Siempre confirma cada elemento añadido y proporciona el total actualizado.
    Pregunta sobre solicitudes especiales o modificaciones.
    """,
    tools=[add_item_to_order, get_order_summary, remove_item_from_order]
)

# 4. Agente de Pago
def calculate_final_total(order_id: str, tax_rate: float = 0.21, tip_percentage: float = 0.0) -> dict:
    """Calcula el total final con impuestos y propina opcional."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    order = ORDERS_DATABASE[order_id]
    subtotal = order["total"]
    tax_amount = subtotal * tax_rate
    tip_amount = subtotal * (tip_percentage / 100)
    final_total = subtotal + tax_amount + tip_amount
    
    return {
        "status": "success",
        "breakdown": {
            "subtotal": round(subtotal, 2),
            "tax": round(tax_amount, 2),
            "tip": round(tip_amount, 2),
            "final_total": round(final_total, 2)
        }
    }

def process_payment(order_id: str, payment_method: str, amount: float) -> dict:
    """Procesa el pago del pedido."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    # Calcular total final
    total_calc = calculate_final_total(order_id)
    if total_calc["status"] == "error":
        return total_calc
    
    expected_total = total_calc["breakdown"]["final_total"]
    
    if amount < expected_total:
        return {
            "status": "error",
            "message": f"Cantidad insuficiente. Se requieren €{expected_total}"
        }
    
    # Simular procesamiento de pago
    if payment_method.lower() in ["tarjeta", "card", "efectivo", "cash"]:
        # Actualizar estado del pedido
        ORDERS_DATABASE[order_id]["status"] = "paid"
        ORDERS_DATABASE[order_id]["payment_method"] = payment_method
        ORDERS_DATABASE[order_id]["paid_amount"] = amount
        ORDERS_DATABASE[order_id]["paid_at"] = datetime.now().isoformat()
        
        # Generar tiempo estimado de entrega
        max_prep_time = max([item["preparation_time"] for item in ORDERS_DATABASE[order_id]["items"]] + [10])
        estimated_ready = datetime.now() + timedelta(minutes=max_prep_time)
        
        return {
            "status": "success",
            "message": "Pago procesado exitosamente",
            "transaction_id": f"TXN-{order_id}-{datetime.now().strftime('%Y%m%d%H%M%S')}",
            "change": round(amount - expected_total, 2) if amount > expected_total else 0,
            "estimated_ready": estimated_ready.strftime("%H:%M"),
            "order_number": order_id
        }
    else:
        return {
            "status": "error",
            "message": "Método de pago no válido. Use 'tarjeta' o 'efectivo'"
        }

payment_agent = Agent(
    name="payment_processor",
    model="gemini-2.0-flash", 
    description="Especialista en procesamiento de pagos",
    instruction="""
    Eres un especialista en pagos de restaurante. Tu trabajo es:
    
    1. Calcular totales finales con impuestos
    2. Manejar propinas opcionales
    3. Procesar diferentes métodos de pago
    4. Generar recibos y confirmaciones
    5. Proporcionar tiempos estimados de entrega
    6. Manejar cambio para pagos en efectivo
    
    Siempre confirma el total antes del pago y proporciona recibos claros.
    """,
    tools=[calculate_final_total, process_payment]
)

# 5. Agente de Estado de Pedidos
def check_order_status(order_id: str) -> dict:
    """Verifica el estado actual de un pedido."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    order = ORDERS_DATABASE[order_id]
    
    status_messages = {
        "building": "El pedido está siendo construido",
        "paid": "Pago recibido, preparando pedido",
        "preparing": "El pedido está siendo preparado en la cocina",
        "ready": "El pedido está listo para recoger",
        "completed": "Pedido completado"
    }
    
    return {
        "status": "success",
        "order_status": order["status"],
        "message": status_messages.get(order["status"], "Estado desconocido"),
        "order_details": order
    }

def get_wait_time_estimate(order_id: str) -> dict:
    """Proporciona una estimación del tiempo de espera."""
    if order_id not in ORDERS_DATABASE:
        return {"status": "error", "message": "Pedido no encontrado"}
    
    order = ORDERS_DATABASE[order_id]
    
    if order["status"] == "building":
        return {"status": "info", "message": "Complete su pedido primero"}
    
    # Calcular tiempo basado en elementos del pedido
    max_prep_time = max([item["preparation_time"] for item in order["items"]] + [10])
    
    if order["status"] == "paid":
        estimated_ready = datetime.fromisoformat(order["paid_at"]) + timedelta(minutes=max_prep_time)
        remaining_time = (estimated_ready - datetime.now()).total_seconds() / 60
        
        if remaining_time > 0:
            return {
                "status": "success",
                "estimated_minutes": int(remaining_time),
                "ready_time": estimated_ready.strftime("%H:%M")
            }
        else:
            return {
                "status": "success", 
                "message": "Su pedido debería estar listo ahora"
            }
    
    return {"status": "info", "message": f"Tiempo estimado de preparación: {max_prep_time} minutos"}

status_agent = Agent(
    name="status_tracker",
    model="gemini-2.0-flash",
    description="Especialista en seguimiento de estado de pedidos",
    instruction="""
    Eres un especialista en seguimiento de pedidos. Tu trabajo es:
    
    1. Verificar el estado actual de pedidos
    2. Proporcionar tiempos de espera precisos
    3. Mantener a los clientes informados
    4. Manejar consultas sobre retrasos
    5. Actualizar estados cuando sea apropiado
    
    Mantén a los clientes informados con actualizaciones claras y tiempos realistas.
    """,
    tools=[check_order_status, get_wait_time_estimate]
)

# 6. Agente Coordinador Principal
coordinator_agent = Agent(
    name="restaurant_coordinator",
    model="gemini-2.0-flash",
    description="Coordinador principal del sistema de restaurante",
    instruction="""
    Eres el coordinador principal de nuestro sistema de restaurante. Tu trabajo es:
    
    1. Dirigir a los clientes al agente especializado correcto
    2. Mantener el contexto de la conversación
    3. Manejar transiciones suaves entre agentes
    4. Proporcionar asistencia general
    5. Manejar situaciones especiales o quejas
    
    Agentes disponibles:
    - greeting_assistant: Para saludos y bienvenidas iniciales
    - menu_specialist: Para consultas sobre el menú, ingredientes y alergias
    - order_specialist: Para tomar y modificar pedidos
    - payment_processor: Para manejar pagos y totales
    - status_tracker: Para verificar estado de pedidos
    
    Usa el contexto para determinar qué agente necesita el cliente.
    Mantén un tono amigable y profesional en todo momento.
    """,
    tools=[greeting_agent, menu_agent, order_agent, payment_agent, status_agent]
)
```

### Flujo de Conversación Típico

```python
# Ejemplo de flujo completo
from google.adk.runner import InMemoryRunner

# Crear el runner con el agente coordinador
runner = InMemoryRunner(coordinator_agent)

# Crear sesión para el cliente
session = runner.session_service().create_session(
    agent_name="restaurant_coordinator",
    user_id="customer_001"
).blocking_get()

# Simulación de conversación
conversation_flow = [
    "Hola, ¿puedo ver el menú?",                    # → greeting_assistant + menu_specialist
    "¿La pizza margherita tiene gluten?",           # → menu_specialist
    "Tengo alergia al gluten, ¿qué me recomiendas?", # → menu_specialist
    "Quiero pedir una ensalada césar",              # → order_specialist
    "Añade también una coca cola",                  # → order_specialist  
    "¿Cuál es el total?",                           # → payment_processor
    "Pago con tarjeta",                             # → payment_processor
    "¿Cuándo estará listo mi pedido?"               # → status_tracker
]

# Ejecutar cada mensaje
for message in conversation_flow:
    print(f"\n👤 Cliente: {message}")
    
    from google.genai.types import Content, Part
    user_msg = Content.from_parts(Part.from_text(message))
    
    events = runner.run_async("customer_001", session.id(), user_msg)
    
    print("🤖 Restaurante: ", end="")
    events.blocking_for_each(lambda event: print(event.stringify_content()))
```

### Mejoras y Extensiones Recomendadas

#### 1. **Integración con Base de Datos Real**
```python
import sqlite3
from sqlalchemy import create_engine

# Conexión a base de datos real
def get_menu_from_db():
    """Conecta con base de datos real del restaurante."""
    engine = create_engine('sqlite:///restaurant.db')
    # Implementar consultas reales
    pass
```

#### 2. **Sistema de Notificaciones**
```python
def send_sms_notification(phone: str, message: str):
    """Envía notificaciones SMS a clientes."""
    # Integración con Twilio, AWS SNS, etc.
    pass

def send_email_receipt(email: str, order_details: dict):
    """Envía recibo por email."""
    # Integración con SendGrid, AWS SES, etc.
    pass
```

#### 3. **Integración con Sistema POS**
```python
def sync_with_pos_system(order_data: dict):
    """Sincroniza pedidos con sistema POS del restaurante."""
    # Integración con Square, Toast, etc.
    pass
```

#### 4. **Analytics y Métricas**
```python
def track_customer_analytics(user_id: str, action: str, data: dict):
    """Rastrea métricas de cliente para análisis."""
    # Integración con Google Analytics, Mixpanel, etc.
    pass
```

---

## 9. Despliegue en Producción

### Opciones de Despliegue

#### 1. **Vertex AI Agent Engine** (Recomendado)
```yaml
# deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: adk-config
data:
  GOOGLE_CLOUD_PROJECT: "tu-proyecto"
  GOOGLE_CLOUD_LOCATION: "us-central1"
  GOOGLE_GENAI_USE_VERTEXAI: "TRUE"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restaurant-bot
spec:
  replicas: 3
  selector:
    matchLabels:
      app: restaurant-bot
  template:
    metadata:
      labels:
        app: restaurant-bot
    spec:
      containers:
      - name: restaurant-bot
        image: gcr.io/tu-proyecto/restaurant-bot:latest
        envFrom:
        - configMapRef:
            name: adk-config
        ports:
        - containerPort: 8080
```

#### 2. **Cloud Run**
```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY . .

# Configurar puerto
ENV PORT=8080

# Comando de inicio
CMD ["adk", "api_server", "--host", "0.0.0.0", "--port", "$PORT"]
```

```bash
# Comandos de despliegue a Cloud Run
gcloud builds submit --tag gcr.io/TU_PROJECT_ID/restaurant-bot
gcloud run deploy restaurant-bot \
  --image gcr.io/TU_PROJECT_ID/restaurant-bot \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=TU_PROJECT_ID
```

#### 3. **Google Kubernetes Engine (GKE)**
```yaml
# gke-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restaurant-bot-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: restaurant-bot
  template:
    metadata:
      labels:
        app: restaurant-bot
    spec:
      containers:
      - name: restaurant-bot
        image: gcr.io/tu-proyecto/restaurant-bot:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        env:
        - name: GOOGLE_CLOUD_PROJECT
          value: "tu-proyecto"
        - name: GOOGLE_CLOUD_LOCATION
          value: "us-central1"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: restaurant-bot-service
spec:
  selector:
    app: restaurant-bot
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Mejores Prácticas de Despliegue

#### 1. **Configuración de Entorno**
```python
# config.py
import os
from dataclasses import dataclass

@dataclass
class Config:
    # Google Cloud
    project_id: str = os.getenv("GOOGLE_CLOUD_PROJECT")
    location: str = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
    
    # Base de datos
    db_host: str = os.getenv("DB_HOST", "localhost")
    db_name: str = os.getenv("DB_NAME", "restaurant")
    
    # Redis para cache
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    
    # APIs externas
    payment_api_key: str = os.getenv("PAYMENT_API_KEY")
    sms_api_key: str = os.getenv("SMS_API_KEY")
    
    # Configuración del agente
    model_name: str = os.getenv("MODEL_NAME", "gemini-2.0-flash")
    max_tokens: int = int(os.getenv("MAX_TOKENS", "1000"))
    temperature: float = float(os.getenv("TEMPERATURE", "0.7"))

config = Config()
```

#### 2. **Logging y Monitoreo**
```python
import logging
from google.cloud import logging as cloud_logging

# Configurar logging
def setup_logging():
    """Configura logging para producción."""
    if config.project_id:
        # Google Cloud Logging
        client = cloud_logging.Client(project=config.project_id)
        client.setup_logging()
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

# Logging de eventos del agente
def log_agent_event(event_type: str, data: dict):
    """Registra eventos importantes del agente."""
    logger = logging.getLogger("restaurant_bot")
    logger.info(
        f"Agent Event: {event_type}",
        extra={
            "event_type": event_type,
            "data": data,
            "timestamp": datetime.now().isoformat()
        }
    )
```

#### 3. **Health Checks y Métricas**
```python
from flask import Flask, jsonify
import psutil
import time

app = Flask(__name__)

@app.route("/health")
def health_check():
    """Endpoint de health check para Kubernetes."""
    try:
        # Verificar conexión a la base de datos
        # Verificar disponibilidad del modelo
        # Verificar servicios externos
        
        return jsonify({
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "services": {
                "database": "connected",
                "model": "available",
                "external_apis": "operational"
            }
        }), 200
    except Exception as e:
        return jsonify({
            "status": "unhealthy", 
            "error": str(e)
        }), 500

@app.route("/metrics")
def metrics():
    """Métricas para monitoreo."""
    return jsonify({
        "cpu_percent": psutil.cpu_percent(),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent,
        "active_sessions": len(get_active_sessions()),
        "requests_per_minute": get_rpm_count()
    })
```

#### 4. **Seguridad y Autenticación**
```python
from functools import wraps
import jwt

def require_auth(f):
    """Decorator para requerir autenticación."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'error': 'Token requerido'}), 401
        
        try:
            # Verificar JWT token
            payload = jwt.decode(token, config.secret_key, algorithms=['HS256'])
            current_user = payload['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expirado'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token inválido'}), 401
        
        return f(current_user, *args, **kwargs)
    return decorated_function

# Aplicar autenticación a endpoints sensibles
@app.route("/admin/orders")
@require_auth
def admin_orders(current_user):
    """Endpoint administrativo protegido."""
    # Lógica administrativa
    pass
```

#### 5. **Scaling y Performance**
```python
# Configuración de auto-scaling
from google.adk.runner import InMemoryRunner
import redis
from concurrent.futures import ThreadPoolExecutor

# Cache Redis para sesiones
redis_client = redis.Redis.from_url(config.redis_url)

# Pool de threads para concurrencia
executor = ThreadPoolExecutor(max_workers=20)

class ScalableRunner:
    """Runner escalable con cache y pooling."""
    
    def __init__(self, agent):
        self.agent = agent
        self.runner = InMemoryRunner(agent)
    
    def get_session(self, user_id: str):
        """Obtiene sesión desde cache o crea nueva."""
        session_key = f"session:{user_id}"
        session_data = redis_client.get(session_key)
        
        if session_data:
            return json.loads(session_data)
        else:
            # Crear nueva sesión
            session = self.runner.session_service().create_session(
                agent_name=self.agent.name,
                user_id=user_id
            ).blocking_get()
            
            # Guardar en cache (1 hora)
            redis_client.setex(
                session_key, 
                3600, 
                json.dumps(session.to_dict())
            )
            return session
    
    async def process_message_async(self, user_id: str, message: str):
        """Procesa mensaje de forma asíncrona."""
        session = self.get_session(user_id)
        
        # Ejecutar en thread pool
        future = executor.submit(
            self._process_message_sync,
            user_id, 
            session.id(), 
            message
        )
        
        return await asyncio.wrap_future(future)
```

### Monitoreo y Observabilidad

#### **Métricas Clave a Monitorear**
1. **Latencia de respuesta del agente**
2. **Tasa de error en procesamiento** 
3. **Uso de tokens del modelo**
4. **Sesiones activas concurrentes**
5. **Tiempo de respuesta de herramientas**
6. **Tasa de completación de pedidos**

#### **Alertas Recomendadas**
```yaml
# alerting-rules.yaml
groups:
- name: restaurant_bot_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(adk_errors_total[5m]) > 0.1
    for: 2m
    annotations:
      summary: "Alta tasa de errores en el bot del restaurante"
  
  - alert: HighLatency
    expr: histogram_quantile(0.95, rate(adk_request_duration_seconds_bucket[5m])) > 5
    for: 2m
    annotations:
      summary: "Alta latencia en respuestas del bot"
  
  - alert: TokenLimitNearExceeded
    expr: adk_tokens_used / adk_tokens_limit > 0.9
    annotations:
      summary: "Uso de tokens cerca del límite"
```

---

## 10. Recursos Oficiales y Aprendizaje

### Documentación Oficial

#### **Recursos Principales**
- **Sitio Oficial**: [https://google.github.io/adk-docs/](https://google.github.io/adk-docs/)
- **Repositorio Python**: [https://github.com/google/adk-python](https://github.com/google/adk-python)
- **Repositorio Java**: [https://github.com/google/adk-java](https://github.com/google/adk-java)
- **Ejemplos**: [https://github.com/google/adk-samples](https://github.com/google/adk-samples)
- **Protocolo A2A**: [https://github.com/google/A2A/](https://github.com/google/A2A/)

#### **Documentación Técnica**
- **Guía de Inicio**: [https://google.github.io/adk-docs/get-started/](https://google.github.io/adk-docs/get-started/)
- **Referencia API Python**: [https://google.github.io/adk-docs/api-reference/python/](https://google.github.io/adk-docs/api-reference/python/)
- **Referencia API Java**: [https://google.github.io/adk-docs/api-reference/java/](https://google.github.io/adk-docs/api-reference/java/)
- **Guía de Despliegue**: [https://google.github.io/adk-docs/deploy/](https://google.github.io/adk-docs/deploy/)

### Google Cloud Integration

#### **Vertex AI**
- **Quickstart ADK + Vertex AI**: [https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit/quickstart](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit/quickstart)
- **Agent Engine**: [https://google.github.io/adk-docs/deploy/agent-engine/](https://google.github.io/adk-docs/deploy/agent-engine/)

### Codelabs y Tutoriales Interactivos

#### **Google Codelabs**
1. **Tu Primer Agente con ADK**
   - URL: [https://codelabs.developers.google.com/your-first-agent-with-adk](https://codelabs.developers.google.com/your-first-agent-with-adk)
   - Nivel: Principiante
   - Duración: 30 minutos

2. **Agente de Viajes con MCP y ADK**
   - URL: [https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk](https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk)
   - Nivel: Intermedio
   - Duración: 45 minutos

3. **Aplicación Multi-Agente con ADK**
   - URL: [https://codelabs.developers.google.com/multi-agent-app-with-adk](https://codelabs.developers.google.com/multi-agent-app-with-adk)
   - Nivel: Avanzado
   - Duración: 60 minutos

4. **Asistente de Gastos Multimodal**
   - URL: [https://codelabs.developers.google.com/personal-expense-assistant-multimodal-adk](https://codelabs.developers.google.com/personal-expense-assistant-multimodal-adk)
   - Nivel: Intermedio
   - Duración: 50 minutos

### Videos y Contenido Multimedia

#### **Videos Oficiales**
1. **"Introducing Agent Development Kit"** - Google for Developers
   - URL: [https://www.youtube.com/watch?v=44C8u0CDtSo](https://www.youtube.com/watch?v=44C8u0CDtSo)
   - Duración: 15 minutos

2. **"Getting Started with ADK"** - Google for Developers  
   - URL: [https://www.youtube.com/watch?v=C1Zn19BcC2M](https://www.youtube.com/watch?v=C1Zn19BcC2M)
   - Duración: 20 minutos

#### **Tutoriales de la Comunidad**
1. **"Build Your First AI Agent With Google ADK in Minutes!"**
   - URL: [https://youtu.be/QN14IFM9s04](https://youtu.be/QN14IFM9s04)
   - Creador: Comunidad
   - Duración: 12 minutos

2. **"Agent Development Kit (ADK) Masterclass"**
   - URL: [https://youtu.be/P4VFL9nIaIA](https://youtu.be/P4VFL9nIaIA)
   - Nivel: Completo (Principiante a Profesional)
   - Duración: 90 minutos

### Blogs y Artículos Técnicos

#### **Blog Oficial de Google**
- **"Making it easy to build multi-agent applications"**
  - URL: [https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/](https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/)

#### **Artículos de la Comunidad (Seleccionados)**
1. **"The Complete Guide to Google's Agent Development Kit (ADK)"**
   - URL: [https://www.siddharthbharath.com/the-complete-guide-to-googles-agent-development-kit-adk/](https://www.siddharthbharath.com/the-complete-guide-to-googles-agent-development-kit-adk/)
   - Nivel: Completo

2. **"Agent Development Kit (ADK): A Guide With Demo Project"**
   - URL: [https://www.datacamp.com/tutorial/agent-development-kit-adk](https://www.datacamp.com/tutorial/agent-development-kit-adk)
   - Plataforma: DataCamp

3. **"Building Intelligent Agents Made Easy"**
   - URL: [https://ai.plainenglish.io/building-intelligent-agents-made-easy-a-guide-to-googles-agent-development-kit-adk-f583425bde8d](https://ai.plainenglish.io/building-intelligent-agents-made-easy-a-guide-to-googles-agent-development-kit-adk-f583425bde8d)

### Proyectos de Ejemplo y Demos

#### **Repositorios de Ejemplo**
1. **ADK-Powered Travel Planner**
   - Repositorio: [https://github.com/AashiDutt/Google-Agent-Development-Kit-Demo](https://github.com/AashiDutt/Google-Agent-Development-Kit-Demo)
   - Descripción: Planificador de viajes multi-agente

2. **US Stock Market AI Agent**
   - Repositorio: [https://github.com/RashRAJ/stockAIAgent](https://github.com/RashRAJ/stockAIAgent)
   - Descripción: Agente de análisis de mercado

3. **GitHub Agent con OpenAPI Tools**
   - Repositorio: [https://github.com/arjunprabhulal/adk-github-agent](https://github.com/arjunprabhulal/adk-github-agent)
   - Descripción: Agente para gestión de GitHub

### Comunidad y Soporte

#### **Canales Oficiales**
- **GitHub Issues**: [https://github.com/google/adk-python/issues](https://github.com/google/adk-python/issues)
- **Guía de Contribución**: [https://google.github.io/adk-docs/contributing-guide/](https://google.github.io/adk-docs/contributing-guide/)

#### **Comunidades Externas**
- **Reddit r/LangChain**: Discusiones sobre frameworks de agentes
- **Discord Comunidades AI**: Múltiples servidores con canales ADK
- **Stack Overflow**: Tag `google-adk` para preguntas técnicas

### Herramientas de Desarrollo

#### **IDEs y Extensiones Recomendadas**
1. **Visual Studio Code**
   - Extensión Python
   - Extensión Docker
   - Extensión Google Cloud

2. **PyCharm Professional**
   - Soporte nativo para Python
   - Integración con Google Cloud
   - Debugging avanzado

3. **IntelliJ IDEA** (para Java)
   - Plugin Google Cloud
   - Soporte Maven/Gradle

#### **Herramientas de Testing**
```python
# pytest para testing de agentes
def test_menu_agent():
    """Test del agente de menú."""
    result = menu_agent.tools[0]("pizzas")  # get_menu_section
    assert result["status"] == "success"
    assert "pizzas" in result

# unittest para testing más formal
import unittest
from google.adk.testing import AgentTester

class TestRestaurantBot(unittest.TestCase):
    def setUp(self):
        self.tester = AgentTester(coordinator_agent)
    
    def test_order_flow(self):
        """Test del flujo completo de pedido."""
        responses = self.tester.conversation([
            "Hola, quiero hacer un pedido",
            "Pizza margherita",
            "¿Cuál es el total?"
        ])
        
        self.assertIn("pizza margherita", responses[-1].lower())
```

### Roadmap y Futuro

#### **Características Próximas (Según Roadmap Público)**
- Mejoras en el sistema de callbacks
- Más herramientas preconstruidas
- Mejor soporte para modelos open source
- Integración mejorada con MCP
- Herramientas de debugging avanzadas

#### **Mantenerse Actualizado**
- **Newsletter Google Developers**: [https://developers.google.com/newsletter](https://developers.google.com/newsletter)
- **Blog Google Cloud**: [https://cloud.google.com/blog](https://cloud.google.com/blog)
- **GitHub Releases**: Seguir releases en repositorios oficiales

---

## Conclusión

Google Agent Development Kit (ADK) representa una solución robusta y bien diseñada para el desarrollo de agentes de IA y sistemas multi-agente. Para el caso específico de desarrollo de chatbots de restaurante, ADK ofrece:

### **Fortalezas Clave para Chatbots de Restaurante:**
1. **Arquitectura Multi-Agente**: Perfecta para separar responsabilidades (menú, pedidos, pagos, estado)
2. **Integración Google Cloud**: Excelente para empresas que ya usan el ecosistema Google
3. **Herramientas de Desarrollo**: CLI y Web UI facilitan el desarrollo y debugging
4. **Despliegue Simplificado**: Múltiples opciones desde local hasta cloud escalable
5. **Streaming Integrado**: Permite interacciones de voz para pedidos telefónicos

### **Consideraciones Importantes:**
1. **Curva de Aprendizaje**: Requiere familiarización con conceptos específicos de ADK
2. **Limitaciones Actuales**: Estructura rígida y algunas restricciones en herramientas
3. **Madurez**: Framework relativamente nuevo (abril 2025) comparado con alternativas

### **Recomendación:**
ADK es una excelente opción para chatbots de restaurante, especialmente si:
- Ya usas servicios de Google Cloud
- Necesitas capacidades multi-agente sofisticadas  
- Priorizas herramientas de desarrollo integradas
- Requieres deployment escalable en la nube

La documentación y ejemplos proporcionados en esta guía te permitirán implementar un sistema completo de chatbot para restaurante utilizando las mejores prácticas de ADK.

---

*Documentación generada el 5 de junio de 2025*  
*Versión de ADK: 1.2.1*  
*Estado: Producción*
