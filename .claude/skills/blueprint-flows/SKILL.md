---
name: blueprint-flows
description: Fase 4 do blueprint tecnico — gera 07-critical_flows e 08-use_cases.
---

# Blueprint — Fase 4: Fluxos Criticos e Casos de Uso

Gera os 2 documentos de comportamento. Saem juntos porque usam a mesma materia-prima: quando escritos em sessoes separadas, divergem entre si.

## Contexto (ler uma vez)

- `docs/prd.md` — fonte primaria
- `docs/blueprint/04-domain-model.md` — entidades e regras de negocio (RN-XX)
- `docs/blueprint/06-system-architecture.md` — componentes e comunicacao
- `docs/blueprint/09-state-models.md` — transicoes que os casos de uso disparam
- `docs/blueprint/03-requirements.md` — requisitos a rastrear (RF-XXX)
- Templates a preencher: `docs/blueprint/07-critical_flows.md`, `08-use_cases.md`
- `docs/diagrams/sequences/template-flow.mmd` — base dos diagramas de sequencia

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Nunca invente** SLAs por fluxo — extraia de `03-requirements.md` ou pergunte.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento).

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Cenarios de erro** (07) — o que o PRD quase sempre omite
2. **SLAs por fluxo** (07) — latencia e throughput esperados
3. **Fluxos alternativos** (08) — variacoes validas alem do caminho feliz

---

## 07 — Fluxos Criticos

Identifique **3-5 fluxos** cuja falha impacta o negocio diretamente. Para cada um:

- Descricao e nivel de criticidade
- Tabela de atores envolvidos (quem inicia, quem participa)
- Lista numerada de passos — caminho feliz
- Tabela de tratamento de erros: falha, comportamento esperado
- Metricas de performance: latencia, throughput

**Diagramas:** para cada fluxo, crie `docs/diagrams/sequences/{nome-do-fluxo}.mmd` (kebab-case) a partir de `template-flow.mmd`.

---

## 08 — Casos de Uso

Cada feature do PRD corresponde a um ou mais casos de uso. Para cada um:

- **ID** no formato UC-001, UC-002...
- **Ator principal** e atores secundarios
- **Pre-condicao** e pos-condicao
- **Fluxo principal** numerado
- **Fluxos alternativos** (1a, 2a...)
- **Excecoes** (E1, E2...)
- **Referencias**: regras de negocio (RN-XX de `04`) e requisitos (RF-XXX de `03`)

**Consistencia obrigatoria:** os casos de uso que alteram estado devem usar exatamente os gatilhos nomeados em `09-state-models.md`. Se encontrar uma transicao sem caso de uso correspondente — ou um caso de uso que exige uma transicao nao documentada — reporte ao usuario em vez de inventar.

---

## Revisao e Proxima Etapa

Apresente os 2 documentos e a lista de diagramas criados. Aponte divergencias encontradas contra `09-state-models.md`. Aplique ajustes. Salve os arquivos finais.

> "Fluxos e casos de uso documentados (07, 08). Rode `/blueprint-quality` para testes, seguranca, escalabilidade e observabilidade."
