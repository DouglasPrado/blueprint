---
name: init
description: Instala os templates do Blueprint no projeto atual. Rode uma vez, antes de qualquer outra skill do plugin.
---

# Blueprint — Instalacao no Projeto

Copia a biblioteca de templates que vem com o plugin para `docs/` no projeto atual. **Rode uma vez, antes de tudo.**

```
/blueprint:init [suites]

/blueprint:init                      # pergunta o que instalar
/blueprint:init all                  # tudo
/blueprint:init blueprint            # so o blueprint tecnico
/blueprint:init blueprint,prototype,backend,frontend:web
```

## Por que esta skill existe

As skills do Blueprint **preenchem templates**, nao criam documentos do zero. Elas esperam encontrar `docs/blueprint/04-domain-model.md` com os `{{placeholders}}` no lugar, e substituem placeholder por conteudo.

Quando o Blueprint era um repositorio para clonar, os templates ja vinham juntos. Como plugin, eles vivem dentro do plugin — e precisam ser copiados para o **seu** projeto, porque e la que voce vai versiona-los preenchidos.

> **Os documentos preenchidos sao seus.** Ficam no seu repositorio, no seu histórico, no seu code review. O plugin so fornece a forma inicial.

---

## Passo 1: Verificar o Estado

Rode a partir da **raiz do projeto-alvo** (nao do repositorio do plugin).

| Verificacao | Acao |
| --- | --- |
| `docs/` nao existe | Instalacao limpa — siga |
| `docs/` existe com templates (`{{placeholders}}`) | Ja instalado. Reporte e ofereca completar as suites que faltam |
| `docs/` existe com conteudo real | **Nunca sobrescreva.** Instale apenas o que falta e diga o que foi pulado |

Localize os templates do plugin em `${CLAUDE_PLUGIN_ROOT}/docs/`. Se a variavel nao resolver, pare e diga ao usuario que o plugin parece nao estar instalado corretamente — em vez de adivinhar caminho.

## Passo 2: Escolher as Suites

Se o usuario nao passou argumento:

> "O que instalar?
>
> | Suite | Docs | Quando |
> |---|---|---|
> | **blueprint** | 17 | Sempre — e a fonte primaria do dominio |
> | **shared** | 4 | Sempre — glossario e mapeamentos cross-layer |
> | **prototype** | 6 | Se for descobrir o contrato de API construindo a UI antes do backend |
> | **backend** | 15 | Se o sistema tem servidor |
> | **frontend:web** \| **:mobile** \| **:desktop** | 3 shared + 13 por cliente | Um por cliente |
> | **diagrams** | 10 `.mmd` + 4 READMEs | Diagramas C4, sequencia, dominio, deploy |
> | **templates** | 6 | PRD, epic, story, task, use case, CLAUDE.md router |
> | **adr** | 1 | Template de decisao arquitetural |
>
> Recomendado para um SaaS web: `blueprint,shared,prototype,backend,frontend:web,diagrams,templates,adr`
>
> Responda as suites, ou `all`."

## Passo 3: Copiar

Para cada suite escolhida, copie de `${CLAUDE_PLUGIN_ROOT}/docs/{suite}/` para `./docs/{suite}/`.

**Tres regras:**

1. **Nunca sobrescreva arquivo existente.** Se `docs/blueprint/04-domain-model.md` ja existe, pule e registre. O conteudo do usuario sempre vence o template.
2. **Preserve a estrutura de diretorios** exatamente — as skills referenciam caminhos relativos entre os documentos (`../shared/glossary.md`, `../diagrams/domain/er-diagram.mmd`). Achatar a arvore quebra todas as referencias cruzadas.
3. **Copie os `.mmd` junto** quando a suite `diagrams` for escolhida. Os templates de diagrama sao duplicados por entidade e por fluxo mais tarde; sem eles, as skills de dominio e fluxos nao tem base.

Mapa das suites:

| Suite | Origem | Destino |
| --- | --- | --- |
| blueprint | `docs/blueprint/` | `docs/blueprint/` |
| shared | `docs/shared/` | `docs/shared/` |
| prototype | `docs/prototype/` | `docs/prototype/` |
| backend | `docs/backend/` | `docs/backend/` |
| frontend:{client} | `docs/frontend/shared/` + `docs/frontend/{client}/` | idem |
| diagrams | `docs/diagrams/` | `docs/diagrams/` |
| templates | `docs/templates/` | `docs/templates/` |
| adr | `docs/adr/` | `docs/adr/` |

## Passo 4: O PRD

O PRD e a **entrada de tudo** e o unico documento que o plugin nao pode gerar — ele carrega conhecimento de negocio que so o usuario tem.

- Se `docs/prd.md` nao existe, copie `docs/templates/prd-template.md` para `docs/prd.md`
- Se ja existe, nao toque

> "O PRD e o teto de qualidade de tudo que vem depois. O framework estrutura incerteza; ele nao inventa conhecimento de negocio. PRD raso gera documentacao rasa com muitas suposicoes de risco alto."

## Passo 5: Relatorio e Proximo Passo

> "**Blueprint instalado** — {{N}} documentos em `docs/`.
>
> | Suite | Criados | Pulados (ja existiam) |
> |---|---|---|
> | blueprint | {{n}} | {{n}} |
> | ... | | |
>
> {{Se algum foi pulado: liste quais e por que}}
>
> **Proximo passo:** preencha `docs/prd.md` — quanto mais completo, menos suposicao.
> Depois rode `/blueprint:blueprint` para a analise de cobertura e o roteiro das 6 fases.
>
> Ou, se o PRD ja esta detalhado: `/blueprint:pipeline docs/prd.md web ../projeto/` para o passe autonomo."

---

## Atualizar os templates depois

Quando uma nova versao do plugin trouxer templates novos ou corrigidos, rode `/blueprint:init` de novo: ele instala **so o que falta** e nunca toca no que voce ja preencheu.

Para trazer uma melhoria de template para um documento que voce ja preencheu, a ferramenta e `/blueprint:increment` — ela edita cirurgicamente em vez de sobrescrever.

## Limites

- **Nao remove nada.** Se voce nao vai usar a suite `desktop`, apague a pasta manualmente.
- **Nao migra versao.** Documento preenchido com a estrutura da v1.0 continua na v1.0; o plugin nao reescreve o que e seu.
- **Nao adivinha o projeto.** Roda onde voce estiver. Confira o diretorio antes.
