<!-- path: data_entrenamiento/Proyectos_adkaget/adk_research.md -->
```markdown
# Investigación y aprendizaje de adk google agents

## ¿Qué es el Agent Development Kit (ADK)?

El Agent Development Kit (ADK) es un framework flexible y modular para el desarrollo y despliegue de agentes de IA. Está optimizado para Gemini y el ecosistema de Google, pero es agnóstico al modelo y al despliegue, y está construido para ser compatible con otros frameworks. ADK fue diseñado para que el desarrollo de agentes se parezca más al desarrollo de software, facilitando a los desarrolladores la creación, el despliegue y la orquestación de arquitecturas de agentes que van desde tareas simples hasta flujos de trabajo complejos.

### Características clave:

*   **Orquestación flexible:** Define flujos de trabajo utilizando agentes de flujo de trabajo (`Sequential`, `Parallel`, `Loop`) para pipelines predecibles, o aprovecha el enrutamiento dinámico impulsado por LLM (`LlmAgent` transfer) para un comportamiento adaptativo.
*   **Arquitectura multi-agente:** Construye aplicaciones modulares y escalables componiendo múltiples agentes especializados en una jerarquía. Permite una coordinación y delegación complejas.
*   **Ecosistema de herramientas enriquecido:** Equipa a los agentes con diversas capacidades: utiliza herramientas preconstruidas (Búsqueda, Ejecución de código), crea funciones personalizadas, integra bibliotecas de terceros (LangChain, CrewAI), o incluso utiliza otros agentes como herramientas.
*   **Listo para el despliegue:** Conteneriza y despliega tus agentes en cualquier lugar: ejecútalos localmente, escala con Vertex AI Agent Engine, o intégralos en una infraestructura personalizada utilizando Cloud Run o Docker.
*   **Evaluación incorporada:** Evalúa sistemáticamente el rendimiento del agente evaluando tanto la calidad de la respuesta final como la trayectoria de ejecución paso a paso contra casos de prueba predefinidos.
*   **Construcción de agentes seguros:** Aprende a construir agentes potentes y confiables implementando patrones y mejores prácticas de seguridad en el diseño de tu agente.




## Instalación de ADK Google Agents (Python)

La versión estable más reciente de ADK se puede instalar usando `pip`:

```bash
pip install google-adk
```

La cadencia de lanzamiento es semanal. Esta versión se recomienda para la mayoría de los usuarios, ya que representa la versión oficial más reciente.

Si necesitas acceder a cambios que aún no se han incluido en una versión oficial de PyPI, puedes instalar directamente desde la rama principal:

```bash
pip install git+https://github.com/google/adk-python.git@main
```

**Nota:** La versión de desarrollo se construye directamente a partir de los últimos commits de código. Si bien incluye las correcciones y características más recientes, también puede contener cambios experimentales o errores no presentes en la versión estable. Úsala principalmente para probar los próximos cambios o acceder a correcciones críticas antes de su lanzamiento oficial.

## Conceptos clave de ADK

### Agentes

En el Agent Development Kit (ADK), un Agente es una unidad de ejecución autocontenida diseñada para actuar de forma autónoma para lograr objetivos específicos. Los agentes pueden realizar tareas, tomar decisiones y comunicarse con otros agentes.

### Herramientas

Las herramientas son las capacidades que un agente puede utilizar para interactuar con el mundo exterior. Pueden ser funciones preconstruidas (como la búsqueda web), funciones personalizadas o integraciones con bibliotecas de terceros.

### Orquestación Multi-Agente

ADK permite construir sistemas multi-agente modulares y escalables, donde múltiples agentes especializados trabajan juntos en una jerarquía para lograr tareas complejas. Esto permite una coordinación y delegación complejas.

### Ejemplo de Agente Raíz (Root Agent)

Un agente raíz puede orquestar otros agentes. Por ejemplo, un `LlmAgent` puede tener `sub_agents` que se encargan de tareas específicas.

```python
from google.adk.agents import Agent
from google.adk.tools import google_search

root_agent = Agent(
    name="search_assistant",
    model="gemini-2.0-flash", # O tu modelo Gemini preferido
    instruction="You are a helpful assistant. Answer user questions using Google Search when needed.",
    description="An assistant that can search the web.",
    tools=[google_search]
)
```

### Ejemplo de Sistema Multi-Agente

```python
from google.adk.agents import LlmAgent, BaseAgent

# Define agentes individuales
greeter = LlmAgent(name="greeter", model="gemini-2.0-flash", ...)
task_executor = LlmAgent(name="task_executor", model="gemini-2.0-flash", ...)

# Crea el agente padre y asigna los hijos a través de sub_agents
coordinator = LlmAgent(
    name="Coordinator",
    model="gemini-2.0-flash",
    description="I coordinate greetings and tasks.",
    sub_agents=[ # Asigna sub_agents aquí
        greeter,
        task_executor
    ]
)
```

## Próximos pasos

Ahora que tengo una comprensión básica de la librería ADK, procederé a la fase de análisis de requerimientos y diseño del sistema para el chatbot.

```