# Blueprint Framework

Framework de documentacao tecnica para projetos de software. Templates estruturados + skills do Claude Code que documentam um produto de ponta a ponta — do contexto do sistema a arquitetura de frontend — e depois geram codigo fiel a essa documentacao.

**3 blueprints** | **52 documentos** | **21 skills**

---

## O que e

Um conjunto de templates Markdown com placeholders (`{{...}}`) e skills do Claude Code que preenchem cada secao a partir do PRD do seu projeto.

| Blueprint | Foco | Docs | Skills |
|-----------|------|------|--------|
| **Tecnico** | Contexto, dominio, dados, arquitetura, seguranca | 17 | 7 |
| **Backend** | Classes, servicos, API, eventos, integracoes, testes | 15 | 1 |
| **Frontend** | Design system, componentes, estado, rotas, performance | 3 + 13/cliente | 4 |

Mais 9 skills de apoio: dois loops automaticos (`/pipeline` e `/build`), incremento, patch global, backlog de tasks e geracao de codigo.

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

### Automatico — dois comandos

```
/pipeline docs/prd.md web ../meu-saas/    # 52 docs + scaffold tipado
/build                                     # implementa as features com TDD
```

O `/pipeline` roda as 12 fases sem parar para perguntar, gera os 52 documentos, o scaffold do codigo, e consolida cada inferencia em `docs/ASSUMPTIONS.md` classificada por risco. O `/build` implementa as features em loop, parando na primeira suite vermelha.

Bom para: primeira versao rapida, PRD ja detalhado. Ruim para: projeto critico com PRD raso — sem perguntas, o que o PRD nao cobre vira suposicao. Veja [limites](#pipeline--execucao-automatica).

### Manual — fase a fase

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

## Pipeline — Execucao Automatica

`/pipeline` roda todas as fases de documentacao de uma vez, sem intervencao.

```
/pipeline                          # usa docs/prd.md, infere os clientes do PRD
/pipeline docs/prd.md web,mobile   # explicito
```

### Como funciona

Cada fase executa num **subagente com contexto limpo** — le so o que precisa, escreve seus documentos e devolve um resumo. O orquestrador guarda apenas os resumos, nunca os documentos gerados. E isso que permite produzir 52 documentos sem estourar o contexto.

```
[1/12] blueprint-foundation   → 00, 01, 02, 03
[2/12] blueprint-domain       → 04, 05, 09
...
[7/12] backend                → 15 docs
[8/12] frontend-design-system → shared/03
[9/12] frontend               → shared/06, shared/15
[10/12] frontend-app web      → 8 docs
[11/12] frontend-quality web  → 5 docs
[12/12] codegen-setup         → CLAUDE.md, src/contracts/, schema, scaffold
```

A fase 12 e a unica com **portao objetivo**: type check, lint e validacao de schema. Se falhar apos correcao, o pipeline reporta o erro em vez de declarar sucesso. Ela escreve fora deste repositorio — informe o projeto-alvo como argumento, ou responda `pular` no kickoff.

**Retomavel:** se a sessao cair no meio, rode `/pipeline` de novo — ele detecta quais documentos ja tem conteudo real e pula as fases concluidas.

### Modo autonomo — o trade-off

As skills individuais fazem ate 3 perguntas cada. O pipeline **nao faz nenhuma** — infere tudo do PRD. Onde o PRD e vago, o conteudo gerado e suposicao, nao fato.

A compensacao e tornar cada suposicao auditavel:

1. Marcada no proprio documento: `<!-- assumido: {valor} — base: {de onde inferiu} -->`
2. Consolidada em `docs/ASSUMPTIONS.md`, classificada por risco
3. As de risco alto aparecem no relatorio final

| Risco | Quando | Exemplo |
|-------|--------|---------|
| **Alto** | Numero, SLA ou nome proprio sem base no PRD | `p95 < 300ms` quando o PRD nao fala de latencia |
| **Medio** | Escolha tecnica plausivel mas nao declarada | `PostgreSQL` inferido de "dados relacionais" |
| **Baixo** | Derivacao logica direta | Entidade `Order` porque o PRD fala em pedidos |

Corrija as suposicoes com `/increment` (um blueprint) ou `/patch` (mudanca global).

### Limites

- **Qualidade depende do PRD** — PRD raso gera muitas suposicoes de risco alto. O pipeline extrapola o que existe; nao inventa contexto de negocio.
- **Nao substitui as skills individuais** — para projeto critico, rode fase a fase e responda as perguntas.
- **Vai ate o scaffold, nao ate as features** — implementar features e outro loop, com outros portoes: `/build`.
- **O scaffold herda as suposicoes** — se `05-data-model.md` supos PostgreSQL, o schema nasce em PostgreSQL. Revise `ASSUMPTIONS.md` antes de construir em cima.
- **Custo** — um subagente por fase consome mais tokens que rodar tudo numa sessao. E o preco por nao estourar o contexto.

Trate o resultado como **rascunho completo**, nao como documentacao final.

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

Ou `/build`, que roda esse ciclo inteiro em loop — veja abaixo.

### `/build` — loop de features com portoes

```
/build                      # todas as entregas Must, em ordem de dependencia
/build ENT-001 ENT-002      # entregas especificas
/build --max 5              # limita a 5 features nesta sessao
```

Cada feature roda num subagente e passa por dois portoes:

| Portao | Frequencia | Reprova se |
|--------|-----------|------------|
| **Suite completa** | Toda feature | Qualquer teste vermelho, ou a contagem de testes caiu (sinal de teste apagado/pulado) |
| **`/codegen-verify`** | A cada 3 features | Score de aderencia < 90% |

Suite vermelha → 1 retry com o output real do erro → ainda vermelha → **para**. Commit por feature, para `git revert` granular.

**Por que este loop para e o `/pipeline` nao:** o pipeline pula uma fase que falha, porque um documento ruim nao contamina o proximo. Aqui e o oposto — a feature 1 estabelece abstracoes que a feature 8 herda. Uma feature errada contamina todas as seguintes e voce termina com um codigo internamente consistente, todo verde, e arquiteturalmente errado.

**A regra que mais protege:** e proibido apagar, pular (`skip`/`only`) ou afrouxar qualquer teste para deixar a suite verde. O portao compara a contagem de testes contra o baseline justamente para detectar isso.

**Por que `/codegen-verify` e obrigatorio no loop:** teste escrito pelo mesmo agente que escreveu o codigo nao e verificacao independente. Suite verde prova consistencia interna, nao conformidade com o blueprint. O `verify` compara o codigo com os *documentos* — e a unica checagem externa.

Limites: verde nao e correto (revise o diff); deriva arquitetural so aparece no verify da 3a feature — rode `/build --max 3` nas primeiras e revise antes de soltar o loop inteiro.

### Estrategia de contexto

Blueprints preenchidos ultrapassam 2M tokens — nao cabem em nenhum contexto. A solucao:

1. **CLAUDE.md Router** — tabela que mapeia tipo de tarefa → 2-3 docs relevantes
2. **Context Excerpting** — carrega so as secoes relevantes (grep por headers)
3. **Contracts as Cache** — `src/contracts/` e o "cache compilado" do domain model
4. **Budget por sessao** — ~70-100k tokens de contexto, deixando o resto para geracao

### Templates (6)

`docs/templates/`: `claudemd-template.md`, `prd-template.md`, `epic-template.md`, `story-template.md`, `task-template.md`, `use-case-template.md`

---

## Referencia Rapida — 21 Skills

### Automacao (2)

| Comando | Descricao |
|---------|-----------|
| `/pipeline` | Documentacao completa + scaffold, automatico (subagente por fase, zero perguntas) |
| `/build` | Implementa as features em loop com TDD e portoes de teste (para na primeira falha) |

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
| `/codegen-setup` | CLAUDE.md router + contratos + schema + scaffold | Setup (uma vez, ou via `/pipeline`) |
| `/codegen` | Apresenta entregas do build plan | Inicio de sessao |
| `/codegen-feature` | Implementa feature vertical com TDD | Dia-a-dia (ou em loop via `/build`) |
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
│   ├── ASSUMPTIONS.md            # suposicoes do /pipeline, por risco
│   ├── specs/                    # TASKS.md (gerado por /specs)
│   ├── diagrams/                 # diagramas Mermaid
│   ├── templates/                # 6 templates
│   └── adr/                      # Architecture Decision Records
├── .claude/skills/               # 21 skills
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

- **Comece pelo PRD** — sem ele, as skills nao tem de onde extrair. Quanto mais detalhado, menos o `/pipeline` precisa supor
- **Siga a ordem** — cada fase le o que a anterior produziu; pular quebra as dependencias
- **Depois do `/pipeline`, leia `docs/ASSUMPTIONS.md`** antes de tratar a documentacao como definitiva — o scaffold e o codigo herdam as suposicoes
- **Rode `/build --max 3` primeiro** e revise o diff antes de soltar o loop inteiro; deriva arquitetural so aparece depois de algumas features
- **Nao reexecute uma skill para adicionar** — use `/increment`
- **Use `/patch` para renomear** — entidade, endpoint, tecnologia, versao
- **Templates sao templates** — os `{{placeholders}}` sao substituidos pelas skills, nao edite a mao
- **`docs/shared/`** conecta os blueprints com glossario e mapeamentos de erro e eventos
