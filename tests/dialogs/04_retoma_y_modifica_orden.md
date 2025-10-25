# Escenario: Retomar y modificar
- user: "muéstrame mi pedido"
- expect_say_contains: "tu pedido actual"
- user: "agrega una hawaiana familiar"
- expect_state_contains: { "current_order": { "items_count": ">=2" } }
- user: "quita la pepperoni"
- expect_state_contains: { "current_order": { "items_count": 1 } }
- user: "es todo"
- expect_stage: CONFIRMANDO_PEDIDO
