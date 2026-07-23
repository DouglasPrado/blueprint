---
name: blueprint-plan
description: Fase 6 do blueprint tecnico — gera 11-build_plan e 16-evolution, fechando o blueprint.
---

# Blueprint — Fase 6: Plano de Construcao e Evolucao

Fase de fechamento. Transforma tudo o que foi decidido em roadmap executavel e define como o sistema evolui depois do MVP.

## Contexto (ler uma vez)

- `docs/prd.md` — prazos, prioridades, MVP e visao de longo prazo
- `docs/blueprint/03-requirements.md` — requisitos priorizados por MoSCoW
- `docs/blueprint/07-critical_flows.md` — fluxos criticos (determinam a ordem das entregas)
- `docs/blueprint/08-use_cases.md` — casos de uso (definem o escopo de cada entrega)
- `docs/blueprint/10-architecture_decisions.md` — consequencias negativas aceitas viram divida tecnica
- `docs/blueprint/14-scalability.md` — limites atuais e projecoes
- Templates a preencher: `docs/blueprint/11-build_plan.md`, `16-evolution.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Nunca invente** prazos em datas absolutas — use estimativas T-shirt e dependencias.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento).

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Prioridades de entrega** (11) — se o PRD nao define, proponha a partir dos Must/Should/Could de `03`
2. **Dependencias externas** (11) — equipes, sistemas e parceiros fora do controle do time
3. **Estrategia de versionamento** (16) — SemVer do sistema e versionamento de API

---

## 11 — Plano de Construcao

Preencha:
- **Entregas**: IDs sequenciais (ENT-001, ENT-002...) com objetivo, itens, dependencias explicitas entre entregas, criterios de aceite, prioridade (Must/Should/Could) e estimativa T-shirt (S/M/L/XL)
- **Priorizacao**: tabela com entrega, prioridade, dependencias e justificativa
- **Riscos tecnicos**: descricao, probabilidade, impacto e mitigacao
- **Dependencias externas**: sistema/equipe, tipo, responsavel e status

**Cobertura obrigatoria:** todo requisito Must de `03-requirements.md` precisa estar dentro de alguma entrega. Liste explicitamente qualquer Must que ficou de fora.

---

## 16 — Evolucao e Migracao

Preencha:
- **Roadmap tecnico**: item, prioridade, justificativa e entrega associada — melhorias alem do MVP
- **Debitos tecnicos**: debito, impacto, esforco e prioridade. Transporte as **consequencias negativas aceitas** nos ADRs de `10` e os **limites atuais** de `14`
- **Versionamento**: versao atual, estrategia SemVer, versionamento de API (URI, header)
- **Deprecacao**: funcionalidade, data de deprecacao, periodo de transicao e alternativa
- **Revisao do blueprint**: gatilhos de revisao, cadencia e responsavel
- **Historico de revisoes**: tabela inicial com a data de criacao

---

## Revisao e Conclusao

Apresente os 2 documentos. Aplique ajustes. Salve os arquivos finais.

Feche com o resumo de cobertura:

| Fase | Docs | Status |
|------|------|--------|
| 1. Fundacao | 00, 01, 02, 03 | ✅ |
| 2. Dominio | 04, 05, 09 | ✅ |
| 3. Arquitetura | 06, 10 | ✅ |
| 4. Fluxos | 07, 08 | ✅ |
| 5. Qualidade | 12, 13, 14, 15 | ✅ |
| 6. Plano | 11, 16 | ✅ |

> "Blueprint tecnico completo — 17 documentos. Diagramas em `docs/diagrams/`, ADRs em `docs/adr/`.
>
> Proximos passos:
> - `/backend` — especificacao de implementacao backend
> - `/frontend` — arquitetura frontend multi-client
> - `/specs` — backlog integral de tasks
> - `/increment` — adicionar feature ou corrigir sem reescrever"
