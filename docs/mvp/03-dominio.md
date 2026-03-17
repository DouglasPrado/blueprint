# Domínio

O modelo de domínio representa os **conceitos centrais do negócio**, suas regras e como se relacionam. Ele serve como linguagem compartilhada entre equipe técnica e stakeholders — todos devem usar os mesmos termos ao discutir o sistema.

> O modelo de domínio NÃO é o modelo de dados. Aqui focamos em **comportamento e regras de negócio**, não em tabelas e colunas.

---

## Glossário

> Quais termos do negócio precisam de definição clara para evitar ambiguidade? Liste todos os termos que alguém de fora do projeto precisaria entender.

| Termo | Definição |
| --- | --- |
| {{Termo 1}} | {{Definição em uma frase}} |
| {{Termo 2}} | {{Definição em uma frase}} |

<!-- APPEND:glossario -->

<details>
<summary>Exemplo</summary>

| Termo | Definição |
| --- | --- |
| Prestador | Profissional que oferece serviços e disponibiliza horários para agendamento |
| Cliente | Pessoa que busca e reserva horários com prestadores |
| Agendamento | Reserva de um horário específico de um prestador por um cliente |
| Slot | Unidade de tempo disponível na agenda do prestador (ex.: 30min, 1h) |
| Disponibilidade | Conjunto de slots que o prestador marcou como livres para agendamento |
| No-show | Quando o cliente não comparece ao agendamento confirmado |

</details>

---

## Entidades e atributos

> Quais são os conceitos centrais que o sistema precisa representar? Cada entidade deve ter identidade própria e atributos-chave que a descrevem.

### {{Nome da Entidade}}

**Descrição:** {{O que representa e qual seu papel no domínio}}

**Atributos-chave:**

| Atributo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| {{atributo_1}} | {{tipo}} | {{Sim/Não}} | {{descrição}} |
| {{atributo_2}} | {{tipo}} | {{Sim/Não}} | {{descrição}} |

<!-- APPEND:entidades -->

> Repita este bloco para cada entidade do domínio.

<details>
<summary>Exemplo</summary>

### Prestador

**Descrição:** Profissional que oferece serviços e gerencia sua agenda de atendimentos.

**Atributos-chave:**

| Atributo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| nome | string | Sim | Nome completo do prestador |
| email | string | Sim | E-mail para login e notificações |
| telefone | string | Não | Telefone de contato |
| servico | string | Sim | Tipo de serviço oferecido (ex.: "Corte de cabelo") |
| duracao_slot | integer | Sim | Duração padrão de cada atendimento em minutos |

### Cliente

**Descrição:** Pessoa que busca prestadores e realiza agendamentos.

**Atributos-chave:**

| Atributo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| nome | string | Sim | Nome completo |
| email | string | Sim | E-mail para login e notificações |
| telefone | string | Não | Telefone de contato |

### Agendamento

**Descrição:** Reserva de um slot específico vinculando um cliente a um prestador.

**Atributos-chave:**

| Atributo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| data_hora | datetime | Sim | Data e horário do agendamento |
| status | enum | Sim | Estado atual (confirmado, cancelado, concluído, no-show) |
| prestador | referência | Sim | Prestador vinculado |
| cliente | referência | Sim | Cliente que agendou |
| observacoes | string | Não | Notas do cliente para o prestador |

</details>

---

## Relacionamentos

> Como as entidades se conectam? Quais dependências existem entre elas?

| Entidade A | Cardinalidade | Entidade B | Descrição |
| --- | :-: | --- | --- |
| {{Entidade A}} | {{1:N / N:M / 1:1}} | {{Entidade B}} | {{Descrição do relacionamento}} |

<details>
<summary>Exemplo</summary>

| Entidade A | Cardinalidade | Entidade B | Descrição |
| --- | :-: | --- | --- |
| Prestador | 1:N | Disponibilidade | Um prestador define vários slots de disponibilidade |
| Prestador | 1:N | Agendamento | Um prestador recebe vários agendamentos |
| Cliente | 1:N | Agendamento | Um cliente pode ter vários agendamentos |
| Disponibilidade | 1:1 | Agendamento | Um slot disponível gera no máximo um agendamento |

</details>

---

## Regras de negócio

> Quais regras o sistema precisa respeitar? Regras de negócio são restrições que existem independente da tecnologia — são impostas pelo domínio, não pelo código.

- **{{ID}}:** {{Descrição da regra}}

<!-- APPEND:regras-negocio -->

> Dica: prefixe com um ID (RN1, RN2...) para facilitar referência nos fluxos e requisitos.

<details>
<summary>Exemplo</summary>

- **RN1:** Um horário só pode ser agendado se estiver marcado como disponível pelo prestador
- **RN2:** Não pode haver dois agendamentos para o mesmo prestador no mesmo horário
- **RN3:** Cancelamento pelo cliente só é permitido com mais de 24h de antecedência
- **RN4:** Após cancelamento, o slot volta a ficar disponível automaticamente
- **RN5:** O prestador pode bloquear horários mesmo que estejam marcados como disponíveis
- **RN6:** Um agendamento concluído não pode ser cancelado ou alterado

</details>
