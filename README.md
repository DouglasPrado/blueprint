# Blueprint Framework

Framework de documentacao tecnica para projetos de software. Templates estruturados + skills do Claude Code que documentam um produto de ponta a ponta — do contexto do sistema a arquitetura de frontend — e depois geram codigo fiel a essa documentacao.

**3 blueprints** | **52 documentos** | **19 skills**

---

## O que e

Um conjunto de templates Markdown com placeholders (`{{...}}`) e skills do Claude Code que preenchem cada secao a partir do PRD do seu projeto.

| Blueprint | Foco | Docs | Skills |
|-----------|------|------|--------|
| **Tecnico** | Contexto, dominio, dados, arquitetura, seguranca | 17 | 7 |
| **Backend** | Classes, servicos, API, eventos, integracoes, testes | 15 | 1 |
| **Frontend** | Design system, componentes, estado, rotas, performance | 3 + 13/cliente | 4 |

Mais 7 skills de apoio: incremento, patch global, backlog de tasks e geracao de codigo.

Cada skill gera um **grupo de documentos** numa unica passada — le o contexto uma vez e escreve tudo que deriva dele. E isso que mantem o processo curto.

---

## Pre-requisitos

1. **Claude Code** instalado
2. **PRD do projeto** — sera salvo em `docs/prd.md`
3. **MCP Context7** — usado pelas skills para consultar versoes atualizadas de tecnologias:
   ```json
   {
     "mcpServers": {
       "context7": {
         "command": "npx",
         "args": ["-y", "@upstreamapi/context7-mcp@latest"]
       }
     }
   }
   ```

---

## Quick Start

```
/blueprint                    # salva o PRD, analisa cobertura, mostra o roadmap
/blueprint-foundation         # 00, 01, 02, 03
/blueprint-domain             # 04, 05, 09
/blueprint-architecture       # 06, 10
/blueprint-flows              # 07, 08
/blueprint-quality            # 12, 13, 14, 15
/blueprint-plan               # 11, 16
```

Seis comandos e o blueprint tecnico esta completo. Depois:

```
/backend                      # 15 docs de especificacao de implementacao
/frontend                     # orquestrador + docs compartilhados
/frontend-design-system       # tokens, tipografia, cores, iconografia
/frontend-app web             # 8 docs do cliente
/frontend-quality web         # 5 docs do cliente
```

---

## Fluxo

```
PRD (docs/prd.md)
  │
  ▼
/blueprint  ──►  docs/blueprint/     17 docs   ← fonte primaria
  │
  ├──►  /backend   ──►  docs/backend/    15 docs
  ├──►  /frontend  ──►  docs/frontend/   3 shared + 13 por cliente
  └──►                  docs/shared/     4 docs transversais

Depois:
  /increment   → adicionar feature ou corrigir sem reescrever
  /patch       → propagar mudanca global (renomear entidade, trocar tecnologia)
  /specs       → gerar backlog integral de tasks
  /codegen     → gerar codigo a partir dos blueprints (XP/TDD)
```

A ordem importa: cada fase le o que a anterior produziu.

---

## 1. Blueprint Tecnico (`docs/blueprint/`)

Inicio: `/blueprint`

| Skill | Docs gerados | Conteudo |
|-------|--------------|----------|
| `/blueprint-foundation` | `00-context`, `01-vision`, `02-architecture_principles`, `03-requirements` | Atores, limites, problema, metricas, principios, requisitos MoSCoW |
| `/blueprint-domain` | `04-domain-model`, `05-data-model`, `09-state-models` | Glossario ubiquo, entidades, regras, tabelas, indices, maquinas de estado |
| `/blueprint-architecture` | `06-system-architecture`, `10-architecture_decisions` | Componentes, comunicacao, infra, ADRs |
| `/blueprint-flows` | `07-critical_flows`, `08-use_cases` | 3-5 fluxos criticos, casos de uso UC-XXX |
| `/blueprint-quality` | `12-testing_strategy`, `13-security`, `14-scalability`, `15-observability` | Piramide de testes, STRIDE, OWASP, cache, rate limit, Golden Signals |
| `/blueprint-plan` | `11-build_plan`, `16-evolution` | Entregas ENT-XXX, riscos, roadmap tecnico, tech debt |

O agrupamento segue as dependencias reais: `05` e `09` sao projecoes de `04`; ADR escrito longe da arquitetura vira generico; os 4 atributos de qualidade leem a mesma base (`06` + `07`).

---

## 2. Backend Blueprint (`docs/backend/`)

Inicio: `/backend` — le o blueprint tecnico e gera os 15 docs numa passada.

```
00-backend-vision      Stack, padrao, principios, metricas
01-architecture        Camadas, Clean Architecture, DI
02-project-structure   Pastas, modulos, convencoes
03-domain              Entidades, Value Objects, Aggregates
04-data-layer          Repositories, migrations, queries
05-api-contracts       Endpoints, DTOs, status codes, OpenAPI
06-services            Application services, use cases
07-controllers         Controllers, handlers, routing
08-middlewares         Auth, logging, rate limiting
09-errors              Hierarquia de excecoes, catalogo
10-validation          Regras por campo, sanitizacao
11-permissions         RBAC, policies, guards
12-events              Domain events, workers, filas, DLQ
13-integrations        Clients externos, circuit breaker, canais de comunicacao
14-tests               Piramide, cenarios, CI
```

O blueprint tecnico e a fonte primaria — `/backend` so pergunta o que ele nao cobre (framework, ORM, estrutura de classes, metodos).

**Canais de comunicacao** (email, SMS, WhatsApp) vivem em `13-integrations.md`: provedores, catalogo de templates, variaveis, prioridade entre canais, rate limits e convencoes por canal. Cada template e disparado por um evento declarado em `12-events.md`.

---

## 3. Frontend Blueprint (`docs/frontend/`)

Multi-client em monorepo. Inicio: `/frontend`

```
docs/frontend/
  shared/                          # gerados uma vez
    03-design-system.md            /frontend-design-system
    06-data-layer.md               /frontend
    15-api-dependencies.md         /frontend

  {web|mobile|desktop}/            # gerados por cliente
    00-frontend-vision.md          ┐
    01-architecture.md             │
    02-project-structure.md        │
    04-components.md               ├─ /frontend-app {client}
    05-state.md                    │
    07-routes.md                   │
    08-flows.md                    │
    14-copies.md                   ┘
    09-tests.md                    ┐
    10-performance.md              │
    11-security.md                 ├─ /frontend-quality {client}
    12-observability.md            │
    13-cicd-conventions.md         ┘
```

Cada skill adapta o conteudo a plataforma: `web` (Next.js/Remix, CSP, Core Web Vitals), `mobile` (Expo/React Native, Keychain, cold start), `desktop` (Electron/Tauri, IPC, code signing).

`/frontend-design-system` e a unica skill de secao unica — escolhe o par de fontes (Fontpair), a paleta (Coolors → CSS variables oklch) e a iconografia (Lucide Animated + shadcn/ui).

---

## 4. Documentacao Compartilhada (`docs/shared/`)

| Documento | Descricao |
|-----------|-----------|
| `MAPPING.md` | Rastreabilidade blueprint ↔ backend ↔ frontend |
| `glossary.md` | Glossario unificado do projeto |
| `error-ux-mapping.md` | Erro do backend → UX do frontend |
| `event-mapping.md` | Eventos entre camadas |

---

## Atualizacoes Incrementais (`/increment`)

Uma skill para os tres blueprints. Nunca sobrescreve — sempre `Edit`.

```
/increment
> alvo: blueprint | backend | frontend | all
> "Sistema de chat em tempo real"
→ adiciona entidades, eventos, componentes, estado e rotas nos docs corretos
```

Quatro tipos de alteracao:

| Tipo | Exemplo | Comportamento |
|------|---------|---------------|
| **Adicao** | "Sistema de chat em tempo real" | Insere antes de `<!-- APPEND:... -->`, marca `<!-- adicionado: ... -->` |
| **Correcao** | "campo `email` deve ser `emailAddress`" | Edit cirurgico na linha, marca `<!-- corrigido: ... -->` |
| **Atualizacao** | "plano Pro de R$99 para R$129" | Atualiza todas as ocorrencias |
| **Remocao** | "remover push notifications do escopo" | `~~strikethrough~~` com motivo |

Cada template tem marcadores `<!-- APPEND:section-id -->` como ancora de insercao:

```markdown
| Button | variant, size | primary, secondary |
| Input | type, placeholder | text, password |
<!-- APPEND:primitivos -->
```

O conteudo novo entra **antes** do marcador, preservando tudo que ja existe.

---

## Patch Global (`/patch`)

Para mudancas que atravessam varios blueprints ao mesmo tempo:

```
/patch
> "Renomear entidade Booking para Appointment"
```

1. **Varredura** global (Grep em blueprint, backend, frontend, shared, adr, specs)
2. **Analise de impacto** — direta, contextual ou indireta
3. **Confirmacao** — tabela com todos os arquivos afetados
4. **Aplica** respeitando case (PascalCase, camelCase, kebab-case, paths)
5. **Relatorio** — indiretas ficam marcadas com `<!-- PATCH-REVIEW -->`

| Caso | Comando |
|------|---------|
| Renomear entidade | `/patch` → "Booking → Appointment" |
| Atualizar endpoint | `/patch` → "/api/users → /api/v2/users" |
| Mudar tecnologia | `/patch` → "Zustand → Jotai" |
| Atualizar versao | `/patch` → "Next.js 16 → Next.js 17" |

`/increment` adiciona; `/patch` renomeia em cascata.

---

## Specs — Backlog Integral (`/specs`)

Gera `docs/specs/TASKS.md` com **todas** as tasks de implementacao de uma vez, a partir de `docs/backend/` (fonte primaria), validando contra frontend e blueprint.

Tasks organizadas em 12 grupos:

| Grupo | Prefixo | Fonte |
|-------|---------|-------|
| Setup & Infra | TASK-SETUP | 00-vision, 01-architecture, 02-structure |
| Domain | TASK-DOM | 03-domain (1 por entidade) |
| Data Layer | TASK-DATA | 04-data-layer (1 por repository + migrations) |
| Services | TASK-SVC | 06-services |
| API & Controllers | TASK-API | 05-api-contracts, 07-controllers, 10-validation |
| Auth & Permissions | TASK-AUTH | 11-permissions, 08-middlewares |
| Error Handling | TASK-ERR | 09-errors |
| Middlewares | TASK-MW | 08-middlewares |
| Events & Workers | TASK-EVT | 12-events |
| Integrations | TASK-INT | 13-integrations |
| Tests | TASK-TEST | 14-tests |
| Frontend Sync | TASK-FE | Cross-reference backend ↔ frontend |

Cada task inclui camada, entidade, prioridade, origem, arquivos a criar, dependencias, regras de negocio, criterios de aceite e testes.

Ao final valida contra o blueprint: cada RF tem task? cada fluxo critico tem service + E2E? cada UC tem endpoint + controller + service? cada ameaca STRIDE tem mitigacao?

---

## Code Generation (`/codegen`)

Gera codigo fiel a documentacao seguindo **Extreme Programming** (TDD, small releases).

```
/codegen-setup            → CLAUDE.md router + tipos + schema + scaffold  (uma vez)
       ↓
/codegen                  → apresenta entregas do build plan              (inicio de sessao)
       ↓
/codegen-feature [nome]   → implementa feature vertical (RED→GREEN→REFACTOR)
       ↓        ↑
       ↓   (repete por feature)
       ↓
/codegen-verify           → verifica aderencia ao blueprint               (a cada 3-5 features)
```

### Estrategia de contexto

Blueprints preenchidos ultrapassam 2M tokens — nao cabem em nenhum contexto. A solucao:

1. **CLAUDE.md Router** — tabela que mapeia tipo de tarefa → 2-3 docs relevantes
2. **Context Excerpting** — carrega so as secoes relevantes (grep por headers)
3. **Contracts as Cache** — `src/contracts/` e o "cache compilado" do domain model
4. **Budget por sessao** — ~70-100k tokens de contexto, deixando o resto para geracao

### Templates (6)

`docs/templates/`: `claudemd-template.md`, `prd-template.md`, `epic-template.md`, `story-template.md`, `task-template.md`, `use-case-template.md`

---

## Referencia Rapida — 19 Skills

### Blueprint Tecnico (7)

| Comando | Docs |
|---------|------|
| `/blueprint` | Orquestrador — PRD, cobertura, roadmap |
| `/blueprint-foundation` | 00, 01, 02, 03 |
| `/blueprint-domain` | 04, 05, 09 |
| `/blueprint-architecture` | 06, 10 |
| `/blueprint-flows` | 07, 08 |
| `/blueprint-quality` | 12, 13, 14, 15 |
| `/blueprint-plan` | 11, 16 |

### Backend (1)

| Comando | Docs |
|---------|------|
| `/backend` | 00 a 14 (15 docs) |

### Frontend (4)

| Comando | Docs |
|---------|------|
| `/frontend` | Orquestrador + `shared/06`, `shared/15` |
| `/frontend-design-system` | `shared/03` |
| `/frontend-app {client}` | 00, 01, 02, 04, 05, 07, 08, 14 |
| `/frontend-quality {client}` | 09, 10, 11, 12, 13 |

### Manutencao e Backlog (3)

| Comando | Descricao |
|---------|-----------|
| `/increment` | Adiciona, corrige, atualiza ou remove em qualquer blueprint |
| `/patch` | Propaga mudanca em cascata por todos os docs |
| `/specs` | Backlog integral de tasks (`docs/specs/TASKS.md`) |

### Code Generation (4)

| Comando | Descricao | Quando |
|---------|-----------|--------|
| `/codegen-setup` | CLAUDE.md router + contratos + schema + scaffold | Setup (uma vez) |
| `/codegen` | Apresenta entregas do build plan | Inicio de sessao |
| `/codegen-feature` | Implementa feature vertical com TDD | Dia-a-dia |
| `/codegen-verify` | Score de aderencia codigo vs blueprint | A cada 3-5 features |

---

## Estrutura de Pastas

```
blueprint/
├── docs/
│   ├── prd.md                    # entrada principal
│   ├── blueprint/                # 17 docs — arquitetura tecnica
│   ├── backend/                  # 15 docs — especificacao backend
│   ├── frontend/
│   │   ├── shared/               # 3 docs — design system, data layer, API deps
│   │   ├── web/                  # 13 docs (se selecionado)
│   │   ├── mobile/               # 13 docs (se selecionado)
│   │   └── desktop/              # 13 docs (se selecionado)
│   ├── shared/                   # 4 docs — mapeamentos transversais
│   ├── specs/                    # TASKS.md (gerado por /specs)
│   ├── diagrams/                 # diagramas Mermaid
│   ├── templates/                # 6 templates
│   └── adr/                      # Architecture Decision Records
├── .claude/skills/               # 19 skills
└── README.md
```

---

## Convencoes das Skills

Todas seguem o mesmo contrato:

- **Escrita** — doc so com `{{placeholders}}` → `Write`. Doc com conteudo real → `Edit`, inserindo antes de `<!-- APPEND:... -->`
- **Origem** — conteudo derivado marcado com `<!-- do blueprint: XX-arquivo.md -->`
- **Versoes** — tecnologias consultadas via MCP Context7 (`resolve-library-id` → `query-docs`)
- **Nunca inventar** numeros, metricas, SLAs ou nomes proprios — extrair ou perguntar
- **Maximo 3 perguntas por skill** (nao por documento), agrupadas e feitas antes de gerar
- **Idioma** — identificadores tecnicos (tabelas, campos, IDs) em ingles; descricoes em portugues

---

## Dicas

- **Comece pelo PRD** — sem ele, as skills nao tem de onde extrair
- **Siga a ordem** — cada fase le o que a anterior produziu; pular quebra as dependencias
- **Nao reexecute uma skill para adicionar** — use `/increment`
- **Use `/patch` para renomear** — entidade, endpoint, tecnologia, versao
- **Templates sao templates** — os `{{placeholders}}` sao substituidos pelas skills, nao edite a mao
- **`docs/shared/`** conecta os blueprints com glossario e mapeamentos de erro e eventos
