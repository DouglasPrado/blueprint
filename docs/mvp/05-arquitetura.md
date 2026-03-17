# Arquitetura

Esta seção define **como o sistema é construído**: quais tecnologias são usadas, como os componentes se comunicam e onde o sistema roda. Decisões de arquitetura para POC devem priorizar velocidade de desenvolvimento e simplicidade operacional.

---

## Stack

> Liste as tecnologias escolhidas para cada camada. Para cada escolha, indique brevemente o motivo.

| Camada | Tecnologia | Motivo da escolha |
| --- | --- | --- |
| Frontend | {{tecnologia}} | {{motivo em uma frase}} |
| Backend | {{tecnologia}} | {{motivo em uma frase}} |
| Banco de dados | {{tecnologia}} | {{motivo em uma frase}} |
| Autenticação | {{tecnologia / serviço}} | {{motivo em uma frase}} |
| Infra / Deploy | {{onde roda}} | {{motivo em uma frase}} |

<details>
<summary>Exemplo</summary>

| Camada | Tecnologia | Motivo da escolha |
| --- | --- | --- |
| Frontend | Next.js 14 (App Router) | SSR, rotas API integradas, deploy simples na Vercel |
| Backend | Next.js API Routes | Elimina necessidade de servidor separado na POC |
| Banco de dados | PostgreSQL (Supabase) | Relacional, hosting gratuito, auth e API REST inclusos |
| Autenticação | Supabase Auth | JWT integrado ao banco, login por e-mail/senha sem setup extra |
| Infra / Deploy | Vercel (free tier) | Deploy automático via git push, sem gerenciar servidor |

</details>

---

## Componentes

> Quais são as peças do sistema e qual a responsabilidade de cada uma? Um componente pode ser um serviço, módulo, pacote ou camada lógica.

### {{Nome do Componente}}

**Responsabilidade:** {{O que faz — uma frase}}

**Tecnologia:** {{Framework, lib ou serviço usado}}

**Comunicação:** {{Como se conecta aos outros componentes (REST, import direto, fila, etc.)}}

<!-- APPEND:componentes -->

> Repita para cada componente.

<details>
<summary>Exemplo</summary>

### App Web (Frontend)

**Responsabilidade:** Interface do usuário — telas de busca, agendamento e painel do prestador.

**Tecnologia:** Next.js 14 com React Server Components e Tailwind CSS.

**Comunicação:** Chama API Routes internas via fetch; acessa Supabase diretamente para auth.

### API Routes (Backend)

**Responsabilidade:** Lógica de negócio — validações, regras de agendamento, queries ao banco.

**Tecnologia:** Next.js API Routes (Route Handlers).

**Comunicação:** Recebe requests do frontend; conecta ao Supabase via client SDK.

### Supabase (BaaS)

**Responsabilidade:** Banco de dados, autenticação e storage.

**Tecnologia:** PostgreSQL gerenciado + Supabase Auth + Row Level Security.

**Comunicação:** Acessado pelas API Routes via Supabase JS Client.

### Serviço de E-mail

**Responsabilidade:** Enviar notificações transacionais (confirmação, lembrete, cancelamento).

**Tecnologia:** SendGrid (free tier — 100 e-mails/dia).

**Comunicação:** Chamado pelas API Routes via REST API após eventos de agendamento.

</details>

---

## Diagrama de componentes

> Represente visualmente como os componentes se conectam. Use o formato que preferir (Mermaid, ASCII, draw.io). O objetivo é que qualquer pessoa entenda o fluxo de comunicação em segundos.

```
{{Diagrama aqui — Mermaid, ASCII art ou referência a arquivo externo}}
```

<details>
<summary>Exemplo</summary>

```
┌─────────────┐     fetch      ┌──────────────┐    Supabase SDK    ┌──────────────┐
│   Browser    │ ──────────────▶│  Next.js App │ ──────────────────▶│   Supabase   │
│  (Cliente/   │◀────────────── │  (Frontend + │◀────────────────── │  (PostgreSQL │
│  Prestador)  │     JSON       │  API Routes) │                    │  + Auth)     │
└─────────────┘                 └──────┬───────┘                    └──────────────┘
                                       │
                                       │ REST API
                                       ▼
                                ┌──────────────┐
                                │   SendGrid   │
                                │   (E-mail)   │
                                └──────────────┘
```

</details>

---

## Decisões técnicas

> Quais decisões de arquitetura foram tomadas e por quê? Foque nas decisões que alguém poderia questionar — o óbvio não precisa ser documentado.

| Decisão | Alternativa descartada | Justificativa |
| --- | --- | --- |
| {{O que foi escolhido}} | {{O que foi considerado e descartado}} | {{Por quê — uma frase}} |

<!-- APPEND:decisoes-tech -->

<details>
<summary>Exemplo</summary>

| Decisão | Alternativa descartada | Justificativa |
| --- | --- | --- |
| Monólito (Next.js full-stack) | Backend separado (Express/Fastify) | POC não justifica complexidade de 2 deploys e CORS |
| Supabase em vez de banco local | Docker + PostgreSQL | Reduz setup; time não precisa gerenciar infra na POC |
| Server Components por padrão | SPA com client-side fetch | Menos JS no browser, melhor UX inicial, SEO gratuito |
| Tailwind CSS | Styled Components / CSS Modules | Produtividade maior, sem runtime CSS, bom para prototipação |
| Sem cache/Redis na POC | Redis para sessões e cache | Volume esperado não justifica; adicionar quando necessário |
| E-mail via SendGrid | SES / Resend / Mailgun | Free tier suficiente, SDK simples, sem necessidade de domínio verificado para POC |

</details>
