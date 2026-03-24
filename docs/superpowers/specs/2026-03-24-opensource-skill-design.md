# Design: Skill `/opensource`

**Data**: 2026-03-24
**Status**: Aprovado
**Arquivo**: `.claude/skills/opensource/SKILL.md`

## Problema

Projetos documentados com o blueprint framework (tecnico + frontend + business) sao orientados a negocios proprietarios. Nao existe forma padronizada de transformar esses blueprints para projetos opensource, adaptando conceitos como receita → sustentabilidade, clientes → contribuidores, e marketing → community awareness.

## Solucao

Uma skill unica (`/opensource`) que:

1. Le os 3 blueprints completos (43 docs)
2. Pergunta ao usuario o modelo OSS, licenca, governanca, nome e canais
3. Transforma 10 docs de business in-place (Edit)
4. Adiciona secoes OSS em 6 docs do blueprint tecnico (Edit)
5. Adiciona secoes OSS em 3 docs do frontend blueprint (Edit)
6. Gera 9 arquivos raiz (Write): README, CONTRIBUTING, LICENSE, SECURITY, CODE_OF_CONDUCT, templates GitHub
7. Apresenta resumo e proximos passos

## Decisoes

| Decisao | Escolha | Motivo |
|---------|---------|--------|
| Formato | Skill unica | Usuario preferiu simplicidade vs orquestrador |
| Output | In-place | Preserva contexto existente, nao duplica docs |
| Tipo | Generico/adaptavel | Pergunta modelo OSS e adapta (open-core, community, dev tool, foundation) |
| Escopo | Projeto inteiro | 3 blueprints + arquivos raiz |

## Transformacoes de Business

| Doc Original | Transformado Para |
|---|---|
| 00-business-context | Contexto do Ecossistema |
| 01-value-proposition | Por que Usar / Contribuir |
| 02-segments-personas | Personas OSS |
| 03-channels-distribution | Canais de Comunidade |
| 04-relationships | Engajamento Comunitario |
| 05-revenue-model | Modelo de Sustentabilidade |
| 06-cost-structure | Custos do Projeto |
| 07-metrics-kpis | Metricas OSS |
| 08-marketing-strategy | Posicionamento & Awareness |
| 09-operational-plan | Operacoes Comunitarias |

## Adaptacao por Modelo OSS

| Aspecto | Open-core | Community-driven | Dev tool | Foundation-backed |
|---------|-----------|-----------------|----------|-------------------|
| Receita | Enterprise features + hosted | Sponsors + grants + donations | Marketplace + premium | Membership + sponsors |
| Personas | Users + Enterprise buyers | Contributors + power users | Plugin devs + end users | Corporate adopters |
| North Star | Monthly Active Enterprise Users | Active Contributors/Month | Weekly Downloads | Production Deployments |
| Governanca | Company-led + community | Community-led | Company-led + ecosystem | Foundation charter |

## Regras Criticas

1. Edit para docs existentes, Write para novos
2. Nunca inventar numeros — `{{placeholder}}`
3. Marcar alteracoes: `<!-- atualizado: opensource -->` / `<!-- adicionado: opensource -->`
4. Preservar APPEND markers
5. Preservar todo conteudo existente
6. Portugues nos blueprints, ingles nos arquivos raiz
