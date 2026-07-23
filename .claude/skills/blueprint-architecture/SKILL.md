---
name: blueprint-architecture
description: Fase 3 do blueprint tecnico — gera 06-system-architecture e 10-architecture_decisions (ADRs).
---

# Blueprint — Fase 3: Arquitetura e Decisoes

Gera a arquitetura do sistema e os ADRs que a justificam. Os dois saem juntos de proposito: ADR escrito longe da arquitetura vira generico.

## Contexto (ler uma vez)

- `docs/prd.md` — fonte primaria
- `docs/blueprint/02-architecture_principles.md` — principios que guiam toda decisao
- `docs/blueprint/04-domain-model.md` — entidades e bounded contexts
- `docs/blueprint/05-data-model.md` — tecnologias de persistencia ja escolhidas
- Templates a preencher: `docs/blueprint/06-system-architecture.md`, `10-architecture_decisions.md`
- `docs/adr/adr-template.md` — template de ADR individual

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** toda tecnologia citada com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`. Esta e a fase que mais depende disso.
- **Nunca invente** stack, provider ou versao — proponha opcoes e pergunte.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento).

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Stack e cloud provider** (06) — se o PRD nao especifica, proponha 2-3 opcoes com trade-offs
2. **Padrao arquitetural** (06/10) — monolito modular, microsservicos, event-driven
3. **Justificativa de alguma decisao ja tomada** (10) — quando o "porque" nao aparece em lugar nenhum

---

## 06 — Arquitetura do Sistema

Preencha:
- **Componentes**: para cada um — nome, responsabilidade, tecnologia e interface exposta
- **Comunicacao**: tabela com origem, destino, protocolo (REST/gRPC/eventos/filas), tipo (sync/async) e descricao
- **Infraestrutura**: ambientes (dev, staging, prod) com URLs e configuracoes; decisoes de cloud, orquestracao, CI/CD, banco, cache e mensageria

**Diagramas:** atualize
- `docs/diagrams/containers/container-diagram.mmd` — apps, APIs, bancos, filas
- `docs/diagrams/components/api-components.mmd` — componentes internos do container principal
- `docs/diagrams/deployment/production.mmd` — topologia de deploy em producao

---

## 10 — Decisoes Arquiteturais (ADRs)

Registre as decisoes significativas ja tomadas ate aqui — nao invente decisoes novas:

| Decisao | Vem de |
|---|---|
| Escolha de banco de dados | `05-data-model.md` |
| Padrao arquitetural | `06` acima |
| Protocolos de comunicacao | `06` acima |
| Estrategia de cache, filas e deploy | `06` acima |

Preencha `10-architecture_decisions.md` com a lista de ADRs e crie **um arquivo individual por ADR** em `docs/adr/` a partir de `adr-template.md`. Cada ADR precisa de:

- **Contexto**: problema e restricoes
- **Drivers de decisao**: fatores mais importantes (amarre aos principios de `02`)
- **Opcoes**: 2-3 alternativas com pros, contras, esforco e risco
- **Decisao**: opcao escolhida e justificativa
- **Consequencias**: positivas, negativas e riscos
- **Acoes necessarias**: tarefas para implementar

> As consequencias negativas aceitas aqui viram divida tecnica em `16-evolution.md` (fase 6). Escreva-as de forma que possam ser transportadas.

---

## Revisao e Proxima Etapa

Apresente os 2 documentos e a lista de ADRs criados. Aplique ajustes. Salve arquivos e diagramas.

> "Arquitetura e decisoes registradas (06, 10). Rode `/blueprint-flows` para documentar os fluxos criticos e casos de uso."
