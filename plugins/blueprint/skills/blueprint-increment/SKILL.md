---
name: blueprint-increment
description: Incrementa ou corrige qualquer blueprint (tecnico, backend, frontend, prototipo, shared) sem sobrescrever. Usa Edit.
---
<!-- GERADO por tools/build-codex.py a partir de skills/increment/SKILL.md.
     Nao edite aqui: edite a fonte e rode `python3 tools/build-codex.py`. -->

# Increment — Adicionar, Corrigir, Atualizar ou Remover

Atualiza os blueprints de forma incremental. **Sempre Edit, nunca Write.**

Tipos: **Adicionar** feature | **Corrigir** dado errado | **Atualizar** versao/nome | **Remover** do escopo.

Para uma mudanca que atravessa varios blueprints de uma vez (renomear entidade, trocar tecnologia), use `blueprint-patch` — ele faz varredura global com adaptacao de case.

## Passo 1: Escopo

Se o usuario nao passou o alvo como argumento, pergunte:

> "Qual blueprint atualizar?
> - **blueprint** — tecnico (`docs/blueprint/`, 17 docs)
> - **backend** — implementacao (`docs/backend/`, 15 docs)
> - **frontend** — interface (`docs/frontend/`, multi-client)
> - **prototype** — frontend mockado (`docs/prototype/`, 6 docs)
> - **connectors** — conectores cross-layer (`docs/shared/`, 3 docs geraveis)
> - **all** — os cinco"

> **`connectors` nao e `frontend shared`.** `docs/shared/` liga backend a frontend (glossario, eventos, erros); `docs/frontend/shared/` e a parte do frontend comum aos clientes (design system, data layer). Alvos diferentes, diretorios diferentes.

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
| prototype | `docs/prototype/` (00 a 05) + `docs/blueprint/04-domain-model.md`, `08-use_cases.md`, `09-state-models.md` para contexto |
| connectors | `docs/shared/` (glossary, event-mapping, error-ux-mapping) + a camada que originou o termo, evento ou erro em questao |

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

Marcadores do blueprint tecnico — **os 17 documentos tem marcador**, nenhum e excecao:
- `00`: `actors`, `external-systems`, `constraints`
- `01`: `objectives`, `personas`, `success-metrics`
- `02`: `principles`
- `03`: `functional-requirements`, `nonfunctional-requirements`
- `04`: `glossary`, `entities`, `relationships`
- `05`: `tables`, `critical-queries`
- `06`: `components`, `communication`
- `07`: `flows` · `08`: `use-cases` · `09`: `state-models` · `10`: `adrs`
- `11`: `technical-risks`, `external-dependencies`, `deliverables`
- `12`: `coverage`, `ci-pipeline`
- `13`: `threats`, `roles`, `security-checklist`
- `14`: `capacity-limits`, `cache-strategies`, `rate-limits`
- `15`: `metrics`, `alerts`, `dashboards`
- `16`: `technical-roadmap`, `technical-debt`, `deprecations`, `revision-history`

Marcadores dos conectores (`docs/shared/`):
- `glossary`: `termos`, `acronimos`, `convencoes`
- `event-mapping`: `eventos`, `impacto`
- `error-ux-mapping`: `erros`
- `MAPPING.md` **nao tem marcador e nao e alvo**: descreve o framework, nao o projeto.

Marcadores do prototipo (`docs/prototype/`):
- `00`: `camadas`, `stack`, `nao-objetivos`
- `01`: `mapa-uc`, `uc-sem-tela`, `telas`, `navegacao`, `fluxos`
- `02`: `estrategia`, `personas`, `fixtures`, `cenarios`
- `03`: `convencoes`, `endpoints`, `detalhamento`, `atomicas`, `agregacoes`, `tempo-real`, `divergencias`
- `04`: `matriz-estados`, `erros`, `otimistas`, `transicoes`, `feedback`
- `05`: `lacunas-dominio`, `use-cases`, `estados`, `regras`, `api`, `contradicoes`, `suposicoes`, `encaminhamento`

> **Atencao ao editar `docs/prototype/`:** `03-api-requirements.md` e **extraido de codigo** por `blueprint-prototype-api`. Edita-lo a mao cria uma terceira fonte de verdade — prefira corrigir o prototipo e regerar. A excecao e `05-findings.md`, cuja coluna de status existe para ser atualizada conforme os achados sao encaminhados.

**Se o marcador esperado nao estiver no arquivo**, nao invente posicao: insira na secao apropriada apos a ultima entrada e **avise** que o marcador sumiu — documento que perde o marcador faz toda adicao seguinte cair no lugar errado, e o hook `docs-integrity` existe para impedir exatamente isso.

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

Se a analise de impacto apontou efeitos fora do escopo selecionado, feche listando o que ficou pendente e sugira o proximo `blueprint-increment` ou `blueprint-patch`.
