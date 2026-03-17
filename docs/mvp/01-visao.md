# Visão

Esta seção captura o **porquê** do sistema existir. Define o problema, a solução proposta e como saberemos se a POC teve sucesso.

---

## Problema

> Qual dor ou ineficiência existe hoje? Quem sofre com isso? Seja específico — um problema bem definido guia todas as decisões seguintes.

{{Descreva o problema central em 2-3 frases. Inclua quem é afetado e qual o impacto atual.}}

<details>
<summary>Exemplo</summary>

Prestadores de serviço (barbeiros, dentistas, personal trainers) gerenciam agendamentos por WhatsApp e caderneta. Isso gera conflitos de horário, esquecimentos e perda de clientes. Clientes não têm visibilidade da disponibilidade real e desistem ao não conseguir agendar rapidamente.

</details>

---

## Solução

> Em uma frase, o que o sistema faz para resolver o problema descrito acima?

{{Uma frase clara no formato: "O sistema permite que [quem] faça [o quê] de forma [como], resolvendo [qual problema]."}}

<details>
<summary>Exemplo</summary>

O sistema permite que clientes visualizem a disponibilidade real de prestadores e agendem horários online em tempo real, eliminando conflitos e a dependência de comunicação manual.

</details>

---

## Público-alvo

> Para quem é esta solução? Descreva as personas principais e suas necessidades.

| Persona | Necessidade principal | Frequência de uso |
| --- | --- | --- |
| {{Persona 1}} | {{O que precisa resolver}} | {{Diário / Semanal / Eventual}} |
| {{Persona 2}} | {{O que precisa resolver}} | {{Diário / Semanal / Eventual}} |

<details>
<summary>Exemplo</summary>

| Persona | Necessidade principal | Frequência de uso |
| --- | --- | --- |
| Prestador autônomo | Organizar agenda sem conflitos e reduzir no-shows | Diário |
| Cliente final | Encontrar horário disponível e agendar sem ligar/mandar mensagem | Semanal |

</details>

---

## Métricas de sucesso da POC

> Como saberemos que a POC deu certo? Defina métricas concretas e mensuráveis. Evite métricas vagas como "boa experiência do usuário".

| Métrica | Meta | Como medir |
| --- | --- | --- |
| {{Métrica 1}} | {{Valor alvo}} | {{Forma de medição}} |
| {{Métrica 2}} | {{Valor alvo}} | {{Forma de medição}} |

<!-- APPEND:metricas-sucesso -->

> Dica: para uma POC, 2-4 métricas são suficientes. Foque no que prova que o conceito funciona.

<details>
<summary>Exemplo</summary>

| Métrica | Meta | Como medir |
| --- | --- | --- |
| Agendamentos concluídos | 50 agendamentos reais na primeira semana | Contagem no banco de dados |
| Taxa de conflitos de horário | 0% | Logs de tentativas de agendamento duplicado |
| Tempo médio para agendar | < 2 minutos do início ao fim | Tracking de timestamps (criação vs. confirmação) |
| Taxa de cancelamento | < 20% | Proporção cancelamentos / agendamentos criados |

</details>

---

## Não-objetivos

> O que este sistema deliberadamente NÃO resolve nesta POC? Listar não-objetivos evita que o escopo cresça silenciosamente.

- {{Não-objetivo 1 — ex.: "Não substitui o sistema X existente"}}
- {{Não-objetivo 2 — ex.: "Não atende o perfil de usuário Y"}}

<!-- APPEND:objetivos -->

<details>
<summary>Exemplo</summary>

- Não substitui agendas corporativas (Google Calendar, Outlook) — é complementar
- Não resolve gestão financeira do prestador (controle de receita, impostos)
- Não oferece marketplace com busca por localização na POC
- Não atende clínicas com múltiplas salas/recursos simultâneos

</details>
