# Inventario de Telas

Mapeia cada caso de uso do blueprint tecnico para as telas que o realizam. Este documento e a **fronteira de escopo do prototipo**: tela que nao esta aqui nao e construida; caso de uso sem tela e uma lacuna a reportar, nao a inventar.

> **Deriva de:** [`blueprint/08-use_cases.md`](../blueprint/08-use_cases.md) (casos de uso), [`blueprint/07-critical_flows.md`](../blueprint/07-critical_flows.md) (fluxos) e [`blueprint/00-context.md`](../blueprint/00-context.md) (atores).
> **Alimenta:** `docs/frontend/{client}/07-routes.md` e `04-components.md` na fase de especificacao final.

---

## Mapa Caso de Uso → Tela

> Cada `UC-XXX` precisa de ao menos uma tela. Um `UC` pode gerar varias telas (um wizard); uma tela pode servir varios `UC` (um dashboard).

| UC | Nome do caso de uso | Tela(s) | Rota | Ator | Criticidade |
| --- | --- | --- | --- | --- | --- |
| {{UC-001}} | {{Cadastrar novo usuario}} | {{SignupPage, VerifyEmailPage}} | {{/signup, /verify}} | {{Visitante}} | {{Alta}} |
| {{UC-002}} | {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |

<!-- APPEND:mapa-uc -->

**Cobertura:** {{N}} de {{M}} casos de uso tem tela.

> Casos de uso **sem tela** — liste explicitamente e justifique. Um `UC` sem tela e um de tres casos: (a) e API-only e nao tem interface, (b) foi esquecido, (c) nao deveria existir. Os tres exigem decisao, nenhum exige invencao.

| UC sem tela | Motivo | Acao |
| --- | --- | --- |
| {{UC-0XX}} | {{API-only / esquecido / fora de escopo}} | {{nenhuma / criar tela / `/blueprint:increment` no blueprint}} |

<!-- APPEND:uc-sem-tela -->

---

## Detalhamento por Tela

> Para CADA tela do inventario, preencha o bloco abaixo. E daqui que sai o contrato de API — por isso a coluna "dados exibidos" precisa listar **campo por campo**, nao "dados do usuario".

### {{NomeDaTela}}

| Campo | Valor |
| --- | --- |
| **Rota** | {{/caminho/:param}} |
| **Casos de uso** | {{UC-001, UC-003}} |
| **Acesso** | {{publica / autenticada / role especifica}} |
| **Layout** | {{AuthLayout / AppLayout / AdminLayout}} |
| **Entidades exibidas** | {{User, Order}} |

**Dados exibidos** — cada linha vira um campo obrigatorio no contrato de API:

| Campo | Entidade | Origem | Formato na tela | Obrigatorio para renderizar? |
| --- | --- | --- | --- | --- |
| {{name}} | {{User}} | {{GET /users/me}} | {{texto, truncado em 40 chars}} | {{sim}} |
| {{avatarUrl}} | {{User}} | {{GET /users/me}} | {{imagem 40x40, fallback com iniciais}} | {{nao — tem fallback}} |
| {{total}} | {{Order}} | {{GET /orders}} | {{moeda, 2 casas}} | {{sim}} |

**Acoes do usuario** — cada linha vira um endpoint de escrita:

| Acao | Gatilho | Efeito esperado | Transicao de estado | Confirmacao |
| --- | --- | --- | --- | --- |
| {{Cancelar pedido}} | {{Botao "Cancelar"}} | {{Pedido sai da lista de ativos}} | {{`confirmed → canceled` (09-state-models)}} | {{Modal de confirmacao}} |
| {{Salvar perfil}} | {{Submit do form}} | {{Toast de sucesso, campos persistem}} | {{—}} | {{Nenhuma}} |

**Filtros, ordenacao e paginacao** — o que a tela realmente exercita:

| Recurso | Implementado? | Parametros |
| --- | --- | --- |
| {{Busca}} | {{sim}} | {{?search= — busca por nome e email}} |
| {{Filtro}} | {{sim}} | {{?status=active,pending — multiplo}} |
| {{Ordenacao}} | {{sim}} | {{?sort=created_at&order=desc}} |
| {{Paginacao}} | {{sim}} | {{?page=1&limit=20 — scroll infinito}} |

> Repita este bloco para cada tela.

<!-- APPEND:telas -->

---

## Mapa de Navegacao

> Como o usuario chega a cada tela e para onde ele vai depois. Guards e redirecionamentos definem o que o backend precisa responder em `401` e `403`.

| De | Para | Gatilho | Guard | Se o guard falhar |
| --- | --- | --- | --- | --- |
| {{/login}} | {{/dashboard}} | {{Login com sucesso}} | {{—}} | {{—}} |
| {{qualquer}} | {{/login}} | {{Token expirado}} | {{auth}} | {{Salva a URL atual e volta apos login}} |
| {{/dashboard}} | {{/admin/users}} | {{Item do menu}} | {{role = admin}} | {{Item nem aparece no menu}} |

<!-- APPEND:navegacao -->

**Deep links** — rotas que precisam funcionar como entrada direta (compartilhamento, email, push):

| Rota | Entrada direta funciona? | Requer | Comportamento sem sessao |
| --- | --- | --- | --- |
| {{/orders/:id}} | {{sim}} | {{sessao + ownership}} | {{login com retorno}} |

---

## Fluxos Criticos Percorriveis

> Cada fluxo de `blueprint/07-critical_flows.md` precisa ser percorrivel ponta a ponta no prototipo. Este e um criterio de saida, nao uma aspiracao.

| Fluxo | Telas na sequencia | Percorrivel? | Observacao |
| --- | --- | --- | --- |
| {{Autenticacao}} | {{/login → /dashboard}} | {{sim}} | {{—}} |
| {{Checkout}} | {{/cart → /checkout → /confirm}} | {{sim}} | {{Pagamento mockado com resposta fixa}} |

<!-- APPEND:fluxos -->

> (ver [02-mock-data.md](02-mock-data.md) para os dados que alimentam estas telas)
