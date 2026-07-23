---
name: backend
description: Gera a especificacao de implementacao do backend (docs/backend/, 15 docs) a partir do blueprint tecnico.
---

# Backend — Especificacao de Implementacao

Le o **blueprint tecnico ja preenchido** (`docs/blueprint/`) e transforma as decisoes arquiteturais em especificacao detalhada de implementacao nos 15 templates de `docs/backend/`.

O blueprint e a fonte primaria — ja contem entidades, requisitos, fluxos, casos de uso, ADRs e maquinas de estado. Voce so pergunta o que ele **nao** cobre: detalhes de implementacao (framework, ORM, estrutura de classes, metodos).

## Fonte e Saida

```
docs/blueprint/   →  LEITURA (17 docs, fonte primaria)
docs/backend/     →  ESCRITA (15 docs)
  00-backend-vision      Stack, padrao, principios, metricas
  01-architecture        Camadas, fronteiras, deploy
  02-project-structure   Arvore de diretorios, nomenclatura
  03-domain              Entidades com metodos e eventos
  04-data-layer          Repositories, ORM, queries
  05-api-contracts       Endpoints, DTOs, status codes
  06-services            Services com fluxos detalhados
  07-controllers         Controllers e rotas
  08-middlewares         Pipeline de request
  09-errors              Hierarquia de excecoes, catalogo
  10-validation          Regras por campo, sanitizacao
  11-permissions         RBAC, ownership, JWT
  12-events              Eventos, workers, filas, DLQ
  13-integrations        Clients externos, circuit breaker, canais de comunicacao
  14-tests               Piramide, cenarios, CI
```

## Passo 1: Ler o Blueprint

Leia os 17 arquivos de `docs/blueprint/`. Mapa de extracao:

| Blueprint | Extrair para Backend |
|-----------|---------------------|
| 00-context | Atores → usuarios da API. Sistemas externos → integracoes (13). |
| 01-vision | Metricas → metricas do backend (00). Nao-objetivos → limites (00). |
| 02-principles | Principios → principios do backend (00). Restricoes → stack (00). |
| 03-requirements | RF → endpoints (05). RNF → metricas de performance (00, 08). |
| 04-domain-model | Entidades → domain (03). Regras → validacao (10). Relacionamentos → data layer (04). |
| 05-data-model | Banco/tabelas → data layer (04). Queries → repositories (04). |
| 06-architecture | Componentes → camadas (01). Comunicacao → middlewares (08). Deploy → deploy (01). |
| 07-critical_flows | Fluxos → services com fluxo detalhado (06). Erros → catalogo de erros (09). |
| 08-use_cases | UCs → mapa de endpoints (05). Atores → permissoes (11). |
| 09-state-models | Estados → maquinas de estado em domain (03). Transicoes → metodos (03). |
| 10-decisions | ADRs → justificativas de stack e padrao (00, 01). |
| 11-build_plan | Entregas → ordem de implementacao. |
| 12-testing | Piramide e cobertura → testes backend (14). |
| 13-security | Auth → middlewares (08) + permissoes (11). Dados sensiveis → validacao (10). |
| 14-scalability | Cache e rate limit → middlewares (08). |
| 15-observability | Logs e metricas → pipeline de request (08). |
| 16-evolution | Versionamento de API → contratos (05). Debitos → limites conhecidos (00). |

## Passo 2: Analise de Lacunas

| Categoria | O que o Blueprint JA tem | O que FALTA para o Backend |
|-----------|--------------------------|---------------------------|
| Entidades | Nomes, atributos, regras | **Metodos da classe, construtores, eventos emitidos** |
| Dados | Tabelas, indices | **Interface do repository, queries, schema do ORM** |
| Fluxos | Happy path e erros | **Qual service executa cada passo, transacoes** |
| API | Requisitos funcionais | **Endpoints, DTOs, status codes, erros por rota** |
| Seguranca | STRIDE, metodo de auth | **Roles, matriz RBAC, JWT claims, config de middleware** |
| Teste | Piramide, cobertura | **Ferramentas especificas, cenarios obrigatorios** |

Apresente a tabela de cobertura por template (`# | Template | Cobertura do Blueprint | Lacuna`).

## Passo 3: Questionario de Implementacao

Pergunte **apenas** o que o blueprint nao responde. Pre-preencha com `(do blueprint XX: valor)`. Pergunte em grupos tematicos, aguardando resposta entre grupos.

| # | Tema | Pergunta | Fonte Blueprint |
|---|------|----------|----------------|
| 1 | Stack | Linguagem e framework? (Node+Fastify, Python+FastAPI, Go+Gin, Java+Spring) | 10-decisions |
| 2 | Stack | ORM? (Prisma, Drizzle, TypeORM, SQLAlchemy, raw) | 05-data |
| 3 | Stack | Deploy e CI/CD? (Docker+K8s, ECS, serverless, PaaS) | 06-architecture |
| 4 | API | Confirme os endpoints derivados dos use cases | 08-use_cases |
| 5 | API | Campos de request/response derivados das entidades | 04-domain-model |
| 6 | API | Versionamento? (URL /v1/, header, sem) | 16-evolution |
| 7 | Auth | Provedor de auth? (Auth0, Cognito, Keycloak, Supabase, proprio) | 13-security |
| 8 | Auth | Confirme a matriz RBAC derivada dos use cases | 08-use_cases + 13-security |
| 9 | Async | Message broker? (BullMQ, RabbitMQ, Kafka, SQS) | 06-architecture |
| 10 | Async | Confirme os workers derivados dos fluxos assincronos | 07-flows |
| 11 | Async | Provedores de comunicacao e pagamento? (email, SMS, WhatsApp, gateway) | — |
| 12 | Quality | Ferramentas de teste? (Jest, Vitest, Testcontainers, k6) | 12-testing |
| 13 | Quality | Stack de observabilidade? (Datadog, Grafana, ELK, OpenTelemetry) | 15-observability |
| 14 | Quality | Estrategia de cache? (Redis, in-memory, CDN) | 14-scalability |

## Passo 4: Confirmar e Salvar

Apresente o resumo das decisoes (blueprint + respostas). Salve em `docs/backend-answers.md`.

## Passo 5: Preencher os 15 Templates

Ordem de preenchimento — cada fase usa o que a anterior produziu:

```
A. Base       00-backend-vision → 01-architecture → 02-project-structure
B. Dominio    03-domain → 04-data-layer
C. API        05-api-contracts → 06-services → 07-controllers
D. Infra      08-middlewares → 09-errors → 10-validation → 11-permissions
E. Async      12-events → 13-integrations
F. Qualidade  14-tests
```

> **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, atualizando apenas o que mudou e inserindo antes de `<!-- APPEND:... -->`. Marque a origem com `<!-- do blueprint: XX-arquivo.md -->`.

**Nota sobre 13-integrations:** este doc cobre tanto os clients de APIs externas quanto os **canais de comunicacao** (email, SMS, WhatsApp) — provedores, catalogo de templates, variaveis, prioridade entre canais, rate limits e convencoes de escrita. Cada template de mensagem deve ser disparado por um evento declarado em `12-events.md`; nao crie template orfao.

Atualize o progresso apos cada template (`| # | Template | Status |` com ✅ / 🔄 / ⏳).

## Passo 6: Revisao Final

1. Tabela de progresso final (todos ✅)
2. Resumo: o que veio do blueprint vs. o que veio de perguntas
3. Questoes em aberto

> "Backend blueprint completo (15 docs). Proximos passos:
> - `/codegen-setup` — CLAUDE.md router + shared kernel (tipos, schema, scaffold)
> - `/codegen` — iniciar geracao de codigo
> - `/frontend` — blueprint do frontend
> - `/specs` — backlog integral de tasks"

## Regras

1. **O blueprint e a fonte primaria** — leia tudo antes de perguntar qualquer coisa
2. **So pergunte o que o blueprint nao responde** — detalhes de implementacao
3. **Pre-preencha** respostas do blueprint com `(do blueprint XX: valor)`
4. **Nunca invente** numeros, metricas ou nomes — use o blueprint ou pergunte
5. **Cada entidade deve ter:** atributos, invariantes, metodos, eventos, maquina de estados
6. **Cada endpoint deve ter:** request, response, status codes, erros
7. **Cada service deve ter:** metodos, com fluxo passo-a-passo nos criticos
8. **Cada repository deve ter:** interface, queries, indices
9. **Cada template de mensagem deve ter:** evento disparador, canal, variaveis
10. **Marque a origem** com `<!-- do blueprint: XX-arquivo.md -->`
