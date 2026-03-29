---
name: frontend-data-layer
description: Preenche a secao de Data Layer (06-data-layer.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Data Layer

Preenche `docs/frontend/shared/06-data-layer.md` com base no blueprint tecnico e no contexto do projeto. Este e um documento **compartilhado** entre todos os clientes (web, mobile, desktop).

## Leitura de Contexto

1. Leia `docs/blueprint/05-data-model.md` — modelo de dados e queries
2. Leia `docs/blueprint/06-system-architecture.md` — API e comunicacao
3. Leia `docs/blueprint/03-requirements.md` — requisitos nao-funcionais (latencia, cache)
4. Leia `docs/frontend/shared/06-data-layer.md` — template a preencher
5. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **API Client**: Qual a biblioteca e configuracao do client HTTP (interceptors, base URL, headers)?
- **Data Fetching**: Qual a estrategia de data fetching (SSR, SSG, CSR, ISR) e ferramentas utilizadas?
- **Contratos de API (DTOs)**: Como os contratos entre frontend e backend sao definidos e validados?
- **BFF**: Existe um Backend for Frontend? Qual seu escopo e responsabilidades?
- **Estrategia de Cache**: Como o cache de dados e gerenciado (stale-while-revalidate, TTL, invalidacao)?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/shared/06-data-layer.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Data Layer preenchido (compartilhado entre todos os clientes). Rode `/frontend-routes {client}` para preencher Rotas e Navegacao do cliente desejado."
