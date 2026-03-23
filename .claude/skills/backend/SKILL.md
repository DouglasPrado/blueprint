---
name: backend
description: Orquestrador completo para blueprint de backend. Coleta decisoes tecnicas via questionario tematico, depois preenche 15 templates em docs/backend/ — classes, funcoes, camadas, contratos de API, servicos, repositorios, middlewares, eventos e erros. Produz guia completo para construir o backend.
---

# Backend — Blueprint de Implementacao Backend

Voce e o arquiteto de backend. Sua funcao e coletar decisoes tecnicas e preencher os **15 templates em `docs/backend/`** — descrevendo todas as classes, funcoes, camadas, contratos e responsabilidades necessarias para construir o backend. O resultado nao e codigo, mas um guia completo que permite a qualquer desenvolvedor implementar o sistema sem ambiguidade.

## Saida Esperada

Preencher os **15 templates** em `docs/backend/`:

| # | Arquivo | Conteudo |
|---|---------|----------|
| 00 | `00-backend-vision.md` | Stack, padrao arquitetural, principios, metricas |
| 01 | `01-architecture.md` | Camadas, fronteiras de dominio, comunicacao, deploy |
| 02 | `02-project-structure.md` | Arvore de diretorios, convencoes de nomenclatura |
| 03 | `03-domain.md` | Entidades, atributos, invariantes, metodos, eventos, maquinas de estado |
| 04 | `04-data-layer.md` | Repositories, schema ORM, migrations, indices, queries criticas |
| 05 | `05-api-contracts.md` | Endpoints, DTOs request/response, status codes, erros por rota |
| 06 | `06-services.md` | Services com metodos, parametros, retorno, fluxos detalhados |
| 07 | `07-controllers.md` | Controllers, rotas, entrada/saida, serializers |
| 08 | `08-middlewares.md` | Pipeline de request, rate limiting, CORS, auth |
| 09 | `09-errors.md` | Hierarquia de excecoes, catalogo de erros, formato padrao |
| 10 | `10-validation.md` | Regras por campo, cross-field, sanitizacao |
| 11 | `11-permissions.md` | Roles, matriz RBAC, ownership, campos visiveis |
| 12 | `12-events.md` | Eventos, filas, workers, retry, DLQ, cron jobs |
| 13 | `13-integrations.md` | Clients externos, circuit breaker, webhooks |
| 14 | `14-tests.md` | Piramide de testes, cobertura, cenarios obrigatorios |

Alem disso, preenche tambem os 18 arquivos do blueprint tecnico (`docs/blueprint/`) usando os skills individuais.

---

## Passo 1: Receber o PRD

Verifique se o usuario passou um argumento (caminho de arquivo). Se sim, leia o arquivo. Se nao, pergunte:

> "Para iniciar o blueprint backend, preciso do seu PRD (Product Requirements Document). Voce pode:
> 1. Passar o caminho do arquivo: `/backend docs/prd.md`
> 2. Colar o conteudo do PRD aqui no chat
>
> Como prefere?"

Aguarde a resposta. Salve o conteudo em `docs/prd.md` (se ja existir, pergunte se deve sobrescrever).

## Passo 2: Leitura de Contexto

Leia TODOS os arquivos necessarios:

1. `docs/prd.md` — fonte primaria
2. Todos os 15 templates em `docs/backend/` (00 a 14)
3. Se existir `docs/backend-answers.md`, leia para retomar progresso anterior

## Passo 3: Analise de Cobertura

A partir do PRD, classifique cada template e apresente:

| # | Template | Cobertura | Observacao |
|---|----------|-----------|------------|
| 00 | Visao do Backend | Coberto/Parcial/Lacuna | nota |
| 01 | Arquitetura | ... | ... |
| 02 | Estrutura do Projeto | ... | ... |
| 03 | Dominio | ... | ... |
| 04 | Data Layer | ... | ... |
| 05 | Contratos de API | ... | ... |
| 06 | Services | ... | ... |
| 07 | Controllers | ... | ... |
| 08 | Middlewares | ... | ... |
| 09 | Erros | ... | ... |
| 10 | Validacao | ... | ... |
| 11 | Permissoes | ... | ... |
| 12 | Eventos | ... | ... |
| 13 | Integracoes | ... | ... |
| 14 | Testes | ... | ... |

## Passo 4: Questionario Tematico

Apresente UM GRUPO POR VEZ. Aguarde resposta antes de continuar. Para respostas que o PRD ja cobre, pre-preencha com `(inferido do PRD: ...)`.

---

### Grupo 1: Stack e Arquitetura Base
> Alimenta: `00-backend-vision.md`, `01-architecture.md`, `02-project-structure.md`

| # | Pergunta |
|---|----------|
| 1 | **Qual linguagem e framework principal?** Ex: Node.js + Fastify, Python + FastAPI, Go + Gin, Java + Spring Boot. Inclua versao. |
| 2 | **Qual padrao arquitetural?** Monolito modular, microsservicos, serverless, hexagonal, clean architecture? Descreva as camadas. |
| 3 | **Qual ORM ou query builder?** Prisma, Drizzle, TypeORM, SQLAlchemy, GORM, Ecto, ou raw? |
| 4 | **Qual banco de dados principal e secundarios?** PostgreSQL, MongoDB, MySQL + Redis, ElasticSearch, S3? |
| 5 | **Qual provedor de cloud e servicos?** AWS, GCP, Azure? Quais servicos especificos? |
| 6 | **Qual estrategia de deploy e CI/CD?** Docker + K8s, ECS, serverless, PaaS? GitHub Actions, GitLab CI? |

> Aguarde resposta do usuario.

---

### Grupo 2: Dominio e Entidades
> Alimenta: `03-domain.md`, `04-data-layer.md`

| # | Pergunta |
|---|----------|
| 7 | **Liste TODAS as entidades.** Para cada: nome, descricao, atributos principais (nome, tipo, obrigatorio). |
| 8 | **Quais regras de negocio?** Invariantes por entidade. Ex: "email unico", "pedido so cancela se nao enviado". |
| 9 | **Quais relacionamentos?** Entidade A → B, cardinalidade, cascade, obrigatorio. |
| 10 | **Quais entidades possuem maquina de estados?** Estados e transicoes validas. |
| 11 | **Quais eventos de dominio?** Nome, quando emitido, payload, consumidores. |

> Aguarde resposta do usuario.

---

### Grupo 3: Contratos de API
> Alimenta: `05-api-contracts.md`, `06-services.md`, `07-controllers.md`

| # | Pergunta |
|---|----------|
| 12 | **Liste TODOS os endpoints.** Metodo HTTP, rota, descricao, auth necessaria. Agrupe por recurso. |
| 13 | **Quais campos cada request body recebe?** Campos, tipos, validacoes por endpoint POST/PUT/PATCH. |
| 14 | **Quais campos cada response retorna?** Estrutura do body de sucesso. Paginacao se listagem. |
| 15 | **Quais erros cada endpoint retorna?** Status codes e codigos de erro por endpoint. |
| 16 | **Existe versionamento de API?** URL path, header, ou sem? |

> Aguarde resposta do usuario.

---

### Grupo 4: Autenticacao, Autorizacao e Seguranca
> Alimenta: `08-middlewares.md`, `11-permissions.md`

| # | Pergunta |
|---|----------|
| 17 | **Qual metodo de autenticacao?** JWT, session, OAuth 2.0, API keys? Qual provedor? |
| 18 | **Quais roles existem?** Nome, descricao, permissoes por role. |
| 19 | **Existe controle por recurso?** Owner-only? Multi-tenancy? |
| 20 | **Quais dados sensiveis?** PII, financeiro, saude? Como proteger/mascarar? |

> Aguarde resposta do usuario.

---

### Grupo 5: Fluxos, Erros e Integracoes
> Alimenta: `09-errors.md`, `10-validation.md`, `12-events.md`, `13-integrations.md`

| # | Pergunta |
|---|----------|
| 21 | **Quais sao os 3-5 fluxos mais criticos?** Happy path detalhado, services e repositories envolvidos. |
| 22 | **Quais erros podem ocorrer?** Codigo, mensagem, status HTTP, retentavel, fallback. |
| 23 | **Existem fluxos assincronos?** Evento, worker, fila, retry, DLQ. |
| 24 | **Quais integracoes externas?** Servico, timeout, retry, circuit breaker, fallback. |

> Aguarde resposta do usuario.

---

### Grupo 6: Observabilidade, Testes e Operacao
> Alimenta: `14-tests.md` + blueprint tecnico (observabilidade, comunicacao)

| # | Pergunta |
|---|----------|
| 25 | **Qual stack de observabilidade?** Logs, metricas, traces — ferramentas e provedores. |
| 26 | **Qual estrategia de testes?** Proporcao, ferramentas, cobertura minima. |
| 27 | **Quais canais de comunicacao?** Email, SMS, WhatsApp? Provedores? Mensagens transacionais? |
| 28 | **Qual estrategia de cache?** O que cachear, TTL, invalidacao. |
| 29 | **Rate limiting?** Limites por IP/usuario/endpoint, algoritmo. |

> Aguarde resposta do usuario.

---

## Passo 5: Confirmar Respostas

Apresente resumo organizado por template. Pergunte se o usuario quer ajustar. Apos confirmacao, salve em `docs/backend-answers.md`.

## Passo 6: Preencher os 15 Templates do Backend

Preencha cada arquivo em `docs/backend/` na ordem abaixo, substituindo TODOS os `{{placeholders}}`:

```
Fase A (Base):
  00-backend-vision.md → 01-architecture.md → 02-project-structure.md

Fase B (Dominio e Dados):
  03-domain.md → 04-data-layer.md

Fase C (API e Logica):
  05-api-contracts.md → 06-services.md → 07-controllers.md

Fase D (Infra e Seguranca):
  08-middlewares.md → 09-errors.md → 10-validation.md → 11-permissions.md

Fase E (Async e Externo):
  12-events.md → 13-integrations.md

Fase F (Qualidade):
  14-tests.md
```

> **Modo de escrita:**
> - Se o documento contem apenas `{{placeholders}}` (primeira vez): use **Write** para preencher tudo.
> - Se o documento ja tem conteudo real (reexecucao): use **Edit** para atualizar APENAS o que mudou.
> - Insira novo conteudo antes dos marcadores `<!-- APPEND:... -->`.

Para CADA template preenchido, atualize a tabela de progresso:

```
| # | Template | Status |
|---|----------|--------|
| 00 | Visao | ✅ |
| 01 | Arquitetura | ✅ |
| 02 | Estrutura | 🔄 EM ANDAMENTO |
| 03 | Dominio | ⏳ PENDENTE |
| ... | ... | ... |
```

## Passo 7: Preencher os 18 Blueprints Tecnicos

Apos os 15 templates do backend, preencha os 18 arquivos de `docs/blueprint/` delegando para os skills individuais:

```
/blueprint-context → /blueprint-vision → /blueprint-principles → /blueprint-requirements
→ /blueprint-domain → /blueprint-decisions → /blueprint-data → /blueprint-architecture
→ /blueprint-flows → /blueprint-usecases → /blueprint-states
→ /blueprint-buildplan, /blueprint-testing, /blueprint-security, /blueprint-scalability, /blueprint-observability
→ /blueprint-evolution → /blueprint-communication
```

Passe as respostas coletadas E o conteudo dos templates backend preenchidos como contexto para cada skill.

## Passo 8: Revisao Final

1. Tabela de progresso final (todos ✅)
2. Resumo executivo das decisoes-chave
3. Questoes em aberto
4. Proximos passos:

> "Blueprint backend completo! Proximos passos:
> - `/codegen-claudemd` — Gerar CLAUDE.md router
> - `/codegen-contracts` — Gerar shared kernel (tipos, schema, scaffold)
> - `/codegen` — Iniciar geracao de codigo
> - `/frontend` — Blueprint do frontend
> - `/business` — Blueprint de negocio"

## Regras Importantes

1. **NUNCA invente numeros, metricas ou nomes que o usuario nao mencionou** — pergunte ou marque `[A DEFINIR]`
2. **Cada entidade DEVE ter:** atributos, invariantes, metodos, eventos, maquina de estados (se aplicavel)
3. **Cada endpoint DEVE ter:** request schema, response schema, status codes, erros possiveis
4. **Cada service DEVE ter:** metodos com parametros, retorno, descricao, fluxo detalhado dos criticos
5. **Cada repository DEVE ter:** interface com metodos, queries principais, indices
6. **Use Write** para criar, **Edit** para atualizar
7. **Insira antes dos marcadores** `<!-- APPEND:... -->`
8. **Marque inferencias** com `<!-- inferido do PRD -->`
