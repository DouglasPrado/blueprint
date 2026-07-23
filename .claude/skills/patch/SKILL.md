---
name: patch
description: Aplica alteracao em cascata nos 3 blueprints (tecnico, backend, frontend) com varredura global.
---

# Patch — Edicao Propagada em Todos os Blueprints

Aplica uma alteracao (renomear, atualizar, corrigir) em cascata por todos os documentos dos 3 blueprints. Faz varredura global, mostra o impacto e aplica patches cirurgicos com **Edit — nunca Write**.

Para adicionar uma feature ou corrigir um dado em um blueprint so, use `/increment`.

## Passo 1: Receber a Alteracao

> "Descreva a alteracao a propagar:
>
> - **O que mudar:** termo, valor ou texto atual
> - **Pelo que mudar:** novo termo, valor ou texto
> - **Contexto (opcional):** motivo da mudanca
>
> Exemplos:
> - 'Renomear entidade `Booking` para `Appointment`'
> - 'Atualizar endpoint `/api/users` para `/api/v2/users`'
> - 'Mudar Next.js 16 para Next.js 17'
> - 'Substituir Zustand por Jotai como state manager'"

Extraia `OLD_TERM`, `NEW_TERM` e `CONTEXT`.

## Passo 2: Varredura Global

Use **Grep** em todos os diretorios de documentacao:

```
docs/blueprint/*.md
docs/backend/*.md
docs/frontend/shared/*.md
docs/frontend/*/*.md          # web, mobile, desktop
docs/shared/*.md
docs/specs/*.md               # se existir
docs/adr/*.md
```

Busque todas as variacoes de case:
- **PascalCase**: `Booking`, `UserCard`
- **camelCase**: `booking`, `userCard`
- **kebab-case**: `booking`, `user-card`
- **snake/UPPER**: `booking_id`, `BOOKING`
- **Compostos**: `bookingStore`, `BookingCard`, `useBooking`, `booking-service`, `bookings` (plural)

Use regex case-insensitive para nao perder ocorrencias.

## Passo 3: Analise de Impacto

Classifique cada ocorrencia:

| Tipo | Descricao | Acao |
|------|-----------|------|
| **Direta** | Termo literal (`Booking`) | Substituir automaticamente |
| **Contextual** | Nome derivado (`bookingStore`, `BookingCard`, `useBooking`, `/api/booking`) | Substituir adaptando o case |
| **Indireta** | Prosa descritiva ("o sistema de booking permite...") | Marcar para revisao do usuario |

Apresente a tabela:

| # | Arquivo | Linha | Tipo | Antes | Depois |
|---|---------|-------|------|-------|--------|
| 1 | blueprint/04-domain-model.md | 23 | Direta | Booking | Appointment |
| 2 | backend/04-data-layer.md | 51 | Contextual | BookingRepository | AppointmentRepository |
| 3 | frontend/web/05-state.md | 45 | Contextual | bookingStore | appointmentStore |
| 4 | shared/glossary.md | 12 | Indireta | "sistema de booking" | (revisar) |

## Passo 4: Confirmacao

> "Encontrei **{{N}}** ocorrencias em **{{M}}** arquivos:
>
> - **{{X}}** diretas (aplicarei automaticamente)
> - **{{Y}}** contextuais (aplicarei com adaptacao de case)
> - **{{Z}}** indiretas (marcarei para sua revisao)
>
> | Diretorio | Arquivos | Ocorrencias |
> |-----------|----------|-------------|
> | blueprint/ | {{n}} | {{x}} |
> | backend/ | {{n}} | {{x}} |
> | frontend/ | {{n}} | {{x}} |
> | shared/ | {{n}} | {{x}} |
>
> Deseja prosseguir? Quer excluir algum arquivo ou ocorrencia?"

Aguarde confirmacao antes de aplicar.

## Passo 5: Aplicar Patches

Para cada ocorrencia confirmada: **Read** o arquivo → **Edit** com `old_string` exato → `new_string`, adaptando o case.

| Case original | Old | New |
|---------------|-----|-----|
| PascalCase | `Booking` | `Appointment` |
| camelCase | `booking` | `appointment` |
| kebab-case | `booking-card` | `appointment-card` |
| UPPER_CASE | `BOOKING` | `APPOINTMENT` |
| Composto camelCase | `bookingStore` | `appointmentStore` |
| Composto PascalCase | `BookingCard` | `AppointmentCard` |
| Prefixo `use` | `useBooking` | `useAppointment` |
| Path | `/api/booking` | `/api/appointment` |
| Diretorio de feature | `features/booking/` | `features/appointment/` |

### Regras criticas — nunca violar

- **Sempre Edit, nunca Write**
- **Uma Edit por ocorrencia** — nao agrupe substituicoes diferentes
- **Nao altere** marcadores `<!-- APPEND:... -->` nem `<!-- patch:... -->`
- **Nao altere** `{{placeholders}}` — sao template, nao dado real
- **Nao altere** blocos `<details>` de exemplo generico, a menos que o termo apareca literalmente no exemplo especifico do projeto

Para referencias indiretas, marque em vez de substituir:

```
<!-- PATCH-REVIEW: "booking" pode precisar de atualizacao neste contexto -->
```

## Passo 6: Relatorio

> "**Patch aplicado:** `{{OLD_TERM}}` → `{{NEW_TERM}}`
>
> | Diretorio | Arquivos alterados | Substituicoes |
> |-----------|-------------------|---------------|
> | blueprint/ | {{N}} | {{X}} |
> | backend/ | {{N}} | {{X}} |
> | frontend/ | {{N}} | {{X}} |
> | shared/ | {{N}} | {{X}} |
> | **Total** | **{{N}}** | **{{X}}** |
>
> **{{Z}} referencias indiretas** marcadas com `<!-- PATCH-REVIEW -->` para revisao manual:
> - `arquivo:linha` — contexto
>
> Encontre as pendentes com: `grep -rn 'PATCH-REVIEW' docs/`"

---

## Casos de Uso

| Caso | Comando | Escopo tipico |
|------|---------|--------------|
| Renomear entidade | `/patch` "Booking → Appointment" | domain, data, services, repositories, components, state, hooks |
| Atualizar endpoint | `/patch` "/api/users → /api/v2/users" | api-contracts, controllers, data-layer, api-dependencies |
| Mudar tecnologia | `/patch` "Zustand → Jotai" | frontend (state, vision, cicd), blueprint (decisions) |
| Atualizar versao | `/patch` "Next.js 16 → Next.js 17" | frontend (vision), blueprint (decisions) |
| Renomear componente | `/patch` "UserCard → ProfileCard" | frontend (components, flows, tests, copies) |
| Renomear feature | `/patch` "features/auth/ → features/identity/" | frontend (structure, components), backend (structure) |
