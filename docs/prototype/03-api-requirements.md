# Contrato de API Requerido

**Este e o entregavel que justifica a fase de prototipo.** Ele descreve o contrato que o backend precisa implementar — nao como um desejo, mas como um **inventario extraido do codigo do prototipo**: cada endpoint aqui tem uma tela que o chama, e cada campo tem um lugar onde e renderizado.

> **Regra de ouro deste documento:** nada entra aqui sem consumidor nomeado. Endpoint sem tela, campo sem ponto de renderizacao e ideia, nao requisito — e ideia vai para [`05-findings.md`](05-findings.md).

> **Deriva de:** o codigo do prototipo (handlers de mock + chamadas da aplicacao) e [`01-screens.md`](01-screens.md).
> **Alimenta:** [`docs/backend/05-api-contracts.md`](../backend/05-api-contracts.md) — **fonte primaria do contrato**. E, depois, `docs/frontend/shared/15-api-dependencies.md`.

---

## Como este documento foi produzido

> Preencha para que quem ler saiba o quanto confiar.

| Aspecto | Valor |
| --- | --- |
| **Metodo de extracao** | {{Varredura dos handlers de mock + grep das chamadas na aplicacao}} |
| **Data da extracao** | {{YYYY-MM-DD}} |
| **Commit do prototipo** | {{sha}} |
| **Escrito a mao?** | **Nao.** Divergencias entre este doc e o codigo sao bug do doc |

---

## Convencoes Exercidas

> O que o prototipo de fato usou. Onde o prototipo nao exercitou, diga "nao exercitado" em vez de copiar o padrao do repositorio — copiar cria requisito falso.

| Aspecto | Exercitado no prototipo | Observacao |
| --- | --- | --- |
| Base URL | {{/api/v1}} | {{—}} |
| Autenticacao | {{Bearer token no header}} | {{Mockado, mas o header e enviado}} |
| Paginacao | {{`?page=&limit=` com `{ data, meta }`}} | {{Exercitada em {{N}} telas}} |
| Ordenacao | {{`?sort=&order=`}} | {{Exercitada em {{N}} telas}} |
| Filtros | {{`?status=&role=`}} | {{Multiplo valor via virgula em {{N}} telas}} |
| Busca | {{`?search=`}} | {{Debounce de {{300}}ms no cliente}} |
| Formato de data | {{ISO 8601 UTC}} | {{Convertido para o fuso do usuario na exibicao}} |
| Formato de dinheiro | {{Inteiro em centavos + codigo de moeda}} | {{Evita float; formatado no cliente}} |

<!-- APPEND:convencoes -->

---

## Inventario de Endpoints

> Um por linha, com a tela que o consome. A coluna **chamadas por render** e a que revela problema de desenho: uma tela que faz 6 chamadas para pintar o primeiro paint pede agregacao ou BFF.

| Metodo | Rota | Telas consumidoras | Chamadas por render | Auth | Criticidade |
| --- | --- | --- | --- | --- | --- |
| {{POST}} | {{/auth/login}} | {{LoginPage}} | {{1}} | {{publica}} | {{alta}} |
| {{GET}} | {{/users/me}} | {{Header, Sidebar, ProfilePage}} | {{1 — cacheada}} | {{sessao}} | {{alta}} |
| {{GET}} | {{/orders}} | {{OrdersPage}} | {{1 por pagina}} | {{sessao}} | {{alta}} |
| {{PATCH}} | {{/orders/:id}} | {{OrderDetail}} | {{1 por acao}} | {{sessao + ownership}} | {{alta}} |

<!-- APPEND:endpoints -->

**Total:** {{N}} endpoints · {{M}} de leitura · {{K}} de escrita.

---

## Detalhamento por Endpoint

> Para CADA endpoint, o que a UI realmente precisa. A coluna "usado em" e obrigatoria: campo sem ela nao deveria estar na lista.

### `{{METODO}} {{/rota}}`

**Consumido por:** {{Tela — componente}}
**Disparado por:** {{Montagem da tela / clique em X / polling de Ns}}

**Request:**

| Campo | Tipo | Obrigatorio | Origem na UI | Validacao no cliente |
| --- | --- | --- | --- | --- |
| {{email}} | {{string}} | {{sim}} | {{Campo do formulario}} | {{formato de email, max 255}} |

**Response — campos consumidos:**

| Campo | Tipo | Usado em | Obrigatorio para renderizar | Se vier ausente |
| --- | --- | --- | --- | --- |
| {{id}} | {{UUID}} | {{key da lista, rota do detalhe}} | {{sim}} | {{quebra a navegacao}} |
| {{status}} | {{enum}} | {{Badge de status}} | {{sim}} | {{badge vazio}} |
| {{avatarUrl}} | {{string \| null}} | {{Avatar}} | {{nao}} | {{fallback com iniciais}} |

> **Campos NAO consumidos:** se o mock devolve campos que nenhuma tela usa, liste-os aqui e proponha remocao. Payload que ninguem le e custo de banda, de manutencao e de superficie de vazamento.

| Campo devolvido e nao usado | Proposta |
| --- | --- |
| {{internalNotes}} | {{Remover do DTO publico}} |

**Erros que a UI trata:**

| Status | Codigo | O que a UI faz | Precisa existir no backend? |
| --- | --- | --- | --- |
| {{401}} | {{TOKEN_EXPIRED}} | {{Tenta refresh; se falhar, vai para login}} | {{sim}} |
| {{409}} | {{DUPLICATE_RESOURCE}} | {{Destaca o campo duplicado}} | {{sim}} |

**Requisitos nao funcionais observados:**

| Aspecto | Valor | Como foi determinado |
| --- | --- | --- |
| {{Latencia tolerada}} | {{< 400ms}} | {{Acima disso o skeleton fica visivel e a tela parece travada}} |
| {{Idempotencia}} | {{necessaria}} | {{A UI faz update otimista e pode reenviar}} |
| {{Cache}} | {{5 min}} | {{Consumido por 3 componentes no mesmo render}} |

> Repita para cada endpoint.

<!-- APPEND:detalhamento -->

---

## Operacoes que Precisam Ser Atomicas

> Sequencias que a UI trata como uma acao unica. Se o backend as expuser como chamadas separadas, a interface fica com estado inconsistente quando a segunda falhar.

| Acao na UI | Operacoes envolvidas | Por que precisa ser atomica |
| --- | --- | --- |
| {{Finalizar pedido}} | {{criar pedido + reservar estoque + cobrar}} | {{Cobranca sem pedido deixa o usuario sem recurso e com debito}} |
| {{Convidar membro}} | {{criar convite + enviar email}} | {{Convite sem email e um registro invisivel}} |

<!-- APPEND:atomicas -->

> Estas linhas viram transacao ou saga em [`docs/backend/04-data-layer.md`](../backend/04-data-layer.md) e fluxo detalhado em [`06-services.md`](../backend/06-services.md).

---

## Agregacoes Requeridas

> Telas que precisam de dados de mais de uma entidade num unico render. Cada linha e uma decisao: o backend agrega, ou o cliente faz N chamadas?

| Tela | Dados necessarios | Chamadas se nao agregar | Proposta |
| --- | --- | --- | --- |
| {{Dashboard}} | {{usuario + metricas + atividade recente}} | {{3}} | {{Endpoint agregado ou BFF}} |
| {{Detalhe do pedido}} | {{pedido + itens + cliente + pagamento}} | {{4}} | {{Expandir no proprio recurso}} |

<!-- APPEND:agregacoes -->

---

## Tempo Real e Assincronia

> O que a UI precisa saber sem perguntar. Cada linha vira um evento em [`docs/backend/12-events.md`](../backend/12-events.md) e uma entrada em [`docs/shared/event-mapping.md`](../shared/event-mapping.md).

| Mudanca | Como o prototipo simulou | Canal proposto | Consequencia se nao existir |
| --- | --- | --- | --- |
| {{Status do pedido mudou}} | {{Polling de 10s}} | {{WebSocket}} | {{Usuario recarrega a pagina para ver}} |
| {{Relatorio ficou pronto}} | {{Timer fixo}} | {{Push / notificacao in-app}} | {{Usuario espera sem feedback}} |

<!-- APPEND:tempo-real -->

---

## Divergencias com o Modelo de Dominio

> Onde construir a interface discordou do que `04-domain-model.md` dizia. **Nao resolva aqui** — registre e leve para `/increment`. Resolver em silencio faz o prototipo virar uma segunda fonte de verdade.

| Divergencia | O dominio diz | A UI precisa | Proposta |
| --- | --- | --- | --- |
| {{Campo ausente}} | {{`User` nao tem `lastSeenAt`}} | {{Lista mostra "ativo ha 2h"}} | {{`/increment` no dominio, ou remover da tela}} |
| {{Cardinalidade}} | {{`User` 1:N `Order`}} | {{Tela de pedido compartilhado exige N:M}} | {{Decisao de produto — escalar}} |

<!-- APPEND:divergencias -->

> (ver [04-interaction-states.md](04-interaction-states.md) para os estados que estes endpoints precisam alimentar)
