---
name: blueprint-domain
description: Fase 2 do blueprint tecnico — gera 04-domain-model, 05-data-model e 09-state-models.
---

# Blueprint — Fase 2: Dominio, Dados e Estados

Gera os 3 documentos do coracao conceitual do sistema. `05` e `09` sao projecoes diretas de `04` — por isso saem na mesma passada.

## Contexto (ler uma vez)

- `docs/prd.md` — fonte primaria
- `docs/blueprint/00-context.md` — atores e limites do sistema
- `docs/blueprint/01-vision.md` — objetivos e personas
- Templates a preencher: `docs/blueprint/04-domain-model.md`, `05-data-model.md`, `09-state-models.md`
- `docs/diagrams/domain/state-template.mmd` — base dos diagramas de estado

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca invente** volumes, SLAs ou nomes de tabela — extraia ou pergunte.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento). Agrupe e faca antes de gerar.
- **Idioma:** nomes de entidades, tabelas, campos, indices e constraints em **ingles**; comentarios e descricoes em **portugues**.

## Analise de Lacunas (fazer antes de gerar)

Extraia do PRD as entidades, atributos e regras. Priorize as 3 perguntas nesta ordem:

1. **Regras de negocio e invariantes** (04) — o que NUNCA pode ser violado; e o mais dificil de inferir
2. **Tecnologia de banco e volumes esperados** (05) — determinam indexacao e particionamento
3. **Transicoes de estado proibidas** (09) — o que o PRD quase nunca declara

---

## 04 — Modelo de Dominio

Preencha:
- **Glossario Ubiquo**: tabela de termos com definicao oficial unica
- **Entidades**: para cada uma — atributos (campo, tipo, obrigatorio, descricao), regras de negocio (IDs RN-XX) e eventos de dominio emitidos
- **Relacionamentos**: tabela com entidade A, tipo, cardinalidade (1:1, 1:N, N:M), entidade B e regra

**Diagramas:** substitua todos os placeholders em
- `docs/diagrams/domain/class-diagram.mmd` — classes e relacionamentos
- `docs/diagrams/domain/er-diagram.mmd` — tabelas e campos

---

## 05 — Modelo de Dados

Traduz o dominio conceitual em decisoes concretas de persistencia. Considere padroes de leitura/escrita e requisitos de consistencia (forte vs eventual).

Preencha:
- **Banco de Dados**: tecnologia escolhida e justificativa
- **Tabelas/Collections**: campos com tipo, constraint e descricao
- **Estrategia de Migracao**: ferramenta e abordagem
- **Indices e Otimizacoes**: indices criticos por tabela
- **Queries Criticas**: tabela com query, frequencia e SLA esperado

**Diagrama:** refine `docs/diagrams/domain/er-diagram.mmd` com os detalhes fisicos (tipos, indices, constraints) sobre a base ja criada em `04`.

---

## 09 — Modelos de Estado

Identifique em `04` as entidades com campo de status ou ciclo de vida relevante (pedido, pagamento, assinatura, job, tarefa).

Preencha, para cada entidade com ciclo de vida:
- Nome e descricao da entidade
- Tabela de **estados possiveis** com descricao
- Tabela de **transicoes**: De, Para, Gatilho, Condicao
- Lista de **transicoes proibidas**
- **Acoes por transicao**: emitir evento, auditar, atualizar timestamp

**Diagramas:** para cada entidade com ciclo de vida, crie `docs/diagrams/domain/state-{entidade}.mmd` (kebab-case) usando `state-template.mmd` como base.

> As acoes que disparam transicoes serao detalhadas em `08-use_cases.md` (fase 4). Deixe os gatilhos nomeados de forma que os casos de uso possam referencia-los.

---

## Revisao e Proxima Etapa

Apresente os 3 documentos ao usuario. Aplique ajustes. Salve arquivos e diagramas.

> "Dominio, dados e estados modelados (04, 05, 09). Rode `/blueprint-architecture` para desenhar a arquitetura e registrar os ADRs."
