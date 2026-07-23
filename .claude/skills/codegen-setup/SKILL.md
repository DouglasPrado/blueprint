---
name: codegen-setup
description: Setup inicial do codegen (roda 1x) — gera CLAUDE.md router, tipos compartilhados, schema e scaffold.
---

# Codegen — Setup Inicial

Roda **uma vez** por projeto. Produz duas coisas no projeto-alvo:

1. **`CLAUDE.md` router** — diz ao Claude Code quais docs ler para cada tipo de tarefa
2. **Shared kernel** — `src/contracts/`, schema do banco e scaffold de diretorios

**Por que e critico:** tudo que vem depois importa destes contratos. Com os tipos corretos, cada sessao futura gera codigo tipado sem reler o domain model inteiro.

## Pre-requisitos

- `docs/blueprint/` preenchido (no minimo 04-domain-model, 05-data-model, 06-system-architecture)
- `docs/backend/` gerado

## Passo 1: Projeto-Alvo

Se o usuario nao passou o caminho como argumento:

> "Qual o caminho do projeto-alvo onde o codigo sera gerado? (ex: `../meu-saas/`)"

## Passo 2: Leitura de Contexto

**Leia completos** (essenciais):

| Doc | Extrair |
|-----|---------|
| `blueprint/02-architecture_principles.md` | Patterns (Clean Architecture, DDD, Hexagonal), convencoes |
| `blueprint/04-domain-model.md` | Entidades, atributos, enums, regras, relacionamentos, glossario |
| `blueprint/05-data-model.md` | Tabelas, campos, tipos, constraints, indices, migrations |
| `blueprint/06-system-architecture.md` | Stack, componentes, protocolos |
| `backend/00-backend-vision.md` | Stack e padroes do backend |
| `backend/01-architecture.md` | Camadas e regras de dependencia |
| `backend/02-project-structure.md` | Arvore de diretorios do backend |
| `backend/03-domain.md` | Value objects, domain events, metodos |
| `backend/04-data-layer.md` | Repositories, ORM, migrations |
| `shared/glossary.md` | Linguagem ubiqua e nomenclatura |

**Leia apenas os headers** dos demais docs (Bash + `grep '^#'`) para montar o mapa `doc → secoes preenchidas`. Nao carregue conteudo completo do que nao esta na tabela acima.

Se algum doc passar de 50k tokens, use **Context Excerpting**: grep pelos headers, carregue so as secoes de entidades, tabelas e stack.

> **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Passo 3: Identificar Clientes Frontend

Verifique quais existem **com docs preenchidos** (nao apenas templates):

```
docs/frontend/shared/    → design system, data layer, API deps
docs/frontend/web/       docs/frontend/mobile/       docs/frontend/desktop/
```

Para cada cliente ativo, leia `docs/frontend/{client}/02-project-structure.md` e `docs/frontend/shared/03-design-system.md`.

## Passo 4: Confirmar

> "Vou gerar o setup com base nos blueprints:
>
> **Stack:** {{stack resumida}}
> **Entidades:** {{lista}}
> **Banco:** {{tecnologia}} com {{N}} tabelas
> **Principios:** {{patterns}}
> **Clientes frontend:** {{apenas os existentes}}
>
> Confirma? Ou quer ajustar antes de gerar?"

Aguarde confirmacao.

---

## Passo 5: Gerar o CLAUDE.md Router

Use `docs/templates/claudemd-template.md` como base se existir. Caso contrario:

```markdown
# {{Nome do Projeto}}

## Fonte de Verdade

Todo codigo DEVE implementar fielmente o que esta nos blueprints.

**Docs:** `docs/blueprint/` (O QUE) → `docs/backend/` (COMO backend) → `docs/frontend/` (COMO frontend: `shared/` + por cliente) → `docs/shared/` (glossario, mappings)

**Regras:** (1) Leia os docs relevantes antes de codar. (2) Use a linguagem ubiqua de `docs/shared/glossary.md`. (3) Leia `src/contracts/` antes de implementar. (4) Test-first (RED→GREEN→REFACTOR). (5) Use `docs/shared/MAPPING.md` para rastreabilidade.

## Stack
{{tabela compacta de backend/00-backend-vision + blueprint/06-system-architecture}}

## Clientes Frontend
{{clientes ativos com a stack de cada um}}

## Convencoes
- **Nomenclatura:** entidades PascalCase, campos camelCase — conforme `docs/shared/glossary.md`
- **Rotas API:** {{padrao}}
- **Arquivos:** {{padrao}}
- **Principios:** {{1 linha por principio de 02-architecture_principles.md}}
- **Camadas backend:** {{regras de dependencia de backend/01-architecture.md}}

## Antes de Codar
Leia apenas o necessario. `/codegen-feature` guia a selecao de docs por tipo de feature.
Sempre leia: `src/contracts/` (tipos) + `{{schema}}` (DB, quando relevante).
```

Salve em `{{projeto-alvo}}/CLAUDE.md`.

---

## Passo 6: Gerar o Scaffold

A estrutura **deve** seguir `backend/02-project-structure.md` e `frontend/{client}/02-project-structure.md`.

### 6.1 Configuracao
`package.json` (ou equivalente) com as dependencias da stack, `tsconfig.json`, `.env.example`, `.gitignore` e config de lint/format conforme o blueprint.

### 6.2 Tipos Compartilhados (`src/contracts/`)

```
src/contracts/
├── entities/     # um arquivo por entidade + index.ts
├── enums/        # enums do domain model + index.ts
├── api/          # request/response types por recurso + index.ts
└── index.ts
```

Regras:
- Entidades em **PascalCase**, campos em **camelCase** (conforme glossario)
- Enums: tipo em PascalCase, valores em SCREAMING_SNAKE_CASE
- Cada tipo com JSDoc contendo a descricao do domain model
- IDs como branded types quando a linguagem permitir
- Relacionamentos referenciam os tipos das entidades relacionadas

### 6.3 Schema do Banco

Baseado em `blueprint/05-data-model.md` + `backend/04-data-layer.md`. Formato conforme a stack: `prisma/schema.prisma`, `src/db/schema.ts` (Drizzle), entities com decorators (TypeORM) ou equivalente.

Deve incluir: todas as tabelas, campos com tipos corretos, constraints (unique, not null, default), foreign keys, indices do data model e enums do banco.

### 6.4 Diretorios

Crie a arvore de `backend/02-project-structure.md` com arquivos `index` vazios para: services/use cases, repositories, controllers/rotas e middlewares. Repita para cada cliente frontend ativo conforme seu `02-project-structure.md`.

### 6.5 Testes

Setup do test runner conforme `backend/14-tests.md` e `blueprint/12-testing_strategy.md`: arquivo de configuracao + helper/factory de fixtures baseadas nas entidades.

## Passo 7: Validar

Rode **type check**, **lint** e **validacao de schema** (ex: `prisma validate`). Corrija os erros antes de prosseguir — nao entregue scaffold que nao compila.

## Passo 8: Apresentar

> "Setup concluido.
>
> - `CLAUDE.md` router em `{{caminho}}`
> - **{{N}} tipos** de entidades em `src/contracts/entities/`
> - **{{N}} enums** em `src/contracts/enums/`
> - **{{N}} tipos de API** em `src/contracts/api/`
> - **Schema** com {{N}} tabelas em `{{caminho}}`
> - **Backend** com {{N}} diretorios conforme `backend/02-project-structure.md`
> - **Frontend** ({{clientes}}) com {{N}} diretorios cada
> - Type check, lint e schema: {{resultado}}
>
> Os contratos sao a fonte de verdade tipada — toda feature futura importa de `src/contracts/`.
>
> Commit sugerido: `feat: project scaffold and shared contracts (setup inicial)`
>
> Rode `/codegen` para ver as entregas do build plan, ou `/codegen-feature [nome]` para a primeira feature."
