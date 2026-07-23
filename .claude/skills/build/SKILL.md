---
name: build
description: Implementa as features em loop com TDD e portoes de teste — para na primeira suite vermelha ou queda de aderencia.
---

# Build — Loop de Implementacao com Portoes

Implementa as features do build plan em sequencia, cada uma via `/codegen-feature` num subagente com contexto limpo. **Para na primeira falha real** em vez de acumular deriva.

```
/build                      # todas as entregas Must, em ordem de dependencia
/build ENT-001 ENT-002      # entregas especificas
/build --max 5              # limita a 5 features nesta sessao
```

## Por que este loop para e o `/pipeline` nao

O `/pipeline` pula uma fase que falha: um documento ruim nao contamina o proximo. Aqui e o oposto — a feature 1 estabelece abstracoes que a feature 8 herda. Uma feature errada contamina todas as seguintes, e o resultado final e um codigo internamente consistente, todo verde, e arquiteturalmente errado.

Por isso: **na duvida, para.** Custa uma retomada; nao parar custa refazer.

---

## Passo 1: Pre-requisitos

Valide tudo **antes** de comecar. Depois disso, nenhuma interrupcao ate um portao fechar.

| Verificacao | Se falhar |
|---|---|
| `CLAUDE.md` existe no diretorio atual | "Rode `/codegen-setup` primeiro, ou `cd` para o projeto-alvo." **pare** |
| `src/contracts/` existe e tem tipos | "Scaffold ausente ou vazio. Rode `/codegen-setup`." **pare** |
| Blueprints alcancaveis (caminho em `CLAUDE.md`) | "Nao encontrei os blueprints. Verifique o caminho em `CLAUDE.md`." **pare** |
| `git status` limpo | "Ha mudancas nao commitadas. Commite ou faca stash — o loop commita por feature e precisa de base limpa." **pare** |
| Comando de teste identificado | Detecte em `package.json` scripts, `Makefile` ou `docs/backend/14-tests.md`. Se nao achar, pergunte uma vez. |

**Baseline.** Rode a suite completa antes de comecar. Se ja estiver vermelha, **pare**:

> "A suite ja esta vermelha antes do loop comecar ({{n}} falhas). Corrija primeiro — senao nao ha como distinguir falha pre-existente de falha introduzida pelo loop."

Guarde a contagem de testes do baseline. Ela detecta o modo de falha mais perigoso: teste apagado para ficar verde.

## Passo 2: Montar a Lista de Trabalho

Fonte, em ordem de preferencia:

1. `docs/blueprint/11-build_plan.md` — entregas `ENT-XXX` com dependencias explicitas e prioridade MoSCoW
2. `docs/specs/TASKS.md` — se existir, use para detalhar o escopo de cada entrega

Ordene por **dependencia**, nao por prioridade: uma entrega so entra depois que tudo de que ela depende esta feito. Dentro do mesmo nivel de dependencia, Must antes de Should antes de Could.

Quebre cada entrega nas features que `/codegen-feature` implementa (uma feature = um vertical slice: banco + API + frontend + testes). Se uma entrega listar 4 itens, sao 4 features.

Detecte o que ja existe: se os arquivos e testes de uma feature ja estao no codigo, marque como concluida e pule. Isso torna o loop retomavel.

## Passo 3: Apresentar o Plano

> "**Build:** {{N}} features em {{M}} entregas · suite: `{{comando}}` · baseline {{n}} testes verdes
>
> | # | Entrega | Feature | Depende de | Status |
> |---|---------|---------|-----------|--------|
> | 1 | ENT-001 | {{nome}} | — | pendente |
> | ... | ... | ... | ... | ja implementada |
>
> **Portoes:** suite verde por feature (1 retry) · `/codegen-verify` a cada 3 features (minimo 90%)
> Commit por feature. Comecando."

Nao aguarde confirmacao.

---

## Passo 4: Loop

Para cada feature pendente, em ordem:

### 4.1 Implementar

Ferramenta **Agent**, `subagent_type: general-purpose`, `run_in_background: false`. Nunca paralelize — features compartilham abstracoes.

```
Voce implementa a feature {N} de {TOTAL} no projeto {cwd}.

MODO AUTONOMO — sobrescreve o que a skill disser:
1. NAO faca perguntas e NAO peca confirmacao de plano. Nao ha usuario.
2. Escolha de cliente frontend: use {clientes}. Se a feature for backend-only, pule o frontend.
3. Siga o ciclo TDD integralmente: RED (testes falhando) → GREEN → REFACTOR.
4. NAO commite. O orquestrador commita apos validar.

PROIBIDO — estas acoes invalidam o resultado:
- Apagar, pular (`skip`/`only`/`todo`) ou afrouxar QUALQUER teste, novo ou existente,
  para deixar a suite verde. Se um teste existente quebrou, o certo e corrigir o codigo
  ou reportar conflito real de blueprint — nunca silenciar o teste.
- Baixar limiar de cobertura ou desabilitar regra de lint para passar.
- Criar tipo duplicado em vez de usar `src/contracts/`.

TAREFA: invoque a skill `codegen-feature` pela ferramenta Skill com o argumento
`{nome-da-feature}` e execute-a integralmente.

Escopo desta feature, da entrega {ENT-XXX}:
{itens e criterios de aceite da entrega}

RETORNO — somente neste formato:

FILES:
<cada arquivo criado ou alterado, um por linha>

TESTS:
  escritos: {n}
  red_ok:   sim|nao   (todos falharam antes da implementacao?)
  green_ok: sim|nao   (todos passam agora?)

NOTES:
- <decisao de implementacao que diverge do documentado, se houver>

BLOCKED:
- <o que impediu concluir, se aplicavel>
```

### 4.2 Portao: Suite Completa

Rode a suite **inteira** — nao so os testes da feature. Regressao em outra feature e exatamente o que este portao existe para pegar.

Avalie tres coisas:

| Checagem | Falha se |
|---|---|
| Suite verde | Qualquer teste falhando |
| Contagem de testes | Total **menor** que o baseline + os escritos nesta feature → teste foi apagado ou pulado |
| Retorno do subagente | `red_ok: nao` (nao houve fase RED — codigo veio antes do teste) ou `BLOCKED` preenchido |

**Se falhar — 1 retry.** Novo subagente com o output real:

```
A feature {nome} falhou no portao. Corrija.

{saida completa dos testes falhando}
{se contagem caiu: "A suite tem {n} testes; o baseline + novos seria {m}.
 Algum teste foi removido ou pulado. Restaure-o e corrija o codigo."}

Corrija o CODIGO. E proibido apagar, pular ou afrouxar teste para ficar verde.
Se o teste esta certo e o codigo nao consegue satisfazer o blueprint, nao force:
devolva BLOCKED com a explicacao.
```

**Se o retry tambem falhar: PARE o loop.** Nao siga para a proxima feature.

### 4.3 Commit

Portao verde → commit desta feature apenas:

```
feat: {nome-da-feature} — {descricao curta}

Entrega: {ENT-XXX}
Testes: {n} novos, suite com {total} verdes
```

Commit granular e o que permite `git revert` de uma feature isolada quando a revisao humana reprovar.

### 4.4 Portao: Aderencia (a cada 3 features)

A cada 3 features concluidas, subagente rodando `codegen-verify`:

```
Invoque a skill `codegen-verify` pela ferramenta Skill.

MODO AUTONOMO: nao pergunte o escopo. Verifique as features implementadas desde
a ultima verificacao: {lista}.

Devolva somente:
SCORE: {0-100}
DIVERGENCES:
- {tipo} | {doc vs codigo} | {codigo errado|doc desatualizado|ambiguo}
```

Este portao existe porque **teste escrito pelo mesmo agente que escreveu o codigo nao e verificacao independente**. Suite verde prova consistencia interna, nao conformidade com o blueprint. `codegen-verify` compara o codigo com os documentos — e a unica checagem externa do loop.

| Score | Acao |
|-------|------|
| >= 90% | Segue |
| < 90% | **PARE.** Reporte as divergencias |

Divergencias classificadas como `doc desatualizado` nao sao erro de codigo — liste-as separadamente na parada, porque a correcao e `/increment`, nao `/codegen-feature`.

---

## Passo 5: Parada

Ao parar — por portao fechado, por `--max` ou por fim da lista:

> "**Build {{concluido|interrompido}}** — {{n}}/{{N}} features.
>
> | # | Feature | Entrega | Testes | Commit |
> |---|---------|---------|--------|--------|
> | 1 | {{nome}} | ENT-001 | {{n}} | `{{sha}}` |
>
> **Suite:** {{n}} testes verdes (baseline era {{m}})
> **Aderencia:** {{score}}% na ultima verificacao
>
> {{Se parou por portao:}}
> **Parou em:** {{feature}} — {{suite vermelha apos retry | aderencia {{score}}% < 90%}}
>
> {{saida do erro ou tabela de divergencias}}
>
> **Para destravar:**
> - Codigo errado → corrija e rode `/build` de novo (retoma daqui)
> - Doc desatualizado → `/increment`, depois `/build`
> - Feature ruim ja commitada → `git revert {{sha}}`, ajuste o blueprint, `/build`
>
> **Nao implementadas:** {{lista das features restantes}}"

Retomar e sempre `/build` — ele detecta o que ja existe e continua.

---

## Limites conhecidos

- **Verde nao e correto.** A suite prova que o codigo faz o que os testes dizem; os testes foram escritos pelo mesmo agente. `codegen-verify` mitiga comparando com os documentos, mas nada substitui revisao humana do diff.
- **Deriva arquitetural e detectada tarde.** Uma abstracao ruim na feature 1 so aparece no verify da feature 3. Rode `/build --max 3` nas primeiras features e revise antes de soltar o loop inteiro.
- **Herda as suposicoes dos documentos.** Se o blueprint foi gerado por `/pipeline` em modo autonomo, o codigo implementa fielmente coisas possivelmente supostas. Revise `docs/ASSUMPTIONS.md` antes.
- **Um subagente por feature** consome mais tokens que implementar tudo numa sessao. E o preco por contexto limpo e por nao arrastar erro de uma feature para a seguinte.
