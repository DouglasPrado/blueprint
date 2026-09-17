---
name: shared
description: Gera os conectores cross-layer (docs/shared/) — glossario ubiquo, mapa de eventos e mapa de erro para UX. Roda depois do backend e do frontend.
---

# Shared — Conectores Cross-Layer

Preenche os tres documentos de `docs/shared/` que impedem os blueprints de divergirem entre si.

Nenhum deles carrega conhecimento novo. Todos os tres sao **projecoes** do que blueprint, backend e frontend ja decidiram — e e justamente por serem projecoes que valem: sao o lugar onde uma divergencia entre as camadas fica visivel em vez de ficar enterrada em tres documentos que ninguem le lado a lado.

| Documento | Deriva de | O que conecta |
| --- | --- | --- |
| `glossary.md` | `blueprint/04-domain-model.md` (§Glossario Ubiquo, §Entidades) | Termo do dominio → entidade, endpoint, componente |
| `event-mapping.md` | `backend/12-events.md` + `frontend/{client}/05-state.md` | Evento do backend → estado do frontend |
| `error-ux-mapping.md` | `backend/09-errors.md` + `frontend/{client}/` | Erro do backend → o que o usuario ve |

`MAPPING.md` **nao** e gerado: ele descreve a estrutura do proprio framework, nao o projeto, e ja vem completo.

## Contexto (ler uma vez)

- `docs/blueprint/04-domain-model.md` — **fonte do glossario**
- `docs/blueprint/00-context.md` — atores e vocabulario de negocio
- `docs/backend/09-errors.md` — hierarquia de erros e erros de negocio
- `docs/backend/12-events.md` — eventos de dominio e workers
- `docs/frontend/{client}/05-state.md` — estado do cliente (um por cliente existente)
- Templates a preencher: `docs/shared/glossary.md`, `docs/shared/event-mapping.md`, `docs/shared/error-ux-mapping.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/blueprint:increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->` ou `<!-- do backend: XX-arquivo.md -->`.
- **Nao invente.** Se uma camada nao decidiu algo, isso e uma lacuna a reportar — nao um espaco a preencher com o que pareceria razoavel.

---

## Passo 1: Pre-requisitos

| Verificacao | Se falhar |
|---|---|
| `docs/blueprint/04-domain-model.md` preenchido | "O glossario deriva do modelo de dominio. Rode `/blueprint:blueprint-domain` primeiro." **pare** |
| `docs/backend/` preenchido | Avise e siga: gere so o glossario, registre os outros dois como pendentes |
| `docs/frontend/{client}/` preenchido | Avise e siga: mapeie o lado do backend e deixe a coluna de UX marcada como pendente |

---

## Passo 2: Glossario

`docs/blueprint/04-domain-model.md` tem uma secao `## Glossario Ubiquo` com marcador `<!-- APPEND:glossary -->`. **Ela e a fonte.** Este documento e a projecao cross-layer dela — e a existencia das duas e deliberada: o blueprint define o termo, o shared mostra onde ele aparece em cada camada.

> **Se os dois divergirem, o blueprint vence.** Divergencia nao se resolve aqui: registre e leve para `/blueprint:increment` no `04-domain-model`.

Para cada termo do glossario do blueprint, preencha a tabela com:

| Coluna | De onde sai |
| --- | --- |
| **Termo** | `04-domain-model.md` §Glossario Ubiquo |
| **Definicao** | idem — copie, nao reescreva |
| **Nao Confundir Com** | termos vizinhos do mesmo glossario que causam ambiguidade |
| **Usado em** | **varra as camadas**: nome de entidade em `04`, de endpoint em `backend/05-api-contracts.md`, de componente em `frontend/{client}/04-components.md` |

A coluna **Usado em** e a razao do documento existir. Preencher com "entidades, endpoints, UI" generico e entregar o documento vazio com aparencia de cheio — cite os nomes reais.

**Acronimos:** varra os documentos em busca de siglas usadas sem definicao. Cada uma vira linha.

**Convencoes de nomenclatura:** extraia de `blueprint/06-system-architecture.md` e do que os documentos de backend e frontend efetivamente fazem. Se a convencao declarada e a praticada divergirem, registre a divergencia — nao escolha em silencio.

---

## Passo 3: Mapa de Eventos

Para cada evento em `backend/12-events.md`, uma linha:

| Coluna | De onde sai |
| --- | --- |
| **Evento** | `backend/12-events.md` |
| **Payload** | idem — os campos, com tipo |
| **Quem emite** | service ou worker, de `backend/06-services.md` |
| **Quem consome no frontend** | `frontend/{client}/05-state.md` — qual fatia de estado reage |
| **Efeito na UI** | o que o usuario ve mudar |

**Evento sem consumidor no frontend e achado, nao linha em branco.** Ou o backend emite algo que ninguem usa, ou o frontend depende de algo que ninguem emite. Os dois casos vao para o relatorio.

**Impacto de mudanca de payload:** para cada evento, liste o que quebra se um campo sair. Essa e a secao que transforma o documento de descritivo em util.

---

## Passo 4: Mapa de Erro para UX

Para cada erro em `backend/09-errors.md`:

| Coluna | De onde sai |
| --- | --- |
| **Codigo / Classe** | `backend/09-errors.md` |
| **HTTP** | idem |
| **Quando acontece** | a regra de negocio que o dispara |
| **O que o usuario ve** | **decisao de UX** — texto, tipo de UI (toast, inline, pagina), e a acao de recuperacao |
| **Recuperavel** | o usuario consegue resolver sozinho? |

Se `frontend/{client}/` ja definiu o tratamento, **copie de la**. Se nao definiu, esta skill **propoe** — e marca a proposta com `<!-- suposicao: texto de erro nao definido no frontend -->` para entrar em `docs/ASSUMPTIONS.md`.

**Erro tecnico nao vira texto tecnico.** `ECONNREFUSED` do banco vira "Nao foi possivel carregar. Tente de novo." O mapa existe para que essa traducao seja feita uma vez, num lugar, e nao improvisada em cada tela.

---

## Passo 5: Relatorio

> "**Shared:** 3 documentos preenchidos.
>
> | Documento | Linhas | Derivado de |
> |---|---|---|
> | `glossary.md` | {{n}} termos, {{n}} acronimos | `blueprint/04` |
> | `event-mapping.md` | {{n}} eventos | `backend/12` + `frontend/*/05` |
> | `error-ux-mapping.md` | {{n}} erros | `backend/09` + `frontend/*/` |
>
> **Divergencias entre camadas:** {{n}}
> {{lista: evento sem consumidor, erro sem UX, termo que muda de nome entre camadas}}
>
> **Suposicoes registradas:** {{n}} (texto de erro nao definido, consumidor inferido)
>
> Proximo: `/blueprint:specs` ou `/blueprint:codegen-setup`."

Uma divergencia encontrada aqui e o **retorno** desta fase, nao um defeito dela. Tres documentos que so concordam consigo mesmos nunca revelariam que o backend emite `OrderPaid` e o frontend escuta `PaymentConfirmed`.

Se houver divergencia de risco alto (termo que significa coisas diferentes em duas camadas, evento central sem consumidor), diga qual e leve para `/blueprint:increment` **antes** de `/blueprint:codegen-setup` — o scaffold congela nomes.
