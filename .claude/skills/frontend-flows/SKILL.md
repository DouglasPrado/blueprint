---
name: frontend-flows
description: Preenche a secao de Fluxos de Interface (08-flows.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Fluxos de Interface

Preenche `docs/frontend/{client}/08-flows.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/08-flows.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/07-critical_flows.md` — fluxos criticos do sistema
2. Leia `docs/blueprint/08-use_cases.md` — casos de uso
3. Leia `docs/blueprint/09-state-models.md` — transicoes de estado
4. Leia `docs/frontend/{client}/08-flows.md` — template a preencher
5. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Fluxos Criticos (3-5 fluxos com passos e tratamento de erros)**: Quais sao os fluxos principais do usuario, seus passos detalhados e como erros sao tratados em cada etapa?
- **Microfrontends (quando aplicavel)**: O sistema utiliza microfrontends? Se sim, como os fluxos se distribuem entre eles?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Page transitions, forms e modals; Navegacao baseada em URL e browser history) | **mobile** (Gesture-based interactions (swipe, pull-to-refresh, swipe actions); Haptic feedback em acoes criticas) | **desktop** (Drag-and-drop de arquivos; Keyboard shortcuts para acoes frequentes)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/08-flows.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Fluxos de Interface preenchidos para {client}. Rode `/frontend-tests {client}` para preencher Estrategia de Testes."
