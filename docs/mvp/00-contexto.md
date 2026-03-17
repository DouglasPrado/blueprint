# Contexto do Sistema

Esta seção estabelece **o que é o sistema, quem o usa e onde ele termina**. É o ponto de partida para alinhar todos sobre o escopo da POC antes de entrar em detalhes técnicos.

---

## O que é

> Descreva o sistema em uma única frase. O que ele faz e para quem?

{{Uma frase clara descrevendo o propósito do sistema e seu público principal.}}

<details>
<summary>Exemplo</summary>

Sistema de agendamento online que permite clientes reservarem horários com prestadores de serviço.

</details>

---

## Quem usa

> Quem interage com o sistema? Liste pessoas, sistemas ou dispositivos que participam dos fluxos principais.

| Ator | Tipo | O que faz no sistema |
| --- | --- | --- |
| {{Ator 1}} | {{Pessoa / Sistema / Dispositivo}} | {{Ação principal no sistema}} |
| {{Ator 2}} | {{Pessoa / Sistema / Dispositivo}} | {{Ação principal no sistema}} |

<!-- APPEND:atores -->

<details>
<summary>Exemplo</summary>

| Ator | Tipo | O que faz no sistema |
| --- | --- | --- |
| Cliente | Pessoa | Busca prestadores, agenda horários, cancela agendamentos |
| Prestador | Pessoa | Configura disponibilidade, confirma/recusa agendamentos |
| Admin | Pessoa | Gerencia cadastros e configurações gerais |

</details>

---

## Sistemas externos

> Com quais serviços, APIs ou ferramentas externas o sistema precisa se integrar para a POC funcionar?

| Sistema | Tipo de integração | Função |
| --- | --- | --- |
| {{Sistema 1}} | {{REST API / Webhook / SDK / SMTP / etc.}} | {{O que faz para o sistema}} |
| {{Sistema 2}} | {{REST API / Webhook / SDK / SMTP / etc.}} | {{O que faz para o sistema}} |

<!-- APPEND:sistemas-externos -->

> Se a POC não tem integrações externas, escreva "Nenhuma integração externa na POC."

<details>
<summary>Exemplo</summary>

| Sistema | Tipo de integração | Função |
| --- | --- | --- |
| Google Calendar | REST API (OAuth2) | Sincroniza disponibilidade do prestador |
| SendGrid | REST API | Envia e-mails de confirmação e lembrete |
| Stripe | SDK | Processa pagamento no momento do agendamento |

</details>

---

## Limites da POC

> O que está **fora** do escopo desta POC? Listar os limites evita expectativas desalinhadas e scope creep.

**A POC inclui:**

- {{Capacidade 1 que será implementada}}
- {{Capacidade 2 que será implementada}}

**A POC NÃO inclui:**

- {{Item fora do escopo 1}}
- {{Item fora do escopo 2}}

<details>
<summary>Exemplo</summary>

**A POC inclui:**

- Cadastro de prestadores e clientes
- Agendamento com escolha de horário disponível
- Notificação por e-mail de confirmação

**A POC NÃO inclui:**

- App mobile nativo
- Sistema de avaliação/review
- Pagamento recorrente (assinaturas)
- Integração com múltiplos gateways de pagamento
- Painel administrativo completo

</details>

---

## Restrições e premissas

> Quais limitações técnicas, de negócio ou de prazo influenciam as decisões? Quais premissas estão sendo assumidas como verdadeiras?

**Restrições:**

| Tipo | Descrição |
| --- | --- |
| {{Técnica / Negócio / Prazo}} | {{Descrição da restrição}} |

<!-- APPEND:restricoes -->

**Premissas:**

- {{Premissa 1 — ex.: "O prestador terá no máximo 50 agendamentos por dia."}}
- {{Premissa 2 — ex.: "O time tem experiência com a stack escolhida."}}

> Se alguma premissa se provar falsa, quais decisões precisariam ser revisitadas?

<details>
<summary>Exemplo</summary>

**Restrições:**

| Tipo | Descrição |
| --- | --- |
| Prazo | POC precisa estar funcional em 4 semanas |
| Técnica | Time só tem experiência com Node.js e PostgreSQL |
| Negócio | Sem orçamento para serviços pagos além de Stripe |

**Premissas:**

- Cada prestador atende no máximo 20 clientes por dia
- Apenas um tipo de serviço por prestador na POC
- Usuários acessam via browser desktop (responsivo é desejável mas não obrigatório)

</details>
