---
name: frontend-performance
description: Preenche a secao de Performance (10-performance.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Performance

Preenche `docs/frontend/{client}/10-performance.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/10-performance.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/14-scalability.md` — estrategias de cache e escala
2. Leia `docs/blueprint/03-requirements.md` — requisitos nao-funcionais (latencia, throughput)
3. Leia `docs/frontend/{client}/10-performance.md` — template a preencher
4. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Estrategias de Otimizacao**: Quais tecnicas de otimizacao (code splitting, lazy loading, tree shaking, caching) sao aplicaveis ao projeto?
- **Core Web Vitals**: Quais sao as metas para LCP, FID/INP e CLS e como serao alcancadas?
- **Budget de Performance**: Qual o tamanho maximo aceitavel para bundles, tempo de carregamento e numero de requests?
- **Monitoramento**: Como a performance sera monitorada em producao e quais alertas serao configurados?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Core Web Vitals: LCP, INP, CLS como metricas primarias; Code splitting e lazy loading de rotas) | **mobile** (App startup time (cold start e warm start); Frame rate alvo de 60fps) | **desktop** (Startup time da aplicacao; Uso de memoria (main process + renderer))

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/10-performance.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Performance preenchida para {client}. Rode `/frontend-security {client}` para preencher Seguranca."
