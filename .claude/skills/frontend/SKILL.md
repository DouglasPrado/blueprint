---
name: frontend
description: Orquestrador do frontend blueprint multi-client. Analisa cobertura e gera os docs compartilhados.
---

# Frontend — Orquestrador e Docs Compartilhados

Le o blueprint tecnico, define quais clientes documentar e gera os **docs compartilhados** entre eles. Depois orienta as skills por cliente.

O sistema suporta multiplos clientes (web, mobile, desktop) em monorepo. Cada cliente recebe 13 docs proprios; 3 docs sao compartilhados.

## Passo 1: Ler o Blueprint Tecnico

Leia `docs/blueprint/` como fonte primaria. Para esta skill importam especialmente:

- `00-context.md`, `01-vision.md`, `02-architecture_principles.md` — atores, problema, principios
- `03-requirements.md` — RNFs de latencia e cache
- `04-domain-model.md` — entidades que viram tipos e componentes
- `05-data-model.md` — modelo de dados e queries
- `06-system-architecture.md` — API, comunicacao e deploy
- `07-critical_flows.md`, `08-use_cases.md` — jornadas que viram telas

Se o blueprint estiver vazio, use `docs/prd.md` como fallback. Se nenhum existir:

> "Para iniciar o frontend blueprint, preciso do blueprint tecnico preenchido (`docs/blueprint/`). Voce pode:
> 1. Rodar `/blueprint` para preencher o blueprint tecnico primeiro
> 2. Passar o caminho do PRD como fallback: `/frontend docs/prd.md`
>
> Como prefere?"

## Passo 2: Deteccao de Estrutura Existente

Se existirem `.md` diretamente em `docs/frontend/` (sem subpasta), ofereca migracao:

> "Detectei documentos em formato flat em `docs/frontend/`. O sistema usa estrutura multi-client.
> Deseja migrar para `docs/frontend/web/`? Os compartilhados (design-system, data-layer, api-dependencies) irao para `docs/frontend/shared/`."

## Passo 3: Selecao de Clientes

> "Quais clientes frontend voce precisa documentar?
> 1. **Web** (Next.js / Remix / SPA)
> 2. **Mobile** (React Native / Expo)
> 3. **Desktop** (Electron / Tauri)
>
> Escolha um ou mais (ex: 1,2). Monorepo sera usado como padrao."

Estrutura de saida:

```
docs/frontend/
  shared/                     # esta skill + /frontend-design-system
    03-design-system.md
    06-data-layer.md
    15-api-dependencies.md

  {client}/                   # /frontend-app + /frontend-quality, por cliente
    00-frontend-vision.md   04-components.md   09-tests.md      13-cicd-conventions.md
    01-architecture.md      05-state.md        10-performance.md 14-copies.md
    02-project-structure.md 07-routes.md       11-security.md
                            08-flows.md        12-observability.md
```

## Passo 4: Analisar Cobertura

Classifique cada grupo como **Coberto** / **Parcial** / **Lacuna**:

| Grupo | Docs | Cobertura | Observacao |
|-------|------|-----------|------------|
| Compartilhados | 03, 06, 15 | ... | ... |
| App ({client}) | 00, 01, 02, 04, 05, 07, 08, 14 | ... | ... |
| Qualidade ({client}) | 09, 10, 11, 12, 13 | ... | ... |

Repita as duas ultimas linhas para cada cliente selecionado.

---

## Passo 5: Gerar os Docs Compartilhados (06 e 15)

### Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Perguntas: maximo 3 nesta skill inteira.**

### 06 — Data Layer (`docs/frontend/shared/06-data-layer.md`)

Preencha:
- **API Client**: biblioteca e configuracao do client HTTP (interceptors, base URL, headers)
- **Data Fetching**: estrategia (SSR, SSG, CSR, ISR) e ferramentas
- **Contratos de API (DTOs)**: como sao definidos e validados
- **BFF**: existe Backend for Frontend? Escopo e responsabilidades
- **Estrategia de Cache**: stale-while-revalidate, TTL, invalidacao

### 15 — Dependencias de API (`docs/frontend/shared/15-api-dependencies.md`)

Mapa de endpoints que o frontend consome. Derive de `08-use_cases.md` e `06-system-architecture.md`; se `docs/backend/05-api-contracts.md` existir, use-o como fonte autoritativa.

Preencha: endpoint, metodo, tela/feature consumidora, request, response, erros tratados e criticidade.

---

## Passo 6: Roadmap

```
COMPARTILHADOS (rodar uma vez):
1. /frontend                  → 06-data-layer, 15-api-dependencies  [feito nesta sessao]
2. /frontend-design-system    → 03-design-system

POR CLIENTE (rodar para cada cliente selecionado):
3. /frontend-app {client}     → 00, 01, 02, 04, 05, 07, 08, 14
4. /frontend-quality {client} → 09, 10, 11, 12, 13
```

**Recomendacao:** termine todos os docs de um cliente antes de passar ao proximo.

> "Docs compartilhados de dados prontos. Rode `/frontend-design-system` para definir tokens, tipografia, cores e iconografia — depois `/frontend-app web` (ou o cliente que preferir)."

## Nota sobre Monorepo

```
apps/       api/  web/  mobile/  desktop/
packages/   ui/  api-client/  config/  utils/  types/
```

`docs/frontend/shared/` documenta o que vive em `packages/`; `docs/frontend/{client}/` documenta o que vive em `apps/{client}/`.
