---
name: frontend-structure
description: Preenche a secao de Estrutura do Projeto (02-project-structure.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Estrutura do Projeto

Preenche `docs/frontend/{client}/02-project-structure.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/02-project-structure.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/06-system-architecture.md` — componentes e deploy
2. Leia `docs/frontend/{client}/01-architecture.md` — arquitetura do frontend (ja preenchida)
3. Leia `docs/frontend/{client}/02-project-structure.md` — template a preencher
4. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Estrutura de Pastas**: Qual a organizacao de diretorios do projeto e onde ficam os principais artefatos?
- **Organizacao por Feature**: Como as features sao isoladas e organizadas dentro da estrutura?
- **Monorepo**: O projeto utiliza monorepo? Se sim, qual a estrategia de workspaces e compartilhamento?
- **Regras de Importacao**: Quais convencoes e restricoes de importacao entre modulos devem ser seguidas?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Estrutura app/ router (Next.js) ou routes/ (Remix); Diretorio public/, middleware, API routes) | **mobile** (Expo Router com app/ ou estrutura screens/ tradicional; Diretorio assets/, navegacao, componentes nativos) | **desktop** (Separacao main/ (processo principal) e renderer/ (UI); Diretorio ipc/ para comunicacao entre processos)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/02-project-structure.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Estrutura do Projeto preenchida para {client}. Rode `/frontend-design-system {client}` para preencher Design System."
