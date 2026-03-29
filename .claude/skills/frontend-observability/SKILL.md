---
name: frontend-observability
description: Preenche a secao de Observabilidade (12-observability.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Observabilidade

Preenche `docs/frontend/{client}/12-observability.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/12-observability.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/15-observability.md` — logs, metricas, traces, alertas
2. Leia `docs/frontend/{client}/12-observability.md` — template a preencher
3. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Error Tracking**: Como erros de frontend sao capturados, categorizados e reportados?
- **Logging Estruturado**: Qual a estrategia de logging no frontend e como logs sao enviados ao backend?
- **Metricas de API**: Como chamadas de API sao monitoradas (latencia, taxa de erro, volume)?
- **User Flow Monitoring**: Como fluxos criticos do usuario sao rastreados para detectar abandono ou falhas?
- **Feature Flags**: Como feature flags sao gerenciadas e como a observabilidade se integra com rollouts graduais?

Se houver lacunas criticas que NAO podem ser inferidas do PRD, faca ate 3 perguntas pontuais ao usuario antes de gerar.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Sentry para error tracking; Web Vitals RUM (Real User Monitoring)) | **mobile** (Sentry React Native para error tracking; Firebase Crashlytics para crash reporting) | **desktop** (Sentry Electron para error tracking; Crash reporting nativo do processo main)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/12-observability.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes do blueprint tecnico (fonte primaria)
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: 15-observability.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Observabilidade preenchida para {client}. Rode `/frontend-cicd {client}` para preencher CI/CD e Convencoes."
