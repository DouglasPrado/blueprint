---
name: increment
description: Incrementa ou corrige qualquer blueprint (tecnico, backend, frontend) sem sobrescrever. Usa Edit.
---

# Increment — Adicionar, Corrigir, Atualizar ou Remover

Atualiza os blueprints de forma incremental. **Sempre Edit, nunca Write.**

Tipos: **Adicionar** feature | **Corrigir** dado errado | **Atualizar** versao/nome | **Remover** do escopo.

Para uma mudanca que atravessa varios blueprints de uma vez (renomear entidade, trocar tecnologia), use `/patch` — ele faz varredura global com adaptacao de case.

## Passo 1: Escopo

Se o usuario nao passou o alvo como argumento, pergunte:

> "Qual blueprint atualizar?
> - **blueprint** — tecnico (`docs/blueprint/`, 17 docs)
> - **backend** — implementacao (`docs/backend/`, 15 docs)
> - **frontend** — interface (`docs/frontend/`, multi-client)
> - **all** — os tres"

Se o alvo incluir **frontend**, pergunte tambem o cliente:

> "Qual cliente? **web** | **mobile** | **desktop** | **shared** | **all**"

## Passo 2: Receber a Alteracao

> "O que precisa ser atualizado? (nova feature, correcao, atualizacao ou remocao)"

## Passo 3: Leitura

Leia apenas o escopo selecionado:

| Alvo | Ler |
|------|-----|
| blueprint | `docs/blueprint/` (00 a 16) |
| backend | `docs/backend/` (00 a 14) + `docs/blueprint/04-domain-model.md`, `08-use_cases.md` para contexto |
| frontend `shared` | `docs/frontend/shared/` (03, 06, 15) |
| frontend `{client}` | `docs/frontend/shared/` + `docs/frontend/{client}/` (00 a 14) |
| frontend `all` | shared + todos os clientes existentes |

Leia `docs/prd.md` se existir. Se o alvo for backend ou frontend, o blueprint tecnico e a referencia de verdade — nao contradiga.

> **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Passo 4: Classificar e Analisar Impacto

Classifique (Adicao / Correcao / Atualizacao / Remocao) e apresente a tabela de impacto:

| Blueprint | Doc | Impactado? | Tipo | O que fazer |
|-----------|-----|-----------|------|-------------|
| blueprint | 04-domain-model | Sim | Adicao | Nova entidade X |
| frontend/web | 04-components | Sim | Adicao | Componentes de X |

> **Cross-client:** se impacta `docs/frontend/shared/`, avise que afeta **todos** os clientes.
> **Cross-blueprint:** se a mudanca no blueprint tecnico invalida algo ja escrito em backend ou frontend, liste explicitamente — mesmo que o alvo selecionado nao os inclua.

Confirme com o usuario antes de aplicar.

## Passo 5: Aplicar

**SEMPRE Edit, NUNCA Write.**

**ADICAO** — localize `<!-- APPEND:section-id -->`, insira o conteudo novo **antes** do marcador e marque com `<!-- adicionado: nome -->`.

Marcadores do blueprint tecnico:
- `00`: `actors`, `external-systems`, `constraints`
- `01`: `objectives`, `personas`, `success-metrics`
- `03`: `functional-requirements`, `nonfunctional-requirements`
- `04`: `glossary`, `entities`
- `09`: `state-models` · `10`: `adrs`
- `11`: `technical-risks`, `deliverables`
- `12`: `coverage`, `ci-pipeline`
- `13`: `threats`, `roles`

Docs sem APPEND (02, 05, 06, 07, 08, 14, 15, 16) → insira na secao apropriada, apos a ultima entrada.

**CORRECAO** — Edit com `old_string` = valor antigo, `new_string` = correto. Marque `<!-- corrigido: descricao -->`. Nao toque em outras linhas.

**ATUALIZACAO** — localize TODAS as ocorrencias; use `replace_all` quando houver varias no mesmo arquivo. Marque `<!-- atualizado: descricao -->`.

**REMOCAO** — substitua por `~~conteudo~~ <!-- removido: motivo -->`. Delete de fato apenas se o usuario confirmar.

### Regras

- Tabelas: novas linhas **antes** de `<!-- APPEND:... -->`
- Fluxos, casos de uso e ADRs: novo bloco com numeracao sequencial (`### Fluxo N:`, `UC-00N`, `ADR-00N`)
- Nunca altere linhas nao relacionadas — alteracoes minimas
- Nunca altere `{{placeholders}}` de secoes ainda nao preenchidas

## Passo 6: Revisao

> "Alteracao aplicada em **N** docs:" + tabela de mudancas por arquivo.

Se a analise de impacto apontou efeitos fora do escopo selecionado, feche listando o que ficou pendente e sugira o proximo `/increment` ou `/patch`.
