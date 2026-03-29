---
name: frontend-routes
description: Preenche a secao de Rotas (07-routes.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Rotas

Preenche `docs/frontend/{client}/07-routes.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/07-routes.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/08-use_cases.md` — casos de uso que mapeiam para telas
2. Leia `docs/blueprint/07-critical_flows.md` — fluxos criticos com navegacao
3. Leia `docs/frontend/{client}/07-routes.md` — template a preencher
4. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Estrutura de Rotas**: Quais paginas e rotas o sistema possui e como estao organizadas hierarquicamente?
- **Protecao de Rotas**: Quais rotas exigem autenticacao, autorizacao ou condicoes especiais de acesso?
- **Layouts Compartilhados**: Quais layouts sao reutilizados entre rotas e como a composicao de layouts funciona?
- **Navegacao**: Como o usuario navega entre as paginas, quais menus e breadcrumbs existem?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (URL-based App Router, file-based routing; Guards via middleware) | **mobile** (React Navigation com stacks, tabs e drawers; Deep linking via URL schemes e universal links) | **desktop** (Window-based navigation; Menu bar e system tray com context menu)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/07-routes.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Rotas preenchidas para {client}. Rode `/frontend-flows {client}` para preencher Fluxos de Interface."
