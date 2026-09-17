# Blueprint — O Que É Fundamental Para Criar um SaaS

> **Documento mestre.** Consolidação completa do repositório `DouglasPrado/blueprint`: os 3 blueprints (técnico, backend, frontend), os 4 documentos cross-layer, os templates, os diagramas C4 e as 21 skills do Claude Code — correlacionados num único arquivo.
>
> **O que este arquivo é:** o mapa integral do que precisa existir, estar decidido e estar escrito para construir um SaaS de forma rastreável — e como cada peça se conecta às outras.
>
> **O que este arquivo não é:** um substituto dos documentos individuais. Ele é a visão de conjunto; cada seção aponta para o arquivo-fonte onde o detalhe vive e é preenchido.
>
> **Sobre divergências:** onde os arquivos do repositório se contradizem entre si, este documento **registra o conflito e diz qual fonte seguir** em vez de escolher um lado em silêncio. As **seis divergências verificadas** estão em [§17.4](#174-divergências-internas-do-repositório-verificadas) e as **três lacunas estruturais do framework** em [§14.3](#143-marcadores-de-append-pontos-de-inserção-estáveis) — entre elas a mais consequente: **nenhuma skill gera `docs/shared/`**, de modo que o `/pipeline` entrega 48 documentos preenchidos, não 52.

| Campo | Valor |
| --- | --- |
| Versão | v1.0.0 |
| Fonte | Repositório Blueprint — `README.md`, `docs/**`, `.claude/skills/**` |
| Cobertura | 52 documentos padrão (1 cliente frontend) · 21 skills · 10 diagramas `.mmd` + 4 READMEs de diagramas |
| Idioma | Descrições em português; identificadores técnicos em inglês |

---

## Índice

| # | Parte | O que responde |
| --- | --- | --- |
| **0** | [Como usar este documento](#0-como-usar-este-documento) | Por onde começar, em que ordem |
| **1** | [Os 14 pilares de um SaaS](#1-os-14-pilares-de-um-saas) | O que é fundamental — visão de conjunto |
| **2** | [A cadeia de derivação](#2-a-cadeia-de-derivação-prd--código) | Como a informação flui do PRD ao código |
| **3** | [Matriz de rastreabilidade consolidada](#3-matriz-de-rastreabilidade-consolidada) | Qual arquivo alimenta qual arquivo |
| **4** | [Fundação: PRD, contexto, visão, princípios, requisitos](#4-fundação-contexto-visão-princípios-requisitos) | Por que o sistema existe, o que ele deve fazer, **quem decide e quem é dono do risco** |
| **5** | [Domínio, dados e estados](#5-domínio-dados-e-estados) | O coração conceitual |
| **6** | [Arquitetura do sistema e ADRs](#6-arquitetura-do-sistema-e-adrs) | Como o sistema é montado e por quê |
| **7** | [Fluxos críticos e casos de uso](#7-fluxos-críticos-e-casos-de-uso) | Como o sistema se comporta |
| **8** | [Backend — especificação de implementação](#8-backend--especificação-de-implementação) | Os 15 documentos do servidor |
| **9** | [Frontend — multi-client](#9-frontend--multi-client) | Design system + 13 docs por cliente |
| **10** | [Camada cross-layer](#10-camada-cross-layer-o-que-impede-divergência) | O que impede os blueprints de divergirem |
| **11** | [Atributos de qualidade](#11-atributos-de-qualidade) | Testes, segurança, escalabilidade, observabilidade |
| **12** | [Construção, evolução e operação](#12-construção-evolução-e-operação) | Plano de entrega, deploy, **hierarquia ENT→EP→ST→TSK**, débito, deprecação |
| **13** | [O que é específico de SaaS](#13-o-que-é-específico-de-saas) | Multi-tenancy, billing, planos, quotas, onboarding |
| **14** | [Contrato das skills e automação](#14-contrato-das-skills-e-automação) | Pipeline, build, codegen, increment, patch, specs |
| **15** | [Estratégia de contexto para agentes](#15-estratégia-de-contexto-para-agentes) | Como não estourar a janela de contexto |
| **16** | [Checklists operacionais](#16-checklists-operacionais) | Definition of Done, go/no-go, pré-produção |
| **17** | [Anti-patterns e armadilhas](#17-anti-patterns-e-armadilhas) | O que quebra projetos assistidos por IA + **divergências internas do repositório** |
| **18** | [Índice de arquivos do repositório](#18-índice-de-arquivos-do-repositório) | Onde cada coisa mora |

---

## 0. Como usar este documento

### 0.1 As três leituras possíveis

| Se você é… | Leia | Por quê |
| --- | --- | --- |
| **Fundador / PM iniciando um SaaS** | Partes 1, 2, 4, 13, 16 | Define o que precisa estar decidido antes de qualquer linha de código |
| **Tech lead / arquiteto** | Partes 3, 5, 6, 8, 9, 11, 12 | Define a estrutura técnica e os pontos de decisão irreversível |
| **Agente de IA / engenheiro executando** | Partes 2, 3, 14, 15, 17 | Define a ordem de execução, o que ler para cada tarefa e o que nunca fazer |

### 0.2 A regra fundamental do framework

> **O blueprint descreve o sistema. O código implementa o blueprint.**

Três consequências práticas, que aparecem repetidas em todas as skills:

1. **Uma fonte primária por decisão.** O blueprint técnico (`docs/blueprint/`) decide *o quê*. Backend e frontend decidem *como*, sem redefinir o produto. Se backend e blueprint divergem, o blueprint vence — ou o blueprint é corrigido explicitamente com `/increment`.
2. **Nada é inventado silenciosamente.** SLAs, métricas, percentuais, nomes próprios e volumes vêm do PRD, de uma resposta do usuário, ou são marcados como suposição (`<!-- assumido: X — base: Y -->`) e consolidados em `docs/ASSUMPTIONS.md` com classificação de risco.
3. **Verificação é independente.** Suíte verde prova consistência interna, não conformidade com o desenho. Por isso existe um gate separado (`/codegen-verify`) que compara código contra documento.

### 0.3 Pré-requisitos do ambiente

| Requisito | Por quê |
| --- | --- |
| **Claude Code** | Executa as skills |
| **Um PRD** | Sem ele não há de onde inferir — o resultado seria inteiramente inventado. O `/pipeline` **para** se não encontrar `docs/prd.md` nem receber um caminho |
| **Context7 MCP** | Documentação de tecnologia **atualizada**. Toda skill que cita versão de biblioteca consulta `resolve-library-id` → `query-docs` em vez de assumir o que o modelo memorizou no treino |

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

**Setup:** clonar o repositório → colocar o PRD em `docs/prd.md` → escolher o modo de execução abaixo.

### 0.4 Dois modos de trabalho

```
MODO AUTÔNOMO (PRD detalhado, primeira versão rápida)
  /pipeline docs/prd.md web ../meu-saas/   → 52 docs + scaffold tipado
  revisar docs/ASSUMPTIONS.md              → corrigir risco alto com /increment
  /build                                   → features em loop com portões

MODO GUIADO (sistema crítico, PRD raso)
  /blueprint → -foundation → -domain → -architecture → -flows → -quality → -plan
  /backend
  /frontend → -design-system → -app {client} → -quality {client}
  /specs → /codegen-setup → /codegen-feature → /codegen-verify
```

**Regra de escolha:** PRD raso + sistema crítico = modo guiado. O pipeline não inventa contexto de negócio; ele extrapola o que existe, e extrapolação sobre vácuo vira ficção classificada como risco alto.

---

## 1. Os 14 pilares de um SaaS

Nenhum SaaS sobrevive sem estes 14 blocos decididos e escritos. A coluna **"Onde vive"** mostra o arquivo que é a fonte primária daquele pilar; a coluna **"Colapsa se faltar"** é o modo de falha real.

| # | Pilar | Onde vive (fonte primária) | Colapsa se faltar |
| --- | --- | --- | --- |
| 1 | **Problema, usuários e valor** | `blueprint/01-vision.md` + `prd.md` §2-§5 | Constrói-se a coisa certa para ninguém |
| 2 | **Limites do sistema** | `blueprint/00-context.md` (é / não é responsável por) | Escopo infinito; time entrega para sempre |
| 3 | **Requisitos com threshold** | `blueprint/03-requirements.md` (RF MoSCoW + RNF com métrica) | "Rápido" e "seguro" viram opinião, não teste |
| 4 | **Modelo de domínio e linguagem ubíqua** | `blueprint/04-domain-model.md` + `shared/glossary.md` | Cada camada nomeia a mesma coisa diferente |
| 5 | **Modelo de dados e migrações** | `blueprint/05-data-model.md` + `backend/04-data-layer.md` | Schema evolui por acidente; downtime em migração |
| 6 | **Ciclo de vida das entidades** | `blueprint/09-state-models.md` + `backend/03-domain.md` | Pedido pago que volta a rascunho; estado impossível vira bug de produção |
| 7 | **Arquitetura e decisões registradas** | `blueprint/06-system-architecture.md` + `10-architecture_decisions.md` + `docs/adr/` | Ninguém lembra por que; decisão é refeita a cada trimestre |
| 8 | **Fluxos críticos e casos de uso** | `blueprint/07-critical_flows.md` + `08-use_cases.md` | Caminho feliz implementado, erro descoberto pelo cliente |
| 9 | **Contrato de API** | `backend/05-api-contracts.md` ↔ `frontend/shared/15-api-dependencies.md` | Frontend e backend divergem em silêncio até o deploy |
| 10 | **AuthN, AuthZ e multi-tenancy** | `blueprint/13-security.md` + `backend/11-permissions.md` | Vazamento entre tenants — o erro que mata um SaaS |
| 11 | **Assíncrono: eventos, filas, workers, DLQ** | `backend/12-events.md` + `shared/event-mapping.md` | Job silenciosamente perdido; usuário nunca recebe o e-mail |
| 12 | **Integrações e resiliência** | `backend/13-integrations.md` (timeout, retry, circuit breaker, fallback) | Gateway de pagamento fora do ar derruba o produto inteiro |
| 13 | **Qualidade: testes, performance, escala, observabilidade** | `blueprint/12`,`14`,`15` + `backend/14-tests.md` + `frontend/{client}/09-13` | Não se sabe que quebrou até o cliente avisar |
| 14 | **Plano de construção e evolução** | `blueprint/11-build_plan.md` + `16-evolution.md` | Backlog sem ordem de dependência; débito técnico invisível |

### 1.1 A hierarquia entre os pilares

Nem todos têm o mesmo custo de errar. A ordem abaixo é a ordem de **irreversibilidade** — quanto mais acima, mais caro consertar depois:

```
1. Modelo de domínio + linguagem ubíqua     ← renomear entidade em produção custa semanas
2. Multi-tenancy e isolamento de dados      ← retrofit de tenant_id é migração de risco máximo
3. Modelo de dados e chaves                 ← mudar PK/particionamento com dados reais é cirurgia
4. Contrato de API público                  ← cliente externo acoplado = versionamento eterno
5. Arquitetura (monólito modular vs micro)  ← caro, mas reversível com strangler
6. Stack e frameworks                       ← caro, mas localizado
7. Design system e copies                   ← barato de mudar
8. Ferramentas de observabilidade           ← trocável a qualquer momento
```

**Implicação prática:** o `/blueprint-domain` (fase 2) e a decisão de multi-tenancy (`backend/11-permissions.md`) merecem mais tempo humano do que qualquer outra fase. É onde a pressa cobra juros compostos.

---

## 2. A cadeia de derivação (PRD → código)

### 2.1 O fluxo completo

```
docs/prd.md                                   ENTRADA — única fonte de negócio
      │
      ▼
docs/blueprint/  (17 docs)                    FONTE PRIMÁRIA — o QUÊ
      │  fases: foundation → domain → architecture → flows → quality → plan
      │
      ├──────────► docs/backend/  (15 docs)          COMO, no servidor
      │
      ├──────────► docs/frontend/ (3 shared + 13/cliente)  COMO, no cliente
      │
      └──────────► docs/shared/   (4 docs)           CONECTORES cross-suite
                        │
                        ▼
                  docs/specs/TASKS.md          BACKLOG integral rastreável
                        │
                        ▼
                  CLAUDE.md + src/contracts/   SCAFFOLD tipado (codegen-setup)
                        │
                        ▼
                  RED → GREEN → REFACTOR       FEATURE vertical (codegen-feature)
                        │
                        ▼
                  codegen-verify               ADERÊNCIA código × blueprint
```

### 2.2 Por que a ordem das fases não é negociável

Cada fase consome o que a anterior produziu. Pular gera documento genérico — que é pior do que documento ausente, porque parece preenchido.

| Fase | Skill | Produz | Consome obrigatoriamente |
| --- | --- | --- | --- |
| 1 | `/blueprint-foundation` | `00`, `01`, `02`, `03` | `prd.md` |
| 2 | `/blueprint-domain` | `04`, `05`, `09` | `prd.md`, `00`, `01` |
| 3 | `/blueprint-architecture` | `06`, `10` + `docs/adr/*` | `02` (princípios), `04`, `05` |
| 4 | `/blueprint-flows` | `07`, `08` | `04`, `06`, `09`, `03` |
| 5 | `/blueprint-quality` | `12`, `13`, `14`, `15` | `05`, `06`, `07`, `03` |
| 6 | `/blueprint-plan` | `11`, `16` | `03`, `07`, `08`, `10`, `14` |
| 7 | `/backend` | `backend/00-14` | os 17 docs do blueprint |
| 8 | `/frontend-design-system` | `frontend/shared/03` | `01-vision` (identidade do produto) |
| 9 | `/frontend` | `frontend/shared/06`, `15` | blueprint + `backend/05-api-contracts.md` **quando existir** (a skill o trata como fonte autoritativa se presente — daí a ordem recomendada abaixo) |
| 10 | `/frontend-app {client}` | 8 docs do cliente | blueprint + shared |
| 11 | `/frontend-quality {client}` | 5 docs do cliente | `blueprint/12,13,14,15` + docs do cliente |
| 12 | `/codegen-setup` | `CLAUDE.md`, `src/contracts/`, schema, scaffold | `02` (patterns e convenções), `04`, `05`, `06`, `backend/00-04`, **`shared/glossary.md`** e, por cliente ativo, `{client}/02-project-structure` + `shared/03-design-system` |

> **Detalhe crítico da ordem:** a fase 9 (`/frontend`, que gera `shared/15-api-dependencies.md`) roda **depois** da fase 7 (`/backend`), porque `backend/05-api-contracts.md` é a fonte autoritativa dos endpoints. Inverter a ordem produz um frontend que consome endpoints que não existem.

### 2.3 As três direções de propagação

| Direção | Ferramenta | Quando |
| --- | --- | --- |
| **Para frente** (gerar do zero) | `/pipeline` ou as skills em sequência | Primeira versão |
| **Local** (uma feature, um doc) | `/increment` | Adicionar feature, corrigir dado, remover do escopo |
| **Global** (um termo, todos os docs) | `/patch` | Renomear entidade, trocar tecnologia, versionar endpoint |

`/increment` **evolui uma feature**. `/patch` **propaga uma mudança sistêmica**. Confundir os dois produz documentação parcialmente atualizada — o pior estado possível.

---

## 3. Matriz de rastreabilidade consolidada

Esta é a correlação integral entre arquivos. É o conteúdo de `docs/shared/MAPPING.md` expandido com as conexões que aparecem espalhadas nas skills e nos rodapés dos documentos.

### 3.1 Blueprint técnico → Backend

| Blueprint | Backend | O que flui concretamente |
| --- | --- | --- |
| `00-context` | `13-integrations` | Sistemas externos → clients de API, timeout, circuit breaker |
| `01-vision` | `00-backend-vision` | Métricas de sucesso → metas do backend; não-objetivos → limites |
| `02-principles` | `00-backend-vision` | Princípios → princípios de design; restrições → stack obrigatória |
| `03-requirements` | `05-api-contracts`, `10-validation` | RF → endpoints; RNF → metas de latência/uptime |
| `04-domain-model` | `03-domain`, `10-validation` | Entidades → classes com métodos; RN-XX → regras de validação |
| `05-data-model` | `04-data-layer` | Tabelas → repositories; queries críticas → índices |
| `06-architecture` | `01-architecture`, `08-middlewares` | Componentes → camadas; comunicação → pipeline; deploy → infra |
| `07-critical_flows` | `06-services`, `09-errors` | Fluxos → métodos de service com passo-a-passo; falhas → catálogo de erros |
| `08-use_cases` | `05-api-contracts`, `11-permissions` | UC → endpoint + controller + service; atores → matriz RBAC |
| `09-state-models` | `03-domain` | Estados → enum + máquina de estados na entidade; transições → métodos |
| `10-decisions` | `00-backend-vision`, `01-architecture` | ADRs → justificativa de stack e de padrão arquitetural |
| `11-build_plan` | — | Ordem de implementação (consumido por `/specs` e `/build`) |
| `12-testing` | `14-tests` | Pirâmide e cobertura → ferramentas e cenários obrigatórios |
| `13-security` | `08-middlewares`, `11-permissions` | Método de auth → middleware; RBAC → matriz por recurso |
| `14-scalability` | `08-middlewares` | Cache e rate limit → configuração por rota |
| `15-observability` | `08-middlewares` | Logs, métricas, traces → RequestId + Logger no pipeline |
| `16-evolution` | `05-api-contracts` | Estratégia de versionamento → `/v1/` na URL ou header |

### 3.2 Blueprint técnico → Frontend

| Blueprint | Frontend | O que flui concretamente |
| --- | --- | --- |
| `00-context` | `{client}/00-frontend-vision` | Atores → perfis de usuário e níveis de acesso |
| `01-vision` | `{client}/00`, `shared/03-design-system` | Problema → contexto; identidade → tipografia e paleta |
| `02-principles` | `{client}/01-architecture` | Princípios → regras de dependência entre camadas |
| `03-requirements` | `{client}/09-tests`, `{client}/10-performance` | RNF → Core Web Vitals / startup time / metas de cobertura |
| `04-domain-model` | `shared/03`, `{client}/04-components` | Entidades → tipos, formulários, componentes de feature |
| `05-data-model` | `shared/06-data-layer` | Schema → DTOs tipados e validação em runtime |
| `06-architecture` | `{client}/01`, `{client}/13-cicd` | Deploy → pipeline e ambientes do cliente |
| `07-critical_flows` | `{client}/08-flows` | Fluxo de sistema → fluxo de UI (mesma numeração, mesmos nomes) |
| `08-use_cases` | `{client}/07-routes`, `{client}/04-components` | UC → tela/rota + componentes que a compõem |
| `09-state-models` | `{client}/05-state` | Estados do domínio → o que a UI precisa representar |
| `13-security` | `{client}/11-security` | Auth → proteção de rota client-side (nunca a única) |
| `14-scalability` | `{client}/10-performance` | Cache → estratégia client-side (TTL, invalidação) |
| `15-observability` | `{client}/12-observability` | Métricas → error tracking, RUM, user flow monitoring |
| `backend/05-api-contracts` | `shared/15-api-dependencies` | Endpoints → mapa de dependências consumidas |
| `backend/09-errors` | `shared/error-ux-mapping` | Código de erro → comportamento visual |
| `backend/12-events` | `shared/event-mapping` | Evento de domínio → store afetada + update de UI |
| `backend/13-integrations` | `{client}/14-copies` | Templates de comunicação → copies e mensagens |

### 3.3 Documentos → Diagramas

| Diagrama | Seção que descreve textualmente | Gerado/atualizado por |
| --- | --- | --- |
| `context/system-context.mmd` | `blueprint/00-context` | `/blueprint-foundation` |
| `containers/container-diagram.mmd` | `blueprint/06-system-architecture` | `/blueprint-architecture` |
| `components/{container}-components.mmd` | `blueprint/06-system-architecture` | `/blueprint-architecture` |
| `sequences/{fluxo}.mmd` | `blueprint/07-critical_flows` | `/blueprint-flows` |
| `sequences/auth-flow.mmd` | `blueprint/13-security` | `/blueprint-quality` |
| `deployment/production.mmd` | `blueprint/06`, `14-scalability` | `/blueprint-architecture`, `/blueprint-quality` |
| `deployment/production-scaled.mmd` | `blueprint/14-scalability` | `/blueprint-quality` |
| `domain/class-diagram.mmd` | `blueprint/04-domain-model` | `/blueprint-domain` |
| `domain/er-diagram.mmd` | `blueprint/05-data-model` | `/blueprint-domain` |
| `domain/state-{entidade}.mmd` | `blueprint/09-state-models` | `/blueprint-domain` |
| `{client}/{client}-architecture.mmd` ⚠ | `frontend/{client}/01-architecture` | `/frontend-app` |
| `{client}/fluxo-{n}.mmd` | `frontend/{client}/08-flows` | `/frontend-app` |

**Arquivos-base que são copiados, não editados:**

| Template | Duplicado para | Por |
| --- | --- | --- |
| `domain/state-template.mmd` | `domain/state-{entidade}.mmd`, um por entidade com ciclo de vida | `/blueprint-domain` |
| `sequences/template-flow.mmd` | `sequences/{nome-do-fluxo}.mmd` e `{client}/fluxo-{n}.mmd` | `/blueprint-flows`, `/frontend-app` |
| `components/api-components.mmd` | `components/{container}-components.mmd`, um por container | `/blueprint-architecture` |

⚠️ **Divergências do repositório neste ponto** — verificadas, não resolvidas por escolha silenciosa. São as entradas 2 e 6 do índice consolidado de [§17.4](#174-divergências-internas-do-repositório-verificadas):

1. **Nome do diagrama de arquitetura do cliente web.** A skill `/frontend-app` manda criar `docs/diagrams/{client}/{client}-architecture.mmd`, o que daria `web-architecture.mmd`. Mas `docs/diagrams/web/README.md` declara **`frontend-architecture.mmd`** — e é esse o nome referenciado por `docs/frontend/web/01-architecture.md`. Para `mobile` e `desktop` os READMEs seguem o padrão da skill (`mobile-architecture.mmd`, `desktop-architecture.mmd`). **Só o cliente web diverge.**
2. **Dono do `auth-flow.mmd`.** `docs/diagrams/README.md` §6 atribui todos os `sequences/*.mmd` a `07-critical_flows.md`; a skill `/blueprint-quality` manda atualizar `auth-flow.mmd` com o fluxo de autenticação real ao gerar `13-security.md`. Na prática o arquivo tem dois donos — o fluxo vem de `07`, o detalhe de autenticação de `13`.

**Modelo C4** (Simon Brown), com o nível 4 (Code) intencionalmente omitido — o código-fonte é a documentação mais precisa daquele nível. Arquivos `.mmd` contêm Mermaid puro, sem wrapper markdown, para renderização direta por ferramentas.

### 3.4 As correlações que costumam ser esquecidas

Estas conexões não aparecem no `MAPPING.md` mas são obrigatórias segundo as skills — e são as que mais quebram quando alguém edita um documento isolado:

| Regra de consistência | Onde é exigida |
| --- | --- |
| Todo gatilho de transição em `08-use_cases` deve existir literalmente em `09-state-models` | `/blueprint-flows` — divergência é reportada, nunca inventada |
| Todo requisito **Must** de `03-requirements` deve estar dentro de alguma entrega de `11-build_plan` | `/blueprint-plan` — Musts fora são listados explicitamente |
| Todo threshold de alerta em `15-observability` deve bater com o limite de `14-scalability` | `/blueprint-quality` — dois números diferentes para a mesma métrica é erro |
| Todo fluxo crítico de `07` precisa de ≥1 teste E2E nomeado em `12-testing` | `/blueprint-quality` |
| Toda consequência negativa aceita num ADR (`10`) vira débito técnico em `16-evolution` | `/blueprint-architecture` → `/blueprint-plan` |
| Todo template de mensagem (`backend/13-integrations`) precisa de evento disparador em `backend/12-events` | `/backend` — template órfão é proibido |
| Toda rota de `{client}/07-routes` precisa de subseção em `{client}/14-copies` | `/frontend-app` — checklist de cobertura |
| Todo fluxo de `{client}/08-flows` precisa de ≥1 teste E2E em `{client}/09-tests` | `/frontend-quality` |
| Toda integração externa de `00`/`06` pede **teste de contrato** em `12-testing` | `/blueprint-quality` |
| O glossário de produto de `{client}/14-copies` cobre os termos de domínio de `04-domain-model` | `/frontend-app` — checklist de cobertura |
| As mensagens de erro de `{client}/14-copies` cobrem os cenários de erro dos endpoints de `shared/15-api-dependencies` | `/frontend-app` — checklist de cobertura |
| Toda lista e tela com dados dinâmicos tem **empty state** definido em `{client}/14-copies` | `/frontend-app` — checklist de cobertura |
| `shared/glossary.md` é a fonte única consumida por `blueprint/04-domain-model`, `backend/03-domain`, `{client}/04-components` e `{client}/14-copies` | rodapé do próprio `glossary.md` — nenhum deles cria glossário próprio |
| Débitos de `16-evolution` alimentam os **limites conhecidos** de `backend/00-backend-vision` (além do versionamento → `05-api-contracts`) | `/backend` — mapa de extração |
| Todo erro de `backend/09-errors` precisa de linha em `shared/error-ux-mapping` | `docs/shared/error-ux-mapping.md` — *"Para CADA código de erro do backend, documente a resposta no frontend"*. o Passo 3 de `/specs` manda identificar consumidor de frontend "para cada endpoint/evento/erro do backend", mas o **checklist final de cobertura não inclui esse cruzamento** — a validação depende do zelo do passo intermediário |

---

## 4. Fundação: contexto, visão, princípios, requisitos

**Fase 1** · Skill `/blueprint-foundation` · Gera `00`, `01`, `02`, `03` · Fonte: `docs/prd.md`

As três perguntas que esta fase faz (máximo 3 na skill inteira), em ordem de importância: **limites do sistema e integrações** (00), **métricas de sucesso e não-objetivos** (01), **SLAs e metas de performance** (03). São exatamente os três pontos que um PRD quase nunca cobre.

### 4.0 O PRD — a entrada de todo o sistema

`docs/prd.md`, escrito a partir de `docs/templates/prd-template.md` (20 seções). **A qualidade de tudo o que vem depois é limitada pela qualidade deste arquivo** — o framework estrutura incerteza, não inventa conhecimento de negócio. Um PRD raso produz documentação rasa com muitas suposições de risco alto.

| § | Seção | Por que é fundamental num SaaS | Alimenta |
| --- | --- | --- | --- |
| 1 | Resumo executivo | 3-5 linhas: o quê, para quem, que problema | `01-vision` |
| 2 | **Problema** — situação atual, **evidências** (fonte / dado / data), impacto de não resolver | Separa dor real de opinião: NPS, tickets/mês, % de abandono | `01-vision` §problema |
| 3 | Visão da solução — elevator pitch, solução, **princípios de design de produto** | Os princípios de produto são distintos dos arquiteturais de `02` | `01-vision`, `02-principles` |
| 4 | **Personas · Jobs to Be Done · Jornada atual** | JTBD (*"Quando {situação}, quero {ação}, para que {resultado}"*) e os **pontos de dor da jornada atual** são o insumo dos casos de uso | `00-context` §atores, `08-use_cases` |
| 5 | Objetivos (OBJ-01 com **alinhamento estratégico**) · KPIs (linha de base → meta → prazo → como medir) · **guardrails** | **Guardrails são métricas que NÃO podem piorar com o lançamento** — conversão, latência, disponibilidade. É o que impede uma feature de ganhar adoção destruindo o funil | `01-vision` §métricas, `03-requirements` §RNF |
| 6 | Não-objetivos | Trava expansão de escopo antes que ela comece | `01-vision` §não-objetivos |
| 7 | Requisitos funcionais por área + MoSCoW | RF-001… com **critério de aceitação verificável** por requisito | `03-requirements` |
| 8 | Requisitos não funcionais | RNF-001… com meta e método de medição (inclui **acessibilidade** WCAG e **compatibilidade** de browsers) | `03-requirements`, `12-testing` |
| 9 | User stories + **cenários detalhados** (fluxo principal, alternativos, **cenários de erro**) | É daqui que saem os fluxos alternativos de `08-use_cases`, que o PRD "normal" omite | `08-use_cases`, `07-critical_flows` |
| 10 | Escopo · entregas priorizadas (ENT-001…) · **definição de MVP** | O MVP explícito (*"o menor conjunto que entrega valor real"* + **o que NÃO está nele**) é a fronteira da primeira release | `11-build_plan` |
| 11 | Design e UX — fluxo ideal, wireframes/Figma, **requisitos de UX** | Ex.: "estados de loading, vazio, erro e sucesso para todas as telas" — vira checklist de `{client}/14-copies` | `{client}/08-flows`, `14-copies` |
| 12 | **Dependências** internas (time responsável) · externas (fornecedor, SLA, plano B) · técnicas | Dependência externa não resolvida é o atraso mais comum e o menos visível | `11-build_plan` §dependências externas |
| 13 | Riscos e mitigações (R-01, com owner e status) | | `11-build_plan` §riscos técnicos |
| 14 | **Hipóteses e validações** (H-01: hipótese → como validar → resultado esperado → status) | Um SaaS é uma aposta; a hipótese não validada é a que quebra o produto depois do lançamento | `01-vision`, ADRs |
| 15 | Restrições (técnica / negócio / regulatória / **temporal**) e premissas | *"Se alguma premissa se provar falsa, quais decisões precisariam ser revisitadas?"* | `00-context` §restrições |
| 16 | Segurança e privacidade — dados manipulados e classificação, compliance, considerações | PII, token de pagamento (tokenizar, não armazenar), logs sem PII | `13-security` |
| 17 | **Plano de lançamento** — rollout, comunicação, go/no-go | ver abaixo | `16-evolution`, `06-system-architecture` §deploy |
| 18 | **Suporte e operações pós-lançamento** | Novos tipos de chamado esperados, treinamento do suporte, FAQ; o que monitorar com threshold e ação | `15-observability`, runbooks |
| 19 | **Questões em aberto** (Q-01: questão / impacto / owner / prazo / status) | O que ainda não foi decidido, com dono e prazo — não vira suposição silenciosa | `ASSUMPTIONS.md` |
| 20 | Referências e aprovações (Produto, Engenharia, Design, Segurança, Stakeholder) | | governança |

**Plano de rollout (§17.1) — o que precisa estar decidido antes de lançar:**

| Etapa | Público | Critério de avanço | Rollback |
| --- | --- | --- | --- |
| **Alpha** | Time interno | Ex.: zero bugs críticos por 1 semana | estratégia definida |
| **Beta** | Ex.: 10% dos usuários | Métricas dentro do esperado | estratégia definida |
| **GA** | 100% | KPIs atingidos | estratégia definida |

**Plano de comunicação (§17.2)** — público / canal / mensagem / responsável / quando, cobrindo **usuários** (e-mail, in-app), **suporte** (FAQ, runbook, treinamento **antes** do lançamento) e **stakeholders** (resultados pós-lançamento).

> **Onde o PRD vira o resto:** `/blueprint` salva o PRD em `docs/prd.md`, classifica cada uma das 6 fases como **Coberto / Parcial / Lacuna** e indica nas observações o que provavelmente será perguntado em cada fase. É essa análise de cobertura que diz, antes de qualquer geração, se o modo autônomo é viável ou se o modo guiado é obrigatório.

### 4.1 `00-context.md` — Contexto do sistema

| Bloco | Conteúdo obrigatório | Marcador de append |
| --- | --- | --- |
| **Atores** | Pessoa / Sistema / Dispositivo + papel e motivação | `<!-- APPEND:actors -->` |
| **Sistemas externos** | Protocolo, função, criticidade, SLA conhecido, limites de uso | `<!-- APPEND:external-systems -->` |
| **Limites do sistema** | Lista explícita do que **é** e do que **não é** responsabilidade | — |
| **Restrições e premissas** | Técnica / Negócio / Regulatória + premissas com impacto se falsas | `<!-- APPEND:constraints -->` |
| **Diagrama de contexto** | C4 nível 1 → `docs/diagrams/context/system-context.mmd` | — |

> A pergunta que separa um bom `00` de um ruim: *"Existe funcionalidade que stakeholders assumem como parte do sistema, mas que pertence a outro sistema?"* — escrever isso evita meses de retrabalho.

### 4.2 `01-vision.md` — Visão do sistema

- **Problema** — dor real, quem sofre hoje, limitações das alternativas
- **Elevator pitch** — formato fixo: *"Para {público} que {necessidade}, o {sistema} é um {categoria} que {benefício}. Diferente de {alternativa}, nosso sistema {diferencial}."*
- **Objetivos** — específicos, mensuráveis, ligados ao problema
- **Usuários** — persona / necessidade / frequência de uso
- **Valor gerado** — tangível, por grupo (ex.: "reduz processo X de 15 min para 2 min")
- **Métricas de sucesso** — métrica / meta / como medir
- **Não-objetivos** — o que o sistema deliberadamente NÃO faz

O documento `01` alimenta duas coisas não óbvias: as **métricas do backend** (`backend/00`) e a **personalidade visual** do design system (`frontend/shared/03` — a escolha de tipografia e paleta deriva da identidade descrita aqui).

### 4.3 `02-architecture_principles.md` — Princípios arquiteturais

3 a 7 princípios. Funcionam como **filtro de decisão**: quando dois engenheiros discordam, o princípio decide.

Cada princípio tem: **Nome** (curto, memorável) · **Descrição** (1-2 frases) · **Justificativa** (por que importa para ESTE sistema) · **Implicações** (2-3 consequências concretas no dia a dia).

Um PRD raramente declara princípios. A skill os infere por sinais:

| Sinal no PRD | Princípio sugerido |
| --- | --- |
| Requisitos de segurança / dados sensíveis | Segurança por padrão |
| Requisitos de disponibilidade | Sem ponto único de falha |
| Requisitos de observabilidade / SLA | Observabilidade obrigatória |
| Menções a escala, crescimento, picos | Design para escala horizontal |
| Menções a simplicidade, time pequeno, prazo | Simplicidade sobre complexidade |

Referências prontas no repositório: *Simplicidade sobre complexidade*, *Segurança por padrão*, *Falhe rápido e explicitamente*.

### 4.4 `03-requirements.md` — Requisitos

**Funcionais** — tabela `RF-001 | descrição | prioridade MoSCoW | status`. Cada RF deve se conectar a um objetivo de `01`.

| Prioridade | Significado |
| --- | --- |
| **Must** | Sem ele o sistema não resolve o problema — obrigatório no lançamento |
| **Should** | Importante, mas o sistema funciona sem ele no curto prazo |
| **Could** | Desejável se houver tempo e recurso |
| **Won't** | Fora do escopo desta versão, documentado para o futuro |

**Não funcionais** — tabela `categoria | requisito | métrica | threshold`. Categorias: Performance, Disponibilidade, Segurança, Escalabilidade, Manutenibilidade, Usabilidade.

> **Regra dura:** um RNF sem threshold numérico não é requisito, é desejo. "API rápida" não testa; "latência p95 < 200 ms medida via APM" testa.

**Matriz de priorização** — `valor de negócio (1-5) | esforço técnico (1-5) | risco (1-5) → prioridade final`. Alto valor + baixo esforço são os candidatos naturais às primeiras entregas.

### 4.5 Governança: quem decide, quem é dono do risco, o que está em aberto

Estes blocos vivem no **blueprint master** (`docs/blueprint/README.MD` §0.3, §4, §5, §15, §24). São os que respondem *"quem responde por isso?"* — e num SaaS, ausência de dono é a causa-raiz de decisão que nunca é tomada.

**Precisão importante:** nem todos são exclusivos do master. O **conteúdo** de riscos, restrições e premissas tem casa modular — `00-context.md` §Restrições e Premissas (com `APPEND:constraints`) e `11-build_plan.md` §Riscos Técnicos (com `APPEND:technical-risks`). O que o §15 do master acrescenta são os **campos de governança** que a versão modular não tem: **IDs** (`A-01`, `C-01`, `R-01`), a coluna **"impacto se falsa"** da assunção, a **"fonte"** da restrição e o **"owner"** do risco. Já §0.3 (aprovações), §5 (stakeholders) e §24 (questões em aberto) não têm equivalente modular nenhum.

**Status de aprovação (§0.3)** — o documento não é "verdade" até ser aprovado:

| Papel | Responsável | Status | Data |
| --- | --- | --- | --- |
| Produto · Arquitetura · Segurança · Engenharia | | | |

**Stakeholders e responsabilidades (§5)** — stakeholder / área / interesse / **poder de decisão** (alto-médio-baixo) / **cadência de alinhamento** (semanal-mensal-ad hoc); e responsabilidade por área: Produto · Engenharia · Segurança · SRE · QA.

**Riscos, restrições e assunções (§15)** — três tabelas com ID e dono:

| Tabela | Campos |
| --- | --- |
| Assunções | `A-01` · assunção · **impacto se falsa** |
| Restrições | `C-01` · restrição · **fonte** (estratégia interna, legal, comercial) |
| Riscos | `R-01` · risco · probabilidade · impacto · mitigação · **owner** |

**Questões em aberto (§24)** — `Q-01` · questão · impacto · **owner** · prazo. Distinção que importa: uma **questão em aberto** tem dono e prazo; uma **suposição** (`ASSUMPTIONS.md`) já foi resolvida por inferência e precisa ser auditada. Confundir as duas é como um projeto perde rastreabilidade.

**Escopo (§4)** — escopo funcional · escopo técnico (serviços a criar, serviços a alterar, bancos impactados, filas impactadas, **contratos impactados**) · fora de escopo · fases de entrega.

### 4.6 Histórico de decisões por documento

**24 arquivos** terminam com uma tabela `Data | Decisão | Motivo`: exatamente os documentos **07 a 14 de cada um dos três clientes frontend** (`07-routes`, `08-flows`, `09-tests`, `10-performance`, `11-security`, `12-observability`, `13-cicd-conventions`, `14-copies` × web, mobile, desktop). **Nenhum documento de `docs/backend/`, de `docs/blueprint/` ou de `docs/frontend/shared/` tem essa seção** — é uma convenção que existe só na metade "de cliente" do frontend.

É o mecanismo de rastreabilidade mais barato do framework: registra **por que aquele documento mudou**, sem exigir um ADR formal. Que ele não exista nos outros **54 documentos do repositório** (78 docs com os três clientes, menos os 24 que o têm) é, em si, uma assimetria a resolver — e explica por que só o frontend de cliente consegue responder *"por que essa decisão mudou?"* sem abrir um ADR.

| Nível | Artefato | Quando usar |
| --- | --- | --- |
| Decisão estrutural do sistema | **ADR** em `docs/adr/` | Banco, framework, protocolo, padrão arquitetural, segurança estrutural |
| Decisão local do documento | **Histórico de Decisões** no rodapé do próprio doc | "Trocamos bottom tabs por drawer porque…", "Subimos o TTL do cache de 5 para 15 min porque…" |
| Decisão do blueprint inteiro | **Histórico de revisões** (`16-evolution`, `README.MD` §0.4) | Versão, data, autor, seções alteradas, motivo |

---

## 5. Domínio, dados e estados

**Fase 2** · Skill `/blueprint-domain` · Gera `04`, `05`, `09` — juntos, porque `05` e `09` são projeções diretas de `04`.

As três perguntas priorizadas: **regras de negócio e invariantes** (o mais difícil de inferir), **tecnologia de banco e volumes esperados** (determinam indexação e particionamento), **transições de estado proibidas** (o que o PRD quase nunca declara).

### 5.1 `04-domain-model.md` — Modelo de domínio

> O modelo de domínio **não** é o modelo de dados. Aqui o foco é comportamento e regra de negócio, não estrutura de armazenamento.

| Bloco | Conteúdo |
| --- | --- |
| **Glossário ubíquo** | Termo / definição. **Fonte única: `docs/shared/glossary.md`** — atualize lá também |
| **Entidades** | Por entidade: descrição, atributos (campo/tipo/obrigatório/descrição), regras de negócio `RN-XX`, eventos de domínio emitidos |
| **Relacionamentos** | Entidade A / cardinalidade (1:1, 1:N, N:M) / entidade B / regra |
| **Diagrama** | `docs/diagrams/domain/class-diagram.mmd` |

**Convenção de idioma (do `shared/glossary.md`):**

| Contexto | Convenção | Exemplo |
| --- | --- | --- |
| Entidades | PascalCase, singular, inglês | `User`, `Order`, `Product` |
| Campos | camelCase, inglês | `createdAt`, `userId`, `orderTotal` |
| Endpoints | kebab-case, plural, inglês | `/api/v1/users`, `/api/v1/order-items` |
| Eventos | PascalCase, passado, inglês | `UserCreated`, `OrderPaid` |
| Estados | lowercase, inglês | `created`, `active`, `suspended` |
| Erros | UPPER_SNAKE_CASE | `USER_NOT_FOUND`, `VALIDATION_ERROR` |
| Tabelas | snake_case, plural | `users`, `order_items` |

### 5.2 `05-data-model.md` — Modelo de dados

Traduz o domínio conceitual em persistência concreta.

- **Banco de dados** — tecnologia + justificativa ligada ao padrão de leitura/escrita e aos requisitos de consistência (forte vs eventual)
- **Tabelas/Collections** — campos com tipo, constraint (PK, FK, NOT NULL, UNIQUE), descrição
- **Índices** — nome, campos, tipo (BTREE/HASH/GIN), justificativa
- **Estratégia de migração** — ferramenta, convenção de nomes (`V001__create_users_table.sql`), rollback, política para migrações destrutivas (ex.: "deprecar coluna por 2 sprints antes de remover")
- **Queries críticas** — descrição, tabelas, frequência, SLA esperado
- **Diretrizes de otimização** — ex.: paginação por cursor em listagens grandes; cache para queries com leitura > 90%

**Retenção, arquivamento e recuperação** (`README.MD` §9.5-§9.6) — dois blocos que o template modular de `05-data-model` não traz e que num SaaS são obrigação contratual, não higiene:

| Bloco | O que decidir |
| --- | --- |
| **Retenção e arquivamento** | Por tipo de dado (logs, dados de negócio, PII): período de retenção · política de descarte · **justificativa** (legal, contratual, custo). É o que torna a promessa de exclusão da LGPD verificável |
| **Backup e restauração** | Periodicidade · **RPO** (quanto de dado se aceita perder) · **RTO** (em quanto tempo se volta) · **testes de restauração** periódicos |

> Nem toda entidade do domínio vira tabela, e uma entidade pode se espalhar por várias tabelas. A separação entre `04` e `05` existe para que decisões de negócio e de infraestrutura evoluam independentemente.

### 5.3 `09-state-models.md` — Modelos de estado

Para cada entidade com ciclo de vida (pedido, pagamento, **assinatura**, job, tarefa):

- **Estados possíveis** — estado / descrição
- **Transições** — De / Para / Gatilho / Condição
- **Transições proibidas** — explícitas (ex.: `completed → running`, `failed → pending` sem reset)
- **Estados terminais** — de onde não se sai
- **Ações por transição** — emitir evento, auditar mudança, atualizar timestamp
- **Diagrama** — `docs/diagrams/domain/state-{entidade}.mmd`

**Exemplo canônico do repositório (Pedido):** `Rascunho → Confirmado → Pago → Em Separação → Enviado → Entregue`, com `Cancelado` alcançável de `Confirmado` (antes do pagamento) e de `Pago` (com política de reembolso).

> Os gatilhos nomeados aqui são **contrato** com a fase 4: os casos de uso de `08` devem usar exatamente estes nomes. Divergência é reportada, não resolvida por invenção.

---

## 6. Arquitetura do sistema e ADRs

**Fase 3** · Skill `/blueprint-architecture` · Gera `06`, `10` + um arquivo por ADR em `docs/adr/`.

Os dois documentos saem juntos de propósito: **ADR escrito longe da arquitetura vira genérico**.

### 6.1 `06-system-architecture.md`

| Bloco | Conteúdo |
| --- | --- |
| **Componentes** | Nome, responsabilidade, tecnologia, interface exposta (REST/gRPC/eventos/fila) |
| **Comunicação** | De / Para / Protocolo / sync-async / descrição do fluxo |
| **Ambientes** | Dev, Staging, Prod — finalidade, URL, observações |
| **Decisões de infraestrutura** | Cloud provider, orquestração, CI/CD, monitoramento, banco, mensageria |
| **Diagramas** | `containers/container-diagram.mmd`, `components/api-components.mmd`, `deployment/production.mmd` |

A versão estendida (README mestre) acrescenta blocos que valem ouro em SaaS:

- **Responsabilidades por componente** — o que faz, **o que não faz**, dependências, limites operacionais
- **Padrões arquiteturais usados** — monólito modular, microsserviços, event-driven, CQRS, outbox, saga, cache-aside
- **Boundaries e isolamento** — bounded contexts, trust boundaries, **multi-tenant vs single-tenant**, isolamento lógico/físico
- **Single points of failure** — lista explícita + mitigação
- **Trade-offs conhecidos** — concessões assumidas (ex.: menor consistência por escala)

**Integrações e interfaces** (`README.MD` §11) — o único bloco do master **sem equivalente modular nenhum**. Ele consolida numa página a fronteira contratual do sistema:

| Bloco | Campos |
| --- | --- |
| **APIs expostas** | Interface · consumidor · método · objetivo · auth · SLA |
| **Eventos emitidos** | Evento · quando ocorre · payload · **consumidores** |
| **Eventos consumidos** | Evento · origem · ação no recebimento · **regra de idempotência** |
| **Contratos externos** | Webhooks · APIs parceiras · SLAs · retries · circuit breaker · fallback |
| **Política de versionamento de interface** | URI versioning? Header versioning? Schema evolution? |

Na estrutura modular, esse conteúdo se espalha por `backend/05-api-contracts` (APIs), `backend/12-events` (eventos) e `backend/13-integrations` (contratos externos) — o que funciona, mas perde a visão única de *"tudo que atravessa a fronteira do sistema"*. Para um SaaS com integradores, essa página única costuma valer o esforço de manter.

### 6.2 `10-architecture_decisions.md` + `docs/adr/`

**Quando escrever um ADR:** escolha de banco/fila/infra · framework ou linguagem principal · protocolo de comunicação · padrão arquitetural · alteração de decisão anterior (marcar a antiga como Substituída) · impacto estrutural em segurança, performance ou escalabilidade.

> Na dúvida, registre. É melhor um ADR a mais do que perder o contexto de uma decisão importante.

**Estrutura do ADR** (`docs/adr/adr-template.md`):

```
ADR-{ID}: {Título}     Data · Status (Proposta|Aceita|Deprecada|Substituída por ADR-XX) · Autores
├── Contexto              problema, cenário atual, restrições (prazo, equipe, orçamento, legado)
├── Drivers de decisão    fatores decisivos — amarrados aos princípios de 02
├── Opções consideradas   2-3 alternativas: prós, contras, esforço, risco
├── Decisão               opção escolhida + justificativa ligada aos drivers
├── Consequências         positivas · negativas (viram débito em 16) · riscos + mitigação
├── Ações necessárias     checklist de implementação
└── Histórico             data, autor, mudança
```

**A regra que fecha o ciclo:** as **consequências negativas aceitas** aqui viram **débito técnico** em `16-evolution.md` na fase 6. Escreva-as de forma transportável.

---

## 7. Fluxos críticos e casos de uso

**Fase 4** · Skill `/blueprint-flows` · Gera `07`, `08` — juntos porque usam a mesma matéria-prima; separados, divergem.

As três perguntas priorizadas: **cenários de erro** (o que o PRD quase sempre omite), **SLAs por fluxo**, **fluxos alternativos**.

### 7.1 `07-critical_flows.md` — 3 a 5 fluxos

Um fluxo é crítico quando sua falha impacta diretamente o valor entregue. Por fluxo:

| Bloco | Conteúdo |
| --- | --- |
| Descrição e criticidade | 1-2 frases + por que é crítico |
| Atores envolvidos | Quem inicia, quem participa, serviços externos |
| Passos | Lista numerada — caminho feliz |
| Diagrama de sequência | `docs/diagrams/sequences/{nome-do-fluxo}.mmd` |
| Tratamento de erros | Passo / falha possível / comportamento esperado (retry, fallback, mensagem) |
| Requisitos de performance | Latência p95, p99, throughput mínimo |

**Fluxos mínimos recomendados** (README mestre §12.2): criação · atualização · exclusão · processamento assíncrono · retry · falha parcial · reprocessamento · rollback/compensação.

A versão estendida do template de fluxo acrescenta ainda: **pré/pós-condições**, **timeouts e retries**, **idempotência** (como evitar duplicidade), **observabilidade** (quais logs, métricas e traces devem existir) e **critérios de aceitação**.

**Exemplo do repositório (Autenticação):** 7 passos (credenciais → gateway → auth service → validação → DB → JWT → retorno), com erros mapeados: gateway indisponível (mensagem + retry), DB indisponível (503 + circuit breaker), credenciais inválidas (401 + contador, bloqueio após 5 falhas), falha na geração do token (500 + log). Metas: p95 < 300 ms, p99 < 800 ms, 200 req/s.

### 7.2 `08-use_cases.md` — Casos de uso

| | Casos de Uso | User Stories |
| --- | --- | --- |
| **Formato** | Estruturado, fluxos passo a passo | "Como ___, quero ___, para ___" |
| **Detalhe** | Alto — alternativas e exceções | Baixo — foco na intenção |
| **Melhor para** | Regras complexas, integrações, contratos de API | Backlog ágil, priorização, comunicação rápida |

> Na dúvida: comece com User Story para capturar intenção, evolua para Caso de Uso quando precisar detalhar comportamento.

Por caso de uso: **UC-{ID}** · ator principal e secundários · pré-condição · fluxo principal numerado · fluxos alternativos (`2a`, `3a`) · fluxo de exceção (`2b`, `3b`) · pós-condição · regras de negócio relacionadas (`RN-XX` de `04`) · requisitos relacionados (`RF-XXX` de `03`).

**Consistência obrigatória:** casos de uso que alteram estado usam exatamente os gatilhos nomeados em `09-state-models.md`. Transição sem caso de uso — ou caso de uso exigindo transição não documentada — é reportado ao usuário, nunca resolvido por invenção.

Os casos de uso são a ponte para o frontend: `08-use_cases` → `{client}/07-routes` (cada UC vira tela) e → `backend/05-api-contracts` (cada UC vira endpoint + controller + service).

---

## 8. Backend — especificação de implementação

**Skill `/backend`** · Lê os 17 docs do blueprint · Gera 15 documentos em `docs/backend/`.

> O blueprint é a fonte primária. O backend especifica **detalhes de implementação** — framework, ORM, estrutura de classes, métodos — sem redefinir o produto.

**Ordem de preenchimento** (cada fase usa o que a anterior produziu):

```
A. Base       00-backend-vision → 01-architecture → 02-project-structure
B. Domínio    03-domain → 04-data-layer
C. API        05-api-contracts → 06-services → 07-controllers
D. Infra      08-middlewares → 09-errors → 10-validation → 11-permissions
E. Async      12-events → 13-integrations
F. Qualidade  14-tests
```

### 8.1 `00-backend-vision` — Stack e princípios

| Camada | Exemplo do repositório |
| --- | --- |
| Linguagem | TypeScript 5.x — tipagem estática, ecossistema npm |
| Framework | Fastify 4.x — performance, validação por schema |
| ORM | Prisma 5.x — type-safety, migrations, studio |
| Banco principal | PostgreSQL 16 — ACID, JSONB, extensões |
| Cache | Redis 7.x — sessions, cache, rate limiting |
| Fila | BullMQ 5.x — jobs assíncronos, retry, backoff |
| Storage | S3 — arquivos, imagens, documentos |

Mais: **camadas** (responsabilidade / depende de / não depende de), **princípios de design** (fail-fast, observabilidade, idempotência), **objetivos e métricas** (p95, uptime, taxa de erro, throughput), **não-objetivos**, **provedores** (RDS/Supabase/Neon, Redis Cloud, S3/R2, Resend/SES).

### 8.2 `01-architecture` — Camadas e regras de dependência

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │  Controllers, Routes, Middlewares
├─────────────────────────────────────────┤
│           Application Layer             │  Services, DTOs, Validators
├─────────────────────────────────────────┤
│             Domain Layer                │  Entities, Value Objects, Events
├─────────────────────────────────────────┤
│         Infrastructure Layer            │  Repositories, Cache, Queue, External
└─────────────────────────────────────────┘
```

**Regras de dependência inegociáveis:**

- Domain **nunca** importa de Infrastructure ou Presentation
- Controllers **nunca** acessam repositories diretamente — sempre via Service
- Services **nunca** retornam entidades de ORM — sempre DTO ou entidade de domínio
- Toda dependência externa (banco, cache, API) é acessada via **interface definida em Domain**

**Fronteiras de domínio** — módulo / responsabilidade / entidades principais / depende de. **Comunicação entre módulos** — síncrona (chamada de service) ou assíncrona (evento via fila). Exemplo: `Orders → Users` síncrono; `Orders → Notifications` assíncrono (`OrderPaid` → e-mail).

**Pipeline CI/CD:** `Push → Lint → Test → Build → Deploy Staging → Smoke Test → Deploy Prod`.

### 8.3 `02-project-structure` — Árvore e convenções

```
src/
├── config/          env.ts, database.ts, cache.ts, auth.ts
├── domain/          entities/ value-objects/ events/ errors/
├── application/     services/ dtos/ validators/
├── infrastructure/  repositories/ cache/ messaging/ external/ orm/
├── presentation/    controllers/ routes/ middlewares/ serializers/
├── workers/         jobs assíncronos e consumers de fila
├── shared/          types/ utils/ constants/
└── tests/           unit/ integration/ e2e/
```

Alternativa **por módulo** (`src/modules/users/{domain,application,infrastructure,presentation}`) para backends multi-domínio.

> **Escolha por camada OU por módulo. Não misture.**

| Tipo | Convenção | Exemplo |
| --- | --- | --- |
| Entidade | PascalCase, singular | `User.ts` |
| Service | PascalCase + Service | `UserService.ts` |
| Controller | PascalCase + Controller | `UserController.ts` |
| Repository | PascalCase + Repository | `UserRepository.ts` |
| DTO | PascalCase + sufixo DTO | `CreateUserDTO.ts` |
| Middleware | camelCase | `authenticate.ts` |
| Teste | `arquivo.test.ts` | `UserService.test.ts` |
| Migration | `timestamp_descricao` | `20240101_create_users.ts` |
| Erro | PascalCase + Error | `UserNotFoundError.ts` |
| Evento | PascalCase passado | `UserCreated.ts` |

### 8.4 `03-domain` — Entidades ricas

Cada entidade documenta: **atributos** (campo, tipo, obrigatório, validação, descrição) · **invariantes** (regras que NUNCA podem ser violadas) · **métodos** (parâmetros, retorno, descrição) · **eventos emitidos** (quando, payload).

Exemplo `User` do repositório:

- Atributos: `id`, `email` (único, max 255), `name`, `passwordHash`, `role` (enum), `status` (enum), `createdAt`, `updatedAt`, `deletedAt` (soft delete)
- Invariantes: email único no sistema · status só transiciona conforme a máquina · `passwordHash` nunca exposto em response
- Métodos: `create()`, `activate()`, `suspend(reason)`, `deactivate()`, `changeEmail()`, `changePassword()`
- Eventos: `UserCreated`, `UserActivated`, `UserDeactivated`, `UserEmailChanged`, `UserPasswordChanged`

Mais: **value objects** (Email, Money, Address — imutáveis, definidos pelo valor) · **regras de negócio** com `RN-XX` e onde validar (Domain / Service / Controller) · **relacionamentos** com cascade · **máquinas de estado** com transições, side-effects, estados terminais e transições proibidas.

### 8.5 `04-data-layer` — Repositories e persistência

- **Estratégia de persistência** — PostgreSQL (transacional) + Redis (cache/sessões) + S3 (arquivos), cada um com justificativa
- **Repositories** — interface (método, parâmetros, retorno, query principal) + índices com justificativa
- **Schema do ORM** — Prisma/Drizzle/TypeORM, cada tabela mapeando para uma entidade
- **Migrations** — ferramenta, convenção, rollback obrigatório, política por ambiente (dev auto, staging CI, prod manual com aprovação), seed nunca em prod
- **Queries críticas** — descrição, tabelas, frequência, SLA p95, otimização
- **Consistência e transações** — local (BEGIN/COMMIT), distribuída (saga com compensação), eventual (write-through ou invalidação por evento)
- **Idempotência** — idempotency key no header, dedup por `event_id`

Exemplo de índices para `users`: `idx_users_email` (UNIQUE — login e unicidade), `idx_users_role` (BTREE — filtro), `idx_users_created` (BTREE DESC — ordenação), `idx_users_deleted` (BTREE — soft delete).

### 8.6 `05-api-contracts` — O contrato entre frontend e backend

**Convenções gerais** (aplicam-se a todos os endpoints):

| Aspecto | Convenção |
| --- | --- |
| Base URL | `/api/v1` |
| Formato | JSON (`application/json`) |
| Autenticação | `Authorization: Bearer <token>` |
| Paginação | `?page=1&limit=20` → `{ data: [], meta: { total, page, limit, pages } }` |
| Ordenação | `?sort=created_at&order=desc` |
| Filtros | `?status=active&role=admin` |
| Versionamento | URL path (`/v1/`) |
| Rate limit headers | `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` |

**Mapa de endpoints** por recurso: `Método | Rota | Controller.método | Service.método | Auth | Descrição`. Padrão REST: POST (criar) · GET lista (paginada) · GET `/:id` · PATCH `/:id` · DELETE `/:id`.

**Por endpoint:** request (campo, tipo, obrigatório, validação, exemplo) · response 2xx (JSON real) · **erros** (status, código, mensagem, quando).

**DTOs:** request (`CreateUserDTO`, `UpdateUserDTO`, `ListUsersQueryDTO`) e response (`UserResponseDTO` — com lista explícita do que **exclui**: `passwordHash`, `deletedAt`; `PaginatedResponseDTO`).

> Este documento é consumido literalmente por `docs/frontend/shared/15-api-dependencies.md`. Mudança de campo aqui quebra tela lá — e o mapa de campos críticos existe para tornar isso visível antes do deploy.

### 8.7 `06-services` — Orquestração de negócio

**Convenções:** services orquestram, não acessam banco direto · recebem DTO, retornam entidade/DTO · operação crítica dentro de transação · emitem eventos após sucesso · **não conhecem HTTP** (sem req/res/headers/status).

Por service: responsabilidade · **o que NÃO faz** (delimita fronteira) · dependências (repository, outros services, EventBus, cache) · métodos.

**Fluxo detalhado** dos métodos críticos, passo a passo. Exemplo `UserService.register()`:

```
1. Recebe CreateUserDTO { email, name, password }
2. Valida formato de email e força da senha
3. UserRepository.findByEmail(email)
4. Se existe → lança UserAlreadyExistsError
5. Hash da senha com bcrypt (salt rounds: 12)
6. User.create({ email, name, hashedPassword })
7. BEGIN TRANSACTION
8.   UserRepository.save(user)
9. COMMIT
10. Emite UserCreated via EventBus
11. Enfileira SendWelcomeEmail
12. Retorna User (sem passwordHash)
```
Transação: sim (save). Idempotência: email único garante dedup natural.

**Injeção de dependências:** constructor injection, container DI (tsyringe/inversify/Nest) ou factory functions.

### 8.8 `07-controllers` — Borda HTTP

Controllers **não** contêm lógica de negócio e **não** acessam repositories. Responsabilidade: parse de parâmetros → chamar service → formatar response.

Registro de rotas com a cadeia completa de middlewares:

```
router.post  ('/api/v1/users',     authenticate, validate(CreateUserSchema), UserController.create)
router.get   ('/api/v1/users',     authenticate, authorize('admin','manager'), UserController.list)
router.get   ('/api/v1/users/:id', authenticate, UserController.findById)
router.patch ('/api/v1/users/:id', authenticate, authorizeOwner, validate(UpdateUserSchema), UserController.update)
router.delete('/api/v1/users/:id', authenticate, authorize('admin'), UserController.delete)
```

**Serializers:** `toUserResponse()` (remove `passwordHash`, `deletedAt`), `toPaginatedResponse()`, `toErrorResponse()` (remove stack trace em prod).

### 8.9 `08-middlewares` — Pipeline de request

```
Request
  → 1.  RequestId        gera UUID para tracing (X-Request-Id)
  → 2.  Logger           method, path, início
  → 3.  CORS             headers de cross-origin
  → 4.  RateLimiter      limites por IP, usuário e endpoint
  → 5.  BodyParser       parse JSON, limite de tamanho (1MB)
  → 6.  Authentication   valida JWT, extrai user       → 401
  → 7.  Authorization    verifica role/permissão        → 403
  → 8.  Validation       schema Zod/Joi                 → 400
  → 9.  Controller       executa via service
  → 10. Serializer       formata, remove campos sensíveis
  → 11. ErrorHandler     catch global, erro padronizado → 500
  → 12. Logger           status, duração, tamanho
Response
```

**Condicionais:** Authentication (todas exceto `/auth/login`, `/auth/register`, `/health`) · Authorization (rotas admin) · FileUpload (multipart) · **Idempotency** (`POST /orders`, `POST /payments` exigem header `Idempotency-Key`).

**Rate limiting** (fonte da estratégia: `blueprint/14-scalability`; valores por rota aqui):

| Escopo | Limite | Janela | Algoritmo | Storage |
| --- | --- | --- | --- | --- |
| Global por IP | 100 req | 1 min | Sliding window | Redis |
| Login | 10 req | 1 min | Token bucket | Redis |
| API por usuário | 1000 req | 1 min | Sliding window | Redis |
| Upload | 5 req | 1 min | Fixed window | Redis |

### 8.10 `09-errors` — Contrato de erro

**Formato único de toda a API:**

```json
{
  "error": {
    "code": "UPPER_SNAKE_CASE",
    "message": "Mensagem legível e segura para o usuário",
    "status": 400,
    "details": [{ "field": "email", "message": "formato inválido" }],
    "requestId": "uuid-do-request",
    "timestamp": "ISO8601"
  }
}
```

Regras: `details` só em validação (400) · `requestId` vem do middleware RequestId · **stack trace NUNCA em produção**.

**Hierarquia:** `AppError` → `ValidationError (400)` · `AuthenticationError (401)` · `AuthorizationError (403)` · `NotFoundError (404)` · `ConflictError (409)` · `BusinessRuleError (422)` · `RateLimitError (429)` · `ExternalServiceError (502)`.

**Catálogo** (código / status / quando / retentável):

| Código | Status | Quando | Retentável |
| --- | --- | --- | --- |
| `VALIDATION_ERROR` | 400 | Schema falhou | Não |
| `INVALID_CREDENTIALS` | 401 | Login falhou | Não |
| `TOKEN_EXPIRED` | 401 | JWT vencido | Sim (refresh) |
| `INVALID_TOKEN` | 401 | JWT malformado | Não |
| `INSUFFICIENT_PERMISSIONS` | 403 | Role sem acesso | Não |
| `RESOURCE_OWNERSHIP` | 403 | Dado de outro usuário | Não |
| `NOT_FOUND` | 404 | ID inexistente | Não |
| `DUPLICATE_RESOURCE` | 409 | Violação de unicidade | Não |
| `INVALID_STATE_TRANSITION` | 422 | Ex.: cancelar pedido entregue | Não |
| `RATE_LIMIT_EXCEEDED` | 429 | Limite atingido | Sim (após cooldown) |
| `EXTERNAL_SERVICE_ERROR` | 502 | Timeout/falha de terceiro | Sim |
| `INTERNAL_ERROR` | 500 | Não tratado | Sim |

**Estratégia por tipo** (onde tratar / logar / alertar / retry): validação → middleware, debug, sem alerta · autenticação → middleware, warn, alerta se >10/min por IP · negócio → service, info · externo → client, error, alerta se >5% de falha, retry com backoff · interno → ErrorHandler global, error+stack, **sempre alerta**.

### 8.11 `10-validation` — Validação em 4 camadas

| Camada | O que valida | Ferramenta | Exemplo |
| --- | --- | --- | --- |
| Presentation | Formato (tipo, required, min/max) | Zod / Joi / class-validator | email é string válida |
| Application | Regra de negócio simples | Lógica do service | email único no sistema |
| Domain | Invariante da entidade | Método da entidade | status só transiciona conforme máquina |
| Infrastructure | Constraint do banco | ORM / DB | UNIQUE, NOT NULL, FK |

Mais: **regras por campo** (tipo, regras, mensagem) · **validações cross-field** (datas coerentes, confirmação de senha, desconto ≤ 50%) · **params e query** (`:id` UUID v4, `?page` ≥1, `?limit` 1-100, `?sort` enum) · **sanitização** (email lowercase+trim, HTML strip tags → anti-XSS, URLs só https → anti-SSRF).

### 8.12 `11-permissions` — AuthZ e ownership

| Aspecto | Decisão a registrar |
| --- | --- |
| Modelo | RBAC / ABAC / Híbrido |
| Autenticação | JWT / Session / OAuth 2.0 |
| Provedor | Auth0 / Cognito / Keycloak / Supabase / próprio |
| Onde verificar | Middleware de Authorization |
| **Multi-tenancy** | **Sim/Não — se sim, `tenant_id` em todo recurso** |

**Roles** com herança (`admin` → tudo; `manager` herda `user`; `user` herda `viewer`; `viewer` só leitura).

**Matriz de permissões por recurso** — ação × role, com regra especial (ex.: manager filtra por `team_id`; user só edita a si mesmo).

**Ownership** — recurso / owner field / regra. **Campos visíveis por role** — nem todo role vê todo campo (ex.: `Order.internalNotes` só admin/manager).

**JWT claims:**
```json
{ "sub": "userId", "email": "...", "role": "...", "teamId": "...", "iat": 0, "exp": 0, "iss": "..." }
```
Access token: 15 min. Refresh token: 7 dias (`POST /auth/refresh`).

### 8.13 `12-events` — Assíncrono

**Estratégia:** broker (BullMQ/RabbitMQ/Kafka/SQS) · padrão (Pub-Sub / Queue / Event Sourcing) · formato JSON · **idempotência por `eventId` + timestamp**.

**Mapa de eventos:** evento / produtor / consumidores / fila / retry / DLQ.

**Schema de evento** (envelope padronizado):
```json
{
  "eventId": "UUID",
  "type": "UserCreated",
  "version": "1.0",
  "timestamp": "ISO8601",
  "source": "user-service",
  "payload": { }
}
```

**Workers:** fila, função, concorrência, timeout, retry, DLQ. Exemplos: `EmailWorker` (5 concorrentes, 30 s, 3× backoff 30 s), `WebhookWorker` (10 concorrentes, 15 s, 5× exponencial), `ReportWorker` (2 concorrentes, 120 s).

**Retry:** exponencial (1,2,4,8,16 s) para serviços externos · linear (30,60,90 s) para e-mail/notificação · imediato para erro transiente de banco. Esgotados os retries → **DLQ**, revisada periodicamente.

**Cron jobs:** `CleanExpiredSessions` (1 h), `GenerateDailyReport` (02:00), `RetryFailedPayments` (30 min).

### 8.14 `13-integrations` — Terceiros e canais de comunicação

**Por integração:** client class · métodos (endpoint externo, timeout, retry) · **circuit breaker** (threshold 5 falhas/60 s → aberto 30 s → half-open com 1 request de teste) · **fallback** (enfileirar para reprocessamento, cache da última leitura, refund manual) · variáveis de configuração.

**Webhooks recebidos:** serviço / evento / endpoint local / ação / **validação** (signature verification — obrigatória).
**Webhooks enviados:** evento / destino / payload / retry / **assinatura HMAC-SHA256**.

**Canais de comunicação** (e-mail, SMS, WhatsApp) — este bloco é o que conecta backend e copies do frontend:

- **Provedores por canal** com fallback, limite mensal e custo por envio
- **Catálogo de templates** — `ID | canal | evento disparador | assunto | variáveis | obrigatório`. **Todo template precisa de um evento declarado em `12-events`; template órfão é proibido.**
- **Variáveis e personalização** — origem, fallback, exemplo
- **Prioridade entre canais** — ex.: verificação vai por SMS; se falhar 2×, WhatsApp
- **Rate limits de envio** — por usuário/canal (5/h), marketing (2/7d), global por provedor (1000/min com backpressure)
- **Convenções por canal** — e-mail (assunto ≤ 50 chars, 1 CTA, descadastro obrigatório em marketing) · SMS (160 chars, sem links encurtados) · WhatsApp (template pré-aprovado pela Meta, janela de 24 h)

**Health checks de integração:** PostgreSQL `SELECT 1` (10 s, P1) · Redis `PING` (10 s, P1) · gateway de pagamento (60 s, P2, enfileirar) · e-mail (60 s, P3, fallback de provedor).

### 8.15 `14-tests` — Estratégia do backend

**Pirâmide:** 70% unitário (< 1 s) · 20% integração (< 5 s) · 10% E2E (< 30 s).

**Cobertura mínima:** geral 80% · **domain (entidades, regras) 95%** · services 90% · controllers 70% · **fluxos críticos 100%**.

**Cenários obrigatórios (Must):** happy path de cada fluxo crítico (E2E) · validação de todos os campos de entrada · regras de negócio/invariantes · transições de máquina de estado · autenticação (token válido, expirado, ausente) · autorização (role certo, errado, owner) · dados inválidos e edge cases.
**(Should):** timeout de serviço externo · retry e DLQ · concorrência/race condition · idempotência · performance sob carga.

**Ambientes:** unit (tudo mock) · integration (**Testcontainers** com Postgres e Redis reais) · E2E (staging + sandbox real) · load (staging com externos mockados).

**CI:** pre-commit (lint+unit, 2 min, bloqueia) · PR (unit+integration, 5 min, bloqueia) · merge main (+E2E, 10 min, bloqueia) · nightly (load+stress, 30 min, alerta).

---

## 9. Frontend — multi-client

**Skills:** `/frontend` (orquestrador + shared 06, 15) · `/frontend-design-system` (shared 03) · `/frontend-app {client}` (8 docs) · `/frontend-quality {client}` (5 docs).

```
docs/frontend/
├── shared/                        gerado UMA VEZ, vale para todos os clientes
│   ├── 03-design-system.md        tokens, tipografia, cores, iconografia, a11y
│   ├── 06-data-layer.md           API client, data fetching, DTOs, BFF, cache
│   └── 15-api-dependencies.md     mapa de endpoints consumidos + campos críticos
└── {web|mobile|desktop}/          13 docs POR CLIENTE
    ├── 00-frontend-vision  01-architecture  02-project-structure
    ├── 04-components       05-state         07-routes        08-flows   14-copies
    └── 09-tests  10-performance  11-security  12-observability  13-cicd-conventions
```

> Em monorepo: `docs/frontend/shared/` documenta o que vive em `packages/`; `docs/frontend/{client}/` documenta o que vive em `apps/{client}/`.

### 9.1 `shared/03-design-system.md` — Fonte única do visual

**Design tokens:** cores (primary, secondary, background, surface, text, error, warning, success) · tipografia (heading-1/2, body, caption, code) · **espaçamento em grid de 8px** (xs 4 · sm 8 · md 16 · lg 24 · xl 32 · 2xl 48) · breakpoints (sm 640 · md 768 · lg 1024 · xl 1280).

**Tipografia** — a skill deriva a **categoria** da identidade do produto descrita em `01-vision.md`, **apresenta 2-3 pares** (heading + body, Google Fonts, referência [Fontpair](https://www.fontpair.co/all)) e **pergunta ao usuário** qual representa melhor o produto — não decide sozinha:

| Categoria | Quando usar | Exemplos (Heading / Body) |
| --- | --- | --- |
| Serif + Sans | Editorial, premium, confiança | Playfair Display / Source Sans 3 · Lora / Open Sans |
| Sans + Sans | Moderno, limpo, tech | Montserrat / Lato · Inter / Inter |
| Display + Sans | Bold, criativo, impactante | Abril Fatface / Raleway · Anton / Roboto |
| Slab Serif + Sans | Sólido, editorial moderno | Arvo / Lato · Bitter / Source Sans Pro |
| Monospace + Sans | Técnico, developer tools | JetBrains Mono / Inter · Space Mono / Work Sans |

Tokens: `--font-heading`, `--font-body`, `--font-mono` · escala de `font-size` (xs 12 → 4xl 36) · `font-weight` (300→700) · `line-height` (tight 1.25 · normal 1.5 · relaxed 1.75).

**Paleta** — 5 cores (Coolors) mapeadas para variáveis semânticas em `oklch`, padrão shadcn/ui:

```
Cor 1 (mais escura/âncora)  → --primary       botões, links, CTA principal
Cor 2 (complementar)        → --accent        destaque secundário, hover
Cor 3 (neutra/suave)        → --secondary     backgrounds alternativos, badges
Cor 4 (quente/atenção)      → --warning       alertas
Cor 5 (vibrante/contraste)  → --destructive   erros, ações destrutivas
```

O `globals.css` documenta **todas** as variáveis em light e dark: backgrounds, card/popover, semânticas, status (success/warning/info), border/input/ring, chart-1..5 e sidebar. **Regras de derivação:** `ring` = `primary` · `card/popover` levemente mais claro que `background` · dark mode inverte a lightness (L) do oklch mantendo chroma (C) e hue (H).

**Iconografia:** Lucide Animated (primária — loading, transições, feedback, onboarding, empty states) + shadcn/ui Icons (complementar — navegação, botões, menus, tabelas). Tamanhos: sm 16 · md 20 · lg 24 · xl 32; stroke 1.5-2px; sempre `currentColor`; **não misturar outros icon packs**.

**Temas** — decisão explícita entre *light only* / *light + dark* / *customizável pelo usuário*, com a estratégia documentada: como os tokens são alternados, onde fica a lógica de troca, se usa CSS variables ou outra abordagem. A regra de derivação do dark mode é **inverter a lightness (L) do oklch mantendo chroma (C) e hue (H)**. *(Nota: o template usa o seletor `[data-theme="dark"]` e a skill usa `.dark` — divergência menor, mas escolha um e use em todo o projeto.)*

**Ferramentas que ligam design e código** — **Figma** (design de interfaces e prototipação) e **Storybook** (documentação interativa de componentes), com URL registrada. O Storybook é citado como o lugar a consultar **antes de criar qualquer componente novo**.

**Catálogo de componentes base** — tabela `componente | variantes | status` (Pronto / Em desenvolvimento / Planejado), cobrindo os 10 primitivos: Button, Input, Select, Card, Modal, Toast, Badge, Avatar, Tooltip, Skeleton. O status é o que impede duas pessoas construírem o mesmo componente em paralelo.

**Acessibilidade — meta WCAG 2.1/2.2 AA.** Os 8 itens verificáveis estão consolidados em [§16.6](#166-checklist-de-acessibilidade); aqui ficam os **padrões por componente**, que são a parte que o design system precisa carregar.

Padrões ARIA documentados por componente: Button (`role="button"`, aria-label se icon-only) · Modal (`role="dialog"`, `aria-modal`, `aria-labelledby`) · Toast (`aria-live` polite/assertive, `role="status"|"alert"`) · Input (`htmlFor`, `aria-invalid`, `aria-describedby`) · Select (`role="listbox"`, setas, Enter, Esc).

### 9.2 `shared/06-data-layer.md` — Comunicação com o backend

**API Client centralizado** (`src/services/api-client.ts`) responsável por: injeção de token via interceptor · headers padrão · tratamento de erros com mapeamento de status · retry com backoff exponencial · base URL por ambiente. Config: timeout 30 s, 3 tentativas, `Authorization: Bearer <token>`.

**Data fetching** — TanStack Query / SWR, organizado por feature:
```
features/users/
  api/user-api.ts        funções puras de API
  hooks/useUser.ts       useQuery wrapper
  hooks/useUpdateUser.ts useMutation wrapper (+ invalidateQueries no onSuccess)
  types/user.types.ts    DTOs e interfaces
```

**Contratos (DTOs):** um DTO tipado por endpoint · validação em runtime (Zod/Yup) · podem ser **gerados do OpenAPI/Swagger do backend**, garantindo sincronização.

**BFF** — decisão explícita: não necessário (API direta) / Next.js Route Handlers / serviço separado. Quando existe: agregação de múltiplas APIs, autenticação server-side, otimização de payload.

**Cache em 4 camadas:** Browser (Cache-Control, ETag) · Query Cache (staleTime + gcTime, invalidateQueries após mutação) · Server Cache (ISR/SSG, revalidatePath/Tag) · CDN (assets com hash, 1 ano).

### 9.3 `shared/15-api-dependencies.md` — O contrato visto do cliente

Este documento existe para tornar visível o acoplamento que normalmente é invisível:

- **Mapa de dependências** — endpoint / método / usado em (página ou componente) / **campos consumidos** / frequência
- **Campos críticos** — endpoint / campo / componentes que usam / **impacto se removido** (ex.: "`role` removido → rotas protegidas param de funcionar")
- **Contrato de paginação** — formato esperado e parâmetros de query
- **Cache strategy por endpoint** — stale-while-revalidate / cache-first / network-first / no-cache
- **Checklist antes de lançar feature** — endpoints implementados · campos existem no response · paginação consistente · erros mapeados em `error-ux-mapping` · cache definido · rate limit compatível com a UX

### 9.4 Documentos de aplicação (8 por cliente)

| Doc | Conteúdo essencial |
| --- | --- |
| `00-frontend-vision` | Responsabilidades, princípios, plataformas suportadas, stack, tipos de usuários |
| `01-architecture` | Camadas, regras de dependência, fronteiras de domínio, diagrama |
| `02-project-structure` | Árvore, organização por feature, monorepo, regras de importação |
| `04-components` | Hierarquia Primitive → Composite → Feature, template de doc, padrões de composição |
| `05-state` | Tipos de estado, server state, global state, event bus, anti-patterns |
| `07-routes` | Estrutura de rotas, proteção, layouts, navegação |
| `08-flows` | 3-5 fluxos críticos de UI derivados de `blueprint/07` |
| `14-copies` | Todos os textos: telas, feedback, validação, componentes globais, convenções |

#### Adaptação por plataforma — o que muda em cada um dos 8 documentos

A mesma estrutura de documento produz conteúdo substancialmente diferente por cliente. Esta é a matriz que `/frontend-app` aplica:

| Doc | web | mobile | desktop |
| --- | --- | --- | --- |
| **00 Visão** | Next.js / Remix / SPA (Vite+React); SSR/SSG, hidratação, **SEO**, responsividade | React Native / Expo; navegação nativa, **gestos**, push, **offline-first**; versões mínimas (iOS 16, Android API 24) | Electron / Tauri; integração com o SO, menu bar, system tray, **auto-update** |
| **01 Arquitetura** | Camadas SSR/SSG, React Server Components, API routes, middleware no edge | **Bridge para módulos nativos** (câmera, GPS, biometria); arquitetura de navegação stack/tab/drawer | **Processo main vs renderer** (Electron) ou core vs webview (Tauri); **IPC entre processos** |
| **02 Estrutura** | `app/` router (Next.js) ou `routes/` (Remix); `public/`, middleware, API routes | Expo Router com `app/` ou `screens/`; `assets/`, navegação | Separação `main/` e `renderer/`; pasta `ipc/` para comunicação entre processos |
| **04 Componentes** | Base DOM (div, button, input); shadcn/ui, Radix, Headless UI | React Native Views (View, Text, Pressable, ScrollView); **listas performáticas FlatList, FlashList, SectionList** | Base web + **TitleBar, SystemTray, MenuBar, ContextMenu** |
| **05 Estado** | **SSR hydration** (sincronização servidor↔cliente); URL state via searchParams, shallow routing | **Persistência background/foreground** (AppState listener); cold start, warm start, resume | **Sincronização main↔renderer via IPC** (invoke/handle); estado persistido em disco (electron-store, tauri fs) |
| **07 Rotas** | App Router file-based; guards via middleware | React Navigation (stacks, tabs, drawers); **deep linking via URL schemes e universal links** | **Navegação baseada em janelas**; menu bar e system tray com context menu |
| **08 Fluxos** | Page transitions, forms, modals; navegação por URL e histórico do browser | **Gestos** (swipe, pull-to-refresh, swipe actions); **haptic feedback** em ações críticas | **Drag-and-drop de arquivos do SO**; **keyboard shortcuts** para ações frequentes; multi-window |
| **14 Copies** | i18next / next-intl / react-intl; **SEO** (meta titles, descriptions, OpenGraph) | expo-localization, react-native-localize; **push notifications**, app store listing, onboarding, **textos de permissão** (câmera, localização, notificação) | i18next/next-intl + **strings de menu bar, system tray e diálogos nativos do SO** |

> A implicação prática: `04-components` e `14-copies` **não são portáveis entre clientes**. Uma tab bar com textos de permissão de iOS não tem equivalente no web; um menu bar de macOS não tem equivalente no mobile. Por isso esses 8 documentos são por cliente, e só `03-design-system`, `06-data-layer` e `15-api-dependencies` são compartilhados.

**Microfrontends** (`08-flows`, quando aplicável) — decisão explícita: não necessário (aplicação monolítica) · por rota · por componente. Se sim, documentar microfrontend / rota ou componente / bundle independente? / ferramenta (Webpack Module Federation, single-spa, Next.js Multi-Zones).

#### Camadas do frontend (Clean Architecture adaptada)

```
UI Layer (Pages, Layouts, Components)
        ↓
Application Layer (Hooks, Orchestration, State)
        ↓
Domain Layer (Models, Business Rules, Interfaces)
        ↓
Infrastructure Layer (API Client, Storage, Analytics)
```

**Regra de ouro:** dependências apontam sempre para dentro. Domain não importa de ninguém. Infrastructure implementa interfaces definidas em Domain.

**Comunicação entre features:** features **não** importam umas das outras. Comunicação via **event bus leve** ou estado global compartilhado. Componentes compartilhados vivem fora das features.

#### Tipos de estado — a decisão arquitetural mais importante do frontend

| Tipo | Ferramenta | Exemplo |
| --- | --- | --- |
| **UI State** | `useState` / `useReducer` | Modal aberto, sidebar colapsada, valor de input |
| **Server State** | TanStack Query | Lista de usuários, detalhe de arquivo |
| **Global State** | Zustand (store por domínio) | Usuário autenticado, preferências, tema |
| **Domain State** | Zustand | `authStore`, `billingStore` |
| **URL State** | Router / SearchParams | Filtros, paginação, aba ativa |

> **Regra:** use o tipo mais simples que resolve. Não coloque em global o que pode ser local.

**Anti-patterns de estado** (fonte: `{client}/05-state.md`; reaparecem no índice consolidado de [§17.1](#171-os-que-o-repositório-declara-explicitamente) junto com os das demais camadas):

| Anti-pattern | Por que evitar | Alternativa |
| --- | --- | --- |
| Server state em store global | Duplica cache, perde revalidação | TanStack Query |
| Estado global para dado local | Complexidade e re-renders | `useState`/`useReducer` |
| Prop drilling > 2 níveis | Código frágil | Contexto ou store |
| Sincronizar server/local à mão | Bugs de sincronização, dado stale | Deixar o query client gerenciar |
| Store monolítica gigante | Difícil de testar, re-renders | Stores pequenas por domínio |

#### Hierarquia de componentes

- **Primitive** (`components/ui/`) — atômicos, sem lógica de negócio: Button, Input, Select, Card, Modal, Toast, Badge, Avatar, Tooltip, Skeleton
- **Composite** (`components/`, `components/forms/`) — combinam primitivos: Form, Sidebar, Navbar, DataTable, Pagination
- **Feature** (`features/xxx/components/`) — ligados a um domínio: UserProfile, FileUploader, BillingPanel, DashboardGrid

**Quando criar vs reutilizar:** usado em 2+ lugares → `components/ui/` · específico de feature → dentro da feature · já existe no design system → reutilize · é variante → adicione variante ao existente.

**Padrões de composição:** Compound Components (`<Tabs><Tab/><TabPanel/></Tabs>`) · Children pattern · Render Props (só quando children não resolve) · Headless (`useCombobox()`).

#### Copies — o documento mais subestimado

Centralizar copies permite revisão por produto/UX, consistência de tom de voz e prepara i18n. Estrutura: estratégia (idioma, i18n, chaves `namespace.screen.element`, tom de voz, pessoa gramatical) · glossário do produto (termo / definição / **não usar**) · copies por tela · mensagens de feedback (sucesso, erro, validação, aviso) · componentes globais · empty states · convenções.

**Convenções de escrita do repositório:**

| Regra | Correto | Incorreto |
| --- | --- | --- |
| Capitalize só a primeira palavra em títulos | Criar nova conta | Criar Nova Conta |
| Voz ativa | Salve suas alterações | Suas alterações devem ser salvas |
| CTAs curtos (≤ 60 chars) | Salvar | Clique aqui para salvar as alterações |
| Sem jargão técnico | Algo deu errado | Erro 500: Internal Server Error |
| Pontuação em frases completas | Suas alterações foram salvas. | Suas alterações foram salvas |
| Sem ponto em labels e botões | Salvar alterações | Salvar alterações. |
| Tooltip autoexplicativo | Exportar dados em CSV | Clique para exportar |

### 9.5 Documentos de qualidade (5 por cliente)

| Doc | Web | Mobile | Desktop |
| --- | --- | --- | --- |
| `09-tests` | Playwright (E2E) + Testing Library | Detox/Maestro + RN Testing Library | Playwright+Electron + **testes de IPC handlers** |
| `10-performance` | **Core Web Vitals** (LCP < 2.5s, INP < 200ms, CLS < 0.1, TTFB < 800ms) | **Cold/warm start**, 60fps, Hermes, otimização de imagens | **Startup time**, memória (main+renderer), memory leak detection |
| `11-security` | CSP headers, XSS, CSRF | **Keychain/Keystore**, certificate pinning, ATS, ProGuard, root detection | **Code signing**, context isolation, secure IPC, auto-update seguro |
| `12-observability` | Sentry + Web Vitals RUM | Sentry RN + Crashlytics + OTA monitoring | Sentry Electron + crash reporting do main + telemetria de auto-update |
| `13-cicd` | Vercel/Netlify + PR previews | **EAS Build**, TestFlight, Play Console, OTA updates | electron-builder/tauri-action, DMG/NSIS/AppImage, notarization |

#### A metade "conventions" do `13-cicd-conventions`

O nome do documento tem duas partes e a segunda costuma ser esquecida. Além do pipeline e dos ambientes, ele fixa:

| Bloco | Conteúdo |
| --- | --- |
| **Nomenclatura** | Componentes PascalCase (`UserProfile.tsx`) · hooks camelCase com prefixo `use` (`useUser.ts`) · utils camelCase · types PascalCase · constantes UPPER_SNAKE_CASE · testes `mesmo-nome.test.tsx` |
| **Componentes** | Nomes descritivos (`UserProfileCard`, não `UPC`) · um componente por arquivo · props tipadas com `interface` (não `type` alias) · **export named**, não default (exceto páginas Next.js) |
| **Commits** | Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`) · escopo opcional (`feat(auth): add OAuth login`) · mensagem em inglês, imperativo (`add`, não `added`) |
| **Ferramentas de qualidade** | ESLint · Prettier · TypeScript strict mode · **Husky** (git hooks) · **lint-staged** (lint só nos arquivos staged) |
| **Documentação viva** | Storybook para componentes · README por feature · ADRs para decisões técnicas · blueprint atualizado a cada milestone |

> *"Documentação que não é mantida atualizada é pior que nenhuma documentação."* — a frase está literalmente no template, e é o motivo de `/increment` e `/patch` existirem.

**Versionamento do app (mobile):** além do SemVer, `version` + `buildNumber`/`versionCode` incrementais, e a política de quando um update vai por **OTA** (JS apenas) vs **submissão à store** (código nativo).

#### O que `12-observability` cobre além de error tracking

| Bloco | Conteúdo |
| --- | --- |
| **Logging estruturado no cliente** | Níveis com critério: Error (exceções, falha de API) · Warn (retry, fallback ativado) · Info (ações do usuário / analytics) · Debug (só desenvolvimento) |
| **Métricas de API vistas do cliente** | Latência p95, taxa de erro, timeout rate, disponibilidade — cada uma com meta **e** condição de alerta (ex.: erro > 5% por 2 min). São diferentes das métricas do servidor: medem a experiência real, com a rede do usuário no meio |
| **User flow monitoring** | Cada fluxo crítico de `08-flows` instrumentado com eventos e **meta de conclusão** (onboarding 80%, checkout 90%, login 95%) — é o que detecta abandono antes do churn |
| **Feature flags** | Flag / descrição / status (inativo, 10% rollout, beta users). Ciclo: flag → avaliação → renderização condicional → métricas → decisão (manter/remover). Ferramentas: LaunchDarkly, Unleash, Flagsmith ou custom |
| **Específicos de plataforma** | mobile: crash reporting (Crashlytics) + **OTA update monitoring** (taxa de adoção, rollback) · desktop: crash do processo main + **telemetria de auto-update** + monitoramento de recursos do sistema |

> Feature flags são a peça que liga observabilidade a produto: sem elas, o rollout Alpha→Beta→GA do §4.0 não tem mecanismo de execução.

#### Budget de performance (web, referência do repositório)

| Recurso | Budget |
| --- | --- |
| JavaScript total | < 200 KB gzipped |
| CSS total | < 50 KB gzipped |
| Imagens por página | < 500 KB |
| Web fonts | < 100 KB |
| First Load JS | < 80 KB |

**Técnicas:** code splitting · lazy loading · streaming (Suspense) · partial hydration (RSC) · edge rendering · memoização · **virtualização** para listas 100+ itens.

#### Segurança client-side

> Segurança no frontend é a primeira linha de defesa, **nunca a única**. Toda validação é replicada no backend. A autorização real vive no servidor.

| Vulnerabilidade | Proteção |
| --- | --- |
| XSS | Auto-escape do framework + DOMPurify para HTML dinâmico |
| CSRF | Cookie `SameSite=Strict` + CSRF header |
| Clickjacking | `X-Frame-Options: DENY` |
| Injection | Zod schemas + validação server-side |
| Open Redirect | Whitelist de domínios |
| Sensitive Data Exposure | Server Components para dados sensíveis |

**CSP de referência:** `default-src 'self'; script-src 'self' 'nonce-{random}'; connect-src 'self' {api-domain}; frame-ancestors 'none'`.

**Armazenamento de token:** cookie `httpOnly; Secure; SameSite=Strict` é o padrão recomendado no repositório — o checklist diz literalmente *"tokens nunca expostos em localStorage"*.

> Os checklists de release das três plataformas (web, mobile, desktop) estão consolidados em [§16.5](#165-checklist-de-segurança-consolidado), para serem usados como um artefato só na hora de lançar.

#### Especificidades de plataforma que mudam a arquitetura

**Mobile** — versões mínimas (iOS 16, Android API 24) · stack Expo/React Native + Expo Router + NativeWind + Hermes · **armazenamento seguro obrigatório**: token em SecureStore/Keychain/Keystore, nunca AsyncStorage (grava em texto puro) · certificate pinning · App Transport Security (nunca `NSAllowsArbitraryLoads` em prod) · proteção do binário (ProGuard/R8, Hermes bytecode, root/jailbreak detection, tamper detection) · deep links **validados e sanitizados** · screenshot protection em telas sensíveis · estado de app lifecycle (background/foreground, cold/warm start).

**Desktop** — arquitetura de **dois processos**:
```
Main Process (Node.js / Rust)          Renderer Process (Chromium / WebView)
├── Window Management                  ├── UI Layer
├── Application Menu / System Tray     ├── Application Layer
├── Auto-Updater                       ├── Domain Layer
├── File System Access          ↕IPC   └── Infrastructure (API + IPC Client)
└── IPC Handlers
       Preload Script (contextBridge) — ponte segura, acesso limitado
```
Toda mensagem IPC **tipada e validada nos dois lados**, com canais declarados em `shared/ipc-channels.ts`. Context isolation e sandbox ativos. Code signing + notarization. Auto-update com verificação de integridade. Estado persistido em disco (electron-store / tauri fs) e sincronizado main↔renderer via IPC.

---

## 10. Camada cross-layer (o que impede divergência)

Quatro documentos em `docs/shared/`. Existem para impedir que cada blueprint vire **uma interpretação independente do mesmo produto**.

### 10.1 `glossary.md` — Fonte única de termos

Termo / definição / **não confundir com** / onde é usado. Mais: acrônimos (RBAC, JWT, DTO, DLQ, ADR, SLA, SLO, RPO, RTO, MoSCoW) e as convenções de nomenclatura da §5.1.

**Regra:** não crie glossários separados. `blueprint/04-domain-model`, `backend/03-domain`, `{client}/04-components` e `{client}/14-copies` todos referenciam este arquivo.

### 10.2 `error-ux-mapping.md` — Erro do backend → comportamento visual

Para **cada** código de `backend/09-errors`, a resposta na interface:

| Código | Status | Ação na UI | Componente | Retentável |
| --- | --- | --- | --- | --- |
| `VALIDATION_ERROR` | 400 | Highlight nos campos, scroll ao primeiro erro | Form + FieldError | Sim (usuário corrige) |
| `INVALID_CREDENTIALS` | 401 | Shake no form, limpar senha | LoginForm | Sim |
| `TOKEN_EXPIRED` | 401 | Silencioso → refresh; se falhar, modal "Sessão expirada" → login | AuthProvider | Auto |
| `INVALID_TOKEN` | 401 | Limpar tokens, redirect login | AuthProvider | Não |
| `INSUFFICIENT_PERMISSIONS` | 403 | Toast de erro, mantém na página | Toast | Não |
| `RESOURCE_OWNERSHIP` | 403 | "Recurso não encontrado" + redirect à lista — **não revelar existência** | Router | Não |
| `NOT_FOUND` | 404 | Tela 404 com link para home | NotFoundPage | Não |
| `DUPLICATE_RESOURCE` | 409 | Highlight do campo duplicado + sugestão | Form + FieldError | Sim |
| `INVALID_STATE_TRANSITION` | 422 | Toast de aviso + desabilitar botão | Toast + ActionButton | Não |
| `RATE_LIMIT_EXCEEDED` | 429 | Desabilitar form + countdown | RateLimitBanner | Sim (após cooldown) |
| `EXTERNAL_SERVICE_ERROR` | 502 | Toast + botão de retry | Toast + RetryButton | Sim |
| `INTERNAL_ERROR` | 500 | Toast + log para observabilidade | Toast + ErrorBoundary | Sim |

**Padrões visuais por categoria:** validação → inline por campo, permanente até corrigir · auth → modal ou redirect, salva a URL atual · permissão → toast vermelho 5 s · 404 → página inteira com CTA · conflito → inline + toast amarelo · negócio → toast amarelo explicando por que não é possível · rate limit → banner com countdown · servidor → toast vermelho com retry + **request ID para suporte**.

**Fallback global (ErrorBoundary):** capturar → logar com `requestId`, stack e contexto → tela genérica com "Tentar novamente" / "Voltar ao início" → se persistir: *"Entre em contato com suporte. Ref: {requestId}"*.

> A linha `RESOURCE_OWNERSHIP` merece destaque num SaaS: responder 403 "esse recurso é de outro usuário" **vaza a existência do recurso**. O mapeamento correto é tratar como 404.

### 10.3 `event-mapping.md` — Evento do backend → estado do frontend

Para cada evento: origem (service) / **canal** / ação no frontend / store impactada / update de UI.

**Canais e quando usar:**

| Canal | Tecnologia | Quando | Latência |
| --- | --- | --- | --- |
| REST Response | HTTP | Resposta imediata à ação do usuário | < 200 ms |
| WebSocket | Socket.io / WS | Tempo real (chat, status) | < 100 ms |
| Polling | HTTP interval | Fallback quando WS indisponível | Intervalo |
| Push Notification | FCM / APNs | Usuário fora do app | Segundos |
| Server-Sent Events | SSE | Stream unidirecional (feeds, logs) | < 100 ms |

**Impacto de mudança de payload:** evento / campo / frontend que consome / o que quebra se removido. É o equivalente de `15-api-dependencies` para o mundo assíncrono.

### 10.4 `MAPPING.md` — Índice mestre

O grafo completo PRD → blueprint → backend/frontend/shared, expandido na §3 deste documento. Use-o para rastrear qualquer decisão até sua origem — e é o arquivo que `/codegen-feature` lê para descobrir **quais 2-3 documentos** carregar para uma tarefa específica.

---

## 11. Atributos de qualidade

**Fase 5** · Skill `/blueprint-quality` · Gera `12`, `13`, `14`, `15` — juntos porque derivam da mesma base (arquitetura `06` + fluxos `07`).

### 11.1 `12-testing_strategy.md`

**Pirâmide:** base larga de unitários (rápidos e baratos) · camada média de integração · topo estreito de E2E (lentos e frágeis) · **carga** e **resiliência** complementam validando RNFs.

| Categoria | Objetivo | Escopo | Critério de sucesso |
| --- | --- | --- | --- |
| **Unit** | Função/método/classe isolados | Lógica de negócio, validações, cálculos, edge cases | Cobertura atingida, verde no CI, execução < limite |
| **Integration** | Contrato entre componentes | Queries, eventos, APIs de terceiros | Contratos validados, sem falha de comunicação |
| **E2E** | Jornada do usuário | Fluxos críticos, auth, checkout, onboarding | Fluxos cobertos, flaky rate < 2% |
| **Load/Performance** | Carga esperada e gargalos | Throughput, latência p50/p95/p99, picos, recursos | Suporta carga alvo com p99 dentro da meta |
| **Chaos/Resilience** | Recuperação de falhas | Queda de nós, falha de banco, latência de rede, esgotamento | Recupera automaticamente, circuit breakers atuam, sem perda de dados |

**Testes não funcionais** (`README.MD` §18.4) — além de carga e chaos, quatro que raramente entram no plano e são os que pegam o bug caro:

| Teste | O que revela |
| --- | --- |
| **Soak** | Vazamento de memória e degradação sob carga sustentada por horas — invisível num load test de 10 minutos |
| **Failover** | Se a réplica assume de fato, e em quanto tempo |
| **Cold start** | Latência do primeiro request após escalar do zero (serverless, container novo, cache frio) |
| **Restore de backup** | Se o backup é restaurável. Backup nunca testado é backup que não existe — e é o que define se o **RPO/RTO** documentado é real |

**Cenários obrigatórios** (`README.MD` §18.3): cenário feliz · dados inválidos · **timeout de dependência** · retry · **duplicidade** · **concorrência** · **falha parcial** · recuperação.

**Ambientes:** local (mock/fixtures) · CI (seed, banco em container) · staging (produção anonimizada) · produção (chaos e monitoramento — **nunca testes destrutivos**).

**Automação:** por etapa do pipeline, quais testes rodam, gatilho e se bloqueia merge. Defina o **tempo máximo aceitável do pipeline completo**.

### 11.2 `13-security.md`

**Modelo de ameaças — STRIDE** aplicado aos componentes de `06`:

| Letra | Ameaça | Exemplo de mitigação |
| --- | --- | --- |
| **S** | Spoofing (falsificação de identidade) | MFA, rotação de token, `iss`/`aud` validados |
| **T** | Tampering (adulteração de dados) | Assinatura HMAC, integridade de payload, TLS |
| **R** | Repudiation (negação de autoria) | Log de auditoria imutável, trilha assinada |
| **I** | Information Disclosure (vazamento) | Criptografia, mascaramento, 404 em vez de 403 |
| **D** | Denial of Service | Rate limiting, quotas, circuit breaker, autoscale |
| **E** | Elevation of Privilege | RBAC no middleware, menor privilégio, revisão de acessos |

**Autenticação:** método (OAuth 2.0 / JWT / API Keys / SSO / MFA) · provedor · fluxo (Authorization Code + PKCE, Client Credentials) · políticas de credenciais (complexidade, expiração, refresh, limite de tentativas, MFA).

**Autorização:** modelo (RBAC/ABAC/ACL/policy-based) · roles e permissões · **princípio do menor privilégio** · segregação de funções · **revisão periódica de acessos**.

**Proteção de dados:**
- *Em trânsito* — TLS 1.3 / mTLS, certificate pinning, cifras permitidas, HSTS
- *Em repouso* — AES-256, gerenciamento de chaves (KMS/Vault), backups criptografados
- *PII* — classificação, proteção, retenção, mascaramento/anonimização, tokenização, política de descarte

**Checklist OWASP Top 10:** prevenção de injection · autenticação e sessão · exposição de dados sensíveis · controle de acesso em cada endpoint · configuração segura (headers, CORS, hardening) · XSS (sanitização, CSP, encoding contextual) · CSRF (tokens, SameSite, validação de origin) · **dependências** (Dependabot/Snyk, atualizações, SBOM).

**Auditoria e compliance:** regulamentações aplicáveis (LGPD, GDPR, SOC 2, PCI-DSS, HIPAA, ISO 27001) · eventos auditados (login, alteração de dados, acesso a PII, mudança de permissão, exportação, exclusão) · formato (JSON estruturado/CEF) · destino (SIEM/CloudWatch/ELK) · **imutabilidade** (write-once, assinatura digital) · retenção por tipo · plano de resposta a incidentes com **SLA de notificação (72 h para LGPD)**.

### 11.3 `14-scalability.md`

**Estratégias:**
- *Horizontal* — componentes elegíveis, balanceamento, estado da sessão (stateless / sticky / externalizada), auto-scaling com regras, mín/máx de instâncias
- *Vertical* — componentes que se beneficiam, config atual, **limite prático** antes de precisar escalar horizontalmente
- *Caching* — tecnologia, camadas (CDN → Gateway → app → banco), o que cachear, invalidação (TTL / event-driven / write-through / write-behind)
- *Particionamento/Sharding* — estratégia (**por tenant** / por região / range / hash), chave, número de shards, rebalanceamento, queries cross-shard

**Limites atuais** — componente / limite / gargalo / **ação quando atingir**. Exemplos: API 500 req/s (CPU → escalar horizontal) · banco 10k conexões (→ read replicas, pooling, sharding) · fila 50k msg/s (→ partições, mais consumers) · storage 500 GB (→ arquivar) · cache 16 GB (→ cluster, ajustar TTL/eviction).

**Plano de capacidade** — métrica / atual / 6m / 12m / ação necessária, para usuários ativos, RPS, volume de dados, storage, conexões simultâneas e tempo de resposta.

**Rate limiting** — algoritmo (token bucket / sliding window / fixed window / leaky bucket) · onde aplicar (gateway / middleware / LB) · storage dos contadores · identificação do cliente (IP / API key / token / **tenant ID**) · headers de resposta · tratamento de burst.

**Degradação graciosa em 4 níveis:**
```
1. Alerta        métricas acima de X% do limite — monitoramento ativado
2. Throttle      reduzir funcionalidades não-críticas (ex.: relatórios pesados)
3. Shedding      rejeitar requisições de menor prioridade, manter só o crítico
4. Circuit Breaker  isolar serviços em falha para evitar cascata
```

**Resiliência** (README mestre §20.4): retries · circuit breaker · bulkhead · dead letter queue · graceful degradation. **Disaster recovery:** RPO, RTO, failover — com **teste de restauração periódico**, não apenas backup configurado.

### 11.4 `15-observability.md`

> Se você não consegue observar, você não consegue operar.

**Logs** — JSON estruturado com `timestamp`, `level`, `service`, `trace_id`, `message`, `context` (user_id, action). Níveis: DEBUG (diagnóstico) · INFO (eventos normais) · WARN (inesperado não-fatal) · ERROR (falha de operação) · FATAL (impede o sistema de operar). Retenção por ambiente. **Sem dados sensíveis, sempre com correlation id.**

**SLA × SLO × error budget** (`README.MD` §20.1 — *Objetivos operacionais*: SLA · SLO · erro budget · p95 · throughput). A distinção é o que separa promessa de operação, e é pressuposta em vários pontos do framework sem nunca ser explicada:

| Conceito | O que é | Quem define | Consequência de violar |
| --- | --- | --- | --- |
| **SLA** | O compromisso **externo**, contratual, com o cliente | Produto + Jurídico | Crédito, multa, churn |
| **SLO** | A meta **interna**, mais rigorosa que o SLA | Engenharia + SRE | Aciona o time antes de o cliente sentir |
| **Error budget** | `100% − SLO`: quanto de falha é aceitável no período | Derivado do SLO | Orçamento gasto → congela release, prioriza confiabilidade |

> A regra prática: **SLO < SLA**, com folga. Se o SLA é 99.9% (43 min de indisponibilidade por mês), o SLO interno deveria ser 99.95% (21 min) — a diferença é a margem para reagir antes de quebrar o contrato. O error budget transforma confiabilidade numa decisão de produto: com orçamento sobrando, lança-se mais rápido; com orçamento estourado, para-se de lançar. Sem essa distinção escrita, "uptime" vira número único que ninguém sabe se é promessa ou meta.

**Métricas — Golden Signals (Google SRE):**

| Métrica | Descrição |
| --- | --- |
| **Latência** | Tempo de resposta (p50, p95, p99) |
| **Tráfego** | Volume de requisições por segundo |
| **Erros** | Taxa de falha (5xx, timeouts, exceções) |
| **Saturação** | Uso de recursos (CPU, memória, disco, conexões) |

**Tracing distribuído** — ferramenta, protocolo de propagação, taxa de amostragem, convenções de span (`service.name`, atributos obrigatórios, formato do trace ID).

**Alertas** — alerta / severidade / condição / **runbook**:

| Severidade | Significado |
| --- | --- |
| **P1** | Sistema fora do ar ou perda de dados |
| **P2** | Funcionalidade crítica degradada |
| **P3** | Funcionalidade secundária impactada |
| **P4** | Problema menor, sem impacto imediato |

Cada severidade com SLA de resposta, e **política de escalação em 3 etapas** (tempo, responsável, canal). A pergunta-guia do template: *"Quais situações devem acordar alguém às 3h da manhã?"*

**Dashboards** — no mínimo dois: **operacional** (engenharia/SRE) e **de negócio** (produto/gestão). O README mestre acrescenta: filas, dependências, latência por endpoint.

**Health checks:**
- *Liveness* — processo ativo, sem deadlock (o orquestrador reinicia o container)
- *Readiness* — pronto para receber tráfego, com dependências verificadas (o LB decide se manda request)
```json
{ "status": "healthy", "checks": { "database": "...", "cache": "...", "external_api": "..." },
  "version": "...", "uptime": "..." }
```

> **Coerência obrigatória:** os thresholds de alerta em `15` devem bater com os limites de `14`. Dois números diferentes para a mesma métrica é erro, não detalhe.

---

## 12. Construção, evolução e operação

**Fase 6** · Skill `/blueprint-plan` · Gera `11`, `16` — fechamento do blueprint.

### 12.1 `11-build_plan.md` — Plano de construção

**Entregas** (`ENT-001`, `ENT-002`…): objetivo · prioridade MoSCoW · itens concretos · **dependências explícitas** · critérios de aceite verificáveis · estimativa T-shirt.

| Tamanho | Significado |
| --- | --- |
| **S** | Até 1 semana |
| **M** | 1 a 3 semanas |
| **L** | 3 a 6 semanas |
| **XL** | Mais de 6 semanas — **considere quebrar** |

**Ordem de priorização** (na ordem em que o repositório recomenda pensar):

1. **Redução de risco** — o que pode invalidar a abordagem técnica? Construa primeiro.
2. **Valor para o usuário** — entregue algo usável o mais cedo possível
3. **Dependências técnicas** — infraestrutura e autenticação antes de features de negócio
4. **Feedback** — priorize o que permite validar com usuários reais

**Exemplo canônico (MVP de e-commerce):** `ENT-001 Fundação` (repo, CI/CD, auth, banco com migrações — M) → `ENT-002 Catálogo e Carrinho` (M) → `ENT-003 Checkout e Pagamento` (L, depende de contrato com gateway assinado).

Mais: **riscos técnicos** (risco / impacto / probabilidade / mitigação) e **dependências externas** (sistema ou equipe / responsável / status / impacto se atrasar).

**Cobertura obrigatória:** todo requisito **Must** de `03-requirements.md` está dentro de alguma entrega. Musts fora são listados explicitamente.

**Definition of Done** (README mestre §17.7) — seis condições, consolidadas em [§16.2](#162-definition-of-done-por-entrega). A que mais é esquecida: *logs e métricas implementados* — uma entrega sem observabilidade está pronta para o desenvolvedor, não para a operação.

### 12.2 Deploy e ambientes

> **Fonte:** este bloco **não** é produzido por `/blueprint-plan`. Ele vive em `blueprint/06-system-architecture.md` (§Infraestrutura e Deploy, gerado na **fase 3**), no blueprint master `README.MD` §22, e é detalhado por cliente em `frontend/{client}/13-cicd-conventions.md` e por ambiente em `backend/01-architecture.md` §Estratégia de Deploy. Está aqui por proximidade temática com o plano de construção, não por autoria.

| Bloco | Decisões |
| --- | --- |
| Ambientes | dev / staging / prod — objetivo e fidelidade |
| Estratégia de deploy | rolling / blue-green / canary / feature flags |
| Configuração | como segredos, variáveis e parâmetros são gerenciados |
| Rollback | estratégia objetiva e **ensaiada** |
| Checklist pré-produção | Cinco itens aqui (migrações validadas · dashboards prontos · alertas ativos · rollback testado · owners definidos); a versão completa de 10 itens está em [§16.3](#163-critérios-mínimos-antes-de-produção) |

### 12.3 `16-evolution.md` — Evolução e migração

- **Roadmap técnico** — item / prioridade / justificativa / fase
- **Débitos técnicos** — débito / impacto / esforço / prioridade. **Transporte aqui as consequências negativas aceitas nos ADRs de `10` e os limites atuais de `14`.** Processo: como registrar, frequência de revisão, critério de priorização
- **Versionamento SemVer** — MAJOR (breaking) · MINOR (feature retrocompatível) · PATCH (correção)
- **Versionamento de API** — estratégia (URI/header), formato, versões ativas, política de suporte a anteriores
- **Plano de deprecação** — anúncio com antecedência → período de transição com ambas as versões → guia de migração → remoção
- **Critérios de revisão do blueprint** — gatilhos (mudança de arquitetura, entrada de novos membros, **incidentes que revelem lacunas na documentação**), cadência, responsável
- **Histórico de revisões**

### 12.4 A hierarquia de trabalho: ENT → EP → ST → TSK

O framework tem **duas** granularidades de backlog que convivem, e confundi-las é fonte comum de planejamento incoerente:

```
ENT-XXX   Entrega          blueprint/11-build_plan.md · unidade de VALOR e de dependência
   │                        prioridade MoSCoW, estimativa T-shirt (S/M/L/XL), critérios de aceite
   │
   ├── EP-XXX   Epic        docs/templates/epic-template.md · agrupamento de valor
   │      │                  contexto, escopo dentro/fora, critérios de aceite do epic,
   │      │                  dependências (bloqueia/depende), riscos
   │      │
   │      └── ST-XXX  Story  docs/templates/story-template.md
   │             │            "Como {persona}, quero {ação}, para {benefício}"
   │             │            critérios de aceite em Gherkin (Dado/Quando/Então),
   │             │            CENÁRIOS DE ERRO obrigatórios, estimativa P/M/G/GG,
   │             │            Definição de Pronto própria
   │             │
   │             └── TSK-XXX  Task  docs/templates/task-template.md
   │                           tipo (backend/frontend/infra/banco/teste/doc),
   │                           checklist de implementação, critérios técnicos
   │
   └── TASK-{GRP}-{NNN}      docs/specs/TASKS.md · gerado por /specs
                              derivado de docs/backend/, com camada, entidade, origem
                              (arquivo), dependências entre tasks, RN-XX, arquivos a
                              criar/editar, testes e componente de frontend dependente
```

| Eixo | `EP → ST → TSK` (templates) | `TASK-{GRP}-{NNN}` (`/specs`) |
| --- | --- | --- |
| Origem | Escrito por pessoas, a partir de `11-build_plan` e do PRD | **Derivado mecanicamente** de `docs/backend/` |
| Linguagem | Produto — valor, persona, benefício | Implementação — classes, métodos, campos, tipos |
| Agrupamento | Por valor de negócio | Por camada técnica — 14 grupos (SETUP, DOM, DATA, SVC, API, CTRL, AUTH, ERR, VAL, MW, EVT, INT, TEST, FE); ver o aviso em [§14.8](#148-specs--backlog-integral) |
| Consumidor | Time, board ágil, stakeholders | `/build` e `/codegen-feature` |
| Estimativa | P/M/G/GG (story), S/M/L/XL (entrega) | — (dependências, não estimativa) |

**Como usar os dois sem duplicar:** a entrega (`ENT-XXX`) é a fonte comum. Para o time, ela vira epics e stories com linguagem de produto. Para o agente, `/specs` a decompõe em tasks técnicas rastreáveis até o arquivo de origem. O `/build` quebra cada entrega em **features verticais** (banco + API + frontend + testes) e usa `TASKS.md`, quando existe, para detalhar o escopo de cada uma.

O blueprint master (`README.MD` §17.3-17.5) traz as três tabelas — Epics, Stories e Tasks técnicas — no mesmo documento, para quem prefere um arquivo único a templates separados.

### 12.5 Migração (README mestre §23)

Situação atual → situação futura → **estratégia** (big bang / incremental / paralela / **strangler**) → compatibilidade (backward compatibility, contratos legados, janelas de coexistência) → depreciação (o que sai, quando e como comunicar).

---

## 13. O que é específico de SaaS

Esta parte consolida o que está **espalhado** pelo repositório e é o que diferencia um SaaS de um software qualquer. Onde o repositório é explícito, a fonte está citada; onde ele deixa a decisão em aberto (campo `{{...}}`), o ponto está marcado como **decisão obrigatória**.

### 13.1 Multi-tenancy — a decisão mais cara de adiar

| Onde aparece no repositório | O que diz |
| --- | --- |
| `backend/11-permissions.md` | Campo `Multi-tenancy: Sim/Não — se sim, **`tenant_id` em todo recurso**` |
| `backend/11-permissions.md` (JWT claims) | `teamId` no token — o mesmo mecanismo serve para `tenantId` |
| `blueprint/06-system-architecture` (§10.7 do README mestre) | **Boundaries e isolamento: multi-tenant vs single-tenant, isolamento lógico/físico** |
| `blueprint/14-scalability` | Sharding **por tenant** como estratégia de particionamento |
| `blueprint/14-scalability` | Rate limit de webhooks/integrações **por tenant** |
| `blueprint/14-scalability` (§Rate limiting) | Identificação do cliente para rate limit pode ser **tenant ID** |

**As decisões obrigatórias que precisam estar escritas antes da primeira migração:**

| Decisão | Opções | Consequência |
| --- | --- | --- |
| **Modelo de isolamento** | Banco por tenant · Schema por tenant · **Linha por tenant (`tenant_id`)** | Custo operacional × força do isolamento |
| **Onde o `tenant_id` entra** | Claim no JWT · subdomínio · header · path | Define o middleware de resolução de tenant |
| **Como é imposto** | Middleware global · row-level security no banco · filtro no repository | Onde um esquecimento vira vazamento |
| **Chave de particionamento** | `tenant_id` · região · hash | Define o caminho de sharding futuro |
| **Dados compartilhados** | Planos, feature flags, templates | O que **não** é isolado por tenant |
| **Cross-tenant admin** | Impersonation? Suporte com acesso? | Exige trilha de auditoria dedicada |

**Regra defensiva:** o teste de autorização obrigatório em `backend/14-tests.md` ("role certo, errado, owner") deve incluir explicitamente o cenário **tenant errado**. O erro retornado é `NOT_FOUND` (404), não `RESOURCE_OWNERSHIP` (403) — conforme `shared/error-ux-mapping.md`, para não revelar a existência do recurso.

### 13.2 Billing, planos e assinaturas

Onde o repositório toca no assunto:

- `frontend/{client}/01-architecture` e `02-project-structure` — `billing` é um dos **domínios de exemplo**, com `PlanSelector`, `InvoiceList`, `PaymentForm` e `billingStore`
- `frontend/{client}/05-state` — evento `subscription:updated` no event bus, com payload `{ planId, limits }`, ouvido por `dashboard` e `storage`
- `backend/13-integrations` — Stripe como integração de criticidade **alta**, com `createCharge`, `refund`, `getCharge`, circuit breaker e webhooks (`payment_intent.succeeded`, `charge.refunded`) com **signature verification**
- `backend/12-events` — `OrderPaid` produzido por `PaymentService`, consumido por `OrderService` e `NotificationWorker`, com retry 5× e DLQ; cron `RetryFailedPayments` a cada 30 min
- `blueprint/09-state-models` — **assinatura** é citada nominalmente como entidade com ciclo de vida
- `frontend/{client}/14-copies` — glossário de produto com `Plano` ("nível de assinatura", não usar "Pacote"/"Tier")

**As decisões obrigatórias:**

| Decisão | Onde documentar |
| --- | --- |
| Máquina de estados da assinatura (`trialing → active → past_due → canceled → expired`) | `blueprint/09-state-models.md` |
| Entidades `Plan`, `Subscription`, `Invoice`, `UsageRecord` | `blueprint/04-domain-model.md` |
| Quem é a fonte de verdade: o gateway ou o seu banco | ADR em `docs/adr/` |
| Idempotência de webhook de pagamento (dedup por `event_id`) | `backend/12-events.md` + `04-data-layer.md` |
| Proration, upgrade/downgrade, trial sem cartão | `blueprint/08-use_cases.md` |
| Dunning: quantas tentativas, em que intervalo, quando suspender | `backend/12-events.md` (cron) + `13-integrations.md` (templates) |
| O que acontece com os dados após cancelamento (retenção, export, exclusão) | `blueprint/13-security.md` §privacidade |

> **Armadilha clássica:** tratar o webhook do gateway como comando em vez de notificação. O padrão correto, coerente com `12-events`, é: webhook chega → valida assinatura → enfileira evento idempotente → worker reconsulta o gateway → atualiza estado. Nunca confie no payload do webhook como verdade final.

### 13.3 Quotas, limites por plano e rate limiting

O repositório dá o mecanismo; o SaaS precisa ligá-lo ao plano:

| Camada | Fonte | O que definir |
| --- | --- | --- |
| **Rate limit técnico** | `backend/08-middlewares` · `blueprint/14-scalability` | Proteção contra abuso — por IP, por usuário, por tenant |
| **Quota de plano** | **decisão obrigatória** | Limites de negócio: usuários, storage, chamadas de API, seats |
| **Enforcement** | `backend/06-services` | Onde a quota é verificada — antes da operação, dentro da transação |
| **Resposta ao exceder** | `shared/error-ux-mapping` | `RATE_LIMIT_EXCEEDED` (429) para técnico; erro de negócio (422) + CTA de upgrade para quota |
| **Feedback na UI** | `{client}/14-copies` · `12-observability` | Banner de uso, aviso em 80%, bloqueio em 100% |

O payload `subscription:updated → { planId, limits }` do event bus do frontend já antecipa isso: **os limites do plano são estado global do cliente**, não constante hardcoded.

### 13.4 Onboarding e ativação

- `blueprint/08-use_cases` traz `UC-001 Cadastrar Novo Usuário` completo: fluxo principal, alternativa OAuth (Google/GitHub), e-mail já cadastrado, dados inválidos, **falha no envio do e-mail de confirmação → cria a conta, registra o erro e agenda reenvio** (não perde o cadastro)
- `backend/06-services` — `UserService.register()` enfileira `SendWelcomeEmail` **fora** da transação
- `backend/13-integrations` — `TPL-001` (boas-vindas, com `activationUrl`) e `TPL-002` (reset de senha, com `expiresIn`)
- `{client}/12-observability` — **User Flow Monitoring**: onboarding com eventos `start, step_1, step_2, complete` e meta de conclusão de 80%
- `{client}/14-copies` — empty states com CTA ("Nenhum dado disponível ainda" + "Começar agora") — o principal veículo de ativação

**Decisão obrigatória:** o estado `created` (antes de `active`) já existe na máquina de estados de `User`. Documente o que o usuário **pode** fazer em `created` — isso é a diferença entre um trial fluido e um funil que morre na verificação de e-mail.

### 13.5 Compliance e privacidade (LGPD/GDPR)

De `blueprint/13-security` e do README mestre §7.3 e §19.6:

- Minimização de dados · finalidade declarada · retenção definida por tipo de dado
- Anonimização / pseudonimização
- **Direito ao esquecimento** — exclusão completa em prazo definido (o PRD template sugere 30 dias)
- Consentimento explícito para coleta
- Trilha de auditoria para leitura sensível, mudança de permissão, exclusão e **exportação**
- Residência de dados e segregação
- SLA de notificação de incidente — **72 h para LGPD**

**Ligação com o produto:** exclusão de conta interage com soft delete (`deletedAt` em todas as entidades), com backups criptografados e com retenção de logs. Esses três pontos precisam estar coerentes ou a promessa de exclusão é falsa.

### 13.6 As lacunas honestas do repositório

O framework cobre a engenharia de um SaaS com profundidade, mas há temas de SaaS que ele **não** documenta explicitamente. São decisões que você precisa acrescentar (via `/increment`) e que este mapa marca para que não passem despercebidas:

| Tema ausente | Onde deveria entrar |
| --- | --- |
| Métricas de negócio SaaS (MRR, ARR, churn, LTV, CAC, NRR) | `blueprint/01-vision` §métricas + dashboard de negócio em `15-observability` |
| Modelo de pricing e packaging | `prd.md` §3 + ADR dedicado |
| Self-service vs sales-assisted | `blueprint/00-context` §atores + `08-use_cases` |
| Seats, convites e gestão de time | `blueprint/04-domain-model` (entidade `Membership`) + `11-permissions` |
| SSO empresarial (SAML/SCIM) | `blueprint/13-security` §autenticação + ADR |
| API pública para clientes, API keys e developer portal | `backend/05-api-contracts` + `11-permissions` |
| Data residency por região e failover regional | `blueprint/06-system-architecture` §boundaries + `14-scalability` |
| Status page e comunicação de incidente ao cliente | `blueprint/15-observability` §runbooks |
| Impersonation e ferramentas de suporte | `backend/11-permissions` + trilha de auditoria em `13-security` |
| Analytics de produto e experimentação (A/B) | `{client}/12-observability` §feature flags |
| **Fuso horário e moeda como decisão de domínio** — armazenar em UTC, exibir no tz do tenant/usuário; multi-moeda e taxa de conversão no momento da cobrança | `blueprint/04-domain-model` (convenção de campo) + `05-data-model` (tipo de coluna) + ADR. É causa clássica de bug de faturamento e de relatório |
| **Entitlements por plano** — quais *features* ligam e desligam por plano, distinto de quota numérica | `blueprint/04-domain-model` (entidade `Plan`) + `backend/11-permissions` (checagem) + `{client}/12-observability` (feature flags) |
| **Ciclo de vida do próprio tenant** — criar, provisionar (seed inicial, subdomínio), suspender, excluir com hard delete e backups | `blueprint/09-state-models` (máquina de estados de `Tenant`) + `08-use_cases` |
| **Import/export de dados do tenant** — migração na entrada, export sob demanda, portabilidade LGPD/GDPR | `blueprint/08-use_cases` + `13-security` §privacidade + `backend/12-events` (job assíncrono) |
| **Audit log exposto ao cliente como feature** (distinto da trilha interna de compliance) | `blueprint/04-domain-model` + `backend/05-api-contracts` + `13-security` |
| **SLA contratual, créditos de SLA e níveis de suporte** — o compromisso externo, distinto do SLO interno | `blueprint/03-requirements` §RNF + `15-observability` (o que comprova) + `11-build_plan` |
| **Custo por tenant / unit economics de infraestrutura** (COGS, FinOps, atribuição de custo por plano) | `blueprint/14-scalability` §plano de capacidade + dashboard de negócio em `15-observability` |
| **Faturamento fiscal** — nota fiscal, impostos, faturamento por país e moeda | `backend/13-integrations` + ADR; complementa a lacuna de pricing acima |
| **Metering de uso para pricing por consumo** — agregação de `UsageRecord`, janela de faturamento, reconciliação com o gateway, o que fazer com evento perdido | `backend/12-events` (worker de agregação) + `04-data-layer` (tabela de uso); complementa "Entitlements por plano" |
| **Usuário em múltiplas organizações** — cardinalidade N:M entre `User` e `Tenant`, resolução do tenant ativo, org switcher | `blueprint/04-domain-model` (entidade `Membership`) + `backend/11-permissions` (claim de tenant ativo no JWT). É mais que convite de seat: muda a chave primária da autorização |
| **Webhooks de saída como feature do cliente** — endpoints cadastrados por tenant, rotação de secret, log de entregas, **replay**. Distinto do bloco técnico de envio | `backend/05-api-contracts` (CRUD de endpoints) + `13-integrations` (entrega) + `{client}/07-routes` (tela) |
| **Preferências de notificação por usuário/tenant** — opt-out por categoria, digest, *quiet hours* | `blueprint/04-domain-model` (`NotificationPreference`) + `backend/13-integrations` (checagem antes do envio) + `{client}/14-copies`. Hoje o repositório fixa só rate limit de envio |
| **Entregabilidade de e-mail** — domínio de envio, SPF/DKIM/DMARC, reputação de IP, tratamento de bounce e complaint | `backend/13-integrations` + ADR. O framework escolhe o provedor e define fallback, mas entregabilidade não é problema de provedor — é de configuração e higiene de lista |

> Reconhecer a lacuna é parte do blueprint. Um documento que finge cobrir tudo é mais perigoso do que um que marca explicitamente onde não vai.

---

## 14. Contrato das skills e automação

### 14.1 As 21 skills

| Grupo | Skill | Produz |
| --- | --- | --- |
| **Automação** | `/pipeline` | Todos os documentos + scaffold, em fases isoladas |
| | `/build` | Features implementadas em loop com portões |
| **Blueprint técnico** | `/blueprint` | PRD salvo, análise de cobertura, roadmap de 6 fases |
| | `/blueprint-foundation` | `00`, `01`, `02`, `03` |
| | `/blueprint-domain` | `04`, `05`, `09` + diagramas de domínio |
| | `/blueprint-architecture` | `06`, `10` + ADRs individuais |
| | `/blueprint-flows` | `07`, `08` + diagramas de sequência |
| | `/blueprint-quality` | `12`, `13`, `14`, `15` + deployment scaled |
| | `/blueprint-plan` | `11`, `16` |
| **Backend** | `/backend` | 15 documentos |
| **Frontend** | `/frontend` | `shared/06`, `shared/15` + orquestração |
| | `/frontend-design-system` | `shared/03` |
| | `/frontend-app {client}` | 8 documentos do cliente |
| | `/frontend-quality {client}` | 5 documentos do cliente |
| **Evolução** | `/increment` | Alteração local em um blueprint |
| | `/patch` | Propagação global com adaptação de case |
| | `/specs` | `docs/specs/TASKS.md` |
| **Codegen** | `/codegen-setup` | `CLAUDE.md`, `src/contracts/`, schema, scaffold |
| | `/codegen` | Dashboard de entregas e próxima recomendada |
| | `/codegen-feature` | Feature vertical com TDD |
| | `/codegen-verify` | Score de aderência código × blueprint |

### 14.2 O contrato comum a todas as skills

| Convenção | Regra |
| --- | --- |
| **Write vs Edit** | Documento só com `{{placeholders}}` → **Write**. Documento com conteúdo real → **Edit**, inserindo antes de `<!-- APPEND:... -->`. Alteração pontual → `/increment` |
| **Rastreabilidade** | Conteúdo derivado é marcado: `<!-- do PRD -->`, `<!-- inferido do PRD -->`, `<!-- do blueprint: XX-arquivo.md -->` |
| **Versões de tecnologia** | Consultadas via Context7 (`resolve-library-id` → `query-docs`), nunca assumidas do treino do modelo |
| **Números são sensíveis a evidência** | Nunca inventar SLAs, metas de performance, métricas de negócio, nomes próprios ou constraints numéricos |
| **Perguntas são limitadas** | Nas skills de fase (as 6 do blueprint técnico, `/frontend`, `/frontend-app`, `/frontend-quality`): máximo **3 por skill inteira** (não por documento), agrupadas e feitas **antes** de gerar. **Exceções declaradas:** `/backend` faz até **14 perguntas** de implementação em grupos temáticos, aguardando resposta entre grupos; `/frontend-design-system` não tem teto — as escolhas de tipografia e paleta *são* as perguntas da skill |
| **Idioma** | Identificadores técnicos em inglês; descrições em português |

### 14.3 Marcadores de append (pontos de inserção estáveis)

`/increment` insere conteúdo **antes** destes marcadores, em vez de reescrever o documento:

> ⚠️ **Divergência do repositório, verificada arquivo por arquivo.** A skill `/increment` afirma que os documentos `02`, `05`, `06`, `07`, `08`, `14`, `15` e `16` do blueprint técnico **não têm** marcador `APPEND` e devem receber inserção "na seção apropriada". **Isso é falso: todos os oito têm marcador.** E mesmo entre os documentos que a skill reconhece, a lista dela é incompleta — omite `relationships` (04), `external-dependencies` (11) e `security-checklist` (13). A lista abaixo é o inventário real, extraído dos arquivos. Seguir a skill neste ponto faz um agente inserir conteúdo no lugar errado — este é o erro mais caro que o documento poderia propagar, e por isso ele é corrigido aqui em vez de repetido.

**Blueprint técnico** (inventário completo, com linha do arquivo):

| Doc | Marcadores reais |
| --- | --- |
| `00-context` | `actors`, `external-systems`, `constraints` |
| `01-vision` | `objectives`, `personas`, `success-metrics` |
| `02-architecture_principles` | `principles` *(a skill diz que não existe — existe, linha 110)* |
| `03-requirements` | `functional-requirements`, `nonfunctional-requirements` |
| `04-domain-model` | `glossary`, `entities`, `relationships` |
| `05-data-model` | `tables`, `critical-queries` *(linhas 42, 75)* |
| `06-system-architecture` | `components`, `communication` *(linhas 42, 67)* |
| `07-critical_flows` | `flows` *(linha 114)* |
| `08-use_cases` | `use-cases` *(linha 141)* |
| `09-state-models` | `state-models` |
| `10-architecture_decisions` | `adrs` |
| `11-build_plan` | `technical-risks`, `deliverables`, `external-dependencies` |
| `12-testing_strategy` | `coverage`, `ci-pipeline` |
| `13-security` | `threats`, `roles`, `security-checklist` |
| `14-scalability` | `capacity-limits`, `cache-strategies`, `rate-limits` *(linhas 75, 109, 128)* |
| `15-observability` | `metrics`, `alerts`, `dashboards` *(linhas 71, 116, 153)* |
| `16-evolution` | `technical-roadmap`, `technical-debt`, `deprecations`, `revision-history` *(linhas 17, 31, 82, 113)* |

**Backend** — 50 marcadores distintos nos 15 documentos:
`stack` · `camadas` · `principios` · `metricas` · `provedores` · `dominios` · `comunicacao` · `deploy` · `estrutura` · `nomenclatura` · `entidades` · `value-objects` · `regras` · `relacionamentos` · `maquinas` · `persistencia` · `repositories` · `schema` · `queries` · `endpoints` · `detalhamento` · `dtos` · `services` · `fluxos` · `controllers` · `rotas` · `serializers` · `middlewares` · `condicionais` · `hierarquia` · `codigos` · `cross-field` · `roles` · `matriz` · `campos-visiveis` · `eventos` · `schemas` · `workers` · `cron` · `catalogo` · `integracoes` · `webhooks` · `webhooks-enviados` · `provedores-comunicacao` · `templates-comunicacao` · `variaveis-comunicacao` · `regras-envio` · `convencoes-comunicacao` · `cenarios` · `ci`

**Frontend** — 60 marcadores distintos entre `shared/` e os clientes:
`cores` · `a11y` · `catalogo` · `hooks` · `dtos` · `cache` · `dependencias` · `campos-criticos` · `principios` · `usuarios` · `dominios` · `features` · `regras-importacao` · `primitivos` · `compostos` · `feature-components` · `desktop-components` · `stores` · `eventos` · `rotas` · `layouts` · `janelas` · `menus` · `tray` · `shortcuts` · `fluxos` · `flows` · `cobertura` · `estrategias` · `budget` · `vulnerabilidades` · `checklist` · `flags` · `ambientes` · `glossario` · `convencoes` · `decisoes` · `notifications` · `feedback-sucesso` · `feedback-erro` · `feedback-validacao` · `feedback-aviso` · e a família `copies-*` (`login`, `cadastro`, `dashboard`, `telas`, `navbar`, `sidebar`, `footer`, `modais`, `empty-states`, `tabbar`, `header`, `permissoes`, `alertas`, `titlebar`, `menubar`, `tray`, `notifications`, `dialogs`)

**Cross-layer** (`docs/shared/`) — 6 marcadores:

| Doc | Marcadores |
| --- | --- |
| `glossary.md` | `termos`, `acronimos`, `convencoes` *(linhas 10, 29, 47)* |
| `error-ux-mapping.md` | `erros` *(linha 26)* |
| `event-mapping.md` | `eventos`, `impacto` *(linhas 18, 45)* |

> ⚠️ **Segunda lacuna do framework:** `docs/shared/` tem marcadores de append, mas **não é alvo de `/increment`**. Atenção à ambiguidade: a skill *oferece* a opção `shared`, mas apenas como **cliente de frontend** (`docs/frontend/shared/` — design system, data layer, api-dependencies). `docs/shared/` (glossário, error-ux-mapping, event-mapping, MAPPING) não é alvo em nenhum nível. Adicionar um termo ao glossário exige edição manual ou `/patch`.
>
> ⚠️ **Terceira lacuna, e a mais consequente: nenhuma skill gera `docs/shared/`.** Verificado nas 21 skills: as 12 fases do `/pipeline` vão de `blueprint-foundation` a `codegen-setup` e **não incluem** os quatro documentos cross-layer; `/specs`, `/codegen-*` e `/patch` apenas os **leem**. Na prática, `glossary.md`, `error-ux-mapping.md` e `event-mapping.md` permanecem com `{{placeholders}}` depois de um `/pipeline` completo — e são justamente os documentos que impedem os três blueprints de divergirem. Consequências diretas:
>
> - O `/pipeline` entrega **48 documentos preenchidos**, não 52. Os 4 de `docs/shared/` continuam template.
> - A regra *"fonte única de termos"* de `glossary.md` não tem quem a execute: cada blueprint acaba com seu próprio glossário local, exatamente o que o arquivo existe para evitar.
> - `/specs` valida cobertura **contra** `shared/glossary.md` (linguagem ubíqua) e `/codegen-feature` lê `error-ux-mapping.md` — ambos leem um arquivo que ninguém preencheu.
>
> **O que fazer:** preencher os quatro manualmente após o `/pipeline`, ou com `/increment` mirando `blueprint` e propagando à mão. `04-domain-model.md` já instrui: *"Fonte única de termos: `docs/shared/glossary.md`. Ao preencher esta seção, atualize também o glossário compartilhado."* — a instrução existe; o automatismo não.

### 14.4 `/pipeline` — modo autônomo

**Pré-requisitos validados antes do run** (depois, nenhuma interrupção): PRD existe · projeto-alvo definido (ou `pular`).

**Detecção de clientes frontend** a partir de sinais no PRD:

| Sinal | Cliente |
| --- | --- |
| "app", "iOS", "Android", "React Native", "Expo", "push", "offline" | `mobile` |
| "desktop", "Electron", "Tauri", "system tray", "menu bar" | `desktop` |
| "web", "SaaS", "dashboard", "painel", "SEO", "navegador" | `web` |
| Nenhum sinal claro | `web` (padrão, registrado como suposição de risco médio) |

**Retomada:** verifica quais documentos já têm conteúdo real (sem `{{placeholders}}`) e pula as fases concluídas. Rodar `/pipeline` de novo continua de onde parou.

**Isolamento de contexto:** cada fase roda num subagente com contexto limpo, lê só o que precisa, escreve seus documentos e devolve um **resumo compacto**. O orquestrador acumula os resumos — **nunca relê os documentos gerados**. É isso que permite produzir 52 documentos sem estourar a janela de contexto.

**Retorno padronizado de cada subagente:**
```
DOCS:         <caminho de cada arquivo escrito>
ASSUMPTIONS:  - {arquivo} | {o que foi assumido} | {base} | {alto|medio|baixo}
GAPS:         - {o que o PRD não cobre e onde a suposição ficou frágil}
```

**Classificação de risco das suposições:**

| Risco | Quando | Exemplo |
| --- | --- | --- |
| **Alto** | Número, SLA, métrica ou nome próprio sem base no PRD | `p95 < 300ms` quando o PRD não fala de latência |
| **Médio** | Escolha técnica plausível mas não declarada | PostgreSQL inferido de "dados relacionais" |
| **Baixo** | Derivação lógica direta | Entidade `Order` porque o PRD fala em pedidos |

Tudo é consolidado em `docs/ASSUMPTIONS.md` — **escrito pelo orquestrador**, nunca pelos subagentes (evita conflito de escrita) — com resumo por risco e seção de lacunas do PRD.

**Tolerância a falha:** uma fase que falha **não para o pipeline** (documento incompleto não corrompe os seguintes), é registrada e reportada no final. A exceção é a fase 12 (`codegen-setup`), que tem **portão objetivo**: typecheck + lint + validação de schema. Se falhar após correção, reporta falha em vez de declarar sucesso.

### 14.5 `/build` — loop de implementação com portões

**Por que este loop para e o pipeline não:** documentação ruim não contamina o documento seguinte; **uma abstração errada na feature 1 contamina as features 4, 8 e 15**. O resultado é um código internamente consistente, todo verde e arquiteturalmente errado. Por isso: **na dúvida, para.**

**Pré-requisitos (todos bloqueantes):** `CLAUDE.md` existe · `src/contracts/` tem tipos · blueprints alcançáveis · **`git status` limpo** · comando de teste identificado · **suíte verde no baseline** (se já está vermelha, não há como distinguir falha pré-existente de falha introduzida).

**Ordenação:** por **dependência**, não por prioridade. Dentro do mesmo nível: Must → Should → Could. Uma entrega com 4 itens vira 4 features (cada feature = um vertical slice: banco + API + frontend + testes).

**Dois portões:**

| Portão | Frequência | Falha se |
| --- | --- | --- |
| **Suíte completa** | Toda feature | Qualquer teste vermelho · **contagem de testes menor que baseline + novos** · `red_ok: não` (código veio antes do teste) · `BLOCKED` preenchido |
| **Aderência (`/codegen-verify`)** | A cada 3 features | Score < 90% |

A checagem de **contagem de testes** existe para pegar o modo de falha mais perigoso: teste apagado ou pulado para deixar a suíte verde.

**Proibições explícitas no prompt do subagente:**
- Apagar, pular (`skip`/`only`/`todo`) ou afrouxar qualquer teste, novo ou existente
- Baixar limiar de cobertura ou desabilitar regra de lint para passar
- Criar tipo duplicado em vez de usar `src/contracts/`

Uma falha recebe **1 retry** com o output real do erro. Se o retry falhar, o loop **para**.

**Commit por feature** — granularidade que permite `git revert` de uma feature isolada quando a revisão humana reprova:
```
feat: {nome-da-feature} — {descrição curta}

Entrega: {ENT-XXX}
Testes: {n} novos, suíte com {total} verdes
```

### 14.6 `/codegen-feature` — ciclo TDD/XP

```
1. Carregar contexto  ← apenas 2-3 docs relevantes, via CLAUDE.md + MAPPING.md
2. Apresentar plano   ← banco, backend, frontend, testes
3. RED                ← escrever testes PRIMEIRO; todos devem FALHAR
4. GREEN              ← implementar o mínimo: schema → repository → service →
                        controller → validação → erros → middlewares → frontend
5. REFACTOR           ← extrair duplicação, melhorar nomes (linguagem ubíqua),
                        simplificar — testes verdes após cada passo
6. Commit granular
```

**Carga condicional de contexto por tipo de feature:**

| Tipo | Blueprint (máx 3) | Backend (máx 3) | Frontend (máx 2) |
| --- | --- | --- | --- |
| CRUD | `04-domain`, `05-data`, `08-use_cases` | `03-domain`, `05-api-contracts`, `06-services` | `{client}/04-components` |
| Fluxo | `07-flows`, `08-use_cases`, `09-states` | `06-services`, `09-errors` | `{client}/08-flows`, `{client}/05-state` |
| Auth | `07-flows`, `13-security` | `08-middlewares`, `11-permissions` | `{client}/11-security` |
| Dashboard | `07-flows` | `05-api-contracts`, `06-services` | `{client}/04-components` |
| Integração | `06-architecture` | `13-integrations`, `12-events` | `{client}/08-flows` |

### 14.7 `/codegen-verify` — as 8 verificações

| # | Verificação | Documento × Código | Checklist |
| --- | --- | --- | --- |
| V1 | Entidades × Tipos | `blueprint/04` + `backend/03` × `src/contracts/entities/` | Tipo existe? Atributos completos? Regras implementadas? Linguagem ubíqua? |
| V2 | Tabelas × Schema | `blueprint/05` + `backend/04` × schema do ORM | Campos, constraints, índices, FKs |
| V3 | API × Endpoints | `backend/05` + `blueprint/07` × rotas/controllers | Rota existe? Tipos? Validação? Erros? Middlewares? |
| V4 | Use cases × Testes | `blueprint/08` + `backend/14` × arquivos de teste | Cenário principal, pré-condições, exceções |
| V5 | State machines | `blueprint/09` + `backend/03` × services/entities | Estados no enum? Transições inválidas bloqueadas? |
| V6 | Segurança | `blueprint/13` + `backend/08,11` × middlewares | Auth? RBAC? Validação? Headers? |
| V7 | Frontend (por cliente) | `{client}/04` + `shared/03` × componentes | Props? Estados? Design tokens? |
| V8 | Cross-layer | `shared/event-mapping` + `error-ux-mapping` × handlers | Eventos consumidos? Erros com UX? Payloads consistentes? |

**Resultado:** score de aderência (%). Ação por divergência: código errado → `/codegen-feature` · doc desatualizado → `/increment` · ambíguo → perguntar.

> Este é o único gate **externo** do sistema. Teste escrito pelo mesmo agente que escreveu o código não é verificação independente.

### 14.8 `/specs` — backlog integral

Gera `docs/specs/TASKS.md` a partir de `docs/backend/` (fonte primária), validado contra frontend e blueprint.

**Grupos de task — 14, não 12:** `SETUP` · `DOM` · `DATA` · `SVC` · `API` · **`CTRL`** · `AUTH` · `ERR` · **`VAL`** · `MW` · `EVT` · `INT` · `TEST` · `FE`.

> ⚠️ **Inconsistência interna da skill.** O mapa de extração de `/specs` declara `07-controllers → CTRL` (1 task por controller) e `10-validation → VAL` (1 task por grupo de validação), mas a lista de IDs da estrutura de saída omite os dois. Seguir a lista de saída faz o backlog **perder duas camadas inteiras** — controllers e validação — que o mapa mandou gerar. Use os 14.

**Regra de derivação:** cada entidade gera no mínimo `DOM` + `DATA` + `SVC` + `API`.

**Formato de task:** camada · entidade · prioridade · **origem (arquivo)** · descrição com nomes de classes/métodos/campos · arquivos a criar/editar · dependências (TASK-IDs) · regras de negócio (`RN-XX`) · critérios de aceite verificáveis · testes (unitário e integração) · **componente de frontend que depende**.

**Validação de cobertura final — as perguntas que o documento precisa responder:**
```
Todo requisito funcional tem trabalho de implementação?
Todo fluxo crítico tem um service e cobertura E2E?
Todo caso de uso mapeia para endpoint + controller + service?
Toda ameaça documentada tem mitigação?
Todo template de comunicação tem evento disparador?
```

### 14.9 `/patch` — propagação global com adaptação de case

Varredura em `docs/blueprint/`, `docs/backend/`, `docs/frontend/shared/`, `docs/frontend/*/`, `docs/shared/`, `docs/specs/`, `docs/adr/`.

**Três classes de ocorrência:**

| Tipo | Exemplo | Ação |
| --- | --- | --- |
| **Direta** | `Booking` | Substituir automaticamente |
| **Contextual** | `bookingStore`, `BookingCard`, `useBooking`, `/api/booking` | Substituir **adaptando o case** |
| **Indireta** | "o sistema de booking permite…" | Marcar `<!-- PATCH-REVIEW -->` para revisão humana |

Adaptação de case suportada: PascalCase · camelCase · kebab-case · UPPER_CASE · compostos · prefixo `use` · paths · diretórios de feature.

**Regras críticas:** sempre Edit, nunca Write · uma Edit por ocorrência · **não alterar** marcadores `APPEND`, `{{placeholders}}` ou blocos `<details>` de exemplo genérico.

Encontre pendências com `grep -rn 'PATCH-REVIEW' docs/`.

---

## 15. Estratégia de contexto para agentes

Um blueprint preenchido de projeto real ultrapassa em muito o que cabe numa janela de contexto. O framework usa **quatro mecanismos** para manter o contexto de implementação limitado:

### 15.1 `CLAUDE.md` router

Mapeia **tipo de tarefa → 2-3 documentos relevantes**. Gerado por `/codegen-setup` a partir de `docs/templates/claudemd-template.md`.

> ⚠️ A tabela abaixo usa os **nomes reais** dos arquivos. O template de origem ainda traz nomes em português e em caminho flat (`04-componentes.md`, `05-estado.md`, `07-rotas.md`…) que **não existem** — ver §17.4 #4. Como `docs/templates/` está fora do escopo de `/patch` e `/increment`, essa correção é manual.

| Tipo de tarefa | Documentos a ler |
| --- | --- |
| Schema / Migrations | `blueprint/04-domain-model`, `05-data-model`, `09-state-models` |
| API / Backend | `blueprint/07-critical_flows`, `08-use_cases`, `06-system-architecture` |
| Componentes de frontend | `frontend/04-components`, `05-state`, `06-data-layer` |
| Rotas / Navegação | `frontend/07-routes`, `08-flows` |
| Segurança | `blueprint/13-security`, `frontend/11-security` |
| Testes | `blueprint/12-testing_strategy`, `frontend/09-tests` |
| Observabilidade | `blueprint/15-observability`, `frontend/12-observability` |

**Regras invioláveis que o router declara:**
- Nunca gerar código sem ler os docs de blueprint relevantes para a tarefa
- Usar a linguagem ubíqua do domínio
- **Sempre ler `src/contracts/` antes de implementar qualquer feature**
- Test-first: testes ANTES da implementação

### 15.2 Context excerpting

Para documentos grandes (50k+ tokens), não carregue o arquivo inteiro:
```
1. Leia o índice (grep '^#' — só os headers)
2. Localize as seções relevantes à feature
3. Carregue apenas essas seções (Read com offset/limit)
```

### 15.3 Contratos como cache compilado

`src/contracts/` é a **representação compilada** do modelo de domínio:
```
src/contracts/
├── entities/   um arquivo por entidade + index.ts
├── enums/      enums do domain model + index.ts
├── api/        request/response por recurso + index.ts
└── index.ts
```
Regras: entidades PascalCase, campos camelCase (conforme glossário) · enums em PascalCase com valores SCREAMING_SNAKE_CASE · **JSDoc com a descrição do domain model** · IDs como branded types quando a linguagem permitir.

Com os contratos corretos, cada sessão futura gera código tipado **sem reler o domain model inteiro**.

### 15.4 Orçamento de contexto

Sessões de implementação miram um contexto de documentação limitado (~70-100k tokens), deixando espaço para raciocínio e geração de código.

> O objetivo não é fazer cada agente saber tudo. É fazer cada agente ler **as coisas certas**.

---

## 16. Checklists operacionais

### 16.1 Antes de escrever a primeira linha de código

- [ ] PRD existe e responde: problema, personas, objetivos, métricas de sucesso, não-objetivos
- [ ] Limites do sistema escritos — o que **não** é responsabilidade
- [ ] 3-7 princípios arquiteturais declarados
- [ ] Todo RNF tem métrica e threshold numérico
- [ ] Modelo de domínio com invariantes por entidade
- [ ] Glossário ubíquo preenchido em `docs/shared/glossary.md`
- [ ] Entidades com ciclo de vida têm máquina de estados **com transições proibidas**
- [ ] **Decisão de multi-tenancy tomada e registrada em ADR**
- [ ] Banco escolhido com justificativa ligada ao padrão de leitura/escrita
- [ ] Todo ADR significativo registrado com opções e consequências
- [ ] 3-5 fluxos críticos com tratamento de erro e SLA
- [ ] Casos de uso usando exatamente os gatilhos das máquinas de estado
- [ ] Todo requisito **Must** dentro de alguma entrega do build plan
- [ ] `docs/ASSUMPTIONS.md` revisado — suposições de risco alto resolvidas

### 16.2 Definition of Done (por entrega)

- [ ] Código revisado
- [ ] Testes passando (suíte completa, não só os da feature)
- [ ] **Logs e métricas implementados**
- [ ] Documentação atualizada (blueprint reflete o código)
- [ ] Rollout definido
- [ ] Monitoramento configurado

### 16.3 Critérios mínimos antes de produção

- [ ] Cobertura mínima definida e atingida (domínio ≥ 95%, fluxos críticos 100%)
- [ ] Testes críticos automatizados
- [ ] Performance validada em staging sob carga
- [ ] Segurança revisada (checklist OWASP)
- [ ] **Rollback ensaiado**, não apenas documentado
- [ ] Migrações validadas
- [ ] Dashboards prontos (operacional + negócio)
- [ ] Alertas ativos com runbook e política de escalação
- [ ] Owners definidos por componente
- [ ] Teste de restauração de backup executado

### 16.4 Go / No-go de lançamento

**Go:** testes de aceitação passando · performance validada em staging · documentação de suporte pronta · monitoramento e alertas configurados · plano de rollback testado.

**No-go (bloqueia):** bug crítico aberto em fluxo principal · performance abaixo do threshold · falha em requisito de segurança ou compliance.

### 16.5 Checklist de segurança (consolidado)

**Backend:** queries parametrizadas · sessões seguras com expiração e proteção contra brute force · criptografia em trânsito e repouso · verificação de acesso em **cada** endpoint · headers HTTP seguros e CORS restritivo · sanitização de saída + CSP · tokens CSRF e SameSite · scanning de dependências (Dependabot/Snyk) + SBOM · **stack trace nunca em produção** · rate limit por IP, usuário e tenant.

**Frontend web:** tokens em cookie `httpOnly` (nunca localStorage) · inputs sanitizados antes de renderizar HTML dinâmico · CSP, X-Frame-Options, HSTS · `npm audit` regular · secrets nunca commitados · HTTPS obrigatório em todos os ambientes · **validação duplicada no backend**.

**Mobile:** tokens em SecureStore/Keychain/Keystore · certificate pinning em produção · ATS habilitado (iOS) e Network Security Config restritivo (Android) · root/jailbreak detection · ProGuard/R8 · Hermes (bytecode, não texto puro) · deep links validados e sanitizados · dados sensíveis fora dos logs · screenshot protection em telas sensíveis.

**Desktop:** context isolation e sandbox ativos · IPC tipado e validado nos dois lados · code signing e notarization · auto-update com verificação de integridade · controle de acesso ao file system · CSP no renderer.

### 16.6 Checklist de acessibilidade

- [ ] Contraste WCAG AA (4.5:1 normal, 3:1 large)
- [ ] Todo componente interativo focável via teclado
- [ ] Toda imagem com alt text descritivo
- [ ] Formulários com labels associadas e erros acessíveis
- [ ] Modais com focus trap e Esc para fechar
- [ ] Navegação 100% por teclado
- [ ] Screen reader anuncia mudanças de estado (`aria-live`)
- [ ] **Nenhuma informação transmitida apenas por cor**

---

## 17. Anti-patterns e armadilhas

### 17.1 Os que o repositório declara explicitamente

| Anti-pattern | Por quê | Onde |
| --- | --- | --- |
| Server state em store global | Duplica cache, perde revalidação | `{client}/05-state` |
| Estado global para dado local | Complexidade e re-renders | `{client}/05-state` |
| Prop drilling > 2 níveis | Código frágil | `{client}/05-state` |
| Store monolítica gigante | Difícil de testar, re-renders excessivos | `{client}/05-state` |
| Feature importando de outra feature | Acoplamento entre domínios | `{client}/01-architecture`, `02-project-structure` |
| Controller acessando repository | Pula a camada de negócio | `backend/01-architecture` |
| Service retornando entidade de ORM | Vaza a infraestrutura para fora | `backend/01-architecture` |
| Domain importando de Infrastructure | Inverte a regra de dependência | `backend/01-architecture`, `{client}/01-architecture` |
| Token em `localStorage` / `AsyncStorage` | Legível por XSS / gravado em texto puro | `{client}/11-security` (web e mobile) |
| Misturar organização por camada e por módulo | Ninguém acha nada | `backend/02-project-structure` |
| Template de mensagem sem evento disparador | Órfão, nunca é enviado | `backend/13-integrations` |
| Apagar/pular teste para ficar verde | Destrói o único sinal de regressão | `/build` |
| Dois números para a mesma métrica | Alerta e limite divergem | `/blueprint-quality` |
| `NSAllowsArbitraryLoads: true` em produção | Desliga o TLS obrigatório | `mobile/11-security` |

### 17.2 As armadilhas de trabalhar com agentes de IA

| Armadilha | Mitigação no framework |
| --- | --- |
| **Suíte verde = código correto** | `/codegen-verify` compara código × documento; verde só prova consistência interna |
| **Suposição vira fato silenciosamente** | Marcadores `<!-- assumido -->` + `ASSUMPTIONS.md` com classificação de risco |
| **Deriva arquitetural acumulada** | `/build` para na primeira suíte vermelha; verify a cada 3 features |
| **Contexto estourado / documentação irrelevante carregada** | Router `CLAUDE.md` + context excerpting + `src/contracts/` como cache |
| **Mudança aplicada numa camada e esquecida na outra** | `/patch` com varredura global e `PATCH-REVIEW` |
| **Versão de biblioteca alucinada do treino** | Context7 obrigatório para toda tecnologia com versão |
| **Documento parece preenchido mas é genérico** | Detecção de `{{placeholders}}` + regra de nunca inventar números |
| **Agente pergunta sem parar / trava o pipeline** | Máximo 3 perguntas por skill; modo autônomo infere e marca |
| **Escrita concorrente de subagentes no mesmo arquivo** | `ASSUMPTIONS.md` escrito só pelo orquestrador |
| **Abstração errada na feature 1 contamina a 15** | Loop para na falha; commit granular permite `git revert` isolado |

### 17.3 Os limites honestos do framework

Do próprio README e das seções "Limites conhecidos" das skills:

- **Qualidade do output depende da qualidade do PRD.** O framework estrutura incerteza; não recupera conhecimento de negócio que nunca foi fornecido.
- **Automação custa contexto e tokens.** Um subagente por fase consome mais que uma sessão única — é o preço do isolamento de contexto.
- **O pipeline produz um rascunho completo, não verdade inquestionável.** Revisão de engenharia continua necessária.
- **O scaffold herda as suposições.** Se a fase de dados supôs PostgreSQL, o schema nasce em PostgreSQL.
- **Teste não é verificação de arquitetura.** Suíte verde é necessária, não suficiente.
- **Deriva arquitetural é detectada tarde.** Rode `/build --max 3` nas primeiras features e revise antes de soltar o loop inteiro.
- **Blueprint é pesado para trabalho pequeno.** Experimento descartável, arquitetura temporária, exploração pré-requisitos ou uma sessão curta de agente não justificam o custo.
- **O pipeline autônomo é má escolha para sistema crítico com PRD raso.** Nesse caso, skills guiadas e resolução de incerteza antes da implementação.

### 17.4 Divergências internas do repositório (verificadas)

Um framework documentation-driven também sofre de deriva documental. Estas **seis** divergências foram confirmadas arquivo a arquivo e estão registradas aqui em vez de resolvidas em silêncio — porque um agente que segue a fonte errada produz um erro difícil de rastrear:

| # | Divergência | Fontes em conflito | Qual seguir |
| --- | --- | --- | --- |
| 1 | **Marcadores `APPEND` do blueprint técnico** | `.claude/skills/increment/SKILL.md` diz que `02, 05, 06, 07, 08, 14, 15, 16` não têm marcador; **os oito arquivos têm** | Os arquivos. Inventário real em §14.3 |
| 2 | **Nome do diagrama de arquitetura do cliente web** | `/frontend-app` gera `{client}-architecture.mmd`; `docs/diagrams/web/README.md` declara `frontend-architecture.mmd` | O README do diagrama, que é o que `frontend/web/01-architecture.md` referencia |
| 3 | **Numeração de fluxos alternativos e exceções em casos de uso** | `/blueprint-flows` diz `1a, 2a…` e `E1, E2…`; `docs/blueprint/08-use_cases.md` e `docs/templates/use-case-template.md` usam `2a` (alternativo) e `2b` (exceção) | Os templates, que são o que o documento gerado precisa espelhar |
| 4 | **Referências cruzadas em português e em caminho flat, apontando para arquivos inexistentes** | Não é um template isolado: **37 ocorrências em 25 arquivos**, em quatro classes — (a) o template do router `docs/templates/claudemd-template.md` (`04-componentes.md`, `05-estado.md`, `07-rotas.md`, `08-fluxos.md`, `09-testes.md`, `11-seguranca.md`, `12-observabilidade.md` e o flat `docs/frontend/06-data-layer.md`); (b) **`01-arquitetura.md`, referenciado em 6 documentos de cliente** (`{web,desktop}/00-frontend-vision.md`, `.../02-project-structure.md`, `.../05-state.md`); (c) o resto dos docs de cliente (`07-rotas.md`, `11-seguranca.md`, `09-testes.md`, `13-cicd-convencoes.md`, `12-observabilidade.md`, `00-visao-frontend.md`); (d) os **compartilhados e cross-layer** — `frontend/shared/03-design-system.md:122`, `frontend/shared/06-data-layer.md:149`, `frontend/shared/15-api-dependencies.md:90`, `docs/shared/event-mapping.md:49-51` e `docs/shared/error-ux-mapping.md:60-61`, estes últimos com o caminho **flat** `docs/frontend/06-data-layer.md`, `docs/frontend/11-security.md`, `docs/frontend/12-observability.md` | A estrutura real (`docs/frontend/{shared,web,mobile,desktop}/`, nomes em inglês). **Deriva sistêmica** da migração flat → multi-client: atingiu o template do router, os documentos gerados *e* os conectores cross-layer |
| 5 | **Prefixo de regra de negócio** | `docs/blueprint/04-domain-model.md`, `08-use_cases.md`, `backend/03-domain.md` e `/specs` usam **`RN-XX`**; `docs/templates/use-case-template.md:54` e `docs/blueprint/README.MD:356,608` usam **`RB-01`** | **`RN-XX`** — é o que os documentos modulares, o backend e o gerador de backlog usam. `RB-` sobrevive só no master e no template de caso de uso |
| 6 | **Dono do `auth-flow.mmd`** | `docs/diagrams/README.md` §6 atribui todos os `sequences/*.mmd` a `07-critical_flows.md`; `/blueprint-quality` manda atualizá-lo ao gerar `13-security.md` | Ambos, em momentos diferentes: o fluxo nasce em `07` (fase 4) e o detalhe de autenticação é refinado por `13` (fase 5). Detalhado em §3.3 |

> ⚠️ **E aqui está a quarta lacuna estrutural do framework:** `/patch` e `/increment` **não conseguem corrigir metade destas divergências**. A varredura do `/patch` cobre `docs/blueprint/`, `docs/backend/`, `docs/frontend/shared/`, `docs/frontend/*/`, `docs/shared/`, `docs/specs/` e `docs/adr/` — **`docs/templates/` e `docs/diagrams/` ficam de fora**, e `/increment` também não os alcança. Ou seja: a divergência #2 (`docs/diagrams/web/README.md`) e a classe (a) da #4 (as 8 ocorrências no `claudemd-template.md`) exigem **edição manual**. O framework tem ferramenta para corrigir a si mesmo, mas não para corrigir as próprias ferramentas.
>
> Somem-se a estas as **três lacunas estruturais** registradas em §14.3: marcadores que a skill `/increment` não conhece · `docs/shared/` fora do alvo de `/increment` · `docs/shared/` sem skill que o gere. E a **inconsistência interna do `/specs`** (grupos `CTRL` e `VAL` no mapa, ausentes na saída), em §14.8.

---

## 18. Índice de arquivos do repositório

### 18.1 Documentação

```
docs/
├── prd.md                              ENTRADA (criado pelo usuário a partir de templates/prd-template.md)
├── ASSUMPTIONS.md                      Relatório de inferências do modo autônomo
│
├── blueprint/                          17 documentos modulares + 1 master — FONTE PRIMÁRIA
│   ├── README.MD                       blueprint master: seções 0 a 25 num único arquivo.
│   │                                   SEM equivalente modular — quem escolher "modulares"
│   │                                   perde: §0.3 aprovações · §5 stakeholders · §11 integrações
│   │                                   e interfaces · §20.1 SLA/SLO/error budget (não há "SLO"
│   │                                   em nenhum dos 17) · §24 questões em aberto ·
│   │                                   §9.5/§9.6 retenção, arquivamento, backup e RPO/RTO.
│   │                                   Com equivalente PARCIAL: §4 escopo, §15 riscos/
│   │                                   restrições/assunções (o master acrescenta IDs, owner,
│   │                                   "impacto se falsa" e "fonte" — ver §4.5).
│   │                                   Escolha UM formato: master OU modulares (não sincronize os dois)
│   ├── 00-context.md                   atores, sistemas externos, limites, restrições
│   ├── 01-vision.md                    problema, pitch, objetivos, personas, métricas
│   ├── 02-architecture_principles.md   3-7 princípios com implicações
│   ├── 03-requirements.md              RF (MoSCoW) + RNF (com threshold) + priorização
│   ├── 04-domain-model.md              glossário, entidades, regras, relacionamentos
│   ├── 05-data-model.md                banco, tabelas, índices, migração, queries
│   ├── 06-system-architecture.md       componentes, comunicação, ambientes, infra
│   ├── 07-critical_flows.md            3-5 fluxos com erro e performance
│   ├── 08-use_cases.md                 UC com fluxos alternativos e exceções
│   ├── 09-state-models.md              estados, transições, proibições
│   ├── 10-architecture_decisions.md    índice de ADRs
│   ├── 11-build_plan.md                entregas, priorização, riscos, dependências
│   ├── 12-testing_strategy.md          pirâmide, categorias, cobertura, ambientes, CI
│   ├── 13-security.md                  STRIDE, authN/Z, proteção de dados, OWASP, compliance
│   ├── 14-scalability.md               escala, limites, capacidade, cache, rate limit, degradação
│   ├── 15-observability.md             logs, Golden Signals, tracing, alertas, dashboards, health
│   └── 16-evolution.md                 roadmap, débitos, SemVer, deprecação, revisão
│
├── backend/                            15 documentos — COMO, no servidor
│   └── 00-backend-vision · 01-architecture · 02-project-structure · 03-domain ·
│      04-data-layer · 05-api-contracts · 06-services · 07-controllers · 08-middlewares ·
│      09-errors · 10-validation · 11-permissions · 12-events · 13-integrations · 14-tests
│
├── frontend/                           3 shared + 13 por cliente — COMO, no cliente
│   ├── shared/   03-design-system · 06-data-layer · 15-api-dependencies
│   ├── web/      00,01,02,04,05,07,08,09,10,11,12,13,14
│   ├── mobile/   idem, adaptado (Expo, SecureStore, Hermes, EAS, OTA)
│   └── desktop/  idem, adaptado (Electron/Tauri, IPC, code signing, auto-update)
│
├── shared/                             4 documentos — CONECTORES
│   ├── MAPPING.md                      índice mestre de rastreabilidade
│   ├── glossary.md                     termos, acrônimos, convenções de nomenclatura
│   ├── error-ux-mapping.md             erro do backend → comportamento visual
│   └── event-mapping.md                evento do backend → estado do frontend
│
├── backend-answers.md                  respostas de implementação coletadas por /backend (14 perguntas)
├── specs/TASKS.md                      backlog integral (gerado por /specs)
│
├── templates/                          prd (468 linhas, ENTRADA) · claudemd (router) ·
│                                       epic · story · task · use-case
├── adr/adr-template.md                 template de decisão arquitetural
└── diagrams/                           C4 (contexto, containers, componentes) +
                                        sequences · deployment · domain · por cliente
```

### 18.2 Skills

```
.claude/skills/
├── pipeline/          build/                              automação
├── blueprint/         blueprint-foundation/  blueprint-domain/
│                      blueprint-architecture/ blueprint-flows/
│                      blueprint-quality/     blueprint-plan/    técnico (6 fases)
├── backend/                                                     backend
├── frontend/          frontend-design-system/
│                      frontend-app/          frontend-quality/  frontend
├── increment/         patch/                 specs/             evolução e backlog
└── codegen-setup/     codegen/               codegen-feature/
                       codegen-verify/                            código
```

### 18.3 Referência rápida de comandos

```
# Documentação
/blueprint [prd]                 intake do PRD, análise de cobertura, roadmap
/blueprint-foundation            00, 01, 02, 03
/blueprint-domain                04, 05, 09
/blueprint-architecture          06, 10 + ADRs
/blueprint-flows                 07, 08
/blueprint-quality               12, 13, 14, 15
/blueprint-plan                  11, 16
/backend                         15 docs do servidor
/frontend                        shared 06, 15 + orquestração
/frontend-design-system          shared 03
/frontend-app {client}           8 docs do cliente
/frontend-quality {client}       5 docs do cliente

# Automação
/pipeline [prd] [clientes] [alvo]   tudo, em fases isoladas, sem perguntas
/build [ENT-XXX...] [--max N]       features em loop com portões

# Evolução
/increment                       adicionar, corrigir, atualizar, remover (Edit)
/patch                           propagar mudança global com adaptação de case
/specs                           backlog integral em docs/specs/TASKS.md

# Código
/codegen-setup [alvo]            CLAUDE.md + contracts + schema + scaffold (1×)
/codegen                         dashboard de entregas
/codegen-feature [nome]          feature vertical com TDD
/codegen-verify                  score de aderência código × blueprint
```

---

## Fecho

O que este documento reúne, em uma frase:

> **Um SaaS é fundamentalmente 14 decisões — domínio, dados, estados, limites, arquitetura, contratos, isolamento entre tenants, assíncrono, resiliência, segurança, qualidade, plano, evolução e o vocabulário que amarra tudo — e a diferença entre um sistema que cresce e um que trava está em quantas dessas decisões existem escritas antes do código, e em quantas continuam sendo verdade depois dele.**

O framework não torna as decisões mais fáceis. Torna-as **explícitas, rastreáveis e verificáveis** — e é isso que permite que um agente de IA, ou um engenheiro que entrou ontem, construa a coisa certa sem precisar que alguém explique de novo.

> **Não peça ao agente para lembrar da arquitetura. Dê a ele uma arquitetura que ele consiga ler.**
