# Escenario: Usuario existente en clientes.json
# Precondición: Insertar usuario "Ana" en clientes.json antes del test
- user: "hola"
- expect_state: { "user_identified": true, "user_name": "Ana" }
- expect_say_contains: "REGEX:ana"
- expect_stage: GREETING|MENU|TOMANDO_PEDIDO
