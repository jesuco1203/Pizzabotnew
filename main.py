import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict


OFFLINE_MODE = os.getenv("OFFLINE_MODE", "0").lower() in {"1", "true", "yes", "on"}

DEFAULT_APP_NAME = os.getenv("PIZZABOT_APP_NAME", "pizzabot_cli")
DEFAULT_USER_ID = os.getenv("PIZZABOT_USER_ID", "cli_user")
DEFAULT_SESSION_ID = os.getenv("PIZZABOT_SESSION_ID", "cli_session")

CLIENTS_FILE = Path("data/clientes.json")


if OFFLINE_MODE:
    from offline_simulator import get_session_state, reset_session, run_turn, cli_entry  # noqa: F401
else:
    from google.adk.runners import Runner
    from google.adk.sessions import InMemorySessionService
    from google.genai.types import Content, Part

    from agents.coordinator_agent import coordinator_agent, ConversationPhase

    _session_service = InMemorySessionService()
    _runner = Runner(
        agent=coordinator_agent,
        app_name=DEFAULT_APP_NAME,
        session_service=_session_service,
    )

    def _lookup_client_name(user_id: str) -> str | None:
        try:
            data = json.loads(CLIENTS_FILE.read_text(encoding="utf-8"))
        except (FileNotFoundError, json.JSONDecodeError):
            return None

        if isinstance(data, dict):
            entry = data.get(user_id)
            if isinstance(entry, dict):
                return entry.get("name")
        elif isinstance(data, list):
            for entry in data:
                if isinstance(entry, dict) and str(entry.get("id")) == user_id:
                    return entry.get("name")
        return None

    def _build_initial_state(user_id: str) -> Dict[str, Any]:
        if user_id == "u_luis":
            return {
                "conversation_phase": ConversationPhase.TOMANDO_PEDIDO,
                "user_checked_db": True,
                "awaiting_user_name": False,
                "user_identified": True,
                "user_name": "Luis",
                "current_order": {"items": [], "total": 0.0},
                "item_to_clarify": None,
                "pending_size": False,
                "pending_item": None,
                "order_confirmed": False,
                "summary_presented": False,
                "address_collected": False,
                "delivery_address": None,
            }

        if user_id == "u_carlos":
            return {
                "conversation_phase": ConversationPhase.TOMANDO_PEDIDO,
                "user_checked_db": True,
                "awaiting_user_name": False,
                "user_identified": True,
                "user_name": "Carlos",
                "current_order": {
                    "items": [
                        {
                            "id": "pepperoni-mediana",
                            "name": "Pizza Pepperoni",
                            "quantity": 1,
                            "size": "mediana",
                            "price": 22.0,
                        }
                    ],
                    "total": 22.0,
                },
                "item_to_clarify": None,
                "pending_size": False,
                "pending_item": None,
                "order_confirmed": False,
                "summary_presented": False,
                "address_collected": False,
                "delivery_address": None,
            }

        name = _lookup_client_name(user_id)
        identified = bool(name)
        return {
            "conversation_phase": ConversationPhase.SALUDO,
            "user_checked_db": bool(name),
            "awaiting_user_name": not identified,
            "user_identified": identified,
            "user_name": name,
            "current_order": {"items": [], "total": 0.0},
            "item_to_clarify": None,
            "pending_size": False,
            "pending_item": None,
            "order_confirmed": False,
            "summary_presented": False,
            "address_collected": False,
            "delivery_address": None,
        }

    async def _run_async_turn(
        user_input: str,
        *,
        user_id: str = DEFAULT_USER_ID,
        session_id: str = DEFAULT_SESSION_ID,
    ) -> str:
        session = await _session_service.get_session(
            app_name=DEFAULT_APP_NAME,
            user_id=user_id,
            session_id=session_id,
        )
        if not session:
            initial_state = _build_initial_state(user_id)
            await _session_service.create_session(
                app_name=DEFAULT_APP_NAME,
                user_id=user_id,
                session_id=session_id,
                state=initial_state,
            )
            session = await _session_service.get_session(
                app_name=DEFAULT_APP_NAME,
                user_id=user_id,
                session_id=session_id,
            )

        if session:
            state = session.state
            state.setdefault("conversation_phase", ConversationPhase.SALUDO)
            if name := _lookup_client_name(user_id):
                state.setdefault("user_checked_db", True)
                state.setdefault("user_identified", True)
                state.setdefault("awaiting_user_name", False)
                state.setdefault("user_name", name)
            else:
                state.setdefault("user_checked_db", False)
                state.setdefault("awaiting_user_name", True)
                state.setdefault("user_identified", False)
                state.setdefault("user_name", None)
            state.setdefault("current_order", {"items": [], "total": 0.0})
            state.setdefault("item_to_clarify", None)
            state.setdefault("pending_size", False)
            state.setdefault("pending_item", None)
            state.setdefault("order_confirmed", False)
            state.setdefault("summary_presented", False)
            state.setdefault("address_collected", False)
            state.setdefault("delivery_address", None)

        content = Content(role="user", parts=[Part(text=user_input)])
        final_text = ""
        last_non_empty = ""

        async for event in _runner.run_async(
            user_id=user_id,
            session_id=session_id,
            new_message=content,
        ):
            if event.content and event.content.parts:
                text = event.content.parts[0].text or ""
                if text.strip():
                    last_non_empty = text
                if event.is_final_response():
                    final_text = text
            elif event.is_final_response():
                # No textual content; fall back to last non-empty snippet
                final_text = last_non_empty

        return final_text or last_non_empty or "No pude generar una respuesta."

    def run_turn(
        user_input: str,
        *,
        user_id: str = DEFAULT_USER_ID,
        session_id: str = DEFAULT_SESSION_ID,
    ) -> str:
        """Synchronous helper to run a single turn with the coordinator agent."""
        return asyncio.run(
            _run_async_turn(user_input, user_id=user_id, session_id=session_id)
        )

    def get_session_state(
        *,
        user_id: str = DEFAULT_USER_ID,
        session_id: str = DEFAULT_SESSION_ID,
    ) -> Dict[str, Any]:
        """Expose the current session state (primarily for debugging)."""
        async def _get() -> Dict[str, Any]:
            session = await _session_service.get_session(
                app_name=DEFAULT_APP_NAME,
                user_id=user_id,
                session_id=session_id,
            )
            return session.state if session else {}

        return asyncio.run(_get())

    def reset_session(
        *,
        user_id: str = DEFAULT_USER_ID,
        session_id: str = DEFAULT_SESSION_ID,
    ) -> None:
        """Clear the current session so a new conversation can start cleanly."""
        async def _reset() -> None:
            session = await _session_service.get_session(
                app_name=DEFAULT_APP_NAME,
                user_id=user_id,
                session_id=session_id,
            )
            if session:
                await _session_service.delete_session(
                    app_name=DEFAULT_APP_NAME,
                    user_id=user_id,
                    session_id=session_id,
                )

        asyncio.run(_reset())

    def cli_entry(session_id: str, user_input: str) -> None:
        reset_session(session_id=session_id)
        response = run_turn(user_input, session_id=session_id)
        print(response)


def main():
    if len(sys.argv) <= 2:
        print("Uso: python main.py <session_id> <mensaje>")
        return

    session_id = sys.argv[1]
    user_input = sys.argv[2]

    if OFFLINE_MODE:
        cli_entry(session_id, user_input)
    else:
        response = run_turn(user_input, session_id=session_id)
        print(response)


if __name__ == "__main__":
    main()
