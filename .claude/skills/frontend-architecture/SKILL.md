---
name: frontend-architecture
description: Preenche a secao de Arquitetura (01-architecture.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Arquitetura do Frontend

Preenche `docs/frontend/{client}/01-architecture.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/01-architecture.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/06-system-architecture.md` — componentes, comunicacao, deploy
2. Leia `docs/blueprint/02-architecture_principles.md` — principios
3. Leia `docs/blueprint/10-architecture_decisions.md` — ADRs
4. Leia `docs/frontend/{client}/01-architecture.md` — template a preencher
5. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Camadas Arquiteturais**: Quais camadas compõem o frontend (presentation, application, domain, infrastructure)?
- **Regras de Dependencia**: Quais regras governam as dependencias entre camadas e modulos?
- **Fronteiras de Dominio**: Como os dominios de negocio se refletem na organizacao do frontend?
- **Diagrama de Arquitetura**: Qual a visao geral da arquitetura e como os componentes se conectam?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Camadas SSR/SSG, React Server Components, API routes; Middleware de autenticacao e redirecionamento no edge) | **mobile** (Bridge para modulos nativos (camera, GPS, biometria); Arquitetura de navegacao (stack, tab, drawer)) | **desktop** (Processo main vs renderer (Electron) ou core vs webview (Tauri); IPC (Inter-Process Communication) entre processos)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/01-architecture.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Arquitetura preenchida para {client}. Rode `/frontend-structure {client}` para preencher Estrutura do Projeto."
