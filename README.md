# Blueprint Framework

Framework de documentacao tecnica e de negocio para projetos SaaS. Utiliza templates estruturados + skills do Claude Code para documentar um produto de ponta a ponta — do modelo de negocio a arquitetura frontend.

**4 blueprints** | **63 documentos** | **60 skills**

---

## O que e

Um conjunto de templates Markdown com placeholders (`{{...}}`) e skills do Claude Code que preenchem automaticamente cada secao a partir do PRD (Product Requirements Document) do seu projeto.

| Blueprint | Foco | Docs | Quando usar |
|-----------|------|------|-------------|
| **Tecnico** | Arquitetura, dominio, dados, seguranca | 18 | Sistema ja validado, indo para producao |
| **Frontend** | Componentes, estado, rotas, performance | 16 | Definir arquitetura frontend |
| **Backend** | Classes, servicos, API, eventos, testes | 15 | Especificar implementacao backend |
| **Business** | Proposta de valor, receita, marketing | 10 | Modelar o negocio (BMC + Lean Canvas) |

---

## Pre-requisitos

1. **Claude Code** instalado e configurado
2. **PRD do projeto** — sera salvo em `docs/prd.md`
3. **MCP Context7** configurado — usado pelos skills para consultar versoes atualizadas de tecnologias. Adicione ao seu `claude_desktop_config.json` ou `.claude.json`:
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
4. **MCP Paper** configurado — usado pelo skill `/paper` para criar designs visuais no Paper:
   ```bash
   claude mcp add paper --transport http http://127.0.0.1:29979/mcp --scope user
   ```
5. **MCP Pencil** configurado (opcional) — usado pelo skill `/pencil` para criar designs visuais no Pencil. Instale a extensao [Pencil](https://pencil.dev) no VS Code — o MCP server roda automaticamente quando o Pencil esta ativo.

---

## Quick Start

```
# 1. Inicie o blueprint tecnico (ou qualquer outro)
/blueprint

# 2. O orquestrador vai:
#    - Pedir seu PRD (arquivo ou texto)
#    - Salvar em docs/prd.md
#    - Analisar cobertura
#    - Mostrar roadmap de 18 skills

# 3. Siga a sequencia sugerida:
/blueprint-context
/blueprint-vision
/blueprint-principles
# ... ate completar
```

---

## Blueprints Disponiveis

### Fluxo Recomendado

```
PRD (docs/prd.md)
  |
  ├── /blueprint             ← Sistema validado (18 docs)
  |
  ├── /backend               ← Especificacao backend (15 docs)
  |
  ├── /frontend              ← Arquitetura frontend (16 docs)
  |
  ├── /business              ← Modelo de negocio (10 docs)
  |
  └── docs/shared/           ← Docs transversais (4 docs)

  Depois:
  ├── /xxx-incrementar       ← Adicionar features sem sobrescrever
  ├── /patch                 ← Propagar mudancas globais
  ├── /specs                 ← Gerar backlog integral de tasks (docs/specs/)
  ├── /opensource            ← Transformar em projeto opensource
  |
  └── /codegen               ← Gerar codigo a partir dos blueprints (XP/TDD)
```

---

## Como Usar

### 1. Blueprint Tecnico (`docs/blueprint/`)

Inicio: `/blueprint`

Sequencia de skills:

```
 1. /blueprint-context        — Atores, sistemas externos, restricoes
 2. /blueprint-vision         — Problema, pitch, objetivos, metricas
 3. /blueprint-principles     — 3-7 principios arquiteturais
 4. /blueprint-requirements   — Requisitos funcionais e nao-funcionais
 5. /blueprint-domain         — Glossario, entidades, regras de negocio
 6. /blueprint-data           — Tabelas, schemas, queries criticas
 7. /blueprint-architecture   — Componentes, comunicacao, infra
 8. /blueprint-flows          — 3-5 fluxos criticos
 9. /blueprint-usecases       — Casos de uso estruturados
10. /blueprint-states         — Maquinas de estado
11. /blueprint-decisions      — ADRs (Architecture Decision Records)
12. /blueprint-buildplan      — Entregas, milestones, riscos
13. /blueprint-testing        — Piramide de testes, cobertura
14. /blueprint-security       — STRIDE, auth, OWASP checklist
15. /blueprint-scalability    — Escala, cache, rate limiting
16. /blueprint-observability  — Logs, metricas, alertas, dashboards
17. /blueprint-evolution      — Roadmap tecnico, debt, deprecacao
18. /blueprint-communication  — Templates de email, SMS, WhatsApp
```

---

### 2. Backend Blueprint (`docs/backend/`)

Inicio: `/backend`

Gera a especificacao de implementacao a partir do blueprint tecnico:

```
 1. 00-backend-vision.md      — Visao, stack, principios backend
 2. 01-architecture.md        — Camadas, Clean Architecture, DI
 3. 02-project-structure.md   — Pastas, modulos, convencoes
 4. 03-domain.md              — Entidades, Value Objects, Aggregates
 5. 04-data-layer.md          — Repositories, migrations, queries
 6. 05-api-contracts.md       — Endpoints, request/response, OpenAPI
 7. 06-services.md            — Application services, use cases
 8. 07-controllers.md         — Controllers, handlers, routing
 9. 08-middlewares.md          — Auth, logging, rate limiting
10. 09-errors.md              — Error handling, codes, responses
11. 10-validation.md          — Input validation, schemas
12. 11-permissions.md         — RBAC, policies, guards
13. 12-events.md              — Domain events, handlers, queues
14. 13-integrations.md        — APIs externas, webhooks, SDKs
15. 14-tests.md               — Estrategia de testes backend
```

---

### 3. Frontend Blueprint (`docs/frontend/`)

Inicio: `/frontend`

Sequencia de skills:

```
 1. /frontend-visao           — Papel do frontend, stack, principios
 2. /frontend-arquitetura     — Clean Architecture FE, camadas, dominios
 3. /frontend-estrutura       — Pastas, features, monorepo
 4. /frontend-design-system   — Tokens, cores, tipografia, Storybook
 5. /frontend-componentes     — Primitive/Composite/Feature components
 6. /frontend-estado          — UI/Server/Global/Domain state
 7. /frontend-data-layer      — API client, TanStack Query, DTOs, BFF
 8. /frontend-rotas           — Rotas, guards, layouts
 9. /frontend-fluxos          — Fluxos criticos de interface
10. /frontend-testes          — Piramide, Vitest, Playwright
11. /frontend-performance     — Code splitting, Core Web Vitals
12. /frontend-seguranca       — Auth, XSS, CSRF, CSP
13. /frontend-observabilidade — Sentry, logging, feature flags
14. /frontend-cicd            — Pipeline CI/CD, convencoes, docs viva
15. /frontend-copies          — Textos, microcopy, i18n
16. /frontend-api-deps        — Dependencias de API do backend
```

---

### 4. Business Blueprint (`docs/business/`)

Inicio: `/business`

Sequencia de skills:

```
 1. /business-contexto        — Mercado, concorrencia, SWOT, premissas
 2. /business-proposta-valor  — Necessidades do cliente, diferencial
 3. /business-segmentos       — ICP, personas, TAM/SAM/SOM
 4. /business-canais          — Canais, funil, PLG, parcerias
 5. /business-relacionamento  — Ciclo de vida, churn, expansion revenue
 6. /business-receita         — MRR, NRR, pricing, unit economics
 7. /business-custos          — COGS, margem bruta, runway, sensibilidade
 8. /business-metricas        — North Star, AARRR, cohort, glossario SaaS
 9. /business-marketing       — Posicionamento, GTM, growth loops
10. /business-operacional     — Processos, equipe, timeline, DR
```

---

### 5. Documentacao Compartilhada (`docs/shared/`)

Docs transversais que conectam os blueprints:

| Documento | Descricao |
|-----------|-----------|
| `MAPPING.md` | Mapeamento entre blueprints (tecnico ↔ frontend ↔ backend) |
| `glossary.md` | Glossario unificado do projeto |
| `error-ux-mapping.md` | Mapeamento erro backend → UX frontend |
| `event-mapping.md` | Mapeamento de eventos entre camadas |

---

## Atualizacoes Incrementais

Quando uma nova feature surge, nao e preciso reescrever o documento inteiro. Use os skills de incremento:

| Skill | Escopo | Comando |
|-------|--------|---------|
| Blueprint Tecnico | 18 docs | `/blueprint-incrementar` |
| Frontend | 16 docs | `/frontend-incrementar` |
| Business | 10 docs | `/business-incrementar` |

### Tipos de alteracao suportados

**Adicao** — Nova feature, novo componente, nova rota:
```
/frontend-incrementar
> "Sistema de chat em tempo real"
→ Adiciona componentes, estado, rotas, fluxos nos docs corretos
```

**Correcao** — Dado errado, prop renomeada:
```
/blueprint-incrementar
> "Corrigir: campo 'email' na entidade User deve ser 'emailAddress'"
→ Edit cirurgico na linha especifica
```

**Atualizacao** — Versao mudou, rota renomeada:
```
/business-incrementar
> "Atualizar: plano Pro de R$99 para R$129"
→ Atualiza todas as referencias de preco
```

**Remocao** — Feature saiu do escopo:
```
/blueprint-incrementar
> "Remover feature de notificacoes push do escopo"
→ Marca como removida com strikethrough
```

### Como funciona

Cada template tem marcadores `<!-- APPEND:section-id -->` que servem como ancora para insercao:

```markdown
| Button | variant, size | primary, secondary |
| Input | type, placeholder | text, password |
<!-- APPEND:primitivos -->
```

O skill insere novo conteudo **antes** do marcador, preservando tudo que ja existe.

---

## Patch Global

Para mudancas que afetam **multiplos blueprints** simultaneamente:

```
/patch
> "Renomear entidade Booking para Appointment"
```

O `/patch` faz:
1. **Varredura** em todos os 63 docs (Grep global)
2. **Analise de impacto** — classifica em substituicao direta, contextual e indireta
3. **Confirmacao** — mostra tabela com todos os arquivos afetados
4. **Aplica patches** — respeita case (PascalCase, camelCase, kebab-case)
5. **Relatorio** — resumo do que mudou

Exemplos de uso:

| Caso | Comando |
|------|---------|
| Renomear entidade | `/patch` → "Booking → Appointment" |
| Atualizar endpoint | `/patch` → "/api/users → /api/v2/users" |
| Mudar tecnologia | `/patch` → "Zustand → Jotai" |
| Atualizar versao | `/patch` → "Next.js 16 → Next.js 17" |
| Renomear componente | `/patch` → "UserCard → ProfileCard" |

---

## Code Generation (Blueprints → Codigo)

Apos preencher os blueprints, use os skills de codegen para gerar codigo fiel a documentacao. O workflow segue **Extreme Programming** (TDD, pair programming, small releases).

### Workflow

```
/codegen-claudemd → Gera CLAUDE.md router no projeto-alvo (uma vez)
       ↓
/codegen-contracts → Setup inicial: tipos, schema, scaffold (uma vez)
       ↓
/codegen → Apresenta entregas do build plan (inicio de sessao)
       ↓
/codegen-feature [nome] → Implementa feature vertical com TDD
       ↓                          ↑
       ↓                    (repete por feature)
       ↓
/codegen-verify → Verifica aderencia ao blueprint (periodico)
```

### Estrategia de Contexto (2M+ tokens de blueprints)

Os blueprints preenchidos ultrapassam 2M tokens — nao cabem no contexto de nenhum modelo. A solucao:

1. **CLAUDE.md Router**: tabela que mapeia tipo de tarefa → 2-3 docs relevantes
2. **Context Excerpting**: carrega apenas secoes relevantes de docs grandes (grep por headers)
3. **Contracts as Cache**: `src/contracts/` e o "cache compilado" do domain model — tipos compactos vs docs verbosos
4. **Budget por sessao**: max ~70-100k tokens de contexto, deixando 900k+ para geracao

### Skills de Codegen (5)

| Comando | Descricao | Quando |
|---------|-----------|--------|
| `/codegen-claudemd` | Gera CLAUDE.md router para o projeto-alvo | Setup (uma vez) |
| `/codegen-contracts` | Gera tipos, schema e scaffold (setup inicial) | Setup (uma vez) |
| `/codegen` | Apresenta entregas do build plan e guia execucao | Inicio de sessao |
| `/codegen-feature` | Implementa feature vertical (TDD: RED→GREEN→REFACTOR) | Dia-a-dia |
| `/codegen-verify` | Verifica codigo vs blueprint (score de aderencia) | A cada 3-5 features |

### Templates (6)

| Template | Descricao |
|----------|-----------|
| `docs/templates/claudemd-template.md` | Template do CLAUDE.md router |
| `docs/templates/prd-template.md` | Template de PRD |
| `docs/templates/epic-template.md` | Template de Epic |
| `docs/templates/story-template.md` | Template de User Story |
| `docs/templates/task-template.md` | Template de Task |
| `docs/templates/use-case-template.md` | Template de Use Case |

---

## Specs — Backlog Integral de Tasks (`/specs`)

Gera um documento unico com **todas as tasks de implementacao** a partir dos 3 blueprints. Produz um backlog completo — sem fases, todas as tasks de uma vez.

### Pre-requisitos

Os 3 blueprints devem estar preenchidos:
- `docs/backend/` (fonte primaria — define as tasks)
- `docs/frontend/` (consistencia — valida alinhamento)
- `docs/blueprint/` (validacao — confirma cobertura)

### Como funciona

```
/specs

# 1. Verifica pre-requisitos (backend, frontend, blueprint preenchidos)
# 2. Le o backend (fonte primaria) — extrai tasks de cada doc
# 3. Le o frontend (consistencia) — identifica gaps
# 4. Gera docs/specs/TASKS.md com todas as tasks
# 5. Valida contra o blueprint tecnico
# 6. Apresenta dashboard com metricas e gaps
```

### O que gera

O output e `docs/specs/TASKS.md` com tasks organizadas em **12 grupos**:

| Grupo | Prefixo | Fonte primaria |
|-------|---------|---------------|
| Setup & Infra | TASK-SETUP | 00-backend-vision, 01-architecture, 02-project-structure |
| Domain | TASK-DOM | 03-domain (1 task por entidade) |
| Data Layer | TASK-DATA | 04-data-layer (1 task por repository + migrations) |
| Services | TASK-SVC | 06-services (1 task por service) |
| API & Controllers | TASK-API | 05-api-contracts, 07-controllers, 10-validation |
| Auth & Permissions | TASK-AUTH | 11-permissions, 08-middlewares (auth) |
| Error Handling | TASK-ERR | 09-errors |
| Middlewares | TASK-MW | 08-middlewares (nao-auth) |
| Events & Workers | TASK-EVT | 12-events (1 produtor + 1 consumidor por evento) |
| Integrations | TASK-INT | 13-integrations |
| Tests | TASK-TEST | 14-tests |
| Frontend Sync | TASK-FE | Cross-reference backend ↔ frontend |

Cada task inclui: camada, entidade, prioridade (Must/Should/Could), origem, descricao, arquivos a criar, dependencias, regras de negocio, criterios de aceite, testes necessarios e consistencia com o frontend.

### Validacao

Ao final, cruza as tasks geradas com o blueprint tecnico:
- Cada requisito funcional tem task?
- Cada fluxo critico tem service + teste E2E?
- Cada use case tem endpoint + controller + service?
- Cada ameaca STRIDE tem mitigacao?
- Gaps sao listados com sugestoes de acao

---

## Opensource — Transformacao para Projeto OSS (`/opensource`)

Transforma um projeto documentado com blueprints proprietarios em um **projeto opensource completo**. Adapta os 4 blueprints in-place e gera os arquivos raiz tipicos de projetos OSS.

### Pre-requisitos

Os 4 blueprints devem estar preenchidos:
- `docs/blueprint/` (tecnico)
- `docs/backend/` (backend)
- `docs/frontend/` (frontend)
- `docs/business/` (negocio)

### Como funciona

```
/opensource

# 1. Le todos os documentos dos 4 blueprints
# 2. Pergunta 5 definicoes ao usuario:
#    - Modelo OSS (open-core, community-driven, dev-tool, foundation-backed)
#    - Licenca (MIT, Apache 2.0, GPL v3, AGPL v3, Dual)
#    - Governanca (BDFL, Committee, Foundation, Meritocracy)
#    - Nome do projeto
#    - Canais da comunidade (Discord, Discussions, Slack, etc.)
# 3. Adapta os 10 docs do business blueprint para contexto OSS
# 4. Adiciona secoes OSS nos docs tecnicos, backend e frontend
# 5. Gera arquivos raiz do projeto OSS
```

### O que transforma

**Business Blueprint (10 docs adaptados):**

| Doc original | Transformacao |
|-------------|--------------|
| Contexto de negocio | → Contexto do ecossistema (TAM→Total Addressable Developers) |
| Proposta de valor | → Por que usar / Por que contribuir |
| Segmentos | → Personas OSS (contributors, maintainers, sponsors) |
| Canais | → Canais da comunidade (GitHub, registries, docs, conferences) |
| Relacionamentos | → Engajamento (Newcomer→Contributor→Committer→Maintainer→TSC) |
| Receita | → Modelo de sustentabilidade (varia por modelo OSS) |
| Custos | → Custos do projeto (CI/CD, hosting, maintainer stipend) |
| Metricas | → Metricas OSS (stars, contributors ativos, downloads, bus factor) |
| Marketing | → Posicionamento e awareness (Product Hunt, HN, conferences) |
| Operacoes | → Community ops (releases, RFCs, governanca, triage, security) |

**Blueprint Tecnico (6 secoes adicionadas):**
- Vulnerability Disclosure Policy (seguranca)
- Contribution Architecture (arquitetura)
- Public Roadmap (build plan)
- Contributor Testing Guide (testes)
- Operational Transparency (observabilidade)
- Community Communication Templates (comunicacao)

**Backend Blueprint (9 secoes adicionadas):**
- OSS Backend Principles (visao)
- Contributor Architecture Guide (arquitetura)
- Contributor Directory Guide (estrutura)
- API Contribution Guidelines (contratos)
- Error Handling for Contributors (erros)
- Testing Guide for Contributors (testes)
- Auth for Self-Hosted (permissoes)
- Event System for Contributors (eventos)
- Integration Development Guide (integracoes)

**Frontend Blueprint (3 secoes adicionadas):**
- Contributor Setup Guide (arquitetura)
- CI for Contributors (cicd)
- Design System for Contributors (design system)

### Arquivos raiz gerados

| Arquivo | Descricao |
|---------|-----------|
| `README.md` | README opensource com badges, features, quick start, community |
| `CONTRIBUTING.md` | Guia de contribuicao (setup, PRs, code style, review) |
| `CODE_OF_CONDUCT.md` | Contributor Covenant v2.1 |
| `LICENSE` | Texto completo da licenca escolhida |
| `SECURITY.md` | Politica de divulgacao de vulnerabilidades |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Template de bug report |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Template de feature request |
| `.github/ISSUE_TEMPLATE/config.yml` | Config de issues |
| `.github/PULL_REQUEST_TEMPLATE.md` | Template de PR |

### Modelos OSS suportados

| Aspecto | Open-core | Community-driven | Dev tool | Foundation-backed |
|---------|-----------|-----------------|----------|-------------------|
| Receita | Enterprise + hosted | Sponsors + grants | Marketplace + premium | Membership + sponsors |
| Personas | Users + enterprise | Contributors + power users | Plugin devs + end users | Corporate adopters |
| Metricas | Conversao free→paid | Contributors ativos | Downloads + installs | Deployments producao |
| Governanca | Company-led | Community-led | Company-led + ecosystem | Charter fundacao |
| Riscos | Erosao de confianca | Burnout maintainer | Fragmentacao ecosystem | Burocracia |

### Todo conteudo gerado e em ingles

A skill transforma o conteudo para ingles, mantendo o padrao de projetos OSS internacionais.

---

## Referencia Rapida de Skills

### Orquestradores (4)

| Comando | Descricao |
|---------|-----------|
| `/blueprint` | Inicia blueprint tecnico (18 docs) |
| `/backend` | Gera especificacao backend (15 docs) |
| `/frontend` | Inicia blueprint frontend (16 docs) |
| `/business` | Inicia blueprint business (10 docs) |

### Incremento (3)

| Comando | Descricao |
|---------|-----------|
| `/blueprint-incrementar` | Adiciona/corrige nos docs tecnicos |
| `/frontend-incrementar` | Adiciona/corrige nos docs frontend |
| `/business-incrementar` | Adiciona/corrige nos docs business |

### Transformacao e Backlog (2)

| Comando | Descricao |
|---------|-----------|
| `/opensource` | Transforma blueprints em projeto opensource (adapta 4 blueprints + gera arquivos raiz) |
| `/specs` | Gera backlog integral de tasks a partir de backend + frontend + blueprint (`docs/specs/TASKS.md`) |

### Utilitario (3)

| Comando | Descricao |
|---------|-----------|
| `/patch` | Propaga mudanca em cascata nos 63 docs |
| `/paper` | Cria paginas visuais no Paper a partir do blueprint |
| `/pencil` | Cria paginas visuais no Pencil (pencil.dev) a partir do blueprint |

### Code Generation (5)

| Comando | Descricao |
|---------|-----------|
| `/codegen` | Orquestrador — apresenta entregas do build plan |
| `/codegen-claudemd` | Gera CLAUDE.md router para o projeto-alvo |
| `/codegen-contracts` | Setup inicial — tipos, schema, scaffold |
| `/codegen-feature` | Implementa feature vertical (TDD/XP) |
| `/codegen-verify` | Verifica codigo gerado vs blueprint |

### Blueprint Tecnico (18)

| Comando | Doc |
|---------|-----|
| `/blueprint-context` | 00-context.md |
| `/blueprint-vision` | 01-vision.md |
| `/blueprint-principles` | 02-architecture_principles.md |
| `/blueprint-requirements` | 03-requirements.md |
| `/blueprint-domain` | 04-domain-model.md |
| `/blueprint-data` | 05-data-model.md |
| `/blueprint-architecture` | 06-system-architecture.md |
| `/blueprint-flows` | 07-critical_flows.md |
| `/blueprint-usecases` | 08-use_cases.md |
| `/blueprint-states` | 09-state-models.md |
| `/blueprint-decisions` | 10-architecture_decisions.md |
| `/blueprint-buildplan` | 11-build_plan.md |
| `/blueprint-testing` | 12-testing_strategy.md |
| `/blueprint-security` | 13-security.md |
| `/blueprint-scalability` | 14-scalability.md |
| `/blueprint-observability` | 15-observability.md |
| `/blueprint-evolution` | 16-evolution.md |
| `/blueprint-communication` | 17-communication.md |

### Frontend (16)

| Comando | Doc |
|---------|-----|
| `/frontend-visao` | 00-visao-frontend.md |
| `/frontend-arquitetura` | 01-arquitetura.md |
| `/frontend-estrutura` | 02-estrutura-projeto.md |
| `/frontend-design-system` | 03-design-system.md |
| `/frontend-componentes` | 04-componentes.md |
| `/frontend-estado` | 05-estado.md |
| `/frontend-data-layer` | 06-data-layer.md |
| `/frontend-rotas` | 07-rotas.md |
| `/frontend-fluxos` | 08-fluxos.md |
| `/frontend-testes` | 09-testes.md |
| `/frontend-performance` | 10-performance.md |
| `/frontend-seguranca` | 11-seguranca.md |
| `/frontend-observabilidade` | 12-observabilidade.md |
| `/frontend-cicd` | 13-cicd-convencoes.md |
| `/frontend-copies` | 14-copies.md |
| `/frontend-api-deps` | 15-api-dependencies.md |

### Business (10)

| Comando | Doc |
|---------|-----|
| `/business-contexto` | 00-contexto-negocio.md |
| `/business-proposta-valor` | 01-proposta-valor.md |
| `/business-segmentos` | 02-segmentos-personas.md |
| `/business-canais` | 03-canais-distribuicao.md |
| `/business-relacionamento` | 04-relacionamento.md |
| `/business-receita` | 05-modelo-receita.md |
| `/business-custos` | 06-estrutura-custos.md |
| `/business-metricas` | 07-metricas-kpis.md |
| `/business-marketing` | 08-estrategia-marketing.md |
| `/business-operacional` | 09-plano-operacional.md |

---

## Estrutura de Pastas

```
blueprint/
├── docs/
│   ├── prd.md                    # PRD do projeto (entrada principal)
│   ├── blueprint/                # 18 docs — arquitetura tecnica
│   │   ├── 00-context.md
│   │   ├── 01-vision.md
│   │   └── ... (ate 17-communication.md)
│   ├── backend/                  # 15 docs — especificacao backend
│   │   ├── 00-backend-vision.md
│   │   ├── 01-architecture.md
│   │   └── ... (ate 14-tests.md)
│   ├── frontend/                 # 16 docs — arquitetura frontend
│   │   ├── 00-visao-frontend.md
│   │   ├── 01-arquitetura.md
│   │   └── ... (ate 15-api-dependencies.md)
│   ├── business/                 # 10 docs — modelo de negocio
│   │   ├── 00-contexto-negocio.md
│   │   ├── 01-proposta-valor.md
│   │   └── ... (ate 09-plano-operacional.md)
│   ├── shared/                   # 4 docs — mapeamentos transversais
│   │   ├── MAPPING.md
│   │   ├── glossary.md
│   │   ├── error-ux-mapping.md
│   │   └── event-mapping.md
│   ├── specs/                    # Backlog integral de tasks (gerado por /specs)
│   │   └── TASKS.md
│   ├── diagrams/                 # Diagramas Mermaid
│   ├── templates/                # 6 templates (PRD, Epic, Story, Task, etc.)
│   └── adr/                      # Architecture Decision Records
├── .claude/
│   └── skills/                   # 60 skills do Claude Code
│       ├── blueprint/            # Orquestrador tecnico
│       ├── backend/              # Orquestrador backend
│       ├── frontend/             # Orquestrador frontend
│       ├── business/             # Orquestrador business
│       ├── opensource/           # Transformacao para projeto OSS
│       ├── specs/                # Geracao de backlog integral de tasks
│       ├── patch/                # Propagacao global
│       ├── paper/                # Paginas visuais no Paper
│       ├── pencil/              # Paginas visuais no Pencil
│       ├── blueprint-*/          # 18 skills de secao + incrementar
│       ├── frontend-*/           # 16 skills de secao + incrementar
│       ├── business-*/           # 10 skills de secao + incrementar
│       └── codegen*/             # 5 skills de geracao de codigo
└── README.md                     # Este arquivo
```

---

## Dicas

- **Comece pelo PRD**: sem PRD, os skills nao tem de onde extrair informacoes
- **Siga a ordem**: os orquestradores sugerem a sequencia ideal
- **Nao repita skills**: use `/xxx-incrementar` para adicionar, nao reexecute o skill original
- **Use `/patch` para mudancas globais**: renomear entidade, mudar versao, etc.
- **Versoes atualizadas**: skills usam o MCP context7 (`mcp__context7__resolve-library-id` + `mcp__context7__query-docs`) para consultar documentacao atualizada de tecnologias
- **Templates sao templates**: os `{{placeholders}}` sao substituidos pelos skills, nao edite manualmente
- **Docs compartilhados**: `docs/shared/` conecta os blueprints com glossario, mapeamentos de erro e eventos
