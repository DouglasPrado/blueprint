---
name: blueprint-quality
description: Fase 5 do blueprint tecnico — gera 12-testing, 13-security, 14-scalability e 15-observability.
---

# Blueprint — Fase 5: Atributos de Qualidade

Gera os 4 documentos de atributos nao funcionais. Todos derivam da mesma base — arquitetura (`06`) e fluxos criticos (`07`) — por isso saem na mesma passada.

## Contexto (ler uma vez)

- `docs/prd.md` — fonte primaria
- `docs/blueprint/05-data-model.md` — dados sensiveis e volumes
- `docs/blueprint/06-system-architecture.md` — componentes, stack e comunicacao
- `docs/blueprint/07-critical_flows.md` — fluxos a cobrir com testes e com requisitos de performance
- `docs/blueprint/03-requirements.md` — RNFs com thresholds ja definidos
- Templates a preencher: `docs/blueprint/12-testing_strategy.md`, `13-security.md`, `14-scalability.md`, `15-observability.md`
- `docs/diagrams/sequences/auth-flow.mmd` — template de fluxo de autenticacao

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** ferramentas de teste, monitoramento e seguranca → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca invente** thresholds, projecoes de crescimento ou SLAs — extraia de `03`/`07` ou pergunte.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento).

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Metodo de autenticacao e regulamentacoes aplicaveis** (13) — LGPD, SOC2, PCI-DSS
2. **Projecoes de crescimento** (14) — usuarios, RPS e volume em 6m e 12m
3. **Ferramentas de teste e observabilidade** (12/15) — proponha padroes coerentes com a stack de `06`

---

## 12 — Estrategia de Testes

Preencha:
- **Piramide**: proporcao sugerida (ex: 70% unit, 20% integration, 10% E2E)
- **Categorias**: para unit, integration, E2E, load e chaos — objetivo, escopo, ferramentas e criterios de sucesso
- **Cobertura minima**: tabela com camada, cobertura minima e justificativa
- **Ambientes de teste**: ambiente, proposito e dados utilizados
- **Automacao e CI**: etapa do pipeline, testes executados, gatilho e se e bloqueante

Cada fluxo critico de `07` deve ter ao menos um teste E2E nomeado. Integracoes externas de `00`/`06` pedem testes de contrato.

---

## 13 — Seguranca

Preencha:
- **Modelo de ameacas**: tabela STRIDE aplicada aos componentes de `06` — ameaca, categoria, impacto, mitigacao
- **Autenticacao**: metodo, provedor, fluxo, politicas de credenciais
- **Autorizacao**: modelo (RBAC/ABAC), roles, permissoes e regras de acesso
- **Protecao de dados**: em transito (TLS), em repouso (criptografia), tratamento de PII
- **Checklist OWASP**: status de cada item do Top 10
- **Auditoria e compliance**: regulamentacoes, logging, retencao, resposta a incidentes

**Diagrama:** atualize `docs/diagrams/sequences/auth-flow.mmd` com o fluxo de autenticacao real.

---

## 14 — Escalabilidade

Preencha:
- **Estrategias de escala**: horizontal (quais servicos, balanceamento, auto-scaling), vertical, caching, sharding
- **Limites atuais**: metrica, limite atual, gargalo e acao
- **Plano de capacidade**: metrica, valor atual, projecao 6m e 12m
- **Cache**: item, TTL, estrategia de invalidacao
- **Rate limiting**: recurso, limite e resposta (HTTP 429)
- **Degradacao graciosa**: niveis com trigger e acoes — o que desligar primeiro sob carga

**Diagramas:** atualize
- `docs/diagrams/deployment/production.mmd` — topologia basica
- `docs/diagrams/deployment/production-scaled.mmd` — topologia escalada (multi-AZ, replicas)

---

## 15 — Observabilidade

Preencha:
- **Logs**: formato JSON estruturado com exemplo, niveis, retencao por ambiente, eventos criticos
- **Metricas**: tabela Golden Signals (latencia, trafego, erros, saturacao) com thresholds + metricas custom
- **Tracing**: ferramenta, convencoes de spans, protocolo de propagacao, taxa de amostragem
- **Alertas**: tabela com alerta, severidade, condicao e runbook; tabela de severidades P1-P4 com SLA de resposta; politica de escalacao em 3 etapas
- **Dashboards**: nome, publico-alvo e metricas incluidas (operacional e de negocio)
- **Health checks**: endpoints de liveness e readiness com resposta JSON esperada

Os thresholds de alerta devem ser coerentes com os limites definidos em `14` — nao crie dois numeros diferentes para a mesma metrica.

---

## Revisao e Proxima Etapa

Apresente os 4 documentos ao usuario em sequencia. Aplique ajustes. Salve arquivos e diagramas.

> "Atributos de qualidade definidos (12, 13, 14, 15). Rode `/blueprint-plan` para fechar com plano de construcao e evolucao."
