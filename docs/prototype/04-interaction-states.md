# Estados de Interacao

Cataloga os estados que cada tela assume e os erros que a interface ja sabe tratar. Cada erro listado aqui e uma **obrigacao do backend**: se a UI sabe exibir `RATE_LIMIT_EXCEEDED` com contagem regressiva, o backend precisa devolver esse codigo e o header que alimenta a contagem.

> **Alimenta:** [`docs/backend/09-errors.md`](../backend/09-errors.md) (catalogo de codigos), [`docs/shared/error-ux-mapping.md`](../shared/error-ux-mapping.md) (mapeamento erro → UX) e `docs/frontend/{client}/14-copies.md` (textos).

---

## Os Quatro Estados Obrigatorios

> Toda tela que busca dados assume quatro estados. Tela que so implementa "sucesso" e uma tela que ainda nao existe.

| Estado | Quando | Regra do prototipo |
| --- | --- | --- |
| **Carregando** | {{Enquanto a chamada nao retorna}} | {{Skeleton com a forma do conteudo real — nunca spinner generico em lista}} |
| **Vazio** | {{Retorno com zero registros}} | {{Mensagem + CTA que resolve o vazio; nunca tabela com zero linhas}} |
| **Erro** | {{Falha de rede ou status >= 400}} | {{Mensagem legivel + acao de retry; nunca stack trace}} |
| **Sucesso** | {{Dados renderizados}} | {{—}} |

**Estados adicionais quando aplicavel:** parcial (parte carregou), offline, sem permissao, degradado (dado stale exibido com aviso).

---

## Matriz de Estados por Tela

> Preencha para cada tela de [`01-screens.md`](01-screens.md). Uma celula vazia e uma tela incompleta, nao um detalhe.

| Tela | Carregando | Vazio | Erro | Parcial | Sem permissao |
| --- | --- | --- | --- | --- | --- |
| {{OrdersPage}} | {{Skeleton de 5 linhas}} | {{"Nenhum pedido ainda" + CTA}} | {{Banner + retry}} | {{Lista renderiza, total falha}} | {{Redirect}} |
| {{ProfilePage}} | {{Skeleton de form}} | {{n/a}} | {{Toast + retry}} | {{n/a}} | {{404}} |

<!-- APPEND:matriz-estados -->

---

## Catalogo de Erros Exercidos

> Erros que a UI **ja trata**. Cada linha e um requisito para [`docs/backend/09-errors.md`](../backend/09-errors.md): o codigo precisa existir, com esse status e esse formato.

| Codigo | Status | Como o prototipo dispara | Tratamento na UI | Componente | Retentavel |
| --- | --- | --- | --- | --- | --- |
| {{VALIDATION_ERROR}} | {{400}} | {{`?scenario=invalid`}} | {{Erro por campo, foco no primeiro}} | {{Form}} | {{usuario corrige}} |
| {{TOKEN_EXPIRED}} | {{401}} | {{`?scenario=expired`}} | {{Refresh silencioso; se falhar, modal}} | {{AuthProvider}} | {{automatico}} |
| {{INSUFFICIENT_PERMISSIONS}} | {{403}} | {{Trocar de persona}} | {{Toast, permanece na pagina}} | {{Toast}} | {{nao}} |
| {{NOT_FOUND}} | {{404}} | {{ID inexistente na URL}} | {{Tela 404 com link para a lista}} | {{NotFoundPage}} | {{nao}} |
| {{RATE_LIMIT_EXCEEDED}} | {{429}} | {{`?scenario=ratelimit`}} | {{Form desabilitado + contagem}} | {{RateLimitBanner}} | {{apos cooldown}} |

<!-- APPEND:erros -->

**Requisitos derivados** — o que cada tratamento exige do backend:

| Tratamento na UI | Exige do backend |
| --- | --- |
| {{Erro por campo}} | {{`details: [{ field, message }]` no corpo do 400}} |
| {{Contagem regressiva}} | {{Header `X-RateLimit-Reset` ou `Retry-After`}} |
| {{Refresh silencioso}} | {{Endpoint de refresh e distincao entre token expirado e invalido}} |
| {{Referencia para suporte}} | {{`requestId` em toda resposta de erro}} |

> **Erro sem codigo estavel nao e tratavel.** Se o backend devolver so `message`, a UI passa a comparar string — e a mensagem muda com a traducao. O `code` em UPPER_SNAKE_CASE e o que torna o tratamento possivel.

---

## Mutacoes Otimistas

> Acoes em que a UI atualiza a tela antes da confirmacao do servidor. Cada uma impoe requisitos ao backend.

| Acao | Otimista? | Rollback se falhar | Exige do backend |
| --- | --- | --- | --- |
| {{Marcar como lido}} | {{sim}} | {{Reverte o estado, sem aviso}} | {{Idempotencia}} |
| {{Curtir}} | {{sim}} | {{Reverte + toast}} | {{Idempotencia}} |
| {{Excluir}} | {{sim}} | {{Reinsere na posicao + toast}} | {{Idempotencia + ordenacao estavel}} |
| {{Pagar}} | **{{nao}}** | {{n/a}} | {{Nunca otimista — dinheiro espera confirmacao}} |

<!-- APPEND:otimistas -->

> **Regra:** otimismo exige **idempotencia**. Se a UI pode reenviar apos timeout, o backend precisa tratar a repeticao — via chave de idempotencia ou por natureza da operacao. Este e o vinculo direto entre esta secao e `docs/backend/04-data-layer.md`.

---

## Estados de Entidade Exercidos

> Quais transicoes de [`blueprint/09-state-models.md`](../blueprint/09-state-models.md) sao disparaveis pela interface. Transicao sem gatilho na UI e transicao que so existe no papel — ou falta tela, ou a maquina de estados tem estado morto.

| Entidade | Transicao | Gatilho na UI | Tela | Disparavel? |
| --- | --- | --- | --- | --- |
| {{Order}} | {{`draft → confirmed`}} | {{Botao "Finalizar"}} | {{CartPage}} | {{sim}} |
| {{Order}} | {{`confirmed → canceled`}} | {{Botao "Cancelar"}} | {{OrderDetail}} | {{sim}} |
| {{Order}} | {{`paid → shipped`}} | {{—}} | {{—}} | {{nao — acao de backoffice}} |

<!-- APPEND:transicoes -->

**Transicoes sem gatilho:** {{N}}. Para cada uma, a causa: acao de sistema (worker, cron), acao de backoffice fora de escopo, ou **lacuna**. As duas primeiras sao respostas; a terceira vai para [`05-findings.md`](05-findings.md).

---

## Feedback e Confirmacao

> Convencao unica para todo o app — inconsistencia aqui e percebida como falta de acabamento.

| Situacao | Padrao | Duracao |
| --- | --- | --- |
| {{Sucesso em acao rapida}} | {{Toast discreto}} | {{3s}} |
| {{Sucesso em acao longa}} | {{Toast + atualizacao visivel da lista}} | {{5s}} |
| {{Acao destrutiva}} | {{Modal de confirmacao com o nome do recurso}} | {{ate agir}} |
| {{Acao irreversivel}} | {{Modal + digitar o nome para confirmar}} | {{ate agir}} |
| {{Processo longo}} | {{Barra de progresso ou "avisaremos quando terminar"}} | {{ate concluir}} |
| {{Erro recuperavel}} | {{Inline, proximo da origem}} | {{ate corrigir}} |

<!-- APPEND:feedback -->

> (ver [05-findings.md](05-findings.md) para o que construir estas telas revelou sobre o blueprint)
