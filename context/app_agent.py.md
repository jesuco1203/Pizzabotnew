<!-- path: app/agent.py -->
```python
from app.tools_menu import get_menu
from app.tools_order import quote_order
from app.memory import get_session, save_session
from app.state import OrderState, Item

class Agent:
    def __init__(self, session_id: str):
        self.session_id = session_id
        self.state = OrderState(**get_session(session_id))

    def __del__(self):
        save_session(self.session_id, self.state.__dict__)

    def _log_step(self, tool_name, tool_input, tool_output):
        # To be implemented
        print(f"Tool: {tool_name}, Input: {tool_input}, Output: {tool_output}")

    def run(self, user_input: str):
        """Runs the agent.

        Args:
            user_input: The user's input.

        Returns:
            The agent's response.
        """
        if self.state.stage is None:
            self.state.stage = "greeting"
            return "Hello! I'm Pizzabot. What can I get for you today?"

        if self.state.stage == "greeting":
            # This is a very simple NLU, we will improve it later
            if "menu" in user_input.lower():
                menu = get_menu()
                self._log_step("get_menu", {}, menu)
                return f"Here is our menu: {menu}"
            else:
                # Assume the user is ordering something
                # This is a very simple implementation, we will improve it later
                # For now, we assume the user says something like "a pepperoni pizza size large"
                parts = user_input.lower().split()
                try:
                    size_index = parts.index("size")
                    size = parts[size_index + 1]
                    name = " ".join(parts[:size_index-1])
                    name = name.replace("a ", "").replace("an ", "")
                    item = Item(name=name, size=size)
                    self.state.items.append(item)
                    self.state.stage = "collecting_address"
                    return f"I've added a {size} {name} to your order. What is your address zone?"
                except ValueError:
                    return "I'm sorry, I didn't understand. Please specify the size of the pizza."

        if self.state.stage == "collecting_address":
            self.state.zone = user_input
            quote = quote_order(self.state.items, self.state.zone)
            self.state.total = quote.total
            self.state.stage = "confirmation"
            self._log_step("quote_order", {"items": self.state.items, "zone": self.state.zone}, quote)
            return f"""Here is a breakdown of your order:
Subtotal: ${quote.subtotal:.2f}
Delivery Fee: ${quote.delivery_fee:.2f}
Discount: ${quote.discount:.2f}
Total: ${quote.total:.2f}
ETA: {quote.eta_min} minutes

Does that sound right?"""

        if self.state.stage == "confirmation":
            if "yes" in user_input.lower():
                from app.tools_order import place_order
                order_result = place_order(self.state.__dict__)
                self._log_step("place_order", {"order": self.state.__dict__}, order_result)
                if order_result["status"] == "created":
                    return f"Great! Your order has been placed. Your order ID is {order_result['order_id']}."
                else:
                    return f"It looks like you already placed this order. Your order ID is {order_result['order_id']}."
            else:
                self.state.stage = "greeting"
                self.state.items = []
                return "I've cancelled your order. What would you like to do?"

        return "I'm sorry, I don't know how to handle that yet."
```