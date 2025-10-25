# Escenario: Usuario nuevo, no da nombre al inicio
- user: "hola, ¿tienen promociones?"
- expect_stage: REGISTRO_USUARIO|SALUDO
- expect_requires: user_name
- bot_should: insistir_nombre

- user: "tengo hambre"
- expect_stage: REGISTRO_USUARIO|SALUDO
- expect_requires: user_name
- bot_should: reformular_pidiendo_nombre

- user: "me llamo Carlos"
- expect_state: { "user_identified": true }
- expect_say_contains: "REGEX:.*carlos.*"

- user: "quiero una pepperoni mediana"
- expect_stage: TOMANDO_PEDIDO
