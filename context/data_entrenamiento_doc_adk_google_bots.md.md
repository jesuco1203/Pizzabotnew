print(f"\n\n--- Testing State: Temp Unit Conversion & output_key ---")

# 1. Check weather (Uses initial state: Celsius)
print("--- Turn 1: Requesting weather in London (expect Celsius) ---")

await call_agent_async(query =  "What's the weather in London?",
runner=runner_root_stateful,
user_id=USER_ID_STATEFUL,
session_id=SESSION_ID_STATEFUL
)

# 2. Manually update state preference to Fahrenheit - DIRECTLY MODIFY STORAGE
print("\n--- Manually Updating State: Setting unit to Fahrenheit ---")
try:
# Access the internal storage directly - THIS IS SPECIFIC TO InMemorySessionService for testing
# NOTE: In real applications, state changes are typically triggered by tools or agent logic returning EventActions(state_delta=...), not direct manual updates.
stored_session = session_service_stateful.sessions[APP_NAME][USER_ID_STATEFUL][SESSION_ID_STATEFUL]
stored_session.state["user_preference_temperature_unit"] = "Fahrenheit"