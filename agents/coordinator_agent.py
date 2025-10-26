from google.adk.agents import BaseAgent, Agent
from google.adk.agents.invocation_context import InvocationContext
from google.genai.types import Content, Part
from google.adk.events import Event, EventActions
from google.genai.types import Content, Part

# Importar agentes especializados
from agents.menu_agent import menu_agent
from agents.order_agent import order_agent
from agents.greeting_agent import greeting_agent
from agents.user_management_agent import UserManagementAgent
from agents.confirmation_agent import confirmation_agent
from agents.address_agent import address_agent
from agents.finalization_agent import finalization_agent
from tools.size_validation_tool import valid_sizes
from app.utils import extract_person_name
from app.menu import find_item, size_options, normalize_size, detect_size, item_price, get_item

# Definición de las fases conversacionales
class ConversationPhase:
    SALUDO = "SALUDO"
    TOMANDO_PEDIDO = "TOMANDO_PEDIDO"
    CONFIRMANDO_PEDIDO = "CONFIRMANDO_PEDIDO"
    RECOGIENDO_DIRECCION = "RECOGIENDO_DIRECCION"
    PAGO = "PAGO"
    FINALIZACION = "FINALIZACION"

class CoordinatorAgent(BaseAgent):

    @staticmethod
    def _size_guard(bot_text: str, state: dict):
        if not state.get("pending_size"):
            return False, None
        text = (bot_text or "").lower()
        options = state.get("pending_size_options") or ["grande", "familiar"]
        if not any(opt.lower() in text for opt in options):
            opts = ", ".join(options)
            return True, f"Antes de continuar, nos falta el tamaño. Opciones válidas: {opts}. ¿Cuál prefieres?"
        return False, None

    @staticmethod
    def _add_item_to_order(state: dict, item_id: str, item_info: dict, size: str) -> None:
        order = state.setdefault("current_order", {"items": [], "total": 0.0})
        price = item_price(item_info, size) or 0.0
        order.setdefault("items", []).append({
            "id": item_id,
            "name": item_info.get("Nombre_Base"),
            "quantity": 1,
            "size": size,
            "price": price,
        })
        order["total"] = round(order.get("total", 0.0) + price, 2)

    def _analyze_intention(self, message: str, ctx: InvocationContext) -> str:
        """Analiza la intención del mensaje del usuario para delegar correctamente.
        Esta función es una simplificación y debería ser manejada por un IntentClassifierAgent
        o un LLM más robusto en un entorno de producción.
        """
        message_lower = message.lower()
        current_phase = ctx.session.state.get("conversation_phase", ConversationPhase.SALUDO)

        # Priorizar la fase actual de la conversación
        if current_phase == ConversationPhase.SALUDO:
            # Si estamos en la fase de saludo y esperando nombre, cualquier entrada es para UserManagementAgent
            if ctx.session.state.get("awaiting_user_name"):
                return "customer_registration"
            # Si no, es una conversación general o un intento de iniciar pedido/menú
            if any(keyword in message_lower for keyword in ["hola", "saludos", "hi", "buenas"]):
                return "general_conversation"
            return "initial_inquiry" # Para cualquier otra cosa en la fase de saludo

        elif current_phase == ConversationPhase.TOMANDO_PEDIDO:
            # Si hay un ítem pendiente de clarificación, la intención es de orden
            if ctx.session.state.get("item_to_clarify"):
                return "order_action"
            # Palabras clave para finalizar pedido
            finalize_order_keywords = ["es todo", "terminar pedido", "finalizar pedido", "listo con mi pedido", "confirmar mi pedido"]
            if any(keyword in message_lower for keyword in finalize_order_keywords):
                return "finalize_order"
            # Palabras clave para consultas de menú
            menu_query_categories = ['menú', 'carta', 'platos', 'bebidas', 'postres', 'tienes', 'mostrar', 'que hay', 'opciones', 'pizas', 'lasañas']
            if any(keyword in message_lower for keyword in menu_query_categories):
                return "menu_query"
            # Por defecto, si estamos tomando pedido, cualquier otra cosa es una acción de pedido
            return "order_action"

        elif current_phase == ConversationPhase.CONFIRMANDO_PEDIDO:
            # En esta fase, esperamos confirmación o modificación
            confirmation_keywords = ["sí", "si", "confirmo", "adelante", "ok", "vale", "correcto", "es correcto"]
            modification_keywords = ["modificar", "cambiar", "quitar", "agregar", "añadir", "no es correcto"]
            if any(keyword in message_lower for keyword in confirmation_keywords):
                return "confirm_order"
            if any(keyword in message_lower for keyword in modification_keywords):
                return "modify_order"
            return "clarification_needed" # Si no es confirmación ni modificación

        elif current_phase == ConversationPhase.RECOGIENDO_DIRECCION:
            # En esta fase, cualquier entrada es para el AddressAgent
            return "delivery_info"

        elif current_phase == ConversationPhase.FINALIZACION:
            # En esta fase, el bot ya debería estar despidiéndose o esperando un nuevo inicio
            return "general_conversation"

        # Fallback para intenciones generales si no hay fase específica
        return "general_conversation"

    async def _run_async_impl(self, ctx: InvocationContext):
        print(f"DEBUG: CoordinatorAgent: Iniciando _run_async_impl para el turno. Fase actual: {ctx.session.state.get('conversation_phase', 'N/A')}")
        # Buscar la instancia de UserManagementAgent entre los sub_agents
        user_management_agent_instance = None
        confirmation_agent_instance = None
        order_agent_instance = None
        menu_agent_instance = None
        address_agent_instance = None
        finalization_agent_instance = None

        for agent in self.sub_agents:
            if agent.name == "UserManagementAgent":
                user_management_agent_instance = agent
            elif agent.name == "ConfirmationAgent":
                confirmation_agent_instance = agent
            elif agent.name == "OrderAgent":
                order_agent_instance = agent
            elif agent.name == "MenuAgent":
                menu_agent_instance = agent
            elif agent.name == "AddressAgent":
                address_agent_instance = agent
            elif agent.name == "FinalizationAgent":
                finalization_agent_instance = agent
        
        if not user_management_agent_instance:
            raise ValueError("UserManagementAgent no encontrado en la lista de sub_agents.")
        if not confirmation_agent_instance:
            raise ValueError("ConfirmationAgent no encontrado en la lista de sub_agents.")
        if not order_agent_instance:
            raise ValueError("OrderAgent no encontrado en la lista de sub_agents.")
        if not menu_agent_instance:
            raise ValueError("MenuAgent no encontrado en la lista de sub_agents.")
        if not address_agent_instance:
            raise ValueError("AddressAgent no encontrado en la lista de sub_agents.")
        if not finalization_agent_instance:
            raise ValueError("FinalizationAgent no encontrado en la lista de sub_agents.")

        # Initial user message text capture (only once per turn)
        user_message_text = ""
        if ctx.user_content and ctx.user_content.parts:
            for part in ctx.user_content.parts:
                if part.text:
                    user_message_text += part.text
        print(f"DEBUG: CoordinatorAgent: Mensaje de usuario: {user_message_text}")

        # Persistir el último mensaje del usuario en el estado
        delta_latest = {"latest_user_text": (user_message_text or "").strip()}
        await ctx.session_service.append_event(
            ctx.session,
            Event(author=self.name, actions=EventActions(state_delta=delta_latest))
        )
        ctx.session.state.update(delta_latest)

        while True: # Loop to re-evaluate phase in the same turn
            current_phase = ctx.session.state.get("conversation_phase", ConversationPhase.SALUDO)
            print(f"DEBUG: CoordinatorAgent: Evaluando fase: {current_phase}")

            if ctx.session.state.get("pending_size"):
                options = ctx.session.state.get("pending_size_options") or ["grande", "familiar"]
                message_tokens = user_message_text.lower()
                size_candidate = detect_size(user_message_text)
                pending_item_id = ctx.session.state.get("pending_item_id")
                if size_candidate and pending_item_id:
                    item_info = get_item(pending_item_id)
                    if item_info:
                        canonical = normalize_size(size_candidate) or options[0]
                        if canonical not in options and options:
                            canonical = options[0]
                        self._add_item_to_order(ctx.session.state, pending_item_id, item_info, canonical)
                        delta = {
                            "pending_size": False,
                            "pending_item_id": None,
                            "pending_item_name": None,
                            "last_redirect_note": None,
                            "pending_size_options": options,
                            "current_order": ctx.session.state["current_order"],
                        }
                        ctx.session.state.update(delta)
                        yield Event(
                            invocation_id=ctx.invocation_id,
                            author=self.name,
                            actions=EventActions(state_delta=delta),
                            content=Content(parts=[Part(text=f"Perfecto, agregué una {item_info['Nombre_Base']} {canonical}. ¿Algo más?")])
                        )
                        break
                elif not any(opt.lower() in message_tokens for opt in options):
                    opts = ", ".join(options)
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        content=Content(parts=[Part(text=f"Antes de continuar, nos falta el tamaño. Opciones válidas: {opts}. ¿Cuál prefieres?")])
                    )
                    break

            if current_phase == ConversationPhase.SALUDO:
                print("DEBUG: CoordinatorAgent: Delegando a UserManagementAgent.")
                intention = self._analyze_intention(user_message_text, ctx)
                if intention == "name_captured":
                    name = extract_person_name(user_message_text) or ctx.session.state.get("user_name")
                    delta = {
                        "user_identified": True,
                        "user_name": name,
                        "awaiting_user_name": False,
                        "user_checked_db": True,
                        "conversation_phase": ConversationPhase.TOMANDO_PEDIDO,
                    }
                    ctx.session.state.update(delta)
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta=delta),
                        content=Content(parts=[Part(text=f"Hola {name}, ¿en qué puedo ayudarte hoy?")])
                    )
                    break
                else:
                    async for event in user_management_agent_instance.run_async(ctx):
                        yield event

                if ctx.session.state.get("user_identified"):
                    print("DEBUG: CoordinatorAgent: Usuario identificado. Transicionando a TOMANDO_PEDIDO.")
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.TOMANDO_PEDIDO
                        }),
                        content=Content(parts=[Part(text="")])
                    )
                    break
                else:
                    print("DEBUG: CoordinatorAgent: Usuario no identificado. Permaneciendo en SALUDO.")
                    break

            elif current_phase == ConversationPhase.TOMANDO_PEDIDO:
                print("DEBUG: CoordinatorAgent: En fase TOMANDO_PEDIDO.")
                # Lógica para la fase TOMANDO_PEDIDO
                # Primero, verificar si el usuario quiere finalizar el pedido con la nueva intención específica.
                intention = self._analyze_intention(user_message_text, ctx)
                print(f"DEBUG: CoordinatorAgent: Intención detectada en TOMANDO_PEDIDO: {intention}")

                # Manejo determinista del producto/tamaño
                match = find_item(user_message_text)
                detected_size = detect_size(user_message_text)
                if match:
                    item_id, info = match
                    options = size_options(info)
                    if detected_size:
                        canonical = normalize_size(detected_size) or options[0]
                        if canonical not in options:
                            canonical = options[0]
                        self._add_item_to_order(ctx.session.state, item_id, info, canonical)
                        delta = {
                            "pending_size": False,
                            "pending_item_id": None,
                            "pending_item_name": None,
                            "pending_size_options": options,
                            "current_order": ctx.session.state["current_order"],
                        }
                        ctx.session.state.update(delta)
                        yield Event(
                            invocation_id=ctx.invocation_id,
                            author=self.name,
                            actions=EventActions(state_delta=delta),
                            content=Content(parts=[Part(text=f"Perfecto, agregué una {info['Nombre_Base']} {canonical}. ¿Algo más?")])
                        )
                        continue
                    else:
                        from tools.size_validation_tool import valid_sizes
                        options = valid_sizes() or ["grande","familiar"]
                        delta = {
                            "pending_item_id": item_id,
                            "pending_item_name": info.get("Nombre_Base"),
                            "pending_size": True,
                            "pending_size_options": options,
                        }
                        await ctx.session_service.append_event(
                            ctx.session,
                            Event(author=self.name, actions=EventActions(state_delta=delta))
                        )
                        ctx.session.state.update(delta)
                        yield Event(
                            invocation_id=ctx.invocation_id,
                            author=self.name,
                            actions=EventActions(state_delta=delta),
                            content=Content(parts=[Part(text=f"¿Qué tamaño prefieres para la {info['Nombre_Base']}? Opciones: {', '.join(opt.title() for opt in options)}")])
                        )
                        continue

                if intention == "finalize_order":
                    print("DEBUG: CoordinatorAgent: Intención finalize_order. Transicionando a CONFIRMANDO_PEDIDO.")
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.CONFIRMANDO_PEDIDO
                        })
                    )
                    continue  # Re-evaluar en la nueva fase de confirmación

                # Si no es finalizar, analizar la intención para delegar.
                else:
                    if intention == "menu_query":
                        print("DEBUG: CoordinatorAgent: Delegando a MenuAgent.")
                        async for event in menu_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "order_action":
                        print("DEBUG: CoordinatorAgent: Delegando a OrderAgent.")
                        if not ctx.session.state.get("pending_size"):
                            if not any(
                                keyword in user_message_text.lower()
                                for keyword in valid_sizes()
                            ):
                                ctx.session.state.setdefault("pending_size_options", valid_sizes())
                                ctx.session.state["pending_size"] = True
                                ctx.session.state.setdefault("pending_item", None)
                        async for event in order_agent_instance.run_async(ctx):
                            if event.content and getattr(event.content, "parts", None):
                                text = " ".join(
                                    getattr(part, "text", "") or ""
                                    for part in event.content.parts
                                ).strip()
                                blocked, guard_text = self._size_guard(text, ctx.session.state)
                                if blocked:
                                    text = guard_text
                                    event.content = Content(parts=[Part(text=text)])
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "general_conversation":
                        print("DEBUG: CoordinatorAgent: Delegando a GreetingAgent (general_conversation).")
                        async for event in greeting_agent.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    elif intention == "customer_registration": # NUEVA LÓGICA: Delegar a UserManagementAgent
                        print("DEBUG: CoordinatorAgent: Delegando a UserManagementAgent (customer_registration).")
                        async for event in user_management_agent_instance.run_async(ctx):
                            yield event
                        break # Esperar la siguiente entrada del usuario
                    else:
                        # Si la intención no es clara, delegar al OrderAgent por defecto o dar un mensaje genérico
                        print("DEBUG: CoordinatorAgent: Intención no clara, delegando a OrderAgent por defecto.")
                        if not ctx.session.state.get("pending_size"):
                            ctx.session.state.setdefault("pending_size_options", valid_sizes())
                            ctx.session.state["pending_size"] = True
                        
                        async for event in order_agent_instance.run_async(ctx):
                            if event.content and getattr(event.content, "parts", None):
                                text = " ".join(
                                    getattr(part, "text", "") or ""
                                    for part in event.content.parts
                                ).strip()
                                blocked, guard_text = self._size_guard(text, ctx.session.state)
                                if blocked:
                                    text = guard_text
                                    event.content = Content(parts=[Part(text=text)])
                            yield event
                        break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.CONFIRMANDO_PEDIDO:
                print("DEBUG: CoordinatorAgent: En fase CONFIRMANDO_PEDIDO. Delegando a ConfirmationAgent.")
                # Delegar al ConfirmationAgent
                async for event in confirmation_agent_instance.run_async(ctx):
                    # Interceptar la respuesta del ConfirmationAgent para interpretar los prefijos
                    if event.is_final_response() and event.content and event.content.parts:
                        response_text = event.content.parts[0].text
                        print(f"DEBUG: CoordinatorAgent: Respuesta de ConfirmationAgent: {response_text[:50]}...")
                        if response_text.startswith("PEDIDO_CONFIRMADO:"):
                            print("DEBUG: CoordinatorAgent: Pedido confirmado. Transicionando a RECOGIENDO_DIRECCION.")
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("PEDIDO_CONFIRMADO:", "").strip())]),
                                actions=EventActions(state_delta={
                                    "order_confirmed": True,
                                    "summary_presented": False, # Reset para futuras confirmaciones
                                    "conversation_phase": ConversationPhase.RECOGIENDO_DIRECCION # Transición de fase
                                })
                            )
                            return # Terminar el turno del Coordinator
                        elif response_text.startswith("SOLICITUD_MODIFICACION:"):
                            print("DEBUG: CoordinatorAgent: Solicitud de modificación. Transicionando a TOMANDO_PEDIDO.")
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("SOLICITUD_MODIFICACION:", "").strip())]),
                                actions=EventActions(state_delta={
                                    "modification_requested": True,
                                    "summary_presented": False, # Reset
                                    "conversation_phase": ConversationPhase.TOMANDO_PEDIDO # Transición de fase
                                })
                            )
                            return # Terminar el turno del Coordinator
                        elif response_text.startswith("RESUMEN_PRESENTADO:"):
                            print("DEBUG: CoordinatorAgent: Resumen presentado. Actualizando estado.")
                            # Solo actualizar el estado, no cambiar de fase
                            yield Event(
                                invocation_id=ctx.invocation_id,
                                author=self.name,
                                content=Content(parts=[Part(text=response_text.replace("RESUMEN_PRESENTADO:", "").strip())]),
                                actions=EventActions(state_delta={"summary_presented": True})
                            )
                            return # Terminar el turno del Coordinator
                    yield event # Re-yield cualquier otro evento del ConfirmationAgent
                break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.RECOGIENDO_DIRECCION:
                print("DEBUG: CoordinatorAgent: En fase RECOGIENDO_DIRECCION. Delegando a AddressAgent.")
                async for event in address_agent_instance.run_async(ctx):
                    yield event
                
                # Después de que AddressAgent se ejecute, verificar si la dirección fue recolectada
                if ctx.session.state.get("address_collected"):
                    print("DEBUG: CoordinatorAgent: Dirección recolectada. Transicionando a FINALIZACION.")
                    yield Event(
                        invocation_id=ctx.invocation_id,
                        author=self.name,
                        actions=EventActions(state_delta={
                            "conversation_phase": ConversationPhase.FINALIZACION
                        })
                    )
                    continue # Re-evaluar en la nueva fase
                else:
                    print("DEBUG: CoordinatorAgent: Dirección no recolectada. Permaneciendo en RECOGIENDO_DIRECCION.")
                    break # Esperar la siguiente entrada del usuario

            elif current_phase == ConversationPhase.FINALIZACION:
                print("DEBUG: CoordinatorAgent: En fase FINALIZACION. Delegando a FinalizationAgent.")
                async for event in finalization_agent_instance.run_async(ctx):
                    yield event
                print("DEBUG: CoordinatorAgent: Finalización completada. Terminando el turno.")
                # La conversación termina después de la despedida del agente finalizador.
                break

            # ... other phases will be added here ...
            # If no phase matches or a phase completes without a transition, break the loop
            else: # This 'else' corresponds to the 'if current_phase == ...' chain
                print(f"DEBUG: CoordinatorAgent: Fase desconocida o sin transición: {current_phase}")
                yield Event(
                    invocation_id=ctx.invocation_id,
                    author=self.name,
                    content=Content(parts=[Part(text="Lo siento, no entiendo esa fase de la conversación.")])
                )
                break # Break the while loop, wait for next user input

# Instancia del coordinador
user_management_agent_instance = UserManagementAgent()

# Instancia del coordinador
coordinator_agent = CoordinatorAgent(
    name="PizzabotCoordinator",
    description="Orquesta el flujo conversacional del Pizzabot.",
    sub_agents=[menu_agent, order_agent, user_management_agent_instance, confirmation_agent, address_agent, finalization_agent]
)
