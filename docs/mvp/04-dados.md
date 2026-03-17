# Dados

Esta seção define **como e onde os dados são armazenados** na POC. Traduz o modelo de domínio em estruturas concretas de persistência — tabelas, colunas, tipos e relacionamentos no banco.

> Este é o modelo de dados, não o modelo de domínio. Aqui focamos em **estrutura de armazenamento**, não em comportamento.

---

## Tecnologia escolhida

> Qual banco de dados ou storage será usado na POC? Justifique a escolha em uma frase.

**Banco:** {{Nome da tecnologia (ex.: PostgreSQL, MongoDB, SQLite, Supabase)}}

**Justificativa:** {{Por que essa tecnologia e não outra — considere experiência do time, custo, complexidade e fit com o problema}}

<details>
<summary>Exemplo</summary>

**Banco:** PostgreSQL (via Supabase)

**Justificativa:** Dados relacionais com integridade referencial (agendamentos dependem de prestador e cliente); Supabase oferece hosting gratuito, auth integrado e API REST automática, reduzindo tempo de setup.

</details>

---

## Schema principal

> Defina as tabelas/collections essenciais com seus campos. Para cada tabela, liste: nome do campo, tipo, se é obrigatório e uma descrição breve.

### {{nome_da_tabela}}

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| id | {{uuid / serial / etc.}} | PK | Identificador único |
| {{campo_1}} | {{tipo}} | {{Sim/Não}} | {{descrição}} |
| {{campo_2}} | {{tipo}} | {{Sim/Não}} | {{descrição}} |
| created_at | timestamp | Sim | Data de criação |
| updated_at | timestamp | Sim | Data da última atualização |

<!-- APPEND:tabelas -->

> Repita este bloco para cada tabela. Indique FKs com o formato `nome_tabela_id (FK → tabela)`.

<details>
<summary>Exemplo</summary>

### prestadores

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| id | uuid | PK | Identificador único |
| nome | varchar(255) | Sim | Nome completo |
| email | varchar(255) | Sim, único | E-mail para login |
| telefone | varchar(20) | Não | Telefone de contato |
| servico | varchar(255) | Sim | Tipo de serviço oferecido |
| duracao_slot | integer | Sim | Duração padrão do atendimento em minutos |
| created_at | timestamp | Sim | Data de criação |
| updated_at | timestamp | Sim | Última atualização |

### clientes

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| id | uuid | PK | Identificador único |
| nome | varchar(255) | Sim | Nome completo |
| email | varchar(255) | Sim, único | E-mail para login |
| telefone | varchar(20) | Não | Telefone de contato |
| created_at | timestamp | Sim | Data de criação |
| updated_at | timestamp | Sim | Última atualização |

### disponibilidades

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| id | uuid | PK | Identificador único |
| prestador_id | uuid | FK → prestadores | Prestador dono deste slot |
| dia_semana | integer (0-6) | Sim | Dia da semana (0=domingo) |
| hora_inicio | time | Sim | Início do slot |
| hora_fim | time | Sim | Fim do slot |
| ativo | boolean | Sim | Se o slot está disponível |
| created_at | timestamp | Sim | Data de criação |

### agendamentos

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | :-: | --- |
| id | uuid | PK | Identificador único |
| prestador_id | uuid | FK → prestadores | Prestador vinculado |
| cliente_id | uuid | FK → clientes | Cliente que agendou |
| data_hora | timestamp | Sim | Data e horário do agendamento |
| status | enum | Sim | confirmado, cancelado, concluido, no_show |
| observacoes | text | Não | Notas do cliente |
| created_at | timestamp | Sim | Data de criação |
| updated_at | timestamp | Sim | Última atualização |

</details>

---

## Índices

> Quais consultas serão frequentes? Crie índices para otimizar as queries mais críticas da POC.

| Tabela | Campos | Tipo | Justificativa |
| --- | --- | --- | --- |
| {{tabela}} | {{campo(s)}} | {{btree / unique / composite}} | {{Query que este índice otimiza}} |

<details>
<summary>Exemplo</summary>

| Tabela | Campos | Tipo | Justificativa |
| --- | --- | --- | --- |
| agendamentos | prestador_id, data_hora | composite | Buscar agendamentos de um prestador por data |
| agendamentos | prestador_id, data_hora, status | unique (where status='confirmado') | Garantir que não há conflito de horário |
| disponibilidades | prestador_id, dia_semana | composite | Listar disponibilidade de um prestador por dia |
| clientes | email | unique | Login e busca por e-mail |
| prestadores | email | unique | Login e busca por e-mail |

</details>

---

## Decisões

> Quais decisões de modelagem foram tomadas e por quê? Documente trade-offs importantes.

| Decisão | Justificativa |
| --- | --- |
| {{O que foi decidido}} | {{Por que — em uma frase}} |

<!-- APPEND:decisoes-dados -->

<details>
<summary>Exemplo</summary>

| Decisão | Justificativa |
| --- | --- |
| UUID como PK em vez de serial | Facilita sincronização futura e evita exposição de sequência |
| Status como enum no banco | Poucas transições possíveis; enum garante integridade sem tabela auxiliar |
| Disponibilidade por dia da semana (não por data) | POC foca em agenda recorrente; exceções (feriados) ficam para v1 |
| Soft delete não implementado | Complexidade desnecessária para POC; agendamentos cancelados mudam status |
| Timestamps em UTC | Evita problemas de fuso horário; conversão feita no frontend |

</details>
