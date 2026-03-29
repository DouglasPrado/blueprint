---
name: frontend-increment
description: Incrementa frontend blueprint sem sobrescrever. Multi-client. Usa Edit.
---

# Frontend Blueprint — Incrementar ou Corrigir

Atualiza docs do frontend blueprint de forma incremental (Edit, nunca Write).
Tipos: **Adicionar** feature | **Corrigir** dados | **Atualizar** versoes/nomes | **Remover** do escopo.

## Passo 1: Selecao de Cliente

Pergunte: "Qual cliente? **web** | **mobile** | **desktop** | **shared** | **all**"

## Passo 2: Receber a Alteracao

Pergunte: "O que precisa ser atualizado no frontend blueprint? (nova feature, correcao, atualizacao ou remocao)"

## Passo 3: Leitura

Conforme cliente selecionado:
- **shared**: `docs/frontend/shared/` (03-design-system, 06-data-layer, 15-api-dependencies)
- **per-client**: shared + `docs/frontend/{client}/` (00 a 14)
- **all**: todos os docs em shared + todos os clientes existentes

Leia tambem `docs/blueprint/` para contexto e `docs/prd.md` se existir.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Passo 4: Classificar e Analisar Impacto

Classifique (Adicao/Correcao/Atualizacao/Remocao) e apresente tabela:

| Cliente | Doc | Impactado? | Tipo | O que fazer |
|---------|-----|-----------|------|-------------|
| shared/client | doc | Sim/Nao | Tipo | Descricao |

> **Cross-client:** Se impacta `shared/`, avise que afeta TODOS os clientes.

Confirme com o usuario antes de prosseguir.

## Passo 5: Aplicar Alteracoes

**SEMPRE Edit, NUNCA Write.**

### ADICAO:
Localize `<!-- APPEND:section-id -->` → insira conteudo novo ANTES do marcador → marque `<!-- adicionado: nome -->`.

### CORRECAO:
Edit old_string=antigo, new_string=correto. Marque `<!-- corrigido: descricao -->`. NAO toque outras linhas.

### ATUALIZACAO:
Localize TODAS ocorrencias. Use replace_all se multiplas. Marque `<!-- atualizado: descricao -->`.

### REMOCAO:
Substitua por `~~conteudo~~ <!-- removido: motivo -->`. Delete so se usuario confirmar.

### Regras:
- Tabelas: novas linhas ANTES de `<!-- APPEND:... -->`
- Fluxos: novo bloco `### Fluxo N:` sequencial
- Paths: `docs/frontend/shared/` para compartilhados, `docs/frontend/{client}/` para per-client
- NUNCA altere linhas nao relacionadas. Alteracoes minimas.

## Passo 6: Revisao

Resuma: "Feature **nome** documentada para **cliente**. Alteracoes em **N** docs:" + tabela.

> "Para outra feature: `/frontend-increment`. Para revisar completo: `/frontend`."
