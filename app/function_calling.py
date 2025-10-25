import inspect
from typing import Any, Dict, List, Tuple


async def handle_model_parts(
    parts: List[Any],
    session_state: Dict[str, Any],
    tool_registry: Dict[str, Any],
) -> Tuple[str, Dict[str, Any]]:
    texts: List[str] = []
    new_state: Dict[str, Any] = {}

    for part in parts or []:
        part_type = getattr(part, "type", None) or getattr(part, "mime_type", None) or ""
        if part_type == "function_call":
            name = getattr(part, "name", None)
            args = getattr(part, "args", {}) or {}
            tool = tool_registry.get(name)
            if not tool:
                continue

            callable_tool = tool
            if hasattr(tool, "run") and callable(getattr(tool, "run")):
                callable_tool = tool.run

            try:
                if inspect.iscoroutinefunction(callable_tool):
                    result = await callable_tool(**args)
                else:
                    result = callable_tool(**args)
            except TypeError:
                # fallback si la firma no coincide
                result = callable_tool(**args)

            if isinstance(result, dict):
                delta = result.get("state_delta")
                if isinstance(delta, dict):
                    new_state.update(delta)
                tool_text = result.get("text")
                if tool_text:
                    texts.append(str(tool_text))
        elif hasattr(part, "text"):
            texts.append(getattr(part, "text", "") or "")

    reply = " ".join(t for t in texts if t).strip()
    return reply, new_state
