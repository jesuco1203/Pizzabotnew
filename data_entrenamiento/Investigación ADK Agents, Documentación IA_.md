# **Documentación Detallada de la Librería ADK Agents de Python para Inteligencia Artificial**

## **1\. Introducción y Visión General de ADK Agents**

El Agent Development Kit (ADK) de Google emerge como un toolkit robusto y flexible, diseñado para empoderar a los desarrolladores en la construcción, evaluación y despliegue de agentes de Inteligencia Artificial (IA) sofisticados. Su concepción se basa en la necesidad de ofrecer un control granular y una alta flexibilidad en el proceso de desarrollo agéntico.

### **1.1. Origen y Propósito**

ADK es una iniciativa de código abierto que adopta un enfoque "code-first", permitiendo a los desarrolladores definir la lógica, herramientas y orquestación de los agentes directamente en código Python.1 Aunque está optimizado para operar de manera sinérgica con los modelos Gemini y el ecosistema de Google, una de sus características fundamentales es su agnosticismo respecto al modelo de IA subyacente y a la plataforma de despliegue.1 Esto significa que, si bien se integra fluidamente con las tecnologías de Google, está construido para ser compatible con otros modelos de lenguaje y puede ser desplegado en una variedad de entornos, desde ejecuciones locales hasta infraestructuras personalizadas en la nube.

El propósito principal de ADK es simplificar la creación de arquitecturas agénticas, que pueden variar desde la automatización de tareas simples hasta la orquestación de flujos de trabajo complejos y sistemas multi-agente.1

### **1.2. Filosofía de Diseño**

La filosofía central que guía el diseño de ADK es la de asimilar el desarrollo de agentes de IA a las prácticas establecidas en el desarrollo de software tradicional.1 Este paradigma busca hacer el proceso más accesible, predecible y mantenible para los desarrolladores, aplicando principios de ingeniería de software como la modularidad, la testeabilidad y el versionado al ciclo de vida de los agentes. Al adoptar este enfoque, ADK no solo facilita la entrada de desarrolladores de software al campo de la IA agéntica, sino que también promueve la creación de sistemas de IA más robustos y escalables. Esta perspectiva es crucial, ya que tiende un puente entre dos dominios que históricamente han tenido ciclos de desarrollo y metodologías distintas, fomentando una mayor adopción y una innovación más rápida.

### **1.3. Características Clave**

ADK se distingue por un conjunto de características diseñadas para ofrecer potencia y flexibilidad:

* **Ecosistema Rico de Herramientas:** Los agentes pueden ser equipados con una diversa gama de capacidades mediante el uso de herramientas preconstruidas (como Google Search o ejecución de código), la creación de funciones personalizadas, la especificación de APIs a través de OpenAPI, o la integración con herramientas existentes y bibliotecas de terceros como LangChain o CrewAI. Incluso, un agente puede utilizar a otro agente como herramienta.1  
* **Desarrollo "Code-First":** La lógica del agente, sus herramientas y la orquestación de tareas se definen directamente en código Python. Esto proporciona máxima flexibilidad, facilita las pruebas unitarias y de integración, y permite un control de versiones riguroso, alineándose con las mejores prácticas del desarrollo de software.1  
* **Sistemas Modulares Multi-Agente:** ADK está diseñado para la construcción de aplicaciones escalables mediante la composición de múltiples agentes especializados en jerarquías flexibles. Esto permite abordar problemas complejos dividiéndolos en sub-tareas manejadas por agentes expertos, que luego colaboran para alcanzar un objetivo común.1

El agnosticismo inherente al diseño de ADK, tanto a nivel de modelo como de despliegue, no es meramente una característica técnica, sino una decisión estratégica. Al no atar a los desarrolladores a un único proveedor de modelos o plataforma de nube, Google fomenta una adopción más amplia y permite que ADK se posicione como un estándar de facto en la industria para el desarrollo de agentes, independientemente del stack tecnológico subyacente. Esto es particularmente relevante en un panorama de IA que evoluciona rápidamente, con nuevos modelos y plataformas emergiendo constantemente.

### **1.4. ADK Web: Interfaz de Usuario para el Desarrollo**

Complementando el enfoque "code-first", ADK incluye ADK Web, una interfaz de usuario (UI) de desarrollo integrada.3 Esta herramienta gráfica está diseñada para facilitar el desarrollo y la depuración de agentes, proporcionando un entorno visual para interactuar, probar, evaluar y mostrar los agentes construidos con ADK.1 ADK Web sirve como un puente entre el código y la visualización del comportamiento del agente, lo que resulta especialmente útil durante las fases de iteración y ajuste fino.

### **1.5. Versiones y Ecosistema del Kit de Desarrollo**

El Agent Development Kit ha alcanzado hitos importantes en su desarrollo, ofreciendo estabilidad y expandiendo su alcance. La versión de Python de ADK (google/adk-python) ha llegado a su versión 1.0.0, lo que significa que está lista para producción y ofrece una plataforma fiable para que los desarrolladores construyan y desplieguen sus agentes en entornos reales.2 La cadencia de lanzamiento para las versiones estables es semanal, instalables vía pip install google-adk.1

Paralelamente, se ha lanzado la versión inicial de Java ADK (v0.1.0), extendiendo las capacidades del kit al ecosistema Java y permitiendo a los desarrolladores de esta plataforma aprovechar su flexibilidad para el desarrollo de agentes.2 Esta expansión a Java subraya el compromiso de hacer de ADK una herramienta versátil y accesible a una comunidad de desarrolladores más amplia.

## **2\. Instalación y Configuración del Entorno**

Para comenzar a desarrollar con ADK Agents en Python, es necesario preparar adecuadamente el entorno de desarrollo. Esta sección detalla los prerrequisitos, los diferentes métodos de instalación de la librería y la configuración necesaria para proyectos, incluyendo la interfaz de desarrollo ADK Web.

### **2.1. Prerrequisitos Generales**

El principal prerrequisito para utilizar ADK Python es contar con una instalación de Python. La documentación oficial y los tutoriales sugieren el uso de Python 3.10 o superior, aunque algunas guías de inicio rápido mencionan compatibilidad con Python 3.9+.6 Adicionalmente, se requiere acceso a una terminal o línea de comandos para la instalación de paquetes y la ejecución de comandos de ADK.6

### **2.2. Configuración del Proyecto Google Cloud (Opcional pero Recomendado para Vertex AI)**

Aunque ADK es agnóstico al despliegue, su integración con Vertex AI de Google Cloud es una de sus fortalezas. Para aprovechar esta integración, especialmente para el despliegue y la gestión escalada de agentes, se recomienda configurar un proyecto de Google Cloud 6:

1. Iniciar sesión en la cuenta de Google Cloud o crear una nueva. Los nuevos clientes pueden obtener créditos gratuitos para evaluación.6  
2. Seleccionar o crear un proyecto en la consola de Google Cloud. Es aconsejable crear un proyecto nuevo si los recursos generados no se van a conservar a largo plazo.6  
3. Asegurar que la facturación esté habilitada para el proyecto.6  
4. Habilitar la API de Vertex AI para el proyecto.6

### **2.3. Configuración de Credenciales**

La autenticación es un paso crucial, especialmente al interactuar con servicios de Google Cloud.

* **Google Cloud CLI:** Se debe instalar e inicializar la Google Cloud CLI (gcloud) en la terminal local para gestionar la autenticación con Google Cloud.6  
* **IAM vs. Claves API:** Es importante notar que la API de Vertex AI Gemini utiliza Identity and Access Management (IAM) para gestionar el acceso, en lugar de claves API, que son comunes en servicios como Google AI Studio.6 Esto implica una gestión de permisos más granular y segura.

### **2.4. Entorno Virtual (Recomendado)**

Se recomienda encarecidamente crear y activar un entorno virtual antes de instalar ADK y sus dependencias. Esto aísla las dependencias del proyecto y evita conflictos con otros paquetes de Python instalados en el sistema.6

* Creación: python \-m venv.venv  
* Activación (ejemplos):  
  * macOS/Linux: source.venv/bin/activate  
  * Windows CMD: .venv\\Scripts\\activate.bat  
  * Windows PowerShell: .venv\\Scripts\\Activate.ps1

### **2.5. Métodos de Instalación de ADK Python**

ADK Python ofrece varias vías de instalación para adaptarse a diferentes necesidades de desarrollo:

* Versión Estable (Recomendada):  
  Se puede instalar la última versión estable de ADK desde PyPI usando pip 1:  
  pip install google-adk  
  Esta versión es la recomendada para la mayoría de los usuarios, ya que representa el lanzamiento oficial más reciente y probado, con una cadencia de actualización semanal.1  
* Versión de Desarrollo (Desde GitHub):  
  Para acceder a las últimas correcciones y características que aún no se han incluido en un lanzamiento oficial de PyPI, se puede instalar directamente desde la rama principal del repositorio de GitHub 1:  
  pip install git+https://github.com/google/adk-python.git@main  
  Esta versión puede contener cambios experimentales o errores no presentes en la versión estable, por lo que se utiliza principalmente para pruebas o para acceder a correcciones críticas antes de su lanzamiento oficial.1  
* Uso de uv (Promovido en Tutoriales):  
  Algunos tutoriales y guías de contribución promueven el uso de uv, un gestor de paquetes de Python moderno, para una instalación más rápida y una mejor resolución de dependencias.1  
  1. Instalar uv: pip install uv  
  2. Inicializar el proyecto: uv init  
  3. Añadir dependencias: uv add google-adk python-dotenv pydantic (y otras según sea necesario)

La disponibilidad de múltiples métodos de instalación refleja una flexibilidad que atiende a diversos perfiles de desarrolladores. Mientras que pip con la versión estable es adecuado para usuarios finales que buscan fiabilidad, la instalación desde git sirve a contribuidores o usuarios avanzados que requieren las últimas funcionalidades. La promoción de uv 7 indica una alineación con herramientas modernas del ecosistema Python, buscando mejorar la experiencia del desarrollador y atraer a una comunidad técnicamente actualizada. Este enfoque en herramientas contemporáneas sugiere que el equipo de ADK está atento a las tendencias que pueden optimizar los flujos de trabajo de desarrollo.

### **2.6. Estructura del Proyecto ADK**

Una estructura de proyecto organizada es fundamental, especialmente para aplicaciones multi-agente. Un ejemplo de estructura recomendada, como la utilizada en tutoriales para un clon de ChatGPT, es la siguiente 7:

google-adk-tutorial/  
├── app/                          \# Directorio de la aplicación  
│   ├── main.py                   \# Punto de entrada de la aplicación  
│   ├── requirements.txt          \# Dependencias específicas de la app  
│   └── chatgpt\_agentic\_clone/    \# Paquete del agente (ejemplo)  
│       ├── \_\_init\_\_.py           \# Inicialización del paquete, ej: from. import agent  
│       └── agent.py              \# Definiciones de agentes y herramientas  
├── pyproject.toml                \# Configuración del proyecto (para uv o flit)  
└──.env                          \# Archivo para variables de entorno (ej. claves API)

El archivo \_\_init\_\_.py dentro del paquete del agente (ej. chatgpt\_agentic\_clone/) juega un papel importante. Debe contener la importación de los módulos del agente (ej. from. import agent) para que los activos del agente se carguen y ejecuten correctamente al depurar a través de la interfaz de usuario de ADK Web.7 Una estructura de proyecto bien definida como esta no solo es una buena práctica, sino que es esencial para la mantenibilidad, la reutilización de componentes y la escalabilidad, particularmente en sistemas multi-agente complejos. El requisito de un \_\_init\_\_.py configurado adecuadamente para la funcionalidad completa con ADK Web es un detalle técnico que subraya la interconexión de los componentes de ADK.

### **2.7. Instalación y Configuración de ADK Web**

ADK Web es la interfaz de usuario de desarrollo integrada. Para usuarios que han instalado google-adk vía pip, el comando más directo para lanzar la UI es adk web.6 Este comando generalmente gestiona el inicio del servidor API necesario o se puede complementar con adk api\_server si se requiere una configuración específica.

Para aquellos que deseen desarrollar o contribuir al propio adk-web (el cual es un proyecto separado en Angular, TypeScript, HTML y SCSS 3), o si se necesita una configuración manual más detallada, los pasos son los siguientes:

* **Prerrequisitos para ADK Web (desarrollo del UI):**  
  * Angular CLI 3  
  * Node.js 3  
  * npm (Node Package Manager) 3  
  * google-adk (Python) instalado y accesible en el path o entorno virtual.3  
  * Opcionalmente google-adk (Java) si se trabaja con agentes Java.3  
* **Pasos para ejecutar ADK Web localmente (desde el repositorio adk-web):**  
  1. Clonar el repositorio google/adk-web.  
  2. Instalar dependencias del frontend: sudo npm install (ejecutar en el directorio raíz del repositorio adk-web).3  
  3. Ejecutar la UI de ADK Web (servidor de desarrollo de Angular): npm run serve \--backend=http://localhost:8000.3 Esto sirve el frontend, típicamente en http://localhost:4200.  
  4. En una terminal separada, ejecutar el servidor API de ADK (backend Python): adk api\_server \--allow\_origins=http://localhost:4200 \--host=0.0.0.0 \--port=8000 (el puerto debe coincidir con el especificado en \--backend).3  
  5. Acceder a la UI en el navegador, usualmente en http://localhost:4200.3

Es fundamental comprender que una instalación básica de google-adk podría no ser suficiente para habilitar todas las funcionalidades avanzadas sin la configuración de entorno adecuada. Por ejemplo, la distinción en la configuración de credenciales (IAM para Vertex AI versus claves API para otros servicios como Google AI Studio 6) y los prerrequisitos específicos de Node.js/Angular para el desarrollo de ADK Web 3 son cruciales. Los desarrolladores deben prestar atención a los requisitos particulares de los componentes que planean utilizar. Esta complejidad inherente a un framework versátil como ADK, que interactúa con múltiples servicios y herramientas, puede presentar una curva de aprendizaje inicial si no se siguen guías detalladas. Una documentación clara y modular, que especifique los requisitos por funcionalidad, es esencial para una experiencia de desarrollo fluida.

## **3\. Conceptos Fundamentales de ADK Agents**

Para utilizar eficazmente el Agent Development Kit, es esencial comprender sus conceptos fundamentales. Estos conceptos definen cómo se estructuran los agentes, cómo operan y cómo se pueden combinar para crear aplicaciones de IA complejas.

### **3.1. El Agente: Unidad de Ejecución Autónoma**

En el contexto de ADK, un **Agente** se define como una unidad de ejecución autocontenida, diseñada para actuar de manera autónoma con el fin de alcanzar objetivos específicos.8 Esta autonomía implica que el agente puede tomar decisiones y realizar acciones sin intervención humana directa para cada paso. Un agente tiene la capacidad de realizar tareas, interactuar con los usuarios (recibiendo entradas y generando respuestas), utilizar herramientas externas para ampliar sus capacidades (como buscar información o ejecutar código), y coordinarse con otros agentes dentro de un sistema más grande.8 La "autonomía" y la "orientación a objetivos" son las características distintivas que elevan a un agente por encima de un simple script o una función programada.

### **3.2. La Clase BaseAgent: El Fundamento de Todos los Agentes**

La piedra angular de todos los agentes en ADK es la clase BaseAgent.8 Esta clase sirve como el plano fundamental o el prototipo del cual derivan todos los tipos de agentes.8 BaseAgent encapsula la funcionalidad común y los contratos que todos los agentes deben seguir. Esto es especialmente relevante en el contexto de sistemas multi-agente, ya que contiene la lógica para establecer y gestionar las relaciones padre-hijo entre agentes.9 Para crear agentes funcionales y especializados, los desarrolladores típicamente extienden BaseAgent de una de las tres maneras principales, lo que da lugar a las categorías de agentes que se describirán a continuación.8 Comprender BaseAgent es crucial porque define la interfaz y el comportamiento esperado que permite al Runner (el motor de ejecución de ADK) gestionar el ciclo de vida de los agentes de manera uniforme.

### **3.3. Categorías Principales de Agentes**

ADK proporciona distintas categorías de agentes, cada una diseñada para satisfacer diferentes necesidades, desde el razonamiento inteligente hasta el control estructurado de procesos.

#### **3.3.1. Agentes LLM (LlmAgent, Agent): Agentes Impulsados por Modelos de Lenguaje**

Los Agentes LLM, representados por las clases LlmAgent o, a menudo, simplemente Agent (que en muchos contextos es un alias o una implementación directa de un agente basado en LLM 1), utilizan Modelos de Lenguaje Grandes (LLMs) como su motor central de razonamiento.8 Estos agentes son capaces de:

* Comprender el lenguaje natural de las entradas del usuario.  
* Razonar sobre la información disponible y el estado actual.  
* Planificar secuencias de acciones.  
* Generar respuestas coherentes y contextualmente relevantes.  
* Decidir dinámicamente cómo proceder, incluyendo la selección y el uso de herramientas disponibles.

Son ideales para tareas que requieren flexibilidad, manejo de la ambigüedad y están intrínsecamente centradas en el lenguaje.8 La configuración de un LlmAgent típicamente implica especificar un name (identificador único), model (que puede ser una cadena de texto para un modelo Gemini, como "gemini-2.0-flash", o un objeto LiteLlm para interactuar con otros modelos como los de OpenAI o Anthropic), una instruction (el prompt del sistema que guía el comportamiento del LLM), una description (un resumen conciso de su propósito, crucial para la delegación en sistemas multi-agente), y una lista de tools que el agente puede utilizar.1 La calidad y precisión de la instruction y la description son primordiales para el correcto funcionamiento del agente y para su capacidad de ser orquestado eficazmente.

#### **3.3.2. Agentes de Flujo de Trabajo (WorkflowAgent): Controlando la Ejecución**

Los Agentes de Flujo de Trabajo (WorkflowAgent) son agentes especializados que no realizan tareas por sí mismos, sino que controlan el flujo de ejecución de otros agentes (sus sub-agentes) siguiendo patrones predefinidos y determinísticos.2 A diferencia de los LlmAgent, no utilizan un LLM para decidir el flujo de control en sí, lo que los hace perfectos para procesos estructurados que requieren una ejecución predecible y fiable.8 Estos agentes introducen patrones de ingeniería de software tradicionales en el desarrollo de agentes, permitiendo construir flujos complejos y robustos de manera estructurada.

ADK define varios tipos de WorkflowAgent:

* **SequentialAgent**: Ejecuta una lista de sub-agentes en un orden estrictamente secuencial, uno después del otro.8  
* **ParallelAgent**: Ejecuta un conjunto de sub-agentes de manera concurrente.8 Esto es útil cuando las tareas asignadas a los sub-agentes son independientes entre sí o cuando se necesita agregar resultados de múltiples fuentes simultáneamente.13  
* **LoopAgent**: Ejecuta una secuencia de sub-agentes repetidamente.8 El bucle puede continuar hasta que se cumpla una condición de salida específica (a menudo evaluada por un sub-agente dentro del bucle o por una lógica de callback) o hasta que se alcance un número máximo de iteraciones predefinido.14

#### **3.3.3. Agentes Personalizados (Extendiendo BaseAgent directamente)**

Para situaciones donde los patrones de los LlmAgent o WorkflowAgent no son suficientes, ADK permite la creación de Agentes Personalizados.8 Esto se logra heredando directamente de la clase BaseAgent e implementando la lógica de control de flujo principal dentro del método asíncrono \_run\_async\_impl (en Python) o runAsyncImpl (en Java).15 Este enfoque otorga al desarrollador un control total sobre cómo el agente orquesta las llamadas a otros agentes (sub-agentes), gestiona el estado de la sesión y maneja los eventos del sistema.15

Los agentes personalizados son necesarios cuando se requiere:

* Lógica condicional compleja para la ejecución de sub-agentes.  
* Gestión intrincada del estado que va más allá del simple paso secuencial.  
* Integraciones directas con APIs externas, bases de datos o bibliotecas personalizadas dentro de la lógica de orquestación.  
* Selección dinámica de sub-agentes basada en la evaluación en tiempo de ejecución de la situación o la entrada.  
* Patrones de flujo de trabajo únicos que no se ajustan a las estructuras secuenciales, paralelas o de bucle estándar.15 Esta es la opción más potente y flexible para la orquestación, aunque también es la que requiere una mayor cantidad de código personalizado.

El diseño de ADK, al ofrecer LlmAgent para una flexibilidad basada en IA, WorkflowAgent para una estructura determinista, y CustomAgent para un control total, reconoce implícitamente que no todas las partes de una aplicación agéntica deben ser impulsadas exclusivamente por la IA. Este equilibrio permite a los desarrolladores combinar la toma de decisiones dinámica de los LLMs con la fiabilidad de los flujos de trabajo codificados y la personalización profunda. Este enfoque híbrido es fundamental para construir agentes que sean robustos y mantenibles en entornos de producción, ya que permite confinar la no-determinación inherente de los LLMs a partes específicas del sistema, mientras se utilizan flujos de trabajo deterministas para la orquestación de alto nivel o tareas críticas, mejorando así la previsibilidad y la capacidad de depuración.

Además, el hecho de que todos los tipos de agentes deriven de BaseAgent 8 y que esta clase defina la relación padre-hijo 9 es significativo. BaseAgent no es solo una clase base para la reutilización de código; establece una interfaz o contrato común que todos los agentes deben cumplir. Esta estandarización es lo que permite que diferentes tipos de agentes (LLM, Workflow, Custom) se integren sin problemas en sistemas multi-agente jerárquicos y sean gestionados de manera uniforme por componentes como el Runner. Esta componibilidad es esencial para la escalabilidad del framework.

### **3.4. El Runner: Orquestación de la Ejecución del Agente**

El Runner es un componente central en ADK, actuando como el motor de ejecución que orquesta el ciclo de vida completo de un agente.7 Sus responsabilidades incluyen:

* Gestionar las sesiones de conversación.  
* Procesar las entradas del usuario.  
* Invocar la lógica del agente.  
* Coordinar las llamadas a los LLMs y a las herramientas.  
* Interactuar con los servicios configurados, como el SessionService (para el estado de la conversación), ArtifactService (para datos binarios) y MemoryService (para memoria a largo plazo).11

Se inicializa con el agente raíz que se va a ejecutar, un app\_name (un identificador para la aplicación), y una instancia de SessionService.11 El método principal para interactuar con el agente a través del Runner es run\_async(). Este método toma el session\_id, user\_id y el nuevo mensaje del usuario, y devuelve un iterador asíncrono que produce objetos Event.7 Estos eventos representan cada paso en la ejecución del agente, proporcionando una traza detallada de la interacción. El Runner es una abstracción clave que desacopla la lógica interna del agente de las complejidades de su ejecución y la gestión de su estado, permitiendo que los agentes se escriban de forma más limpia y modular.

### **3.5. Tabla Comparativa de Tipos de Agentes**

La siguiente tabla resume las características distintivas de las principales categorías de agentes en ADK, facilitando la elección del tipo de agente más adecuado para una tarea específica.

| Característica | LlmAgent (Agent) | WorkflowAgent (Sequential, Parallel, Loop) | CustomAgent (subclase de BaseAgent) |
| :---- | :---- | :---- | :---- |
| **Función Primaria** | Razonamiento, Generación, Uso de Herramientas | Control del Flujo de Ejecución de Agentes | Implementación de Lógica/Integraciones Únicas |
| **Motor Central** | Modelo de Lenguaje Grande (LLM) | Lógica Predefinida (Secuencia, Paralelo, Bucle) | Código Personalizado |
| **Determinismo** | No determinístico (Flexible) | Determinístico (Predictable) | Puede ser ambos, según implementación |
| **Uso Principal** | Tareas de lenguaje, Decisiones dinámicas | Procesos estructurados, Orquestación | Requisitos a medida, Flujos específicos |
| **Referencia** | 8 | 8 | 8 |

## **4\. Sistemas Multi-Agente (MAS)**

A medida que la complejidad de las tareas de IA aumenta, la necesidad de sistemas más sofisticados y modulares se vuelve imperativa. Los Sistemas Multi-Agente (MAS) en ADK ofrecen un paradigma para construir aplicaciones agénticas avanzadas mediante la composición y coordinación de múltiples agentes especializados.

### **4.1. ¿Por qué Sistemas Multi-Agente?**

Cuando las aplicaciones agénticas crecen en alcance y complejidad, intentar encapsular toda la funcionalidad dentro de un único agente monolítico presenta desafíos significativos en términos de desarrollo, mantenimiento y razonamiento sobre el comportamiento del sistema.9 Los MAS abordan estos desafíos al permitir la construcción de aplicaciones modulares y escalables. Esto se logra componiendo múltiples agentes distintos, cada uno especializado en un subconjunto de tareas o dominios de conocimiento.2

Los beneficios clave de adoptar una arquitectura MAS incluyen 7:

* **Modularidad Mejorada:** Cada agente es una unidad independiente con responsabilidades bien definidas.  
* **Especialización:** Los agentes pueden ser optimizados para tareas específicas, mejorando el rendimiento y la precisión.  
* **Reutilización:** Los agentes especializados pueden ser reutilizados en diferentes aplicaciones o flujos de trabajo.  
* **Mantenibilidad:** Los cambios o actualizaciones en un agente tienen un impacto limitado en el resto del sistema.  
* **Flujos de Control Estructurados:** Permite la definición de interacciones complejas y flujos de trabajo utilizando agentes dedicados a la orquestación.  
* **Desarrollo Paralelo:** Diferentes equipos pueden trabajar en agentes especializados de forma independiente y luego integrarlos.

Este enfoque de "divide y vencerás" es una respuesta directa a los desafíos de complejidad inherentes al software avanzado, aplicado al dominio de los agentes de IA.

### **4.2. Arquitectura y Estructura Jerárquica**

La piedra angular para estructurar los MAS en ADK es la **relación padre-hijo**, que se define dentro de la clase BaseAgent.9

* **Establecimiento de la Jerarquía:** Se crea una estructura de árbol (o jerarquía) al inicializar un agente padre. Esto se hace pasando una lista de instancias de otros agentes (los futuros hijos) al argumento sub\_agents del constructor del agente padre.1  
  Python  
  \# Ejemplo Conceptual de Definición de Jerarquía en Python  
  from google.adk.agents import LlmAgent, BaseAgent

  \# Definir agentes individuales  
  greeter\_agent \= LlmAgent(name="Greeter", model="gemini-2.0-flash", description="Saluda al usuario.")  
  task\_doer\_agent \= BaseAgent(name="TaskExecutor", description="Ejecuta una tarea específica.") \# Agente personalizado no-LLM

  \# Crear agente padre y asignar hijos vía sub\_agents  
  coordinator\_agent \= LlmAgent(  
      name="Coordinator",  
      model="gemini-2.0-flash",  
      description="Soy un coordinador que gestiona saludos y tareas.",  
      instruction="Coordina con el agente de saludo para saludar y con el ejecutor de tareas para las tareas.",  
      sub\_agents=\[greeter\_agent, task\_doer\_agent\] \# Asignar sub-agentes aquí  
  )

  \# El framework establece automáticamente:  
  \# assert greeter\_agent.parent\_agent \== coordinator\_agent  
  \# assert task\_doer\_agent.parent\_agent \== coordinator\_agent

  Este ejemplo, derivado de 1 y 9, ilustra cómo coordinator\_agent se convierte en el padre de greeter\_agent y task\_doer\_agent.  
* **Asignación Automática de Padre:** ADK establece automáticamente el atributo parent\_agent en cada agente hijo durante este proceso de inicialización, vinculándolo a su agente padre.9  
* **Regla del Padre Único:** Es fundamental destacar que una instancia de agente solo puede ser asignada como sub-agente a un único padre. Cualquier intento de asignar un segundo padre a un agente ya existente en una jerarquía resultará en un error (ValueError).9 Esta regla asegura una jerarquía clara y sin ambigüedades, lo cual es vital para el enrutamiento y la gestión del control.  
* **Importancia de la Jerarquía:** La estructura jerárquica no es meramente organizativa; tiene implicaciones funcionales directas:  
  * **Alcance para WorkflowAgent:** Define el conjunto de sub-agentes sobre los cuales un WorkflowAgent (como SequentialAgent o ParallelAgent) puede operar y orquestar.9  
  * **Objetivos para Delegación Impulsada por LLM:** Influye significativamente en los posibles agentes a los que un LlmAgent padre puede delegar tareas. Típicamente, un LLM considerará las description de sus sub\_agents directos al tomar decisiones de delegación.9  
  * **Navegación Jerárquica:** La jerarquía permite la navegación programática a través de la estructura de agentes, utilizando atributos como agent.parent\_agent para acceder al padre o métodos como agent.find\_agent(name) para localizar descendientes.9

La jerarquía de sub\_agents actúa como un mecanismo de "delimitación cognitiva" o "scoping". En lugar de que un LLM en un agente padre tenga que considerar todos los posibles agentes en un sistema potencialmente grande y plano, solo necesita razonar sobre sus hijos directos. Esto puede mejorar la eficiencia y la precisión de la delegación en sistemas grandes, reduciendo la carga cognitiva del LLM en cada paso de decisión y haciendo que las elecciones de enrutamiento sean más manejables.

### **4.3. Comunicación y Delegación entre Agentes**

ADK proporciona múltiples mecanismos para que los agentes interactúen, colaboren y deleguen tareas dentro de un MAS:

* **Transferencia de Control Impulsada por LLM (Delegación Dinámica):** Un LlmAgent padre puede decidir dinámicamente transferir el control (o delegar una tarea) a uno de sus sub-agentes.2 Esta decisión se basa en la instruction del agente padre, la consulta actual del usuario y, crucialmente, las description proporcionadas para cada uno de los sub-agentes.11 El LLM del padre evalúa qué sub-agente es el más adecuado para manejar la solicitud.  
* **Agentes como Herramientas (AgentTool):** Un agente puede ser explícitamente invocado como una herramienta por otro agente.2 La clase AgentTool facilita esta forma de delegación, donde la capacidad de un sub-agente se presenta como una función que el agente padre puede llamar.  
* **Flujo de Trabajo Orquestado por WorkflowAgent:** Los WorkflowAgent (Sequential, Parallel, Loop) dirigen la ejecución de sus sub-agentes de una manera predefinida y determinista, basándose en su configuración en lugar de en decisiones de un LLM para el flujo.8  
* **Contexto Compartido en la Delegación:** Cuando un agente raíz delega una tarea a un agente especialista (un sub-agente), el historial de la conversación y la información contextual relevante (almacenada en session.state) se transfieren automáticamente.7 Esto asegura que el sub-agente tenga el contexto necesario para realizar su tarea de manera coherente con la interacción general.

Un mismo LlmAgent puede, dependiendo de su instruction y la consulta, actuar como un "trabajador" (ejecutando una herramienta directamente) o como un "orquestador" (delegando a un sub-agente). Esta dualidad es flexible pero exige un diseño cuidadoso de la instruction del agente, que debe guiar no solo *qué* hacer, sino también *cuándo* hacerlo por sí mismo, *cuándo* delegar, y *a quién* delegar.

### **4.4. Orquestación de Agentes Múltiples**

La orquestación es el proceso de coordinar el trabajo de múltiples agentes para lograr un objetivo común. En ADK MAS:

* **Agente Raíz como Orquestador:** Comúnmente, el agente raíz de la jerarquía actúa como el orquestador principal.1 Recibe la solicitud inicial del usuario, analiza su intención y decide a qué agente o secuencia de agentes especializados delegar las subtareas.14  
* **Equipos de Agentes:** Este patrón de orquestación a menudo implementa el concepto de "equipos de agentes", donde cada agente tiene un rol definido y colabora bajo la dirección del orquestador.7  
* **Patrones de Delegación Avanzados:** ADK soporta diversos patrones de delegación, incluyendo:  
  * **Jerárquico:** El flujo de control sigue la estructura de árbol padre-hijo.  
  * **Entre Pares (Peer-to-Peer):** Aunque menos directo en la estructura sub\_agents, se puede modelar con agentes personalizados o mediante un orquestador que facilite la comunicación.  
  * **Enrutamiento Complejo:** Se pueden diseñar agentes enrutadores especializados cuya única función es dirigir las solicitudes al agente adecuado basándose en reglas complejas o lógica de negocio.7

### **4.5. Protocolo Agent-to-Agent (A2A)**

Mientras que la jerarquía de sub\_agents y AgentTool facilitan la colaboración dentro de una misma aplicación ADK, el Protocolo Agent-to-Agent (A2A) está diseñado para una interoperabilidad más amplia.

* **Propósito:** A2A es un protocolo abierto que busca permitir la comunicación y colaboración efectiva entre aplicaciones agénticas "opacas".12 Esto significa que los agentes pueden interactuar incluso si están construidos con diferentes frameworks (no solo ADK), por distintas organizaciones, y se ejecutan en servidores separados.12  
* **Lenguaje Común:** Su objetivo es proporcionar un "lenguaje común" para que estos agentes diversos puedan colaborar de forma segura, sin necesidad de revelar detalles de su implementación interna, como su estado, memoria o las herramientas específicas que utilizan.12 Esta "opacidad" es una característica importante para la seguridad y la protección de la propiedad intelectual.  
* **Capacidades Clave de A2A:**  
  * **Descubrimiento de Capacidades:** Los agentes pueden descubrir y comprender las funcionalidades de otros agentes a través de "Agent Cards" (tarjetas de agente) que publicitan sus capacidades.12  
  * **Negociación de Interacción:** Pueden acordar cómo interactuar (ej. texto, formularios, multimedia).12  
  * **Colaboración Segura:** Permite a los agentes trabajar juntos de forma segura en tareas que pueden ser de larga duración.12  
* **Tecnología Subyacente:** A2A utiliza JSON-RPC 2.0 sobre HTTP(S) como mecanismo de transporte estándar.12  
* **Integración con ADK:** ADK está diseñado para integrarse con A2A. Por ejemplo, el Codelab de InstaVibe demuestra cómo desplegar agentes individuales construidos con ADK como microservicios habilitados para A2A, permitiendo que un agente orquestador se comunique con ellos.14  
* **Evolución del Protocolo:** La especificación del protocolo A2A está en evolución. La versión 0.2, por ejemplo, introdujo mejoras como el soporte para interacciones sin estado (más ligeras y eficientes cuando no se necesita gestión de sesión) y esquemas de autenticación estandarizados basados en un formato similar a OpenAPI, mejorando la seguridad y la fiabilidad.4  
* **SDK de Python para A2A:** Existe un SDK de Python específico para facilitar la construcción de interacciones A2A: pip install a2a-sdk.12

La existencia de A2A sugiere una visión que va más allá de los sistemas multi-agente contenidos dentro de una única aplicación ADK. Habilita la creación de "sociedades de agentes" verdaderamente distribuidas, donde la inteligencia y las capacidades pueden residir en nodos independientes y heterogéneos. Esto podría fomentar ecosistemas donde las empresas exponen agentes especializados como servicios (AaaS \- Agent as a Service) consumibles a través de A2A, transformando la manera en que se construyen y componen las aplicaciones de IA a gran escala.

## **5\. Herramientas (Tools) en ADK**

Las herramientas son un componente esencial en el Agent Development Kit, ya que dotan a los agentes de la capacidad de interactuar con el mundo exterior, realizar acciones concretas y acceder a información que va más allá del conocimiento inherente del modelo de lenguaje.

### **5.1. Concepto y Propósito de las Herramientas**

En ADK, las herramientas son fundamentalmente funciones de Python (o abstracciones sobre ellas) que extienden las capacidades de un agente más allá de la simple generación de texto o el razonamiento basado en su entrenamiento.7 Permiten a los agentes interactuar con sistemas externos, APIs, bases de datos, o ejecutar lógica de negocio específica.7 Son componentes de código modulares, cada uno diseñado para realizar una tarea predefinida y específica.17

El proceso de uso de herramientas implica una colaboración entre el agente (específicamente su LLM) y la herramienta misma:

1. El LLM del agente analiza la solicitud del usuario y su contexto actual.  
2. Basándose en este análisis y en la descripción de las herramientas disponibles, el LLM decide si una herramienta es necesaria, cuál usar y con qué argumentos invocarla.  
3. El framework ADK entonces ejecuta la función de Python correspondiente a la herramienta seleccionada.  
4. El resultado de la ejecución de la herramienta se devuelve al LLM.  
5. El LLM utiliza este resultado para continuar su razonamiento y generar una respuesta final para el usuario o decidir los siguientes pasos.

Las herramientas son cruciales porque 7:

* Permiten a los agentes acceder a **datos en tiempo real y del mundo real** (ej. el clima actual, precios de acciones, noticias recientes).  
* Facilitan la ejecución de **tareas especializadas** que los LLMs no pueden realizar directamente (ej. cálculos complejos, manipulación de archivos, envío de correos electrónicos).  
* Proporcionan **fundamentación (grounding)** a las respuestas del agente, conectándolas a fuentes de datos verificables y reduciendo la probabilidad de "alucinaciones".  
* Extienden las capacidades del agente **sin necesidad de reentrenar** el modelo de lenguaje subyacente.

### **5.2. Definición y Uso de Herramientas de Función (Python Functions)**

La forma más directa de crear una herramienta en ADK es definir una función estándar de Python. Para que estas funciones sean utilizables eficazmente por un LlmAgent, ciertos aspectos de su definición son críticos 10:

* **Nombre de la Función:** Debe ser descriptivo y, preferiblemente, seguir una convención verbo-sustantivo (ej. get\_weather, calculate\_loan\_payment). El LLM utiliza este nombre como identificador primario.17  
* **Parámetros (Argumentos):**  
  * Los nombres de los parámetros deben ser claros y autoexplicativos (ej. city en lugar de c).  
  * Es **esencial** proporcionar anotaciones de tipo (type hints) para todos los parámetros (ej. city: str, amount: float, items: list\[str\]). ADK utiliza estas anotaciones para generar el esquema de la función que se presenta al LLM, permitiéndole construir correctamente la llamada.17  
  * Los tipos de los parámetros deben ser serializables en JSON (tipos estándar de Python como str, int, float, bool, list, dict, y sus combinaciones son generalmente seguros).17  
  * No se deben establecer valores por defecto para los parámetros en la firma de la función, ya que los modelos subyacentes no los soportan de manera fiable.17  
* **Tipo de Retorno:** La función **debe** retornar un diccionario (dict) en Python.17 Si la función devuelve un tipo de dato diferente (ej. un string o un número), ADK lo envolverá automáticamente en un diccionario con una clave 'result' (ej. {'result': \<valor\_original\>}). Es una buena práctica diseñar las claves y valores del diccionario de retorno para que sean descriptivos y fácilmente comprensibles por el LLM. Se recomienda encarecidamente incluir una clave status (ej. 'success', 'error') para indicar claramente el resultado de la ejecución de la herramienta, junto con datos relevantes o mensajes de error.17  
* **Docstring (Cadena de Documentación):** Este es, quizás, el elemento más crítico para la correcta utilización de la herramienta por parte del LLM.10 El docstring es la principal fuente de información descriptiva que el LLM utiliza para:  
  * Entender qué hace la herramienta y cuál es su propósito.  
  * Determinar cuándo es apropiado usar la herramienta.  
  * Comprender qué significa cada parámetro y qué tipo de valor espera.  
  * Interpretar la estructura y el significado del diccionario de retorno, especialmente los diferentes valores de status. No se debe describir el parámetro ToolContext (si se usa) dentro del docstring, ya que ADK lo inyecta automáticamente.17

Una vez definida, la función de herramienta se añade a la lista tools al instanciar un Agent.1

**Ejemplo:**

Python

def get\_current\_weather(location: str, unit: str \= "celsius") \-\> dict:  
    """  
    Obtiene el informe meteorológico actual para una ubicación específica.

    Args:  
        location (str): La ciudad y el estado, por ejemplo, "San Francisco, CA".  
        unit (str): La unidad de temperatura, ya sea "celsius" o "fahrenheit".

    Returns:  
        dict: Un diccionario que contiene la temperatura y la descripción del clima.  
              Ejemplo: {"status": "success", "data": {"temperature": "22", "condition": "soleado"}}  
              o {"status": "error", "message": "Ubicación no encontrada."}  
    """  
    \# Lógica para obtener el clima...  
    if location \== "San Francisco, CA":  
        temp \= "15" if unit \== "celsius" else "59"  
        return {"status": "success", "data": {"temperature": temp, "condition": "parcialmente nublado"}}  
    else:  
        return {"status": "error", "message": "Ubicación no encontrada."}

\# Uso al definir un agente:  
\# from google.adk.agents import Agent  
\# weather\_agent \= Agent(  
\#     name="weather\_assistant",  
\#     model="gemini-2.0-flash",  
\#     instruction="Eres un asistente meteorológico.",  
\#     tools=\[get\_current\_weather\]  
\# )

En este ejemplo, derivado de los principios en 10 y 17, el docstring claro y las anotaciones de tipo son cruciales. La calidad de este docstring no es solo una buena práctica de codificación, sino un requisito funcional. El docstring se convierte en una forma de "especificación de API" para el LLM, y su efectividad para guiar el razonamiento del LLM es un nuevo tipo de habilidad que los desarrolladores deben cultivar.

### **5.3. Herramientas de Larga Duración (Long Running Function Tools)**

ADK contempla el soporte para herramientas que realizan operaciones que pueden tardar un tiempo considerable en completarse o que son intrínsecamente asíncronas.17 El LongRunningTool existente en versiones anteriores permitía que una herramienta devolviera su respuesta final después de un período prolongado, pero no ofrecía un mecanismo para transmitir el progreso intermedio o resultados parciales al usuario o al modelo durante la ejecución.18

Existe un reconocimiento de la necesidad y planes activos para mejorar este soporte, específicamente para permitir que las herramientas de larga duración devuelvan un AsyncGenerator. Esto permitiría a la herramienta transmitir ("stream") actualizaciones de progreso o resultados intermedios de vuelta al modelo o al usuario en tiempo real, de manera similar a como ya se soporta en los agentes de bidi-streaming para interacciones en vivo.18 Esta capacidad es crucial para la experiencia del usuario en tareas prolongadas y para permitir que el modelo reaccione a información intermedia.

### **5.4. Agentes como Herramientas**

Un concepto poderoso dentro de ADK es la capacidad de un agente de utilizar otro agente como si fuera una herramienta.2 Esto se facilita a menudo mediante la clase AgentTool.7 Este patrón permite una delegación explícita de subtareas complejas a agentes especializados, fomentando una arquitectura modular y jerárquica. Un agente "manager" puede invocar a un agente "especialista" (configurado como una herramienta) para realizar una función particular, de forma análoga a cómo un programa llama a una subrutina o a un microservicio. Esta capacidad para que los agentes actúen como herramientas para otros agentes representa un espectro de complejidad, moviéndose de "herramienta como función simple" a "herramienta como servicio agéntico complejo".

### **5.5. Herramientas Preconstruidas (Built-in Tools)**

ADK proporciona un conjunto de herramientas listas para usar, diseñadas para tareas comunes, lo que acelera el desarrollo al evitar que los desarrolladores tengan que implementarlas desde cero.2 Algunos ejemplos notables incluyen:

* **Google Search (google\_search):** Permite al agente realizar búsquedas en la web.1  
* **Code Execution:** Permite al agente ejecutar código de forma segura. El ejecutor de código preconstruido puede, por ejemplo, interactuar con la Vertex Code Interpreter Extension para tareas de análisis de datos.2  
* **Retrieval-Augmented Generation (RAG):** Herramientas para conectar al agente con bases de conocimiento para mejorar la relevancia y factualidad de sus respuestas.2

### **5.6. Integración con Herramientas de Terceros**

Una fortaleza clave de ADK es su capacidad para integrarse con el vasto ecosistema de herramientas y bibliotecas existentes en la comunidad de IA.2 Esto significa que los desarrolladores no están limitados a las herramientas nativas de ADK. Se pueden integrar:

* Herramientas de LangChain.  
* Herramientas de CrewAI.  
* Recuperadores de LlamaIndex (configurados como herramientas personalizadas).20

Esta interoperabilidad es vital, ya que permite a los desarrolladores aprovechar funcionalidades maduras y especializadas de otros frameworks, promoviendo la reutilización y la flexibilidad.

### **5.7. Herramientas de Google Cloud**

ADK ofrece integraciones profundas con el ecosistema de Google Cloud Platform (GCP), permitiendo a los agentes interactuar de forma segura y eficiente con una amplia gama de servicios empresariales y de datos.17

* **Apigee API Hub Tools (ApiHubToolset):** Permite convertir automáticamente APIs documentadas (con especificaciones OpenAPI) en Apigee API Hub en herramientas utilizables por los agentes ADK. Esto incluye la configuración de la autenticación para conexiones seguras.17  
* **Application Integration Tools (ApplicationIntegrationToolset):** Facilita la interacción segura de los agentes con aplicaciones empresariales. Esto se logra a través de:  
  * **Integration Connectors:** Más de 100 conectores preconstruidos para sistemas como Salesforce, ServiceNow, JIRA, SAP, tanto para aplicaciones SaaS como on-premise.17  
  * **Application Integration Workflows:** Permite utilizar automatizaciones de procesos existentes construidas con Application Integration como flujos de trabajo agénticos.17  
* **Toolbox Tools for Databases:** ADK se integra con el([https://github.com/googleapis/genai-toolbox](https://github.com/googleapis/genai-toolbox)), un servidor MCP (Model Context Protocol) de código abierto diseñado para desarrollar herramientas de IA generativa de nivel empresarial para bases de datos. Este toolbox simplifica complejidades como la gestión de pools de conexiones y la autenticación. ADK utiliza el paquete Python toolbox-core para cargar estas herramientas una vez que el servidor Toolbox está desplegado y configurado por el usuario.17

### **5.8. Herramientas MCP (Model Context Protocol)**

El Model Context Protocol (MCP) es un estándar abierto crucial para la interoperabilidad, diseñado para estandarizar cómo los LLMs (como Gemini o Claude) se comunican con aplicaciones externas, fuentes de datos y herramientas.14 MCP opera bajo una arquitectura cliente-servidor.

ADK interactúa con MCP de dos maneras principales:

1. **ADK como Cliente MCP (Consumidor de Herramientas MCP):** Este es el patrón más común. Un agente ADK puede actuar como un cliente MCP, utilizando herramientas que son expuestas por servidores MCP externos. La clase MCPToolset en ADK es el mecanismo primario para esta integración. MCPToolset gestiona la conexión con el servidor MCP (local o remoto), descubre las herramientas disponibles en ese servidor, adapta sus esquemas para que sean compatibles con ADK (como instancias BaseTool), y las presenta al LlmAgent como si fueran herramientas nativas de ADK. Cuando el agente decide usar una de estas herramientas, MCPToolset se encarga de enviar la llamada al servidor MCP y devolver la respuesta al agente.17  
2. **ADK como Proveedor de Herramientas MCP (Exponiendo Herramientas ADK vía un Servidor MCP):** También es posible construir un servidor MCP que envuelva herramientas ADK existentes. Esto permite que las herramientas desarrolladas dentro del framework ADK sean accesibles para cualquier aplicación cliente que sea compatible con el estándar MCP, no solo para otros agentes ADK. Esto se logra utilizando la biblioteca Python model-context-protocol para construir el servidor MCP, donde los manejadores del servidor (list\_tools, call\_tool) se implementan para interactuar con las herramientas ADK.17

La integración con MCP permite a los agentes ADK participar en un ecosistema más amplio de herramientas y servicios estandarizados.

### **5.9. Herramientas OpenAPI**

ADK simplifica enormemente la interacción con APIs REST externas mediante la generación automática de herramientas directamente a partir de una Especificación OpenAPI (versión 3.x).17 Esto elimina la necesidad de escribir manualmente funciones wrapper de Python para cada endpoint de una API.

* **OpenAPIToolset:** Esta es la clase principal que se inicializa con una especificación OpenAPI (proporcionada como un diccionario Python, una cadena JSON o una cadena YAML). Se encarga de parsear la especificación, resolver referencias internas y generar las herramientas.17  
* **RestApiTool:** Por cada operación API válida (GET, POST, PUT, DELETE, etc.) definida en la sección paths de la especificación, OpenAPIToolset crea una instancia de RestApiTool.17  
  * El **nombre** de la RestApiTool se deriva del operationId de la especificación (convertido a snake\_case) o se genera a partir del método HTTP y la ruta si operationId no está presente.17  
  * La **descripción** para el LLM se toma del summary o description de la operación en la especificación.17  
  * Cada RestApiTool genera dinámicamente una FunctionDeclaration (el esquema que ve el LLM) basada en los parámetros de la operación y el esquema del cuerpo de la solicitud. Cuando el LLM la invoca, la RestApiTool construye la solicitud HTTP correcta (URL, cabeceras, parámetros de consulta, cuerpo), maneja la autenticación (si está configurada globalmente en OpenAPIToolset) y ejecuta la llamada API usando la biblioteca requests, devolviendo la respuesta (típicamente JSON) al flujo del agente.17

Esta capacidad de generar herramientas a partir de OpenAPI es extremadamente potente para integrar agentes con el vasto ecosistema de APIs REST existentes, reduciendo significativamente el esfuerzo de desarrollo.

La abstracción de herramientas en ADK es una característica de diseño clave. Aunque existen múltiples formas de definir o integrar herramientas (funciones Python, OpenAPI, MCP), todas se presentan al LlmAgent de una manera relativamente uniforme a través de esquemas de función generados. El LLM no necesita conocer los detalles de implementación subyacentes; solo necesita el nombre, la descripción y el esquema de argumentos/retorno. Esta abstracción simplifica la tarea del LLM y del desarrollador del agente, permitiendo que el ecosistema de herramientas crezca y evolucione sin requerir cambios en la lógica central del LlmAgent sobre cómo consume herramientas, promoviendo así la componibilidad y la reutilización a gran escala.

### **5.10. El ToolContext: Acceso a Capacidades Adicionales dentro de las Herramientas**

Cuando una función de Python se utiliza como herramienta, ADK puede inyectar automáticamente un argumento especial llamado tool\_context (de tipo ToolContext) si la firma de la función lo incluye.11 Este objeto ToolContext es poderoso porque proporciona a la herramienta acceso a información y capacidades contextuales más amplias, elevando las herramientas de simples funciones a componentes más integrados dentro del framework ADK.22

El ToolContext ofrece acceso a:

* **Estado de la Sesión (tool\_context.state):** Permite a la herramienta leer y escribir en el diccionario session.state, facilitando que las herramientas sean "stateful" o que pasen información a pasos posteriores en la conversación.11  
* **Servicio de Artefactos:** A través de métodos como load\_artifact(filename) y save\_artifact(filename, part), las herramientas pueden interactuar con el ArtifactService configurado para manejar datos binarios.22  
* **Servicio de Memoria:** El método search\_memory(query) permite a la herramienta consultar el MemoryService configurado, facilitando la integración con bases de conocimiento a largo plazo.22  
* **Gestión de Autenticación:** Métodos como request\_credential(auth\_config) para iniciar un flujo de autenticación y get\_auth\_response(auth\_config) para recuperar credenciales proporcionadas por el usuario o sistema. El function\_call\_id en ToolContext es crucial para vincular estas solicitudes/respuestas de autenticación con la llamada a herramienta específica.22  
* **Acciones de Evento (tool\_context.actions):** Acceso directo al objeto EventActions para la etapa actual, permitiendo a la herramienta señalar cambios de estado, solicitudes de autenticación y otras acciones que influyen en el flujo.22  
* Metadatos como invocation\_id, agent\_name.

### **5.11. Tabla Resumen de Tipos de Herramientas**

La siguiente tabla ofrece una visión general de los diferentes tipos de herramientas disponibles en ADK y sus características principales:

| Tipo de Herramienta | Definición / Origen | Clase ADK Principal / Mecanismo | Ejemplo de Caso de Uso | Referencias Clave |
| :---- | :---- | :---- | :---- | :---- |
| **Herramientas de Función** | Funciones Python personalizadas | FunctionTool (implícito), def... | Lógica de negocio específica, cálculos personalizados | 10 |
| **Agentes como Herramientas** | Otro agente ADK | AgentTool | Delegar sub-tareas complejas a un agente especializado | 2 |
| **Herramientas Preconstruidas** | Proporcionadas por ADK | Específicas (ej. GoogleSearchTool, CodeExecutorTool) | Búsqueda web, ejecución de código, RAG | 1 |
| **Herramientas de Terceros** | De librerías como LangChain, CrewAI, LlamaIndex | Envoltorios o adaptadores personalizados | Usar recuperadores de LlamaIndex, herramientas de LangChain | 2 |
| **Herramientas Google Cloud** | Integraciones con servicios GCP | ApiHubToolset, ApplicationIntegrationToolset, ToolboxSyncClient | Interactuar con Apigee, App Integration, Bases de Datos GCP | 17 (citando S73, S74, S79, S89) |
| **Herramientas MCP** | Expuestas por un Servidor MCP | MCPToolset (como cliente MCP) | Consumir herramientas de un servicio MCP existente | 14 (citando S94-S101)21 |
| **Herramientas OpenAPI** | Generadas desde una Especificación OpenAPI | OpenAPIToolset, RestApiTool | Interactuar con cualquier API REST documentada con OpenAPI | 2 (citando S72-S88) |

## **6\. Gestión de Sesiones, Estado y Memoria**

La capacidad de un agente para mantener el contexto a lo largo de una interacción y recordar información relevante es fundamental para conversaciones coherentes y personalizadas. ADK proporciona mecanismos para gestionar sesiones, el estado de la conversación a corto plazo y ofrece vías para integrar memoria a largo plazo.

### **6.1. Concepto de Sesión en ADK**

Una **sesión** en ADK representa un único hilo de conversación o interacción entre un usuario y un agente (o sistema de agentes).10 Cada sesión es un contenedor que encapsula:

* Un **identificador único de sesión**.  
* El **historial de interacciones** dentro de esa sesión, típicamente almacenado como una secuencia de objetos Event.14  
* El **estado actual de la conversación (State)**, que es la memoria de trabajo a corto plazo del agente para esa sesión específica.14  
* Metadatos asociados, como el app\_name (nombre de la aplicación) y el user\_id (identificador del usuario).

Las sesiones son cruciales para las conversaciones multi-turno, donde el agente puede necesitar hacer preguntas aclaratorias, recordar información proporcionada anteriormente por el usuario y, en general, mantener la coherencia a lo largo de múltiples intercambios.10

Cuando se utiliza ADK con Vertex AI, la clase AdkApp (parte del SDK de Vertex AI para Python) gestiona las sesiones de manera transparente: utiliza sesiones en memoria cuando el agente se ejecuta localmente para desarrollo y pruebas, y cambia automáticamente a sesiones gestionadas en la nube (cloud-based managed sessions) cuando el agente se despliega en Vertex AI Agent Engine.10 Esta transición fluida simplifica el ciclo de vida de desarrollo y despliegue.

### **6.2. Gestión del Estado de la Conversación (session.state)**

El **estado (State)** de una sesión es la memoria de trabajo mutable y a corto plazo del agente, específica para esa sesión en curso.14 En la implementación de Python de ADK, session.state es típicamente un diccionario (dict).11 Este diccionario se utiliza para almacenar información temporal que es relevante para la conversación actual, como:

* Preferencias del usuario indicadas durante la conversación (ej. unidad de temperatura preferida).11  
* Resultados intermedios de la ejecución de herramientas.  
* Información contextual que necesita ser pasada entre diferentes turnos de la conversación o entre diferentes agentes en un flujo de trabajo multi-agente.  
* Banderas o contadores para controlar la lógica de la conversación.

El estado es accesible y modificable a través de los objetos de contexto que se proporcionan a las funciones de callback y a las herramientas, como ToolContext.state o CallbackContext.state.11 Cualquier cambio realizado en el session.state a través de estos contextos es rastreado por el framework. Estos cambios se asocian con el evento que se genera después de la modificación (a través del campo state\_delta en EventActions) y son persistidos por el SessionService configurado.24

Se puede proporcionar un estado inicial al crear una nueva sesión.11 Además, los LlmAgent pueden configurarse con un output\_key, lo que hace que la respuesta final del agente en un turno se guarde automáticamente en el session.state bajo la clave especificada.11 session.state es el mecanismo primario para compartir información y mantener el contexto *dentro* de una única conversación.

### **6.3. Servicios de Sesión (SessionService)**

El SessionService es una abstracción en ADK responsable de la persistencia y gestión de las sesiones, incluyendo su estado y el historial de eventos.11 El Runner (motor de ejecución de agentes) se inicializa con una implementación concreta de SessionService.11 Esta abstracción permite cambiar el backend de almacenamiento de sesiones sin necesidad de modificar la lógica del agente.

ADK proporciona varias implementaciones de SessionService:

* **InMemorySessionService**:  
  * Almacena todas las sesiones, sus estados y eventos directamente en la memoria del proceso de la aplicación.7  
  * **Ventajas:** Es muy simple de usar, extremadamente rápido y no requiere configuración externa.  
  * **Desventajas:** Es efímero; todos los datos de la sesión se pierden cuando la aplicación termina o se reinicia. Su escalabilidad está limitada por la memoria disponible en el proceso.  
  * **Casos de Uso:** Ideal para desarrollo local, pruebas unitarias, depuración rápida y demostraciones donde la persistencia a largo plazo no es un requisito. Es el servicio utilizado por defecto por AdkApp cuando se ejecuta localmente.10  
* **VertexAiSessionService**:  
  * Se integra con el servicio de Sesiones de Vertex AI Agent Engine, proporcionando una solución de persistencia gestionada, escalable y robusta en Google Cloud.25  
  * **Configuración:** Requiere especificar el PROJECT\_ID de Google Cloud y la LOCATION (región) donde reside la instancia de Agent Engine al inicializar el servicio.25 También necesita credenciales de IAM adecuadas para interactuar con los servicios de GCP.  
  * **Ventajas:** Ofrece persistencia real de las sesiones, escalabilidad para manejar un gran número de usuarios y sesiones concurrentes, y se integra con el ecosistema de gestión y monitorización de Vertex AI.  
  * **Casos de Uso:** Entornos de producción, aplicaciones que requieren alta disponibilidad y escalabilidad, y cuando se utilizan otras características de Vertex AI Agent Engine. Se activa automáticamente cuando un agente desarrollado con AdkApp se despliega en Vertex AI Agent Engine.10  
* Personalización (Opcional y Generalmente No Recomendado para Producción):  
  ADK permite, en ciertos contextos como AdkApp, anular el SessionService gestionado por defecto. Esto se puede hacer definiendo una función session\_service\_builder que devuelva una instancia de un servicio de sesión personalizado (que podría ser otra instancia de InMemorySessionService o una implementación completamente nueva si se adhiere a la interfaz BaseSessionService). Sin embargo, para agentes desplegados, especialmente en Vertex AI, esto no se recomienda debido a posibles problemas de sincronización y la pérdida de los beneficios de los servicios gestionados.10

Los servicios de sesión típicamente exponen operaciones como create\_session, get\_session, list\_sessions, y delete\_session.10 Internamente, también manejan la lógica para añadir eventos al historial de la sesión y aplicar los cambios de estado (append\_event).

La interacción entre el Runner, los objetos de Context (CallbackContext, ToolContext) y el SessionService asegura un flujo de trabajo bien definido para las actualizaciones de estado. Cuando se modifica el estado a través de un objeto de contexto, este cambio se registra y se asocia con el siguiente evento en la conversación a través del campo state\_delta en EventActions. El Runner pasa este evento al SessionService, que es responsable de aplicar estos deltas al estado persistente de la sesión.24 Este mecanismo centralizado es crucial para la depuración, la reproducibilidad y la consistencia del estado, especialmente en sistemas asíncronos y dirigidos por eventos.

### **6.4. Persistencia y Utilización del Estado entre Turnos y Sesiones**

* **Persistencia Entre Turnos (Dentro de una Sesión):** Como se mencionó, session.state es inherentemente persistente entre los diferentes turnos de una misma conversación, siempre que se utilice un SessionService que ofrezca persistencia (como VertexAiSessionService para producción, o InMemorySessionService durante la vida del proceso de la aplicación).11 Cada modificación al state a través de los objetos de contexto se guarda y está disponible en los turnos subsiguientes de esa sesión.  
* **Persistencia Entre Sesiones (Memoria a Largo Plazo del Usuario):** Para que la información relevante para un usuario persista a través de múltiples sesiones diferentes (ej. recordar las preferencias de un usuario de una sesión a otra semanas después):  
  * **Artefactos con Espacio de Nombres de Usuario:** Se pueden utilizar Artefactos (ver Sección 9\) con el prefijo de espacio de nombres "user:" (ej. "user:profile\_settings.json"). Estos artefactos se asocian con el app\_name y el user\_id, y son accesibles desde cualquier sesión de ese usuario dentro de la aplicación, siempre que se utilice un ArtifactService persistente (como GcsArtifactService).26  
  * **Integraciones Externas:** Para una base de conocimiento más estructurada o una memoria semántica a largo plazo, los desarrolladores generalmente necesitan implementar soluciones personalizadas. Esto a menudo implica crear Herramientas (ver Sección 5\) que interactúen con:  
    * Bases de datos externas (SQL, NoSQL).  
    * Bases de datos vectoriales para búsqueda semántica (ej. utilizando recuperadores de LlamaIndex o implementaciones similares como herramientas 20).  
    * APIs de servicios de conocimiento o perfil de usuario.

ADK proporciona una sólida gestión del estado conversacional a corto plazo. Para la memoria a largo plazo, el enfoque es proporcionar la flexibilidad para que los desarrolladores integren las soluciones de almacenamiento y recuperación que mejor se adapten a sus necesidades, utilizando el sistema de herramientas de ADK como el puente de comunicación.

### **6.5. Mecanismos de Memoria a Largo Plazo (MemoryService)**

Aunque los fragmentos de documentación general no detallan exhaustivamente una implementación completa de "MemoryService" para memoria semántica a largo plazo de la misma manera que lo hacen para SessionService o ArtifactService, la existencia de InMemoryMemoryService se menciona en el Codelab de InstaVibe 14, y los objetos de contexto como ToolContext y InvocationContext incluyen un método search\_memory(query) y una referencia a un memory\_service.22

Esto sugiere que ADK contempla una abstracción para la memoria a largo plazo, donde:

* Un MemoryService (cuya implementación concreta puede variar, desde una en memoria hasta una conectada a una base de datos vectorial) sería responsable de almacenar y recuperar información de manera más persistente y consultable semánticamente.  
* Las herramientas o la lógica del agente pueden usar tool\_context.search\_memory(query) para buscar en esta memoria.

La implementación concreta de cómo se populariza y mantiene este MemoryService (especialmente para soluciones persistentes y escalables) parece recaer en el desarrollador o en integraciones específicas (como las herramientas de RAG). La comunidad está explorando activamente cómo integrar sistemas como LlamaIndex para estas capacidades.20 El diseño de ADK parece tratar el estado de la conversación (contexto inmediato y efímero gestionado por SessionService) de manera distinta a la memoria a largo plazo (conocimiento persistente y consultable). Esta separación es arquitectónicamente sólida, permitiendo que el núcleo de ADK se mantenga ágil y enfocado en la orquestación, mientras que las estrategias de memoria a largo plazo, que son diversas y evolucionan rápidamente (especialmente con RAG), pueden implementarse como módulos conectables a través de herramientas o un MemoryService más abstracto.

### **6.6. Tabla de Implementaciones de SessionService**

| Característica | InMemorySessionService | VertexAiSessionService | Personalizado (vía session\_service\_builder) |
| :---- | :---- | :---- | :---- |
| **Persistencia** | En memoria (Efímera) | Google Cloud (Persistente, Gestionada) | Depende de la implementación |
| **Casos de Uso** | Desarrollo local, Pruebas unitarias, Demos rápidas | Producción, Entornos escalables, Colaboración en equipo | Escenarios muy específicos (no recomendado para prod.) |
| **Configuración** | Ninguna especial | PROJECT\_ID, LOCATION, credenciales IAM | Código personalizado |
| **Escalabilidad** | Limitada a la memoria del proceso | Alta (gestionada por Vertex AI) | Variable |
| **Complejidad** | Muy baja | Moderada (configuración de GCP) | Alta |
| **Referencias** | 7 | 10 | 10 |

## **7\. Eventos y Callbacks**

La arquitectura de ADK se basa en un flujo de información dinámico y en la capacidad de intervenir en puntos clave de la ejecución del agente. Los Eventos y los Callbacks son los mecanismos fundamentales que permiten esta interactividad y control.

### **7.1. Eventos en ADK: Estructura y Rol**

Los **Eventos** son las unidades de información fundamentales que circulan dentro del sistema ADK.24 Representan cada suceso significativo que ocurre durante el ciclo de vida de una interacción con un agente. Son cruciales porque sirven como el principal medio para que los diferentes componentes del sistema (UI, Runner, Agentes, LLM, Herramientas) se comuniquen entre sí, gestionen el estado de la conversación y dirijan el flujo de control de la ejecución.24

Estructura Conceptual de un Evento:  
Un Event en ADK (representado por la clase google.adk.events.Event en Python) es un registro inmutable que captura una amplia gama de ocurrencias. Extiende la estructura básica de una respuesta de LLM (LlmResponse) añadiendo metadatos específicos de ADK y una carga útil de acciones (actions).24  
Los campos clave de un objeto Event típicamente incluyen 24:

* id: Un identificador único para esta instancia específica del evento.  
* invocation\_id: Un identificador que agrupa todos los eventos pertenecientes a una única ejecución o "corrida" completa del agente (desde la solicitud inicial del usuario hasta la respuesta final). Esencial para el rastreo y la depuración.  
* timestamp: Una marca de tiempo (generalmente un float) que indica cuándo se creó el evento.  
* author: Una cadena de texto que identifica el origen del evento (ej. 'user' para la entrada del usuario, o el nombre del agente que generó el evento, como 'WeatherAgent').  
* content: Un objeto opcional de tipo google.genai.types.Content. Este es el contenedor principal para la carga útil del evento, que puede ser:  
  * Texto (para mensajes de usuario o respuestas del agente).  
  * Llamadas a función (cuando el LLM decide usar una herramienta).  
  * Respuestas de función (el resultado devuelto por una herramienta).  
* partial: Un booleano opcional que indica si el content es un fragmento incompleto, utilizado principalmente para el streaming de texto.  
* actions: Un objeto EventActions (ver Sección 7.2) que contiene señales para efectos secundarios y control de flujo (ej. cambios de estado, transferencia a otro agente).  
* branch: Una cadena opcional que puede representar una ruta jerárquica, útil en sistemas multi-agente complejos.

**Rol de los Eventos en el Ciclo de Vida del Agente** 24**:**

1. **Comunicación Estandarizada:** Los eventos actúan como el formato de mensaje estándar para toda la comunicación interna en ADK. Esto incluye interacciones entre la interfaz de usuario, el Runner, los diversos tipos de agentes (BaseAgent, LlmAgent, etc.), el Modelo de Lenguaje Grande (LLM) y las herramientas.  
2. **Señalización de Cambios de Estado y Artefactos:** Los eventos transportan instrucciones para modificar el session.state y para rastrear actualizaciones a los Artefactos. Específicamente, los campos state\_delta y artifact\_delta dentro de event.actions son utilizados por el SessionService para persistir estos cambios.  
3. **Dirección del Flujo de Control:** Ciertos campos dentro de event.actions, como transfer\_to\_agent (para delegar a otro agente) o escalate (para terminar un bucle en un LoopAgent), actúan como señales directas que el framework utiliza para dirigir la secuencia de ejecución.  
4. **Identificación de Respuestas Finales:** El método auxiliar event.is\_final\_response() es crucial para determinar qué eventos deben considerarse como la salida completa y visible para el usuario en un turno de la conversación. Este método filtra eventos intermedios (como llamadas a herramientas, fragmentos de texto en streaming o actualizaciones internas de estado) para presentar solo el mensaje o mensajes finales.

**Generación y Procesamiento de Eventos** 24**:**

* **Fuentes de Generación:**  
  * **Entrada del Usuario:** El Runner envuelve los mensajes del usuario en un Event (con author='user').  
  * **Lógica del Agente:** Los agentes generan explícitamente eventos (yield Event(...) en Python, con author=self.name) para comunicar sus respuestas o señalar acciones.  
  * **Respuestas del LLM:** La capa de integración de modelos de ADK traduce la salida cruda del LLM (texto, llamadas a función, errores) en objetos Event, atribuidos al agente que invocó al LLM.  
  * **Resultados de Herramientas:** Tras la ejecución de una herramienta, el framework genera un Event que contiene la function\_response (el resultado de la herramienta).  
* **Flujo de Procesamiento:**  
  1. Un evento es generado y emitido por su fuente.  
  2. El Runner principal que está ejecutando el agente recibe el evento.  
  3. El Runner envía el evento al SessionService configurado. El SessionService aplica los state\_delta y artifact\_delta (si los hay en event.actions) al estado y a los registros de artefactos de la sesión, asigna un event.id único si aún no lo tiene, y añade el evento procesado a la lista session.events (el historial de la conversación).  
  4. Finalmente, el Runner emite el evento procesado hacia el exterior, a la aplicación que lo llamó (ej. la UI o un script cliente).

El historial de eventos (session.events) proporciona una traza cronológica completa de toda la interacción, lo cual es invaluable para la depuración, la auditoría y la comprensión detallada del comportamiento del agente.7 El invocation\_id permite correlacionar todos los eventos de una interacción completa, mientras que el event.id identifica cada suceso de manera única.

### **7.2. EventActions y su Impacto**

El objeto EventActions, que forma parte de un Event, es el mecanismo a través del cual los agentes y las herramientas pueden declarar de forma explícita los efectos secundarios deseados y las intenciones de modificar el flujo de control, sin necesidad de interactuar directamente con la maquinaria interna del Runner o del SessionService de forma imperativa.24 Esto contribuye a mantener la lógica del agente más limpia y enfocada en su tarea.

Campos importantes dentro de EventActions incluyen:

* state\_delta: Optional\]: Un diccionario que especifica los cambios que deben aplicarse al session.state.  
* artifact\_delta: Optional\]: Un diccionario que describe las acciones a realizar sobre los artefactos (ej. guardar un nuevo artefacto, eliminar uno existente).  
* transfer\_to\_agent: Optional\[str\]: El nombre del agente al que se debe transferir el control de la ejecución.  
* escalate: bool: Una señal booleana utilizada principalmente por LoopAgent y agentes personalizados para indicar que se debe terminar un bucle o un flujo de trabajo actual y "escalar" el control, posiblemente al agente padre o finalizando la iteración.  
* end\_invocation: bool: Una señal booleana para indicar al Runner que debe terminar toda la invocación actual del agente (el ciclo completo de solicitud-respuesta).  
* auth\_request: Optional: Un objeto para solicitar que se inicie un flujo de autenticación, típicamente usado por herramientas que necesitan credenciales. Un ejemplo de su uso es actions\_with\_update \= EventActions(state\_delta=state\_changes).25

### **7.3. Tipos de Callbacks y su Propósito**

Los **Callbacks** en ADK son funciones que los desarrolladores pueden definir y registrar para que se ejecuten en puntos específicos del ciclo de vida de un agente o durante interacciones clave (como llamadas a LLMs o herramientas).23 Permiten:

* **Observar** el comportamiento interno del agente.  
* **Personalizar** la lógica en etapas críticas.  
* **Controlar o modificar** el flujo de ejecución o los datos intercambiados.

Los callbacks se adjuntan a las definiciones de los agentes al momento de su instanciación (ej. before\_model\_callback=mi\_funcion\_callback en el constructor de Agent).7

ADK organiza los callbacks en tres categorías principales 23:

1. **Callbacks del Ciclo de Vida del Agente:** Se aplican a cualquier agente que herede de BaseAgent.  
2. **Callbacks de Interacción con LLM:** Específicos para LlmAgent.  
3. **Callbacks de Ejecución de Herramientas:** También específicos para LlmAgent.

### **7.4. Callbacks del Ciclo de Vida del Agente**

Estos callbacks se pueden usar con cualquier tipo de agente (BaseAgent, LlmAgent, WorkflowAgent, CustomAgent).23

* **before\_agent\_callback(callback\_context: CallbackContext) \-\> Optional\[types.Content\]**:  
  * **Cuándo se llama:** Inmediatamente *antes* de que se ejecute el método principal de lógica del agente (\_run\_async\_impl o \_run\_live\_impl), después de que se haya creado el InvocationContext del agente pero antes de que comience su lógica central.23  
  * **Propósito/Casos de Uso:** Ideal para tareas de configuración inicial de recursos o estado que el agente necesitará específicamente para su ejecución, realizar validaciones sobre el estado de la sesión antes de que el agente comience, registrar el punto de entrada de la actividad del agente, o potencialmente modificar el contexto de invocación antes de que la lógica principal lo utilice.23  
  * **Efecto del Valor de Retorno:** Si el callback devuelve un objeto types.Content, la ejecución principal del agente se **omite por completo**, y el contenido devuelto por el callback se utiliza como la respuesta final del agente para ese turno. Si el callback devuelve None (o un objeto vacío equivalente en Java), la ejecución normal del agente procede. Actúa como una "puerta de control" para interceptar la ejecución.23  
* **after\_agent\_callback(callback\_context: CallbackContext) \-\> Optional\[types.Content\]**:  
  * **Cuándo se llama:** Inmediatamente *después* de que el método principal de lógica del agente (\_run\_async\_impl o \_run\_live\_impl) haya completado su ejecución con éxito. No se ejecuta si el agente fue omitido por un before\_agent\_callback o si se estableció end\_invocation=True durante la ejecución del agente.23  
  * **Propósito/Casos de Uso:** Útil para tareas de limpieza de recursos, validación post-ejecución, registrar la finalización de la actividad de un agente, modificar el estado final de la sesión, o aumentar/reemplazar la salida final producida por el agente.23 Un ejemplo práctico es la función modify\_output\_after\_agent en el Codelab de InstaVibe, que procesa el estado para formular la respuesta final de un LoopAgent.14  
  * **Efecto del Valor de Retorno:** Si el callback devuelve un nuevo objeto types.Content, este **reemplaza** la salida original del agente. Si devuelve None (o un objeto vacío en Java), se utiliza la salida original del agente. Permite el post-procesamiento o la modificación del resultado del agente.23

Estos callbacks ofrecen puntos de entrada y salida para la lógica de un agente, permitiendo una gestión del ciclo de vida y una modificación del comportamiento a un nivel más general del agente.

### **7.5. Callbacks de Interacción con LLM (para LlmAgent)**

Estos callbacks son específicos para LlmAgent y proporcionan ganchos alrededor de la interacción con el Modelo de Lenguaje Grande.23 Son cruciales para la seguridad, el control de costes (mediante caching) y la personalización fina de la interacción con el LLM.

* **before\_model\_callback(callback\_context: CallbackContext, llm\_request: LlmRequest) \-\> Optional**:  
  * **Cuándo se llama:** Justo *antes* de que la solicitud generate\_content\_async (o su equivalente para el modelo configurado) se envíe al LLM dentro del flujo de un LlmAgent.23  
  * **Propósito/Casos de Uso:** Permite inspeccionar y, si es necesario, modificar la solicitud que se va a enviar al LLM. Los casos de uso incluyen: añadir instrucciones dinámicas al prompt, inyectar ejemplos few-shot basados en el estado actual de la conversación, modificar la configuración del modelo (ej. temperatura, top\_p), implementar guardrails de seguridad (como filtros de palabras clave o contenido sensible, como se demuestra en el Paso 5 del tutorial del Weather Bot con block\_keyword\_guardrail 11), o implementar mecanismos de caching a nivel de solicitud para evitar llamadas redundantes al LLM.23  
  * **Efecto del Valor de Retorno:** Si el callback devuelve None (o un Maybe.empty() en Java), el LlmAgent continúa con su flujo normal y envía la solicitud (posiblemente modificada) al LLM. Si el callback devuelve un objeto LlmResponse, la llamada real al LLM se **omite**, y el LlmResponse devuelto por el callback se utiliza directamente como si hubiera venido del modelo. Esto es muy potente para implementar guardrails o caching.23  
* **after\_model\_callback(callback\_context: CallbackContext, llm\_response: LlmResponse) \-\> Optional**:  
  * **Cuándo se llama:** Justo *después* de que se recibe una respuesta (LlmResponse) del LLM, pero *antes* de que esta respuesta sea procesada más a fondo por el LlmAgent (ej. para extraer llamadas a herramientas o texto final).23  
  * **Propósito/Casos de Uso:** Permite inspeccionar o modificar la respuesta cruda del LLM. Los usos incluyen: registrar las salidas del modelo para análisis o depuración, reformatear las respuestas para que se ajusten a un esquema específico, censurar información sensible que el modelo pueda haber generado, parsear datos estructurados de la respuesta del LLM y almacenarlos en callback\_context.state para uso posterior, o manejar códigos de error específicos devueltos por el modelo.23  
  * **Efecto del Valor de Retorno:** Si el callback devuelve None (o un Maybe.empty() en Java), se utiliza el llm\_response original del modelo. Si se devuelve un nuevo objeto LlmResponse, este **reemplaza** al llm\_response original, permitiendo la modificación o el filtrado del resultado que el LlmAgent procesará.23

### **7.6. Callbacks de Ejecución de Herramientas (para LlmAgent)**

Estos callbacks también son específicos de LlmAgent y se activan alrededor de la ejecución de herramientas (como FunctionTool, AgentTool, etc.) que el LLM podría solicitar.23 Ofrecen un control granular sobre el uso de herramientas, vital para la seguridad y la eficiencia.

* **before\_tool\_callback(tool: BaseTool, args: Dict\[str, Any\], tool\_context: ToolContext) \-\> Optional**:  
  * **Cuándo se llama:** Justo *antes* de que se llame al método run\_async de una herramienta específica, después de que el LLM haya generado una solicitud de llamada a función (function call) para esa herramienta.23  
  * **Propósito/Casos de Uso:** Permite inspeccionar y modificar los argumentos que se pasarán a la herramienta, realizar comprobaciones de autorización antes de que la herramienta se ejecute, registrar intentos de uso de herramientas, implementar guardrails a nivel de herramienta (ej. bloquear la ejecución de una herramienta si se llama con ciertos argumentos, como se demuestra en el Paso 6 del tutorial del Weather Bot con block\_paris\_tool\_guardrail 11), o implementar caching a nivel de herramienta para evitar ejecuciones redundantes si los argumentos son los mismos.23  
  * **Efecto del Valor de Retorno:** Si el callback devuelve None (o un Maybe.empty() en Java), el método run\_async de la herramienta se ejecuta con los argumentos (posiblemente modificados por el callback). Si el callback devuelve un diccionario (Dict), la ejecución real de la herramienta (run\_async) se **omite**, y el diccionario devuelto por el callback se utiliza directamente como el resultado de la llamada a la herramienta. Esto es útil para implementar caching o para anular el comportamiento de una herramienta bajo ciertas condiciones.23  
* **after\_tool\_callback(tool: BaseTool, args: Dict\[str, Any\], tool\_context: ToolContext, tool\_response: Dict\[str, Any\]) \-\> Optional**:  
  * **Cuándo se llama:** Justo *después* de que el método run\_async de la herramienta haya completado su ejecución con éxito y haya devuelto un resultado (el tool\_response).23  
  * **Propósito/Casos de Uso:** Permite inspeccionar y modificar el resultado de la herramienta *antes* de que este resultado se envíe de vuelta al LLM (potencialmente después de un proceso de resumen si el resultado es muy largo). Es útil para: registrar los resultados de las herramientas, realizar post-procesamiento o formateo de los resultados para que sean más comprensibles para el LLM, o extraer y guardar partes específicas del resultado en tool\_context.state para uso futuro.23  
  * **Efecto del Valor de Retorno:** Si el callback devuelve None (o un Maybe.empty() en Java), se utiliza el tool\_response original de la herramienta. Si se devuelve un nuevo diccionario, este **reemplaza** al tool\_response original, permitiendo la modificación o el filtrado del resultado que el LLM finalmente verá.23

### **7.7. El CallbackContext y ToolContext**

Como se ha mencionado, los objetos CallbackContext y ToolContext son los vehículos a través de los cuales las funciones de callback reciben información contextual y la capacidad de interactuar con el sistema ADK.22 ToolContext es una subclase de CallbackContext y hereda todas sus capacidades, añadiendo funcionalidades específicas para la ejecución de herramientas (como métodos para la autenticación, búsqueda en memoria, etc.).22 Estos objetos de contexto son fundamentales para que los callbacks puedan realizar tareas significativas. (Ver Sección 8 para una discusión más detallada sobre los Objetos de Contexto).

### **7.8. Tabla Resumen de Tipos de Callbacks**

| Tipo de Callback | Se Invoca en... | Cuándo se Llama | Propósito Principal | Efecto del Valor de Retorno (si no es None) | Referencia Clave |
| :---- | :---- | :---- | :---- | :---- | :---- |
| before\_agent\_callback | BaseAgent | Antes de \_run\_async\_impl | Setup, validación previa, logging | types.Content salta la ejecución del agente, usa el contenido como respuesta | 23 |
| after\_agent\_callback | BaseAgent | Después de \_run\_async\_impl (si éxito) | Cleanup, validación posterior, logging, modificar salida | types.Content reemplaza la salida original del agente | 23 |
| before\_model\_callback | LlmAgent | Antes de enviar la solicitud al LLM | Modificar solicitud LLM, guardrails de entrada, caching | LlmResponse salta la llamada al LLM, usa esta respuesta | 11 |
| after\_model\_callback | LlmAgent | Después de recibir la respuesta del LLM | Modificar respuesta LLM, logging, censura, parseo | LlmResponse reemplaza la respuesta original del LLM | 23 |
| before\_tool\_callback | LlmAgent | Antes de ejecutar una herramienta | Modificar args de herramienta, autorización, guardrails de herramienta, caching | Dict salta la ejecución de la herramienta, usa este dict como resultado | 11 |
| after\_tool\_callback | LlmAgent | Después de que una herramienta devuelve un resultado | Modificar resultado de herramienta, logging, post-procesamiento, guardar en estado | Dict reemplaza el resultado original de la herramienta | 23 |

El sistema de Eventos y Callbacks en ADK proporciona un alto grado de observabilidad e interceptación. Los Eventos ofrecen una traza detallada de cada paso, crucial para la depuración y el análisis del comportamiento. Los Callbacks, por su parte, permiten a los desarrolladores inyectar lógica personalizada en puntos críticos, transformando a los agentes de "cajas negras" en sistemas más transparentes y controlables. Esta capacidad de intervención es fundamental para construir agentes seguros, eficientes y alineados con los requisitos específicos de la aplicación. La forma en que los Callbacks pueden anular o modificar el flujo normal (ej. saltarse una llamada al LLM o la ejecución de una herramienta) es una manifestación de la filosofía de "control" que ADK promueve.

## **8\. Objetos de Contexto en ADK (InvocationContext, CallbackContext, ToolContext)**

Los objetos de contexto en ADK son fundamentales, ya que actúan como portadores de información relevante y proveedores de capacidades específicas en diferentes puntos de la ejecución de un agente o una herramienta. Aseguran que cada componente tenga acceso al conjunto adecuado de datos y funcionalidades necesarias para su tarea, sin exponer la complejidad total del estado interno del sistema. ADK define varios "sabores" de objetos de contexto, cada uno adaptado a una situación particular.22

### **8.1. ReadonlyContext**

* **Propósito:** Sirve como la clase base para otros objetos de contexto más especializados y se utiliza en escenarios donde solo se necesita acceso de lectura a información básica y no se permite la modificación del estado o del flujo.22  
* **Contenido Clave:**  
  * invocation\_id: El ID de la invocación actual del agente.22  
  * agent\_name: El nombre del agente actualmente en ejecución.22  
  * state: Una vista de **solo lectura** del session.state actual.22 Intentar modificar el estado a través de este contexto probablemente resultaría en un error o no tendría efecto.  
* **Dónde se Usa:** Un ejemplo típico es en funciones InstructionProvider, donde el prompt del sistema para un LlmAgent puede generarse dinámicamente basándose en el estado actual, pero sin la capacidad de modificarlo directamente en esa etapa.22

### **8.2. InvocationContext (ctx)**

* **Propósito:** Este es el objeto de contexto más completo y se proporciona directamente a los métodos centrales de implementación de un agente (\_run\_async\_impl y \_run\_live\_impl en Python), usualmente con el nombre de variable ctx.22 Ofrece acceso al estado completo de la invocación actual del agente.  
* **Contenido Clave (además de lo heredado de ReadonlyContext):**  
  * session: El objeto de sesión completo, que a su vez contiene el state (mutable), la lista de events, y otros metadatos de la sesión.22  
  * agent: La instancia del agente que se está ejecutando actualmente.22  
  * user\_content: El contenido inicial del mensaje del usuario que desencadenó esta invocación.22  
  * Referencias a los servicios configurados en el Runner:  
    * artifact\_service: BaseArtifactService  
    * memory\_service: BaseMemoryService  
    * session\_service: BaseSessionService  
  * Campos relacionados con el modo de ejecución en vivo (bidi-streaming).22  
  * end\_invocation: bool: Una bandera que el agente puede establecer en True para señalar al framework que la invocación actual debe terminar prematuramente.22  
* **Dónde se Usa:** Principalmente dentro de la lógica central de un agente (especialmente en agentes personalizados que heredan de BaseAgent) cuando se necesita acceso directo y completo a la sesión, a los servicios, o para controlar el ciclo de vida de la invocación.22

### **8.3. CallbackContext (callback\_context)**

* **Propósito:** Este contexto se pasa como argumento (comúnmente callback\_context) a las funciones de callback del ciclo de vida del agente (ej. before\_agent\_callback, after\_agent\_callback) y a los callbacks de interacción con el modelo (ej. before\_model\_callback, after\_model\_callback).22 Está diseñado para permitir que los callbacks inspeccionen el estado, interactúen con artefactos y accedan a detalles de la invocación, con la capacidad de modificar el estado.  
* **Capacidades Clave (además de lo heredado de ReadonlyContext):**  
  * **Propiedad state Mutable:** A diferencia de ReadonlyContext, CallbackContext permite tanto la lectura como la **escritura** en el session.state. Los cambios realizados (ej. callback\_context.state\['nueva\_clave'\] \= 'nuevo\_valor') se rastrean y se asocian con el evento que el framework genera después de que el callback se completa (a través de state\_delta en EventActions).22  
  * **Métodos de Artefactos:** Proporciona load\_artifact(filename: str, version: Optional\[int\] \= None) y save\_artifact(filename: str, part: types.Part) para interactuar con el ArtifactService configurado.22  
  * Acceso directo a user\_content (el contenido del usuario que inició el turno actual).22  
* **Dónde se Usa:** En todos los callbacks de agente y modelo donde se necesita observar o influir en el estado o los datos binarios.23

### **8.4. ToolContext (tool\_context)**

* **Propósito:** Este es el objeto de contexto más especializado y se pasa como argumento (comúnmente tool\_context) a las funciones de Python que respaldan las FunctionTools y a los callbacks de ejecución de herramientas (before\_tool\_callback, after\_tool\_callback).17 Proporciona todas las capacidades de CallbackContext y añade métodos y propiedades cruciales específicamente para la ejecución de herramientas.  
* **Capacidades Clave (además de lo heredado de CallbackContext):**  
  * **Métodos de Autenticación:**  
    * request\_credential(auth\_config: AuthConfig) \-\> None: Permite a una herramienta solicitar que se inicie un flujo de autenticación (ej. OAuth) si necesita credenciales para operar. La auth\_config describe el tipo de autenticación requerida.22  
    * get\_auth\_response(auth\_config: AuthConfig) \-\> Optional: Permite a la herramienta recuperar la respuesta de autenticación (ej. un token) que el usuario o el sistema puedan haber proporcionado después de una request\_credential.22  
  * **Listado de Artefactos:** Ofrece list\_artifacts() \-\> list\[str\] para descubrir los nombres de los artefactos disponibles para el usuario/sesión actual.22  
  * **Búsqueda en Memoria:** Proporciona search\_memory(query: str) \-\> list para consultar el MemoryService configurado, permitiendo a las herramientas acceder a memoria a largo plazo o bases de conocimiento.22  
  * **Propiedad function\_call\_id: str:** Identifica la solicitud de llamada a función específica generada por el LLM que desencadenó la ejecución de esta herramienta. Esto es crucial para vincular correctamente las solicitudes o respuestas de autenticación con la llamada a herramienta correcta.22  
  * **Propiedad actions: EventActions:** Proporciona acceso directo al objeto EventActions para la etapa actual. Esto permite que la herramienta señale cambios de estado (state\_delta), solicitudes de autenticación (auth\_request), y otras acciones que deben registrarse o influir en el flujo del agente.22  
* **Dónde se Usa:** Dentro de la lógica de cualquier FunctionTool que necesite interactuar con el estado de la sesión, artefactos, memoria, o que requiera autenticación. También en los callbacks before\_tool\_callback y after\_tool\_callback.17

La jerarquía y especialización de estos objetos de contexto (ReadonlyContext \-\> CallbackContext \-\> ToolContext, con InvocationContext como una vista más completa) es un diseño cuidadoso. Asegura que cada parte del framework ADK (agentes, callbacks, herramientas) reciba solo el nivel de acceso y las capacidades que necesita, aplicando el principio de menor privilegio y simplificando la interfaz para cada componente. Entender qué contexto está disponible en qué situación y qué se puede lograr con él es clave para un desarrollo efectivo con ADK.

## **9\. Gestión de Artefactos en ADK**

Más allá del estado de la conversación basado en texto o JSON simple, las aplicaciones agénticas a menudo necesitan manejar datos binarios, como archivos, imágenes, audio o documentos. ADK aborda esta necesidad a través de su sistema de **Artefactos**.26

### **9.1. ¿Qué son los Artefactos?**

Un **Artefacto** en ADK es un mecanismo para gestionar datos binarios nombrados y versionados. Estos datos pueden estar asociados con una sesión de interacción específica del usuario o, de manera más persistente, con un usuario a través de múltiples sesiones.26 Los artefactos permiten a los agentes y herramientas manejar una gama más rica de tipos de datos, facilitando interacciones que involucran archivos, imágenes, clips de audio, PDFs y otros formatos binarios.

La representación estándar de un artefacto en ADK es a través del objeto google.genai.types.Part. El contenido binario real se almacena típicamente dentro de la estructura inline\_data de este objeto Part, que a su vez contiene 26:

* data: El contenido binario crudo, como un objeto bytes.  
* mime\_type: Una cadena de texto que indica el tipo de datos (ej. "image/png", "application/pdf", "audio/mpeg"). Este mime\_type es esencial para que la aplicación pueda interpretar y procesar correctamente los datos binarios más tarde.

Los artefactos no se almacenan directamente dentro del estado del agente (session.state) ni en la memoria del proceso del agente de forma predeterminada. Su almacenamiento, versionado y recuperación son gestionados por un componente dedicado llamado **Servicio de Artefactos (ArtifactService)**.26

### **9.2. El Servicio de Artefactos (BaseArtifactService)**

El ArtifactService es una abstracción (definida por la interfaz BaseArtifactService en google.adk.artifacts) responsable de la lógica real de cómo y dónde se persisten los artefactos.26 ADK proporciona diferentes implementaciones de este servicio, como InMemoryArtifactService para almacenamiento temporal y GcsArtifactService para persistencia en Google Cloud Storage.

Cuando se inicializa el Runner, se le puede proporcionar una instancia de un ArtifactService. El Runner luego hace que este servicio esté disponible para los agentes y herramientas a través de los objetos de contexto (CallbackContext y ToolContext).26

El ArtifactService maneja automáticamente el **versionado** cada vez que se guarda un artefacto con el mismo nombre de archivo (filename) dentro del mismo ámbito (sesión o usuario). Típicamente, las versiones comienzan desde 0 y se incrementan con cada nuevo guardado.26

### **9.3. ¿Por Qué Usar Artefactos?**

Mientras que session.state es adecuado para pequeñas piezas de configuración, contexto conversacional o datos JSON simples, los Artefactos están diseñados para escenarios que involucran datos binarios o de gran tamaño por varias razones 26:

1. **Manejo de Datos No Textuales:** Permiten el almacenamiento y la recuperación sencillos de imágenes, clips de audio, fragmentos de video, PDFs, hojas de cálculo o cualquier otro formato de archivo relevante para la función del agente.  
2. **Persistencia de Datos Grandes:** Proporcionan un mecanismo dedicado para persistir blobs de datos más grandes sin sobrecargar el session.state, que generalmente no está optimizado para este propósito.  
3. **Gestión de Archivos de Usuario:** Habilitan capacidades para que los usuarios carguen archivos (que pueden guardarse como artefactos) y para que los agentes generen archivos (como informes o imágenes) que los usuarios pueden luego recuperar o descargar.  
4. **Compartir Salidas Binarias:** Las herramientas o los agentes pueden generar salidas binarias (ej. un informe PDF, una imagen generada) que se guardan mediante save\_artifact y luego pueden ser accedidas por otras partes de la aplicación o incluso en sesiones posteriores (si se utiliza el espacio de nombres de usuario).  
5. **Caching de Datos Binarios:** Los resultados de operaciones computacionalmente costosas que producen datos binarios (ej. renderizar un gráfico complejo) pueden almacenarse como artefactos para evitar su regeneración.

En resumen, los Artefactos gestionados por un ArtifactService son el mecanismo apropiado dentro de ADK siempre que un agente necesite trabajar con datos de tipo archivo que requieran persistencia, versionado o ser compartidos.26

### **9.4. Casos de Uso Comunes para Artefactos**

* Generación de informes o archivos por parte de un agente (ej. un análisis en PDF, una exportación de datos en CSV, un gráfico de imagen).  
* Manejo de archivos cargados por el usuario a través de una interfaz frontend (ej. una imagen para análisis, un documento para resumen).  
* Almacenamiento de resultados binarios intermedios en un proceso multi-etapa (ej. síntesis de audio, resultados de simulación).  
* Almacenamiento de datos de configuración o datos específicos del usuario que no son simples pares clave-valor de estado.  
* Caching de contenido binario generado frecuentemente (ej. el logo de una empresa, un saludo de audio estándar).

### **9.5. Conceptos Clave de los Artefactos**

* **filename (Nombre de Archivo):** Una cadena de texto simple utilizada para nombrar y recuperar un artefacto dentro de su espacio de nombres específico. Los nombres de archivo deben ser únicos dentro de su ámbito.26  
* **Datos del Artefacto (google.genai.types.Part):** El contenido se representa universalmente usando este objeto, con inline\_data (que contiene data: bytes y mime\_type: str) como el portador del contenido binario y su tipo.26  
* **Versionado:** Gestionado automáticamente por el ArtifactService. save\_artifact devuelve el número de versión asignado. load\_artifact sin especificar una versión recupera la última versión; con un número de versión, recupera esa versión específica.26  
* **Espacio de Nombres (Scoping): Sesión vs. Usuario:**  
  * **Ámbito de Sesión (Predeterminado):** Un nombre de archivo simple (ej. "report.pdf") asocia el artefacto con el app\_name, user\_id **y** session\_id específicos, haciéndolo accesible solo dentro de ese contexto de sesión exacto.26  
  * **Ámbito de Usuario (Prefijo "user:"):** Anteponer al nombre de archivo el prefijo "user:" (ej. "user:profile.png") asocia el artefacto solo con el app\_name y el user\_id. Esto permite que el artefacto sea accedido o actualizado desde **cualquier sesión** perteneciente a ese usuario dentro de la aplicación, siempre que se utilice un servicio de artefactos persistente.26

### **9.6. Interacción con Artefactos (Vía Objetos de Contexto)**

La forma principal de interactuar con los artefactos dentro de la lógica de un agente (en callbacks o herramientas) es a través de los métodos proporcionados por los objetos CallbackContext y ToolContext.26

* **Prerrequisito:** Una instancia de una implementación de BaseArtifactService (como InMemoryArtifactService o GcsArtifactService) **debe** ser proporcionada al inicializar el Runner. Si no se configura ningún artifact\_service, llamar a save\_artifact, load\_artifact o list\_artifacts en los objetos de contexto generará un error (ValueError en Python).26  
* **Métodos de Acceso (en CallbackContext y ToolContext):**  
  * save\_artifact(filename: str, part: types.Part) \-\> int: Guarda el contenido de part como un artefacto con el filename dado. Devuelve el número de versión asignado.  
  * load\_artifact(filename: str, version: Optional\[int\] \= None) \-\> Optional\[types.Part\]: Carga un artefacto. Si version no se especifica, carga la última versión. Devuelve None si el artefacto o la versión no existen.  
  * list\_artifacts() \-\> list\[str\]: (Disponible en ToolContext) Lista los nombres de archivo de los artefactos disponibles para el usuario/sesión actual.22  
  * (Potencialmente otros métodos como delete\_artifact o list\_versions dependiendo de la interfaz completa de BaseArtifactService).

### **9.7. Implementaciones Disponibles de ArtifactService**

ADK proporciona implementaciones concretas de la interfaz BaseArtifactService:

* **InMemoryArtifactService**:  
  * **Mecanismo de Almacenamiento:** Utiliza estructuras de datos en memoria (diccionarios de Python o HashMaps de Java).26  
  * **Características Clave:** Simple, rápido, efímero (los artefactos se pierden cuando la aplicación termina).  
  * **Casos de Uso:** Ideal para desarrollo local, pruebas y demostraciones de corta duración donde la persistencia no es un requisito.26  
* **GcsArtifactService**:  
  * **Mecanismo de Almacenamiento:** Utiliza Google Cloud Storage (GCS) para el almacenamiento persistente de artefactos. Cada versión de un artefacto se almacena como un objeto (blob) separado dentro de un bucket de GCS especificado.26  
  * **Características Clave:** Persistencia a través de reinicios de la aplicación, escalabilidad, versionado explícito. Requiere configuración de un bucket GCS y permisos IAM adecuados para que la identidad del agente/aplicación pueda leer y escribir en el bucket. Una característica reciente permite usar GcsArtifactService en adk web.1  
  * **Casos de Uso:** Entornos de producción que requieren almacenamiento persistente, escenarios donde los artefactos necesitan ser compartidos entre diferentes instancias de la aplicación, y aplicaciones que necesitan almacenamiento a largo plazo de datos binarios.26

### **9.8. Mejores Prácticas para el Uso de Artefactos**

* **Elegir el Servicio Adecuado:** InMemoryArtifactService para prototipado/pruebas; GcsArtifactService (u otro servicio persistente) para producción.26  
* **Nombres de Archivo Significativos:** Utilizar nombres de archivo claros y descriptivos. Aunque el mime\_type dicta el manejo programático, un buen nombre ayuda a la organización.  
* **Especificar mime\_type Correctos:** Siempre proporcionar un mime\_type preciso al crear el objeto types.Part para save\_artifact, ya que esto es crucial para la correcta interpretación de los datos por parte de la aplicación o del usuario.26  
* **Comprender el Versionado:** Recordar que load\_artifact() sin un número de versión recupera la *última* versión. Utilizar números de versión específicos cuando se necesite acceder a una versión anterior.  
* **Usar Espacios de Nombres Deliberadamente:** Utilizar el prefijo "user:" solo para datos que son verdaderamente específicos del usuario y necesitan ser accesibles a través de todas sus sesiones. Para datos específicos de una sesión, usar nombres de archivo regulares.26  
* **Manejo de Errores:** Verificar siempre si un artifact\_service está configurado antes de intentar usar sus funciones. Comprobar si load\_artifact devuelve None (lo que indica que el artefacto no se encontró) y estar preparado para manejar excepciones que puedan surgir del servicio de almacenamiento subyacente (ej. errores de red, problemas de permisos con GCS).  
* **Consideraciones de Tamaño:** Ser consciente de los posibles costes de almacenamiento y los impactos en el rendimiento al manejar archivos extremadamente grandes, especialmente con servicios de almacenamiento en la nube.  
* **Estrategia de Limpieza:** Para el almacenamiento persistente (como GCS), implementar una estrategia para la limpieza o el ciclo de vida de los artefactos, ya que permanecerán en el almacenamiento hasta que se eliminen explícitamente.

## **10\. Seguridad en ADK Agents**

La construcción de agentes de IA potentes y autónomos conlleva la responsabilidad de asegurar que operen de manera segura y alineada con los objetivos previstos. ADK, en conjunto con las capacidades de Google Cloud y Vertex AI, ofrece un enfoque de múltiples capas para mitigar riesgos como acciones desalineadas o dañinas, exfiltración de datos y generación de contenido inapropiado.19

### **10.1. Identidad y Autorización**

Controlar "como quién actúa" el agente es fundamental. Esto se logra definiendo la autenticación del agente y del usuario.19

* **Autenticación del Agente (Agent-Auth):**  
  * En este modelo, la herramienta (o el agente que la usa) interactúa con sistemas externos utilizando la **propia identidad del agente**, que típicamente es una cuenta de servicio (service account) de Google Cloud.19  
  * La identidad del agente debe estar explícitamente autorizada en las políticas de acceso del sistema externo (ej. añadir la cuenta de servicio a la política IAM de una base de datos con permisos de solo lectura).  
  * **Ventajas:** Limita al agente a realizar solo las acciones para las que su identidad ha sido explícitamente autorizada por el desarrollador. Por ejemplo, si la cuenta de servicio solo tiene permisos de lectura, el agente no podrá realizar acciones de escritura, independientemente de lo que el modelo LLM decida o intente. Es relativamente simple de implementar.19  
  * **Consideraciones:** Adecuado para agentes donde todos los usuarios finales comparten el mismo nivel de acceso a los recursos a través del agente. Si los usuarios tienen diferentes niveles de acceso, este enfoque necesita complementarse. Es crucial mantener registros (logs) para atribuir las acciones a los usuarios finales, ya que todas las acciones del agente parecerán originarse desde la identidad del agente.19  
* **Autenticación del Usuario (User Auth):**  
  * Aquí, la herramienta interactúa con el sistema externo utilizando la **identidad del "usuario controlador"** (ej. el humano que interactúa con una aplicación frontend que a su vez llama al agente).19  
  * En ADK, esto se implementa comúnmente usando OAuth: el frontend de la aplicación obtiene un token OAuth del usuario, y este token se pasa al agente, que luego lo utiliza en sus herramientas para realizar acciones en sistemas externos.19  
  * El sistema externo autoriza la acción si el usuario controlador tiene los permisos necesarios.  
  * **Ventajas:** Reduce el riesgo de que usuarios maliciosos abusen del agente para obtener acceso no autorizado a datos, ya que las acciones se realizan bajo los permisos del usuario.  
  * **Consideraciones:** Las implementaciones comunes de OAuth pueden otorgar permisos más amplios de los que el agente realmente necesita para sus tareas específicas. Por lo tanto, se pueden requerir técnicas adicionales para restringir aún más las acciones del agente.19

### **10.2. Guardrails para Filtrar Entradas y Salidas**

Estos mecanismos permiten un control preciso sobre las llamadas al modelo LLM y a las herramientas.19

* **Guardrails Dentro de las Herramientas (In-Tool Guardrails):**  
  * Las herramientas deben diseñarse teniendo en cuenta la seguridad, exponiendo solo las acciones deseadas y necesarias. Limitar el rango de acciones que una herramienta puede realizar puede eliminar de manera determinista clases enteras de acciones no deseadas.19  
  * Se puede utilizar el ToolContext (que puede ser configurado determinísticamente por el desarrollador del agente) para pasar políticas o restricciones a la herramienta. Por ejemplo, una herramienta de consulta a base de datos puede esperar una política del ToolContext que la restrinja a operaciones SELECT únicamente o a consultar solo tablas específicas.19  
* **Características de Seguridad Incorporadas en Gemini:**  
  * Si se utilizan modelos Gemini, se deben aprovechar sus mecanismos de seguridad incorporados para la seguridad del contenido y de la marca.19  
  * **Filtros de seguridad de contenido:**  
    * Bloquean la salida de contenido dañino y actúan como una capa de defensa independiente contra intentos de "jailbreak".  
    * Filtros no configurables bloquean automáticamente contenido prohibido (ej. CSAM, PII).  
    * Filtros de contenido configurables permiten definir umbrales de bloqueo para discurso de odio, acoso, contenido sexualmente explícito y contenido peligroso, basados en puntuaciones de probabilidad y severidad. Están desactivados por defecto pero pueden configurarse.19  
  * **Instrucciones del sistema para la seguridad:**  
    * Proporcionar orientación directa al modelo Gemini sobre el comportamiento y la generación de contenido a través del prompt del sistema. Se pueden definir directrices de seguridad de contenido (temas prohibidos/sensibles, lenguaje de descargo de responsabilidad) y directrices de seguridad de marca (voz, tono, valores, audiencia objetivo).19  
  * Aunque robustos para la seguridad del contenido, estos requieren comprobaciones adicionales para el desajuste del agente, acciones inseguras y riesgos para la seguridad de la marca.19  
* **Callbacks de Modelo y Herramienta:**  
  * Cuando la modificación directa de herramientas para implementar guardrails no es posible o práctica, los callbacks before\_tool\_callback y before\_model\_callback pueden usarse para la validación previa de llamadas y entradas.19  
  * before\_tool\_callback tiene acceso al estado del agente, la herramienta solicitada y sus parámetros, permitiendo implementar políticas de herramientas reutilizables.19 (Ver Sección 7.6).  
  * before\_model\_callback puede inspeccionar la entrada del usuario antes de que llegue al LLM y bloquearla si es necesario.19 (Ver Sección 7.5).  
* **Uso de Gemini como Guardrail de Seguridad:**  
  * Se puede utilizar un LLM como Gemini (ej. Gemini Flash Lite por su rentabilidad y velocidad) a través de callbacks para implementar guardrails de seguridad robustos. Esto ayuda a mitigar riesgos de seguridad de contenido, desalineación del agente y seguridad de marca de entradas de usuario y herramientas inseguras.19  
  * **Cómo funciona:** La entrada del usuario, la entrada de la herramienta o la salida del agente se pasa a Gemini Flash Lite, que decide si es segura o insegura. Si es insegura, el agente bloquea la entrada/salida y proporciona una respuesta predefinida. El filtro se puede aplicar a entradas de usuario, entradas de herramientas o salidas de agentes, con instrucciones de sistema personalizables.19

### **10.3. Ejecución de Código en Sandbox**

La ejecución de código es una herramienta especialmente potente pero también con implicaciones de seguridad significativas. Es crucial que cualquier código generado por el modelo se ejecute en un entorno aislado (sandbox) para prevenir que comprometa el entorno local o del servidor.19

* **Opciones Ofrecidas por Google y ADK:**  
  * La característica de ejecución de código de la API empresarial de Vertex Gemini (tool\_execution) permite la ejecución de código en un sandbox del lado del servidor.19  
  * La herramienta preconstruida Code Executor en ADK puede llamar a la Vertex Code Interpreter Extension para la ejecución de código de análisis de datos.19  
* **Construcción Propia:** Si estas opciones no son suficientes, los desarrolladores pueden construir su propio ejecutor de código utilizando los bloques de construcción de ADK.  
* **Recomendaciones:** Es altamente recomendable crear entornos de ejecución herméticos (sin conexiones de red o llamadas a API salientes no controladas) para evitar la exfiltración de datos no controlada. También es importante asegurar una limpieza completa de los datos entre ejecuciones para prevenir preocupaciones de exfiltración de datos entre usuarios.19

### **10.4. Evaluación y Rastreo (Tracing)**

* Utilizar las herramientas de evaluación de ADK (ver Sección 11\) para valorar la calidad, relevancia y corrección de la salida final del agente.19  
* Utilizar el rastreo (tracing), facilitado por el sistema de Eventos (ver Sección 7.1), para obtener visibilidad de las acciones del agente, analizando los pasos tomados para alcanzar una solución, incluyendo las elecciones de herramientas, estrategias y eficiencia.19

### **10.5. Controles de Red y VPC-SC**

Ejecutar agentes dentro de un perímetro de VPC Service Controls (VPC-SC) en Google Cloud asegura que todas las llamadas a API realizadas por el agente manipulen recursos únicamente dentro de ese perímetro definido. Esto reduce significativamente la posibilidad de exfiltración de datos hacia ubicaciones no autorizadas.19 Si bien la identidad y los perímetros proporcionan controles generales, los guardrails de uso de herramientas son esenciales para un control más fino sobre las acciones permitidas por el agente.19

### **10.6. Otros Riesgos de Seguridad**

* **Siempre Escapar Contenido Generado por el Modelo en Interfaces de Usuario:**  
  * Cuando la salida de un agente se muestra en una interfaz de usuario web (navegador), es crítico escapar adecuadamente cualquier contenido HTML o JavaScript.  
  * Si no se escapa, el texto generado por el modelo podría ser interpretado y ejecutado como código por el navegador. Esto puede llevar a vulnerabilidades de Cross-Site Scripting (XSS) y potencial exfiltración de datos (ej. un tag \<img\> malicioso que envíe contenido de la sesión a un sitio de terceros, o URLs maliciosas).19  
  * Un escapado adecuado asegura que el texto generado por el modelo se trate solo como texto y no como código ejecutable.19

Antes de implementar medidas de seguridad, es crucial realizar una **evaluación de riesgos exhaustiva** específica para las capacidades del agente, su dominio de aplicación y el contexto de despliegue. Las fuentes de riesgo pueden incluir instrucciones de agente ambiguas, inyección de prompts y intentos de "jailbreak" por parte de usuarios adversarios, e inyecciones indirectas de prompts a través del uso de herramientas. Las categorías de riesgo incluyen desalineación y corrupción de objetivos, generación de contenido dañino (incluyendo riesgos para la seguridad de la marca) y ejecución de acciones inseguras.19

## **11\. Evaluación de Agentes en ADK**

Evaluar el rendimiento de los agentes basados en Modelos de Lenguaje Grandes (LLMs) presenta desafíos únicos debido a la naturaleza probabilística de estos modelos. Las pruebas tradicionales de "pasa/falla" a menudo no son suficientes. ADK, en cambio, promueve un marco de evaluación que se centra en valoraciones cualitativas tanto de la salida final del agente como de la trayectoria de ejecución que siguió para llegar a esa salida.27

### **11.1. Preparación para la Evaluación**

Antes de iniciar las evaluaciones, ADK recomienda definir claramente los objetivos y criterios de éxito 27:

* **Definir el Éxito:** ¿Qué constituye un resultado exitoso para el agente en el contexto de su tarea?  
* **Identificar Tareas Críticas:** ¿Cuáles son las tareas esenciales que el agente debe realizar correctamente?  
* **Elegir Métricas Relevantes:** ¿Qué métricas se rastrearán para medir el rendimiento de manera objetiva y subjetiva?

### **11.2. Componentes de la Evaluación en ADK**

La evaluación de agentes con ADK se divide en dos componentes principales 27:

1. **Evaluación de la Trayectoria y Uso de Herramientas:**  
   * Implica analizar la secuencia de pasos (la "trayectoria") que un agente toma para llegar a una solución. Esto incluye su elección de herramientas, las estrategias que emplea y la eficiencia de su enfoque.  
   * La trayectoria real del agente se compara con una trayectoria esperada o ideal, que representa la "verdad fundamental" (ground truth) para esa tarea.  
   * Esta comparación ayuda a revelar errores, ineficiencias o desviaciones en el proceso de razonamiento y acción del agente.  
   * ADK soporta varias evaluaciones de trayectoria basadas en la verdad fundamental:  
     * **Coincidencia Exacta (Exact match):** Requiere una correspondencia perfecta con la trayectoria ideal.  
     * **Coincidencia en Orden (In-order match):** Requiere las acciones correctas en el orden correcto, pero permite acciones adicionales.  
     * **Coincidencia en Cualquier Orden (Any-order match):** Requiere las acciones correctas en cualquier orden, permitiendo también acciones adicionales.  
     * **Precisión (Precision):** Mide la relevancia y corrección de las acciones predichas.  
     * **Exhaustividad (Recall):** Mide cuántas de las acciones esenciales son capturadas en la predicción.  
     * **Uso de Herramienta Única (Single-tool use):** Verifica la inclusión de una acción específica (uso de una herramienta particular).  
2. **Evaluación de la Respuesta Final:**  
   * Este componente evalúa la calidad, relevancia y corrección de la salida final que el agente proporciona al usuario.

### **11.3. Métodos de Evaluación en ADK**

ADK ofrece dos enfoques principales para evaluar el rendimiento de los agentes contra conjuntos de datos predefinidos y criterios de evaluación 27:

* **Primer Enfoque: Usando un Archivo de Prueba (.test.json)**:  
  * Este método implica crear archivos de prueba individuales, donde cada archivo representa una única interacción simple agente-modelo (una sesión).  
  * Es más efectivo durante el desarrollo activo del agente, funcionando como una forma de **prueba unitaria**.  
  * Estas pruebas están diseñadas para una ejecución rápida y se centran en una complejidad de sesión simple.  
  * Cada archivo de prueba contiene una única sesión, que puede consistir en múltiples turnos.  
  * Cada turno en el archivo de prueba incluye:  
    * User Content: La consulta o entrada del usuario.  
    * Expected Intermediate Tool Use Trajectory: Las llamadas a herramientas esperadas.  
    * Expected Intermediate Agent Responses: Respuestas en lenguaje natural esperadas del agente o sub-agentes.  
    * Final Response: La respuesta final esperada del agente.  
  * Los archivos de prueba deben tener el sufijo .test.json y están respaldados por los esquemas Pydantic EvalSet y EvalCase definidos en ADK (ej. google.adk.evaluation.eval\_set.py y google.adk.evaluation.eval\_case.py).  
  * Las carpetas que contienen archivos de prueba pueden incluir opcionalmente un archivo test\_config.json para especificar los criterios de evaluación.  
  * Los archivos de prueba existentes que no estén respaldados por el esquema Pydantic pueden migrarse utilizando AgentEvaluator.migrate\_eval\_data\_to\_new\_schema.  
* **Segundo Enfoque: Usando un Archivo Evalset**:  
  * Este enfoque utiliza un conjunto de datos dedicado llamado "evalset" para evaluar las interacciones agente-modelo.  
  * Un evalset puede contener múltiples sesiones, potencialmente largas y complejas, lo que lo hace ideal para simular conversaciones multi-turno y es adecuado para **pruebas de integración**.  
  * Estas pruebas suelen ejecutarse con menos frecuencia que las pruebas unitarias debido a su naturaleza más extensa.  
  * Cada "eval" dentro de un evalset representa una sesión distinta y consiste en uno o más "turnos", que incluyen la consulta del usuario, el uso esperado de herramientas, las respuestas intermedias esperadas del agente y una respuesta de referencia.  
  * Los archivos Evalset también están respaldados por los esquemas Pydantic EvalSet y EvalCase.  
  * ADK proporciona herramientas de UI (a través de adk web) para ayudar a capturar sesiones relevantes y convertirlas en "evals" dentro de un evalset.

### **11.4. Criterios de Evaluación**

Los criterios de evaluación definen cómo se mide el rendimiento del agente contra el evalset. ADK soporta las siguientes métricas 27:

* tool\_trajectory\_avg\_score: Compara el uso real de herramientas por parte del agente con el uso esperado de herramientas. Cada paso coincidente suma 1 punto, una discrepancia suma 0, y la puntuación final es el promedio, representando la precisión de la trayectoria de herramientas.  
* response\_match\_score: Compara la respuesta final en lenguaje natural del agente con la respuesta final esperada utilizando la métrica([https://es.wikipedia.org/wiki/ROUGE\_(m%C3%A9trica](https://es.wikipedia.org/wiki/ROUGE_\(m%C3%A9trica\))) para calcular la similitud.

Si no se proporcionan criterios, se utilizan valores predeterminados: tool\_trajectory\_avg\_score: 1.0 (se requiere una coincidencia del 100%) y response\_match\_score: 0.8 (permitiendo un pequeño margen de error en la similitud de la respuesta).27

### **11.5. Cómo Ejecutar la Evaluación con ADK**

Los desarrolladores pueden evaluar agentes utilizando ADK de tres maneras 27:

1. **Interfaz de Usuario Basada en Web (adk web)**:  
   * Proporciona una forma interactiva de evaluar agentes y generar conjuntos de datos de evaluación.  
   * Se inicia el servidor web con adk web \<RUTA\_A\_MUESTRAS\_O\_AGENTES\> (ej. adk web samples\_for\_testing).  
   * En la UI, se selecciona un agente, se interactúa con él para crear una sesión, y luego se utiliza la pestaña "Eval" para guardar la sesión como un caso de prueba en un evalset existente o nuevo.  
2. **Programáticamente (pytest)**:  
   * Permite integrar la evaluación en pipelines de prueba utilizando pytest y los archivos de prueba .test.json.  
   * Comando de ejemplo: pytest tests/integration/ (asumiendo que los tests están en esa carpeta).  
   * El código de prueba típicamente usaría AgentEvaluator.evaluate para ejecutar un único archivo de prueba.  
3. **Interfaz de Línea de Comandos (adk eval)**:  
   * Ejecuta evaluaciones sobre un archivo evalset existente directamente desde la línea de comandos, lo cual es útil para la automatización.

#### **Obras citadas**

1. google/adk-python: An open-source, code-first Python toolkit for building, evaluating, and deploying sophisticated AI agents with flexibility and control. \- GitHub, fecha de acceso: junio 4, 2025, [https://github.com/google/adk-python](https://github.com/google/adk-python)  
2. Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/](https://google.github.io/adk-docs/)  
3. google/adk-web: Agent Development Kit Web (adk web) is ... \- GitHub, fecha de acceso: junio 4, 2025, [https://github.com/google/adk-web](https://github.com/google/adk-web)  
4. What's new with Agents: ADK, Agent Engine, and A2A Enhancements, fecha de acceso: junio 4, 2025, [https://developers.googleblog.com/en/agents-adk-agent-engine-a2a-enhancements-google-io/](https://developers.googleblog.com/en/agents-adk-agent-engine-a2a-enhancements-google-io/)  
5. google-adk \- PyPI, fecha de acceso: junio 4, 2025, [https://pypi.org/project/google-adk/](https://pypi.org/project/google-adk/)  
6. Quickstart: Build an agent with the Agent Development Kit ..., fecha de acceso: junio 4, 2025, [https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit/quickstart](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit/quickstart)  
7. Comprehensive Guide to Building AI Agents Using Google Agent ..., fecha de acceso: junio 4, 2025, [https://www.firecrawl.dev/blog/google-adk-multi-agent-tutorial](https://www.firecrawl.dev/blog/google-adk-multi-agent-tutorial)  
8. Agents \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/agents/](https://google.github.io/adk-docs/agents/)  
9. Multi-agent systems \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/agents/multi-agents/](https://google.github.io/adk-docs/agents/multi-agents/)  
10. Develop an Agent Development Kit agent | Generative AI on Vertex AI \- Google Cloud, fecha de acceso: junio 4, 2025, [https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/develop/adk](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/develop/adk)  
11. Agent Team \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/tutorials/agent-team/](https://google.github.io/adk-docs/tutorials/agent-team/)  
12. ADK Tutorials\! \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/tutorials/](https://google.github.io/adk-docs/tutorials/)  
13. Exploring Google's Agent Development Kit \- GetStream.io, fecha de acceso: junio 4, 2025, [https://getstream.io/blog/exploring-google-adk/](https://getstream.io/blog/exploring-google-adk/)  
14. Google's Agent Stack in Action: ADK, A2A, MCP on Google Cloud, fecha de acceso: junio 4, 2025, [https://codelabs.developers.google.com/instavibe-adk-multi-agents/instructions](https://codelabs.developers.google.com/instavibe-adk-multi-agents/instructions)  
15. Custom agents \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/agents/custom-agents/](https://google.github.io/adk-docs/agents/custom-agents/)  
16. Agent Development Kit (ADK): A Guide With Demo Project | DataCamp, fecha de acceso: junio 4, 2025, [https://www.datacamp.com/tutorial/agent-development-kit-adk](https://www.datacamp.com/tutorial/agent-development-kit-adk)  
17. Tools \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/tools/](https://google.github.io/adk-docs/tools/)  
18. Support streaming response(AsyncGenerator) in non-bidi-streaming agents · Issue \#1099 · google/adk-python \- GitHub, fecha de acceso: junio 4, 2025, [https://github.com/google/adk-python/issues/1099](https://github.com/google/adk-python/issues/1099)  
19. Safety and Security \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/safety/](https://google.github.io/adk-docs/safety/)  
20. Retriever tools · google adk-python · Discussion \#365 \- GitHub, fecha de acceso: junio 4, 2025, [https://github.com/google/adk-python/discussions/365](https://github.com/google/adk-python/discussions/365)  
21. Model Context Protocol (MCP) \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/mcp/](https://google.github.io/adk-docs/mcp/)  
22. Context \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/context/](https://google.github.io/adk-docs/context/)  
23. Types of callbacks \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/callbacks/types-of-callbacks/](https://google.github.io/adk-docs/callbacks/types-of-callbacks/)  
24. Events \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/events/](https://google.github.io/adk-docs/events/)  
25. Manage sessions with Agent Development Kit | Generative AI on Vertex AI \- Google Cloud, fecha de acceso: junio 4, 2025, [https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/sessions/manage-sessions-adk](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/sessions/manage-sessions-adk)  
26. Artifacts \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/artifacts/](https://google.github.io/adk-docs/artifacts/)  
27. Why Evaluate Agents \- Agent Development Kit \- Google, fecha de acceso: junio 4, 2025, [https://google.github.io/adk-docs/evaluate/](https://google.github.io/adk-docs/evaluate/)