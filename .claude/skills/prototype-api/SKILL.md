---
name: prototype-api
description: Fase C do prototipo — extrai do codigo o contrato de API que o backend deve implementar. Gera 03-api-requirements, 04-interaction-states e 05-findings.
---

# Prototipo — Fase C: Extracao do Contrato

Le o **codigo** do prototipo e extrai o contrato que o backend precisa implementar. Produz os tres documentos que fazem a fase valer: o contrato descoberto, os estados que ele precisa alimentar e o que construir a interface revelou sobre o blueprint.

```
/prototype-api [cliente] [projeto-alvo]
```

## A regra que define esta skill

> **Leia o codigo, nao o plano.** `01-screens.md` diz o que se pretendia construir; o codigo diz o que foi construido. Onde os dois divergem, o codigo vence — e a divergencia vira achado.

Um contrato escrito a partir da intencao e a mesma previsao que a fase de prototipo existe para evitar. Se esta skill copiar `01-screens.md`, a fase inteira perdeu o proposito.

## Pre-requisitos

| Verificacao | Se falhar |
|---|---|
| Prototipo construido no projeto-alvo | "Rode `/prototype-build` primeiro." **pare** |
| `src/mocks/handlers/` existe e tem handlers | "Nao encontrei a camada de mock. O contrato e extraido dela." **pare** |
| Portoes de `/prototype-build` passaram | Avise: contrato extraido de prototipo incompleto nasce incompleto |

## Contexto

- **O codigo do prototipo** — fonte primaria: handlers de mock, chamadas da aplicacao, componentes que renderizam os campos
- `docs/prototype/01-screens.md` — para cruzar e achar divergencia
- `docs/prototype/02-mock-data.md` — fixtures e cenarios
- `docs/blueprint/04-domain-model.md` — para detectar lacuna de dominio
- `docs/blueprint/09-state-models.md` — para detectar transicao sem gatilho
- `docs/shared/glossary.md` — nomenclatura
- Templates a preencher: `docs/prototype/03-api-requirements.md`, `04-interaction-states.md`, `05-findings.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, antes de `<!-- APPEND:... -->`.
- **Origem:** marque cada endpoint com `<!-- extraido de: {arquivo}:{linha} -->`.
- **Nada sem consumidor.** Endpoint sem tela que o chame e campo sem ponto de renderizacao nao entram em `03`. Vao para `05-findings.md` como sobra.
- **Nao resolva achados.** Registre, classifique por risco, encaminhe. O blueprint e a fonte de verdade; o prototipo e a evidencia.
- **Perguntas: maximo 3.**

---

## Passo 1: Varredura

Colete tres inventarios independentes:

| Inventario | Onde | O que extrair |
|---|---|---|
| **Endpoints servidos** | `src/mocks/handlers/` | Metodo, rota, forma do request, forma do response |
| **Chamadas feitas** | Camada de dados da aplicacao (hooks, `api/`) | Quem chama, de qual tela, com que frequencia |
| **Campos renderizados** | Componentes | Qual campo aparece, onde, com qual fallback |

Cruze os tres. As lacunas entre eles sao o achado mais valioso desta skill:

| Cruzamento | Significado | Destino |
|---|---|---|
| Handler existe, ninguem chama | Endpoint sem consumidor | `05-findings` — nao entra no contrato |
| Chamada existe, sem handler | Chamada quebrada | Bug do prototipo — corrija antes de seguir |
| Campo devolvido, nunca renderizado | Payload desnecessario | `03` §campos nao consumidos — propor remocao |
| Campo renderizado, nao devolvido | Lacuna de dominio | `05-findings` — risco alto |

## Passo 2: `03-api-requirements.md`

Para cada endpoint **com consumidor**:

- Telas consumidoras e **chamadas por render** — a coluna que revela problema de desenho: tela que faz 5 chamadas para o primeiro paint pede agregacao
- Request: campo, tipo, obrigatoriedade, origem na UI, validacao no cliente
- Response: **apenas os campos consumidos**, cada um com onde e usado e o que acontece se vier ausente
- Campos devolvidos e nao consumidos, com proposta de remocao
- Erros que a UI trata
- Latencia tolerada — determinada pelo ponto em que o skeleton fica visivel tempo demais
- Idempotencia — necessaria sempre que a UI faz update otimista

Preencha tambem: **operacoes que precisam ser atomicas** (sequencias que a UI trata como acao unica), **agregacoes requeridas** (telas que precisam de varias entidades num render), **tempo real** (o que a UI precisa saber sem perguntar, e como o prototipo simulou) e **divergencias com o modelo de dominio**.

## Passo 3: `04-interaction-states.md`

Extraia dos componentes:

- Matriz de estados por tela — carregando, vazio, erro, parcial, sem permissao. **Celula vazia e tela incompleta**, e volta para `/prototype-build`.
- Catalogo de erros exercidos, com como o prototipo dispara cada um
- **Requisitos derivados**: cada tratamento impoe algo ao backend — erro por campo exige `details[]`; contagem regressiva exige `Retry-After`; refresh silencioso exige distinguir token expirado de invalido; referencia de suporte exige `requestId`
- Mutacoes otimistas e o que cada uma exige de idempotencia
- Transicoes de `09-state-models` disparaveis pela UI, e a causa de cada uma que nao e: acao de sistema, backoffice fora de escopo, ou **lacuna**

## Passo 4: `05-findings.md`

Classifique cada achado por risco:

| Risco | Criterio |
|---|---|
| **Alto** | Bloqueia o backend — campo inexistente que a UI exige, estado faltando, regra sem dono, ordenacao instavel |
| **Medio** | Resolvivel na implementacao, melhor decidir agora — agregacao, DTO inchado, campo conveniente |
| **Baixo** | Ajuste de documentacao |

Preencha as sete secoes: lacunas do dominio · casos de uso que nao sobreviveram ao contato com a UI · estados faltando ou sobrando · **regras de negocio descobertas** · problemas de desenho da API · contradicoes entre documentos · suposicoes do prototipo.

Feche com o **encaminhamento**: cada achado com destino (`/increment` ou `/patch`) e status.

> A secao de **regras de negocio descobertas** costuma ser a mais valiosa. Regras aparecem quando alguem precisa decidir se um botao fica habilitado — e e a primeira vez que alguem precisa decidir isso.

## Passo 5: Portao antes do Backend

```
Nenhum achado de risco ALTO pode permanecer aberto quando /backend rodar.
```

Contrato construido sobre lacuna conhecida propaga a lacuna para o schema — e schema com dados nao se corrige com `/increment`.

Se houver achado alto aberto:

> "**{{N}} achados de risco alto** bloqueiam a fase de backend:
> 1. {{achado}} → {{destino}}
>
> Resolva com `/increment` (local) ou `/patch` (global) e rode `/prototype-api` de novo para regenerar o contrato."

## Passo 6: Relatorio

> "**Contrato extraido** — {{N}} endpoints com consumidor nomeado.
>
> | Metrica | Valor |
> |---|---|
> | Endpoints no contrato | {{N}} |
> | Campos consumidos | {{N}} |
> | Campos devolvidos sem consumidor | {{N}} — propostos para remocao |
> | Endpoints sem consumidor | {{N}} — fora do contrato |
> | Erros que a UI ja trata | {{N}} |
> | Operacoes atomicas | {{N}} |
> | Agregacoes propostas | {{N}} |
> | Achados | {{N}} ({{n}} alto, {{m}} medio, {{k}} baixo) |
>
> {{Se houver achado alto: bloco de bloqueio do Passo 5}}
>
> **Proximo passo:** `/backend` — agora com `docs/prototype/03-api-requirements.md` como **fonte primaria do contrato**, e o blueprint tecnico como fonte do dominio."

## Limites conhecidos

- **O contrato cobre o que a UI pede, nao o sistema inteiro.** Webhooks, jobs, integracoes e endpoints administrativos nao aparecem no prototipo — continuam vindo de `07-critical_flows` e `13-integrations`.
- **Latencia tolerada e percepcao, nao medicao.** E util para priorizar indice e cache; nao substitui teste de carga.
- **Um cliente so.** Mobile e desktop tem necessidades que o web nao revela — offline, push, IPC.
