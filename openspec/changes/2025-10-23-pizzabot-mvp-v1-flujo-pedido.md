# Pizzabot MVP v1 — Flujo completo de pedido

## Contexto
El proyecto actual es un chatbot de pizzería (Pizzabotnew) que puede responder preguntas básicas, pero aún no maneja el flujo completo de pedidos.

## Objetivo
Diseñar e implementar un flujo conversacional end-to-end para realizar pedidos de pizza, desde la toma del nombre hasta la confirmación final.

## Flujo del pedido
1. Capturar nombre y teléfono del cliente  
2. Solicitar tamaño (personal, mediana, grande)  
3. Solicitar tipo de masa (tradicional, delgada, pan)  
4. Seleccionar toppings (máx. 6)  
5. Elegir método de entrega: delivery o recojo  
   - Si delivery → pedir dirección  
6. Elegir método de pago: efectivo o online (placeholder)  
7. Mostrar resumen y confirmar pedido  
8. Guardar pedido en base de datos (`orders`)

## Persistencia
- Tabla `orders`: `id`, `created_at`, `customer_name`, `phone`, `size`, `crust`, `toppings`, `fulfillment`, `address`, `payment_method`, `status`

## Endpoints
- `POST /api/orders` — crea pedido  
- `GET /api/orders/:id` — consulta pedido

## Criterios de Aceptación
- Se completa todo el flujo de conversación sin errores.  
- Los pedidos se guardan correctamente en la tabla `orders`.  
- El bot responde con un resumen claro y un ID de pedido.  

## Futuro
- Integración con WhatsApp y pagos reales.