# Integracoes Externas

Define os clients de APIs externas — metodos, timeout, retry, circuit breaker e fallback para cada integracao.

---

## Catalogo de Integracoes

> Quais servicos externos o backend consome?

| Servico | Funcao | Protocolo | Criticidade | SLA |
| --- | --- | --- | --- | --- |
| {{Stripe}} | {{Pagamentos}} | {{REST API}} | {{Alta}} | {{99.99%}} |
| {{Resend/SES}} | {{Email transacional}} | {{REST API / SDK}} | {{Media}} | {{99.9%}} |
| {{S3}} | {{Armazenamento de arquivos}} | {{SDK}} | {{Alta}} | {{99.99%}} |
| {{Auth0/Cognito}} | {{Autenticacao}} | {{OIDC / SDK}} | {{Critica}} | {{99.99%}} |

<!-- APPEND:catalogo -->

---

## Detalhamento por Integracao

> Para CADA servico externo, documente o client, metodos, resiliencia e configuracao.

### {{NomeServico}} (ex: Stripe)

**Funcao:** {{Processamento de pagamentos}}

**Client Class:** `{{StripeClient}}`

**Metodos:**

| Metodo | Endpoint Externo | Timeout | Retry | Descricao |
| --- | --- | --- | --- | --- |
| {{createCharge(amount, currency, source)}} | {{POST /v1/charges}} | {{10s}} | {{3x, backoff 2^n}} | {{Cria cobranca}} |
| {{refund(chargeId, amount?)}} | {{POST /v1/refunds}} | {{10s}} | {{3x, backoff 2^n}} | {{Estorna cobranca}} |
| {{getCharge(chargeId)}} | {{GET /v1/charges/:id}} | {{5s}} | {{2x}} | {{Consulta cobranca}} |

**Circuit Breaker:**

| Parametro | Valor |
| --- | --- |
| {{Threshold}} | {{5 falhas em 60s}} |
| {{Estado aberto}} | {{30s}} |
| {{Half-open}} | {{1 request de teste}} |
| {{Fallback}} | {{Enfileirar para reprocessamento}} |

**Configuracao:**

| Variavel | Descricao |
| --- | --- |
| {{STRIPE_SECRET_KEY}} | {{API key do ambiente}} |
| {{STRIPE_WEBHOOK_SECRET}} | {{Secret para validar webhooks}} |
| {{STRIPE_MODE}} | {{test / live}} |

<!-- APPEND:integracoes -->

<details>
<summary>Exemplo — Client de Pagamento</summary>

### PaymentGatewayClient

**Metodos:**

| Metodo | Endpoint | Timeout | Retry | Fallback |
| --- | --- | --- | --- | --- |
| createCharge(amount, currency, source) | POST /v1/charges | 10s | 3x, backoff 2^n | Enfileirar em payments.retry |
| refund(chargeId, amount?) | POST /v1/refunds | 10s | 3x | Registrar para refund manual |
| getCharge(chargeId) | GET /v1/charges/:id | 5s | 2x | Cache da ultima leitura |

**Circuit Breaker:** 5 falhas em 60s → aberto por 30s → half-open com 1 request

</details>

---

## Webhooks Recebidos

> Quais webhooks de servicos externos o sistema recebe?

| Servico | Evento | Endpoint Local | Acao | Validacao |
| --- | --- | --- | --- | --- |
| {{Stripe}} | {{payment_intent.succeeded}} | {{POST /webhooks/stripe}} | {{Atualizar status do pedido}} | {{Signature verification}} |
| {{Stripe}} | {{charge.refunded}} | {{POST /webhooks/stripe}} | {{Registrar estorno}} | {{Signature verification}} |
| {{Auth0}} | {{user.created}} | {{POST /webhooks/auth}} | {{Criar perfil local}} | {{Token validation}} |

<!-- APPEND:webhooks -->

---

## Webhooks Enviados

> O sistema envia webhooks para parceiros/integradores?

| Evento | Destino | Payload | Retry | Assinatura |
| --- | --- | --- | --- | --- |
| {{order.completed}} | {{URL cadastrada pelo parceiro}} | {{Order + items}} | {{5x, backoff exponencial}} | {{HMAC-SHA256}} |
| {{user.created}} | {{CRM externo}} | {{User basico}} | {{3x}} | {{API key no header}} |

<!-- APPEND:webhooks-enviados -->

---

## Canais de Comunicacao

> Provedores, templates e regras de envio de email, SMS e WhatsApp. Cada template e disparado por um evento de dominio de [12-events.md](12-events.md).

### Provedores por Canal

| Canal | Provedor | Fallback | Limite | Custo por envio |
| --- | --- | --- | --- | --- |
| {{Email transacional}} | {{Resend}} | {{SES}} | {{100k/mes}} | {{$0.001}} |
| {{SMS}} | {{Twilio}} | {{—}} | {{10k/mes}} | {{$0.05}} |
| {{WhatsApp}} | {{Meta Cloud API}} | {{—}} | {{1k conversas/mes}} | {{$0.03}} |

<!-- APPEND:provedores-comunicacao -->

### Catalogo de Templates

> Um template por evento que gera notificacao. O `Evento` deve existir em [12-events.md](12-events.md).

| ID | Canal | Evento disparador | Assunto / Primeira linha | Variaveis | Obrigatorio |
| --- | --- | --- | --- | --- | --- |
| {{TPL-001}} | {{Email}} | {{user.created}} | {{Bem-vindo ao {{produto}}}} | {{name, activationUrl}} | {{Sim}} |
| {{TPL-002}} | {{Email}} | {{password.reset_requested}} | {{Redefinicao de senha}} | {{name, resetUrl, expiresIn}} | {{Sim}} |
| {{TPL-003}} | {{SMS}} | {{phone.verification_sent}} | {{Seu codigo e {{code}}}} | {{code}} | {{Sim}} |
| {{TPL-004}} | {{WhatsApp}} | {{order.completed}} | {{Pedido confirmado}} | {{orderId, total}} | {{Nao}} |

<!-- APPEND:templates-comunicacao -->

### Variaveis e Personalizacao

| Variavel | Origem | Fallback | Exemplo |
| --- | --- | --- | --- |
| {{name}} | {{User.firstName}} | {{"voce"}} | {{Maria}} |
| {{produto}} | {{config}} | {{—}} | {{Acme}} |
| {{activationUrl}} | {{gerado com token}} | {{—}} | {{https://app/activate?t=...}} |

<!-- APPEND:variaveis-comunicacao -->

### Regras de Envio

**Prioridade entre canais** — quando o mesmo evento pode ir por mais de um canal:

| Evento | 1a opcao | 2a opcao | Condicao de fallback |
| --- | --- | --- | --- |
| {{phone.verification_sent}} | {{SMS}} | {{WhatsApp}} | {{SMS falhou 2x}} |
| {{order.completed}} | {{WhatsApp}} | {{Email}} | {{usuario sem opt-in}} |

**Rate limits e throttling:**

| Regra | Limite | Janela | Acao ao exceder |
| --- | --- | --- | --- |
| {{Por usuario, por canal}} | {{5}} | {{1h}} | {{Enfileirar}} |
| {{Marketing por usuario}} | {{2}} | {{7d}} | {{Descartar}} |
| {{Global por provedor}} | {{1000}} | {{1min}} | {{Backpressure na fila}} |

<!-- APPEND:regras-envio -->

### Convencoes por Canal

| Canal | Limite de tamanho | Tom | Regras |
| --- | --- | --- | --- |
| {{Email}} | {{assunto <= 50 chars}} | {{Direto, 2a pessoa}} | {{1 CTA principal; link de descadastro obrigatorio em marketing}} |
| {{SMS}} | {{160 chars}} | {{Objetivo, sem emoji}} | {{Sem links encurtados; identificar o remetente}} |
| {{WhatsApp}} | {{1024 chars}} | {{Conversacional}} | {{Template pre-aprovado pela Meta; respeitar janela de 24h}} |

<!-- APPEND:convencoes-comunicacao -->

---

## Health Checks de Integracoes

> Como verificar se as integracoes estao funcionando?

| Servico | Endpoint de Health | Frequencia | Acao se falhar |
| --- | --- | --- | --- |
| {{Banco (PostgreSQL)}} | {{SELECT 1}} | {{10s}} | {{Alerta P1, failover}} |
| {{Redis}} | {{PING}} | {{10s}} | {{Alerta P1, fallback in-memory}} |
| {{Stripe}} | {{GET /v1/balance}} | {{60s}} | {{Alerta P2, enfileirar pagamentos}} |
| {{Email (Resend)}} | {{GET /health}} | {{60s}} | {{Alerta P3, fallback para SES}} |

> (ver [14-tests.md](14-tests.md) para estrategia de testes)
