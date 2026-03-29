---
name: business-increment
description: Incrementa o business blueprint com nova informacao ou correcao sem sobrescrever conteudo existente.
---

# Business Blueprint — Incrementar ou Corrigir

Atualiza docs do business blueprint de forma incremental (Edit, nunca Write).
Tipos: **Adicionar** info | **Corrigir** dados | **Atualizar** mercado/custos | **Remover** do escopo.

## Passo 1: Receber a Alteracao

Pergunte: "O que precisa ser atualizado no business blueprint? (nova info, correcao, atualizacao ou remocao)"

## Passo 2: Leitura

Leia todos os docs em `docs/business/` (00 a 09), `docs/blueprint/` para contexto e `docs/prd.md`.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Passo 3: Classificar e Analisar Impacto

Referencia de impacto:
| Doc | Quando impactado |
|-----|-----------------|
| 00-contexto | Novo mercado, concorrente |
| 01-value-proposition | Nova necessidade, diferencial |
| 02-segmentos | Novo segmento, persona |
| 03-canais | Novo canal, parceria |
| 04-relationships | Retencao, churn signal |
| 05-receita | Nova fonte receita, preco |
| 06-custos | Novo custo, fornecedor |
| 07-metrics | Nova metrica, milestone |
| 08-marketing | Canal marketing, growth loop |
| 09-operacional | Processo, contratacao |

Apresente tabela de impacto ao usuario e confirme antes de prosseguir.

## Passo 4: Aplicar Alteracoes

**SEMPRE Edit, NUNCA Write.**

### ADICAO:
Localize `<!-- APPEND:section-id -->` → insira conteudo novo ANTES do marcador → marque `<!-- adicionado: descricao -->`.

**Marcadores disponiveis:** `mercado`, `concorrencia`, `premissas`, `necessidades`, `diferenciais`, `segmentos`, `personas`, `canais`, `rotas-funil`, `parcerias`, `ciclo-vida`, `churn-signals`, `expansion`, `fontes-receita`, `precos`, `projecoes`, `custos-fixos`, `custos-variaveis`, `fornecedores`, `aarrr`, `milestones`, `dashboard`, `canais-marketing`, `growth-loops`, `processos`, `equipe`, `timeline`

### CORRECAO:
Edit old_string=antigo, new_string=correto. Marque `<!-- corrigido: descricao -->`. NAO toque outras linhas.

### ATUALIZACAO:
Localize TODAS ocorrencias. Use replace_all se multiplas. Marque `<!-- atualizado: descricao -->`.

### REMOCAO:
Substitua por `~~conteudo~~ <!-- removido: motivo -->`. Delete so se usuario confirmar.

### Regras:
- Tabelas: novas linhas ANTES de `<!-- APPEND:... -->`
- Secoes: novo bloco com numeracao sequencial
- NUNCA altere linhas nao relacionadas. Alteracoes minimas.

## Passo 5: Revisao

Resuma: "Informacao **nome** documentada. Alteracoes em **N** docs:" + tabela.

> "Para outra alteracao: `/business-increment`. Para revisar completo: `/business`."
