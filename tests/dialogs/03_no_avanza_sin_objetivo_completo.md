# Escenario: No avanzar de fase sin completar objetivo
- user: "quiero una margarita"
- expect_stage: TOMANDO_PEDIDO
- expect_requires: size

- user: "¿cuál es el horario?"
- expect_stage: TOMANDO_PEDIDO
- bot_should: recordar_falta_size

- user: "mediana"
- expect_state_contains: { "current_order": { "items_count": ">=1" } }
- expect_stage: TOMANDO_PEDIDO
