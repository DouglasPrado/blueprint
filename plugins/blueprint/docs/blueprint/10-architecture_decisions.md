# Decisões Arquiteturais

## O que é um ADR?

Um **Architecture Decision Record (ADR)** é um registro curto e objetivo de uma decisão técnica significativa tomada no projeto. ADRs capturam o **contexto** em que a decisão foi tomada, as **opções avaliadas**, a **escolha final** e suas **consequências**.

### Por que registrar decisões?

- **Memória institucional** — Novos membros da equipe entendem rapidamente o "porquê" por trás das escolhas técnicas.
- **Rastreabilidade** — Quando algo precisa mudar, sabe-se exatamente o que foi decidido, quando e por quê.
- **Qualidade** — O ato de escrever força uma análise mais rigorosa das alternativas antes de escolher.
- **Evita retrabalho** — Decisões já avaliadas e descartadas não são revisitadas sem contexto.

> Toda decisão técnica significativa que afeta a estrutura do sistema deve ser registrada aqui.

---

## Quando Escrever um ADR?

Registre um ADR sempre que a equipe tomar uma decisão que:

- Escolhe um **banco de dados**, fila de mensagens ou serviço de infraestrutura
- Define um **framework**, linguagem ou biblioteca principal
- Adota um **protocolo de comunicação** (REST, gRPC, GraphQL, WebSocket)
- Estabelece um **padrão arquitetural** (monolito, microsserviços, event-driven, CQRS)
- Altera uma decisão anterior (neste caso, marque a ADR antiga como **Substituída**)
- Impacta **segurança**, **performance** ou **escalabilidade** de forma estrutural

> Na dúvida, registre. É melhor ter um ADR a mais do que perder o contexto de uma decisão importante.

---

## Template ADR

> 📄 Template completo: [adr-template.md](../adr/adr-template.md)

---

## Exemplo

> Este exemplo usa o formato simplificado. Para novos ADRs, use o [template completo](../adr/adr-template.md) que inclui Drivers de Decisão, Riscos e Histórico.

### ADR-001: Uso de PostgreSQL como banco de dados principal

**Data:** 2026-01-15

**Status:** Aceita

#### Contexto

O sistema precisa de um banco de dados relacional para armazenar dados transacionais com integridade referencial. A equipe possui experiência com bancos relacionais e o volume esperado inicial é de até 500 mil registros por mês. O projeto é hospedado em infraestrutura cloud com suporte a serviços gerenciados.

#### Opções Consideradas

| Opção | Prós | Contras |
|-------|------|---------|
| PostgreSQL | Open-source, extensível (JSONB, full-text search), ampla comunidade, suporte nativo em todos os cloud providers | Configuração de replicação mais manual que alternativas gerenciadas |
| MySQL | Muito popular, simples de operar, boa performance para leitura | Menos recursos avançados (tipos de dados, extensões), suporte a JSON menos maduro |
| MongoDB | Flexibilidade de schema, escala horizontal nativa | Sem transações ACID tradicionais em múltiplas coleções, equipe sem experiência |

#### Decisão

Escolhemos **PostgreSQL** por oferecer o melhor equilíbrio entre funcionalidades avançadas (JSONB, CTEs, índices parciais), maturidade e experiência da equipe. O suporte nativo em cloud providers (RDS, Cloud SQL, Azure Database) simplifica a operação.

#### Consequências

**Positivas:**
- Suporte a consultas complexas e dados semi-estruturados (JSONB) sem banco adicional
- Ecossistema maduro de ferramentas de migração e monitoramento
- Equipe já possui conhecimento, reduzindo curva de aprendizado

**Negativas:**
- Se o volume crescer significativamente, pode ser necessário sharding ou read-replicas
- Funcionalidades NoSQL (JSONB) não substituem um banco de documentos para cenários de alta escala

**Ações necessárias:**
- Provisionar instância PostgreSQL 16 no ambiente cloud
- Configurar ferramenta de migração de schema (ex.: Flyway ou migrate)
- Definir política de backup e retenção

---

## Seus ADRs

> Registre aqui as decisoes significativas ja tomadas. Cada uma tambem ganha um arquivo proprio em [docs/adr/](../adr/), a partir de [adr-template.md](../adr/adr-template.md).

### Indice

| ADR | Titulo | Status | Data | Impacto |
|-----|--------|--------|------|---------|
| ADR-001 | {{titulo_da_decisao}} | {{Proposta / Aceita / Deprecada / Substituida}} | {{AAAA-MM-DD}} | {{o que esta decisao restringe}} |
| ADR-002 | {{titulo_da_decisao}} | {{status}} | {{AAAA-MM-DD}} | {{impacto}} |

### ADR-001: {{Titulo}}

**Data:** {{AAAA-MM-DD}} · **Status:** {{Aceita}}

#### Contexto

{{Qual problema existia, qual o cenario e quais restricoes pesaram (prazo, equipe, orcamento, legado).}}

#### Drivers de decisao

- {{fator decisivo 1 — amarre a um principio de 02-architecture_principles.md}}
- {{fator decisivo 2}}

#### Opcoes consideradas

| Opcao | Pros | Contras | Esforco | Risco |
|-------|------|---------|---------|-------|
| {{opcao_A}} | {{vantagens}} | {{desvantagens}} | {{baixo/medio/alto}} | {{baixo/medio/alto}} |
| {{opcao_B}} | {{vantagens}} | {{desvantagens}} | {{esforco}} | {{risco}} |

#### Decisao

Escolhemos **{{opcao_escolhida}}** porque {{justificativa ligada aos drivers acima}}.

#### Consequencias

**Positivas:**
- {{beneficio_1}}

**Negativas:**
- {{trade-off aceito — transporte para 16-evolution.md como debito tecnico}}

**Riscos:**
- {{risco}} — **Mitigacao:** {{como reduzir}}

#### Acoes necessarias

- [ ] {{tarefa para implementar esta decisao}}

> Duplique o bloco acima para cada ADR.

<!-- APPEND:adrs -->
