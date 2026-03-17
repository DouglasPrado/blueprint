# Fluxos Críticos

Esta seção documenta os **2-3 fluxos mais importantes** da POC — aqueles que, se falharem, invalidam a prova de conceito. Cada fluxo descreve o caminho feliz passo a passo e os principais cenários de erro.

> Foque nos fluxos que exercitam os requisitos must-have. Se um fluxo não está ligado a um must-have, ele provavelmente não é crítico para a POC.

---

## Fluxo: {{Nome do Fluxo}}

**Descrição:** {{O que este fluxo realiza e por que é crítico — 1-2 frases.}}

**Atores envolvidos:** {{Quem participa deste fluxo}}

**Pré-condições:** {{O que precisa ser verdade antes do fluxo começar}}

### Caminho feliz

> Descreva o fluxo passo a passo. Cada passo deve ter um ator ou componente claro e uma ação específica.

1. {{Ator/Componente}} {{realiza ação}}
2. {{Ator/Componente}} {{realiza ação}}
3. {{Ator/Componente}} {{realiza ação}}

**Resultado esperado:** {{O que acontece quando o fluxo termina com sucesso}}

### Erros e exceções

> Quais são os pontos de falha? Para cada erro, descreva o que acontece e como o sistema se comporta.

| Passo | Falha possível | Comportamento do sistema |
| --- | --- | --- |
| {{N}} | {{O que pode dar errado}} | {{Como o sistema reage — retry, fallback, mensagem ao usuário, etc.}} |

### Regras de negócio aplicáveis

> Quais regras de negócio (do documento de Domínio) são exercitadas neste fluxo?

- {{RN_ID}}: {{Descrição breve}}

<!-- APPEND:fluxos -->

> Repita o template acima para cada fluxo crítico (máximo 3 para POC).

---

<details>
<summary>Exemplo completo: Fluxo de Agendamento</summary>

## Fluxo: Realizar Agendamento

**Descrição:** Cliente seleciona um prestador, escolhe horário disponível e confirma o agendamento. É o fluxo central da POC — sem ele, o sistema não tem valor.

**Atores envolvidos:** Cliente, App Web, API Routes, Supabase, SendGrid

**Pré-condições:** Cliente está autenticado; Prestador tem disponibilidade cadastrada.

### Caminho feliz

1. **Cliente** acessa a página do prestador e visualiza os horários disponíveis da semana
2. **App Web** consulta a API para buscar disponibilidades do prestador filtrando agendamentos já existentes
3. **API Routes** consulta Supabase: cruza `disponibilidades` com `agendamentos` (status=confirmado) para retornar apenas slots livres
4. **Cliente** seleciona um horário e clica em "Agendar"
5. **App Web** envia request POST para a API com prestador_id, data_hora e observações
6. **API Routes** valida: (a) slot existe e está disponível, (b) não há conflito de horário, (c) data_hora é futura
7. **API Routes** cria registro em `agendamentos` com status "confirmado" dentro de uma transação
8. **API Routes** dispara e-mail de confirmação via SendGrid para cliente e prestador
9. **App Web** exibe confirmação com detalhes do agendamento

**Resultado esperado:** Agendamento criado com status "confirmado"; cliente e prestador recebem e-mail; slot não aparece mais como disponível.

### Erros e exceções

| Passo | Falha possível | Comportamento do sistema |
| --- | --- | --- |
| 3 | Supabase indisponível | Retorna 503; frontend exibe "Tente novamente em instantes" |
| 6 | Slot já foi agendado por outro cliente (race condition) | Constraint unique no banco rejeita; API retorna 409; frontend pede para escolher outro horário |
| 6 | Data/hora no passado | API retorna 400 com mensagem "Horário não disponível" |
| 8 | SendGrid falha no envio | Agendamento é mantido (e-mail não é bloqueante); erro logado para retry manual |

### Regras de negócio aplicáveis

- **RN1:** Horário só pode ser agendado se estiver marcado como disponível
- **RN2:** Não pode haver dois agendamentos para o mesmo prestador no mesmo horário

</details>

---

<details>
<summary>Exemplo completo: Fluxo de Cancelamento</summary>

## Fluxo: Cancelar Agendamento

**Descrição:** Cliente cancela um agendamento existente. Importante para liberar o slot e notificar o prestador.

**Atores envolvidos:** Cliente, App Web, API Routes, Supabase, SendGrid

**Pré-condições:** Cliente está autenticado; Agendamento existe com status "confirmado".

### Caminho feliz

1. **Cliente** acessa "Meus Agendamentos" e clica em "Cancelar" no agendamento desejado
2. **App Web** exibe modal de confirmação: "Tem certeza que deseja cancelar?"
3. **Cliente** confirma o cancelamento
4. **App Web** envia request PATCH para a API com agendamento_id e novo status "cancelado"
5. **API Routes** valida: (a) agendamento pertence ao cliente, (b) faltam mais de 24h para o horário
6. **API Routes** atualiza status para "cancelado" no Supabase
7. **API Routes** dispara e-mail de cancelamento via SendGrid para cliente e prestador
8. **App Web** exibe confirmação de cancelamento e remove da lista

**Resultado esperado:** Agendamento com status "cancelado"; slot volta a aparecer como disponível; ambos notificados por e-mail.

### Erros e exceções

| Passo | Falha possível | Comportamento do sistema |
| --- | --- | --- |
| 5 | Faltam menos de 24h para o agendamento | API retorna 422; frontend exibe "Cancelamento não permitido com menos de 24h de antecedência" |
| 5 | Agendamento não pertence ao cliente | API retorna 403; frontend exibe mensagem genérica de erro |
| 7 | SendGrid falha | Cancelamento é mantido; erro logado |

### Regras de negócio aplicáveis

- **RN3:** Cancelamento só é permitido com mais de 24h de antecedência
- **RN4:** Após cancelamento, o slot volta a ficar disponível automaticamente

</details>
