---
name: backend
description: Gera a especificacao de implementacao do backend (docs/backend/, 15 docs) a partir do blueprint tecnico.
---

# Backend — Especificacao de Implementacao

Le o **blueprint tecnico ja preenchido** (`docs/blueprint/`) e transforma as decisoes arquiteturais em especificacao detalhada de implementacao nos 15 templates de `docs/backend/`.

O blueprint e a fonte primaria — ja contem entidades, requisitos, fluxos, casos de uso, ADRs e maquinas de estado. Voce so pergunta o que ele **nao** cobre: detalhes de implementacao (framework, ORM, estrutura de classes, metodos).

## Se `docs/prototype/` estiver PREENCHIDO, ele muda esta skill

O prototipo e um frontend completo e mockado construido **antes** do backend. Quando ele existe, o contrato de API deixa de ser inventado e passa a ser **herdado de um consumidor real**.

> **Verifique preenchimento, nao existencia.** `docs/prototype/` e versionado no framework com os 6 templates — a pasta existe sempre. Rode `grep -l '{{' docs/prototype/*.md`: se os arquivos ainda tem `{{placeholders}}`, **a fase nao rodou** e nada desta secao se aplica. Siga o fluxo normal, com o blueprint tecnico como unica fonte.

| Documento do prototipo | Autoridade sobre | Efeito |
|---|---|---|
| `03-api-requirements.md` | **`05-api-contracts.md`** | **Fonte primaria dos endpoints.** Cada endpoint ja tem tela consumidora e cada campo ja tem ponto de renderizacao |
| `04-interaction-states.md` | `09-errors.md` | Todo erro que a UI trata **precisa** existir no catalogo, com o formato que o tratamento exige |
| `02-mock-data.md` | `04-data-layer.md` | Fixtures viram seeds de dev e staging; casos de borda viram fixtures de teste (`14-tests.md`) |
| `01-screens.md` | `11-permissions.md` | As personas ja exercitaram a matriz RBAC — confirme, nao reinvente |
| `05-findings.md` | todos | Achado de risco **alto** aberto **bloqueia esta skill** |

**Portao:** antes de gerar qualquer documento, verifique se `docs/prototype/05-findings.md` esta preenchido (sem `{{placeholders}}`). Se estiver, leia-o. Se houver achado de risco alto em aberto, **pare**:

> "O prototipo registrou {{N}} achados de risco alto ainda abertos. Um contrato construido sobre lacuna conhecida propaga a lacuna para o schema — e schema com dados nao se corrige com `/increment`.
> Resolva com `/increment` ou `/patch`, rode `/prototype-api` para regenerar o contrato, e volte."

**Regras quando o prototipo existe:**

1. **Nao invente endpoint.** Endpoint que nao esta em `03-api-requirements.md` so entra se vier de um fluxo sem interface (webhook, worker, cron, integracao) — e a origem precisa ser citada.
2. **Nao acrescente campo ao DTO de response** sem consumidor. O prototipo ja listou os campos sem consumidor e propos remocao; respeite a proposta ou justifique.
3. **Nao contradiga a latencia tolerada nem a exigencia de idempotencia** — as duas foram observadas, nao estimadas.
4. **As perguntas 4, 5 e 8 do questionario abaixo ficam respondidas** pelo prototipo. Confirme em vez de perguntar.

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
| **prototype/03-api-requirements** | **Endpoints, DTOs, campos, erros, latencia, idempotencia → contratos (05). Fonte primaria quando existir.** |
| **prototype/04-interaction-states** | Erros que a UI trata → catalogo (09). Mutacoes otimistas → idempotencia (04). |
| **prototype/02-mock-data** | Personas → seeds (04). Casos de borda → fixtures de teste (14). |
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
| 4 | API | Confirme os endpoints derivados dos use cases | 08-use_cases — **ou `prototype/03`, que ja os traz com consumidor** |
| 5 | API | Campos de request/response derivados das entidades | 04-domain-model — **ou `prototype/03`, campo a campo com ponto de renderizacao** |
| 6 | API | Versionamento? (URL /v1/, header, sem) | 16-evolution |
| 7 | Auth | Provedor de auth? (Auth0, Cognito, Keycloak, Supabase, proprio) | 13-security |
| 8 | Auth | Confirme a matriz RBAC derivada dos use cases | 08-use_cases + 13-security — **ou `prototype/02`, cujas personas ja a exercitaram** |
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

1. **O blueprint e a fonte primaria do dominio; o prototipo, do contrato de API** — leia os dois antes de perguntar qualquer coisa
2. **So pergunte o que o blueprint nao responde** — detalhes de implementacao
3. **Pre-preencha** respostas do blueprint com `(do blueprint XX: valor)`
4. **Nunca invente** numeros, metricas ou nomes — use o blueprint ou pergunte
5. **Cada entidade deve ter:** atributos, invariantes, metodos, eventos, maquina de estados
6. **Cada endpoint deve ter:** request, response, status codes, erros — e, quando ha prototipo, **consumidor nomeado**
7. **Cada service deve ter:** metodos, com fluxo passo-a-passo nos criticos
8. **Cada repository deve ter:** interface, queries, indices
9. **Cada template de mensagem deve ter:** evento disparador, canal, variaveis
10. **Marque a origem** com `<!-- do blueprint: XX-arquivo.md -->`
