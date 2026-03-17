# Requisitos da POC

Esta seção lista **o que a POC precisa fazer** para ter valor, organizado por prioridade. Use a classificação MoSCoW simplificada: o que é obrigatório (Must), o que é desejável (Should) e o que fica para depois.

---

## Must have

> O que **precisa** funcionar para a POC provar o conceito? Se qualquer item desta lista falhar, a POC não tem valor. Seja rigoroso — menos itens aqui significa foco maior.

- [ ] {{Requisito 1 — verbo no infinitivo + o que + critério de aceite breve}}
- [ ] {{Requisito 2}}
- [ ] {{Requisito 3}}

<!-- APPEND:must-have -->

> Dica: uma boa POC tem entre 3 e 7 requisitos must-have. Se você listou mais de 10, provavelmente está incluindo itens que são "should have".

<details>
<summary>Exemplo</summary>

- [ ] Permitir que o prestador cadastre seus horários disponíveis por dia da semana
- [ ] Permitir que o cliente visualize horários disponíveis de um prestador
- [ ] Permitir que o cliente agende um horário disponível (sem conflitos)
- [ ] Enviar e-mail de confirmação ao cliente e ao prestador após agendamento
- [ ] Permitir que o cliente cancele um agendamento com até 24h de antecedência

</details>

---

## Should have

> O que agrega valor mas **não bloqueia** a validação do conceito? Estes itens entram se sobrar tempo ou na iteração seguinte.

- [ ] {{Requisito 1}}
- [ ] {{Requisito 2}}

<!-- APPEND:should-have -->

<details>
<summary>Exemplo</summary>

- [ ] Permitir que o prestador bloqueie horários pontuais (feriados, folgas)
- [ ] Enviar lembrete por e-mail 24h antes do agendamento
- [ ] Exibir histórico de agendamentos do cliente
- [ ] Permitir reagendamento (cancelar + agendar novo horário em um fluxo)

</details>

---

## Fora do escopo

> O que **não será feito** nesta POC, mesmo que apareça no PRD ou seja pedido por stakeholders? Documentar isso protege o time de scope creep.

- {{Item futuro 1 — breve justificativa de por que fica para depois}}
- {{Item futuro 2}}

<!-- APPEND:out-of-scope -->

<details>
<summary>Exemplo</summary>

- Pagamento online — complexidade regulatória; validar o fluxo de agendamento primeiro
- App mobile nativo — browser responsivo é suficiente para a POC
- Sistema de avaliações — depende de volume de uso que a POC ainda não terá
- Multi-idioma — foco no mercado local inicialmente
- Integração com Google Calendar — será prioridade na v1, mas não na POC

</details>

---

## Requisitos não-funcionais

> Quais características de qualidade são importantes mesmo na POC? Não precisa ser exaustivo — foque no que pode inviabilizar a validação se não for atendido.

| Categoria | Requisito | Meta |
| --- | --- | --- |
| {{Performance / Segurança / Disponibilidade / Usabilidade}} | {{Descrição}} | {{Valor mensurável}} |

<details>
<summary>Exemplo</summary>

| Categoria | Requisito | Meta |
| --- | --- | --- |
| Performance | Tempo de resposta das APIs principais | < 500ms (p95) |
| Segurança | Autenticação de usuários | JWT com expiração de 24h |
| Disponibilidade | Uptime durante período de teste | 95% |
| Usabilidade | Fluxo de agendamento completo | Máximo 3 cliques após login |

</details>
