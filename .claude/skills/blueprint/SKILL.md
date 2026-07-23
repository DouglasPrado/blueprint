---
name: blueprint
description: Inicia blueprint tecnico a partir de um PRD. Analisa lacunas e guia o preenchimento em 6 fases.
---

# Blueprint — Orquestrador

Recebe o PRD, salva, analisa cobertura e guia o preenchimento dos 17 documentos de `docs/blueprint/` em **6 fases**. Cada fase e uma skill que gera varios documentos lendo o contexto uma unica vez.

## Passo 1: Receber o PRD

Se o usuario passou um caminho de arquivo, leia. Se nao:

> "Para iniciar o blueprint, preciso do seu PRD. Voce pode:
> 1. Passar o caminho: `/blueprint docs/prd.md`
> 2. Colar o conteudo aqui no chat
>
> Como prefere?"

Aguarde a resposta.

## Passo 2: Salvar o PRD

Salve em `docs/prd.md`. Se ja existir, pergunte antes de sobrescrever.

## Passo 3: Analisar Cobertura por Fase

Leia o PRD e classifique cada fase como **Coberto** (da para preencher), **Parcial** (falta detalhe) ou **Lacuna** (PRD nao cobre):

| Fase | Docs | Cobertura | Observacao |
|------|------|-----------|------------|
| 1. Fundacao | 00, 01, 02, 03 | Coberto/Parcial/Lacuna | breve nota |
| 2. Dominio | 04, 05, 09 | ... | ... |
| 3. Arquitetura | 06, 10 | ... | ... |
| 4. Fluxos | 07, 08 | ... | ... |
| 5. Qualidade | 12, 13, 14, 15 | ... | ... |
| 6. Plano | 11, 16 | ... | ... |

Indique nas observacoes o que provavelmente sera perguntado em cada fase (max 3 perguntas por fase).

## Passo 4: Apresentar o Roadmap

```
1. /blueprint-foundation    → 00-context, 01-vision, 02-principles, 03-requirements
2. /blueprint-domain        → 04-domain-model, 05-data-model, 09-state-models
3. /blueprint-architecture  → 06-system-architecture, 10-architecture_decisions
4. /blueprint-flows         → 07-critical_flows, 08-use_cases
5. /blueprint-quality       → 12-testing, 13-security, 14-scalability, 15-observability
6. /blueprint-plan          → 11-build_plan, 16-evolution
```

A ordem importa: cada fase le o que a anterior produziu. Nao pule fases.

## Passo 5: Orientar

> "PRD salvo e analisado. Rode `/blueprint-foundation` para comecar pela Fundacao (contexto, visao, principios e requisitos)."

## Depois do Blueprint

| Skill | Para que |
|-------|----------|
| `/backend` | Especificacao de implementacao backend (15 docs) |
| `/frontend` | Arquitetura frontend multi-client |
| `/increment` | Adicionar feature ou corrigir sem reescrever |
| `/patch` | Propagar mudanca global (renomear entidade, trocar tecnologia) |
| `/specs` | Gerar backlog integral de tasks |
| `/codegen` | Gerar codigo a partir dos blueprints |
