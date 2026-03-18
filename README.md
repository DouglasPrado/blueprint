# Blueprint Framework

Framework de documentacao tecnica e de negocio para projetos SaaS. Utiliza templates estruturados + skills do Claude Code para documentar um produto de ponta a ponta — do modelo de negocio a arquitetura frontend.

**3 blueprints** | **41 documentos** | **52 skills**

---

## O que e

Um conjunto de templates Markdown com placeholders (`{{...}}`) e skills do Claude Code que preenchem automaticamente cada secao a partir do PRD (Product Requirements Document) do seu projeto.

| Blueprint | Foco | Docs | Quando usar |
|-----------|------|------|-------------|
| **Tecnico** | Arquitetura, dominio, dados, seguranca | 17 | Sistema ja validado, indo para producao |
| **Frontend** | Componentes, estado, rotas, performance | 14 | Definir arquitetura frontend |
| **Business** | Proposta de valor, receita, marketing | 10 | Modelar o negocio (BMC + Lean Canvas) |

---

## Pre-requisitos

1. **Claude Code** instalado e configurado
2. **PRD do projeto** — sera salvo em `docs/prd.md`

---

## Quick Start

```
# 1. Inicie o blueprint tecnico (ou qualquer outro)
/blueprint

# 2. O orquestrador vai:
#    - Pedir seu PRD (arquivo ou texto)
#    - Salvar em docs/prd.md
#    - Analisar cobertura
#    - Mostrar roadmap de 17 skills

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
  ├── /blueprint             ← Sistema validado (17 docs)
  |
  ├── /business              ← Modelo de negocio (10 docs)
  |
  └── /frontend              ← Arquitetura frontend (14 docs)

  Depois:
  ├── /xxx-incrementar       ← Adicionar features sem sobrescrever
  ├── /patch                 ← Propagar mudancas globais
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
12. /blueprint-buildplan      — Fases, milestones, riscos
13. /blueprint-testing        — Piramide de testes, cobertura
14. /blueprint-security       — STRIDE, auth, OWASP checklist
15. /blueprint-scalability    — Escala, cache, rate limiting
16. /blueprint-observability  — Logs, metricas, alertas, dashboards
17. /blueprint-evolution      — Roadmap tecnico, debt, deprecacao
```

---

### 2. Frontend Blueprint (`docs/frontend/`)

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
```

---

### 3. Business Blueprint (`docs/business/`)

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

## Atualizacoes Incrementais

Quando uma nova feature surge, nao e preciso reescrever o documento inteiro. Use os skills de incremento:

| Skill | Escopo | Comando |
|-------|--------|---------|
| Blueprint Tecnico | 17 docs | `/blueprint-incrementar` |
| Frontend | 14 docs | `/frontend-incrementar` |
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
1. **Varredura** em todos os 41 docs (Grep global)
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
/codegen-contracts → Phase 0: tipos, schema, scaffold (uma vez)
       ↓
/codegen → Apresenta fases do build plan (inicio de sessao)
       ↓
/codegen-feature [nome] → Implementa feature vertical com TDD
       ↓                          ↑
       ↓                    (repete por feature)
       ↓
/codegen-verify → Verifica aderencia ao blueprint (a cada fase)
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
| `/codegen-contracts` | Gera tipos, schema e scaffold (Phase 0) | Setup (uma vez) |
| `/codegen` | Apresenta fases do build plan e guia execucao | Inicio de sessao |
| `/codegen-feature` | Implementa feature vertical (TDD: RED→GREEN→REFACTOR) | Dia-a-dia |
| `/codegen-verify` | Verifica codigo vs blueprint (score de aderencia) | A cada 3-5 features |

### Templates de Codegen (1)

| Template | Descricao |
|----------|-----------|
| `docs/templates/claudemd-template.md` | Template do CLAUDE.md router |

---

## Referencia Rapida de Skills

### Orquestradores (3)

| Comando | Descricao |
|---------|-----------|
| `/blueprint` | Inicia blueprint tecnico (17 docs) |
| `/frontend` | Inicia blueprint frontend (14 docs) |
| `/business` | Inicia blueprint business (10 docs) |

### Incremento (3)

| Comando | Descricao |
|---------|-----------|
| `/blueprint-incrementar` | Adiciona/corrige nos docs tecnicos |
| `/frontend-incrementar` | Adiciona/corrige nos docs frontend |
| `/business-incrementar` | Adiciona/corrige nos docs business |

### Utilitario (1)

| Comando | Descricao |
|---------|-----------|
| `/patch` | Propaga mudanca em cascata nos 41 docs |

### Code Generation (5)

| Comando | Descricao |
|---------|-----------|
| `/codegen` | Orquestrador — apresenta fases do build plan |
| `/codegen-claudemd` | Gera CLAUDE.md router para o projeto-alvo |
| `/codegen-contracts` | Phase 0 — tipos, schema, scaffold |
| `/codegen-feature` | Implementa feature vertical (TDD/XP) |
| `/codegen-verify` | Verifica codigo gerado vs blueprint |

### Blueprint Tecnico (17)

| Comando | Doc |
|---------|-----|
| `/blueprint-context` | 00-context.md |
| `/blueprint-vision` | 01-vision.md |
| `/blueprint-principles` | 02-architecture_principles.md |
| `/blueprint-requirements` | 03-requirements.md |
| `/blueprint-domain` | 04-domain_model.md |
| `/blueprint-data` | 05-data_model.md |
| `/blueprint-architecture` | 06-system_architecture.md |
| `/blueprint-flows` | 07-critical_flows.md |
| `/blueprint-usecases` | 08-use_cases.md |
| `/blueprint-states` | 09-state_models.md |
| `/blueprint-decisions` | 10-architecture_decisions.md |
| `/blueprint-buildplan` | 11-build_plan.md |
| `/blueprint-testing` | 12-testing_strategy.md |
| `/blueprint-security` | 13-security.md |
| `/blueprint-scalability` | 14-scalability.md |
| `/blueprint-observability` | 15-observability.md |
| `/blueprint-evolution` | 16-evolution.md |

### Frontend (14)

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
│   ├── blueprint/                # 17 docs — arquitetura tecnica
│   │   ├── 00-context.md
│   │   ├── 01-vision.md
│   │   └── ... (ate 16-evolution.md)
│   ├── frontend/                 # 14 docs — arquitetura frontend
│   │   ├── 00-visao-frontend.md
│   │   ├── 01-arquitetura.md
│   │   └── ... (ate 13-cicd-convencoes.md)
│   ├── business/                 # 10 docs — modelo de negocio
│   │   ├── 00-contexto-negocio.md
│   │   ├── 01-proposta-valor.md
│   │   └── ... (ate 09-plano-operacional.md)
│   ├── diagrams/                 # Diagramas Mermaid
│   └── adr/                      # Architecture Decision Records
├── .claude/
│   └── skills/                   # 52 skills do Claude Code
│       ├── blueprint/            # Orquestrador tecnico
│       ├── frontend/             # Orquestrador frontend
│       ├── business/             # Orquestrador business
│       ├── patch/                # Propagacao global
│       ├── blueprint-*/          # 17 skills de secao + incrementar
│       ├── frontend-*/           # 14 skills de secao + incrementar
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
- **Versoes atualizadas**: skills consultam https://context7.com/ para tecnologias
- **Templates sao templates**: os `{{placeholders}}` sao substituidos pelos skills, nao edite manualmente
