---
name: frontend-tests
description: Preenche a secao de Estrategia de Testes (09-tests.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Estrategia de Testes

Preenche `docs/frontend/{client}/09-tests.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/09-tests.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/12-testing_strategy.md` — piramide e cobertura do sistema
2. Leia `docs/blueprint/03-requirements.md` — requisitos para criterios de aceite
3. Leia `docs/frontend/{client}/09-tests.md` — template a preencher
4. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Piramide de Testes**: Qual a proporcao ideal entre testes unitarios, de integracao e e2e para este projeto?
- **Padroes por Tipo de Componente**: Quais padroes de teste se aplicam a cada tipo de componente (paginas, formularios, hooks, servicos)?
- **Cobertura e Metas**: Quais metas de cobertura sao adequadas e quais areas criticas exigem cobertura obrigatoria?
- **Integracao com CI**: Como os testes se integram ao pipeline de CI/CD e quais gates de qualidade existem?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Playwright para testes E2E; Testing Library para testes de componentes) | **mobile** (Detox ou Maestro para testes E2E; React Native Testing Library para testes de componentes) | **desktop** (Playwright + Electron para testes E2E; Testes de IPC handlers (main <-> renderer))

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/09-tests.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Estrategia de Testes preenchida para {client}. Rode `/frontend-performance {client}` para preencher Performance."
