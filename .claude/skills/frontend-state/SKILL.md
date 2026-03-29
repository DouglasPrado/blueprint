---
name: frontend-state
description: Preenche a secao de Gerenciamento de Estado (05-state.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Gerenciamento de Estado

Preenche `docs/frontend/{client}/05-state.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/05-state.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/09-state-models.md` — maquinas de estado das entidades
2. Leia `docs/blueprint/04-domain-model.md` — entidades e regras
3. Leia `docs/frontend/{client}/05-state.md` — template a preencher
4. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Tipos de Estado**: Quais categorias de estado existem (local, global, server, URL, form)?
- **Server State**: Como o estado vindo do servidor e gerenciado (caching, revalidacao, optimistic updates)?
- **Global State**: Qual a estrategia para estado global (store, context, signals) e quando utiliza-lo?
- **Event Bus**: Existe comunicacao entre componentes via eventos? Qual o padrao adotado?
- **Anti-patterns**: Quais praticas de gerenciamento de estado devem ser evitadas no projeto?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (SSR hydration: sincronizacao de estado entre servidor e cliente; URL state via searchParams, shallow routing) | **mobile** (Persistencia entre background/foreground (AppState listener); Ciclo de vida do app: cold start, warm start, resume) | **desktop** (Sincronizacao main↔renderer via IPC (invoke/handle); Estado persistido em disco (electron-store, tauri fs))

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/05-state.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Gerenciamento de Estado preenchido para {client}. Rode `/frontend-data-layer {client}` para preencher Data Layer."
