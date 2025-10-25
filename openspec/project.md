# Project: Pizzabotnew

## Overview
Chatbot con inteligencia artificial para una pizzería.  
Permite tomar pedidos, validar datos del cliente y enviar el pedido al backend.

## Tech Stack
- Node.js 20+
- LangChain o ADK Agent (según versión actual)
- Express / Fastify (para endpoints)
- Base de datos: Supabase o SQLite (para pruebas)
- Integración futura: WhatsApp API o webchat

## Structure
- `/src/` → lógica del bot e intents
- `/routes/` → endpoints HTTP
- `/db/` → persistencia de pedidos
- `/openspec/` → especificaciones de desarrollo (esta carpeta)

## Conventions
- Código TypeScript / JavaScript con estilo estándar
- Branches: `main`, `dev`
- Commits: Conventional Commits (`feat:`, `fix:`, `refactor:`)
- Deploy: Render / Vercel

## Goals
- Implementar flujo completo de pedido (nombre → tamaño → toppings → pago → confirmación)
- Mantener conversación natural y validaciones robustas

## Non-Goals
- Integración de pago real
- Delivery por mapa (futuro)