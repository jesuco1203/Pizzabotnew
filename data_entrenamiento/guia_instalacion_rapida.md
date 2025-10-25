# Guía de Instalación Rápida - Google ADK

## ⚡ Instalación Express (5 minutos)

### Requisitos Previos
- ✅ Python 3.9+ (recomendado 3.10+)
- ✅ pip actualizado
- ✅ Cuenta Google Cloud o Google AI Studio

### Paso 1: Configurar Entorno

```bash
# Crear directorio del proyecto
mkdir mi-chatbot-adk
cd mi-chatbot-adk

# Crear entorno virtual
python -m venv .venv

# Activar entorno virtual
# macOS/Linux:
source .venv/bin/activate
# Windows:
.venv\Scripts\activate
```

### Paso 2: Instalar ADK

```bash
# Instalar Google ADK
pip install google-adk

# Verificar instalación
pip show google-adk
```

### Paso 3: Configurar Credenciales

#### Opción A: Google AI Studio (Más Rápido)
1. Ir a [Google AI Studio](https://aistudio.google.com/apikey)
2. Crear clave API
3. Crear archivo `.env`:

```bash
# .env
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=tu_clave_api_aqui
```

#### Opción B: Google Cloud Vertex AI
```bash
# .env
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=tu-proyecto-id
GOOGLE_CLOUD_LOCATION=us-central1
```

### Paso 4: Crear Tu Primer Agente

```python
# agente_simple.py
from google.adk.agents import Agent

def saludar(nombre: str) -> str:
    """Saluda al usuario por su nombre."""
    return f"¡Hola {nombre}! Bienvenido a nuestro restaurante."

# Crear agente
mi_agente = Agent(
    name="asistente_restaurante",
    model="gemini-2.0-flash", 
    description="Asistente amigable de restaurante",
    instruction="Eres un asistente virtual amigable que ayuda a los clientes del restaurante.",
    tools=[saludar]
)
```

### Paso 5: Ejecutar

```bash
# Interfaz web (recomendado)
adk web

# O terminal
adk run asistente_restaurante
```

## 🚀 Estructura de Proyecto Recomendada

```
mi-chatbot-adk/
├── .env                    # Credenciales
├── .venv/                  # Entorno virtual
├── agentes/
│   ├── __init__.py
│   ├── saludo.py          # Agente de saludo
│   ├── menu.py            # Agente de menú  
│   ├── pedidos.py         # Agente de pedidos
│   └── coordinador.py     # Agente principal
├── herramientas/
│   ├── __init__.py
│   ├── base_datos.py      # Funciones de BD
│   └── utilidades.py      # Utilidades
├── datos/
│   ├── menu.json          # Datos del menú
│   └── restaurant.db      # Base de datos
└── tests/
    └── test_agentes.py    # Tests
```

## 📋 Checklist de Instalación

- [ ] Python 3.9+ instalado
- [ ] Entorno virtual creado y activado
- [ ] Google ADK instalado
- [ ] Credenciales configuradas (.env)
- [ ] Primer agente creado
- [ ] Prueba con `adk web` exitosa

## 🔧 Comandos Útiles

```bash
# Ver ayuda de ADK
adk --help

# Listar agentes disponibles
adk list

# Ejecutar agente específico
adk run nombre_agente

# Servidor API local
adk api_server

# Interfaz web de desarrollo
adk web --port 8080
```

## ⚠️ Solución de Problemas Comunes

### Error: "No module named 'google.adk'"
```bash
# Verificar que el entorno virtual está activado
which python
pip list | grep google-adk
```

### Error: "Authentication failed"
```bash
# Verificar archivo .env
cat .env
# Verificar permisos de Google Cloud
gcloud auth list
```

### Error: "Agent not found"
```bash
# Verificar estructura de carpetas
ls -la
# Ejecutar desde directorio padre del agente
cd ..
adk web
```

## 🎯 Próximos Pasos

1. **Explorar Ejemplos**: Revisar `/workspace/code/adk_restaurant_chatbot_complete.py`
2. **Leer Documentación**: `/workspace/docs/google_adk_documentacion_completa.md`
3. **Probar Multi-Agente**: Crear sistema con múltiples agentes especializados
4. **Integrar BD**: Conectar con base de datos real
5. **Desplegar**: Usar Cloud Run o Vertex AI Agent Engine

## 📚 Recursos Adicionales

- **Documentación Oficial**: [https://google.github.io/adk-docs/](https://google.github.io/adk-docs/)
- **Ejemplos**: [https://github.com/google/adk-samples](https://github.com/google/adk-samples)
- **Tutoriales**: [https://google.github.io/adk-docs/tutorials/](https://google.github.io/adk-docs/tutorials/)

---

*⏱️ Tiempo total estimado: 5-10 minutos*
