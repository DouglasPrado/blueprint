# Dados Mockados

Define o dataset que alimenta o prototipo: personas, fixtures por entidade e cenarios de teste. Este documento tem uma segunda vida — **as fixtures viram os seeds do backend**, e as personas viram os usuarios de teste dos ambientes de desenvolvimento e staging.

> **Deriva de:** [`blueprint/04-domain-model.md`](../blueprint/04-domain-model.md) (entidades e atributos) e [`blueprint/09-state-models.md`](../blueprint/09-state-models.md) (estados a representar).
> **Alimenta:** `docs/backend/04-data-layer.md` (seeds) e `docs/backend/14-tests.md` (fixtures de teste).

---

## Estrategia de Mock

> Onde o mock vive determina quanto trabalho a integracao com o backend real vai dar.

| Aspecto | Decisao | Consequencia na integracao |
| --- | --- | --- |
| **Camada do mock** | {{Interceptacao HTTP (MSW)}} | {{Desligar o worker; o codigo da app nao muda}} |
| **Formato das fixtures** | {{TypeScript tipado com os tipos de `src/types/`}} | {{Compilador acusa divergencia. Durante o prototipo os tipos vivem em `src/types/` — `src/contracts/` so nasce no `blueprint-codegen-setup`}} |
| **Persistencia** | {{Em memoria, reset no reload}} | {{Nenhuma — descartavel}} |
| **Latencia simulada** | {{{{200-600}}ms aleatorio}} | {{Estados de loading aparecem de verdade}} |
| **Taxa de erro injetada** | {{Rota de debug liga erro por endpoint}} | {{Estados de erro testaveis sem derrubar nada}} |

<!-- APPEND:estrategia -->

> **Regra:** o mock responde, ele nao decide. Toda regra de negocio — calculo de total, validacao de invariante, transicao condicional — pertence ao backend. O mock devolve o resultado ja pronto. Se o mock precisar calcular para responder, isso e um sinal: [`05-findings.md`](05-findings.md) ganhou uma entrada.

---

## Personas de Teste

> Uma persona por perfil de acesso, no minimo. O prototipo precisa de um seletor de persona para exercitar a matriz de permissoes sem tela de login real.

| Persona | Role | Estado da conta | O que ela consegue ver e fazer | Serve para testar |
| --- | --- | --- | --- | --- |
| {{ana@exemplo.com}} | {{admin}} | {{active}} | {{Tudo}} | {{Telas administrativas, acoes destrutivas}} |
| {{bruno@exemplo.com}} | {{manager}} | {{active}} | {{Recursos do proprio time}} | {{Filtro por `team_id`, ownership parcial}} |
| {{carla@exemplo.com}} | {{user}} | {{active}} | {{Apenas os proprios dados}} | {{Ownership, 404 em recurso alheio}} |
| {{diego@exemplo.com}} | {{user}} | {{created}} | {{Onboarding pendente}} | {{Fluxo de ativacao, estado bloqueado}} |
| {{erika@exemplo.com}} | {{user}} | {{suspended}} | {{Acesso negado com motivo}} | {{Mensagem de conta suspensa}} |

<!-- APPEND:personas -->

> **Por que isso importa para o backend:** esta tabela e o primeiro rascunho verificavel da matriz de `docs/backend/11-permissions.md`. Se a UI mostra um botao que a persona nao deveria poder clicar, a matriz esta errada — e e melhor descobrir aqui.

---

## Fixtures por Entidade

> Para CADA entidade de `04-domain-model.md`, defina o conjunto minimo que cobre os estados e as bordas.

### {{Entidade}}

| Quantidade | Distribuicao | Motivo |
| --- | --- | --- |
| {{24 registros}} | {{18 `active`, 3 `suspended`, 3 `inactive`}} | {{Cobre a maquina de estados e enche 2 paginas de 20}} |

**Casos de borda obrigatorios** — o que quebra layout e revela suposicao:

| Caso | Exemplo | O que revela |
| --- | --- | --- |
| {{Texto no limite}} | {{Nome com 100 caracteres}} | {{Truncamento, quebra de linha}} |
| {{Texto vazio ou nulo}} | {{Sem avatar, sem telefone}} | {{Fallbacks, campos opcionais reais}} |
| {{Numero extremo}} | {{Total de R$ 1.234.567,89 e R$ 0,00}} | {{Formatacao de moeda, alinhamento}} |
| {{Caractere especial}} | {{Nome com acento, emoji, aspas}} | {{Encoding, escape}} |
| {{Data limite}} | {{Criado hoje, criado ha 3 anos}} | {{Formato relativo vs absoluto}} |
| {{Relacionamento vazio}} | {{Pedido sem itens}} | {{Estado vazio dentro de um registro}} |

<!-- APPEND:fixtures -->

> Repita para cada entidade.

---

## Cenarios

> Estados globais do dataset que o prototipo precisa conseguir assumir sob demanda. Sem isso, so o caminho feliz e visto.

| Cenario | Como acionar | Estado do dataset | Telas afetadas |
| --- | --- | --- | --- |
| {{Conta nova}} | {{Persona `diego`}} | {{Zero registros em tudo}} | {{Todos os empty states}} |
| {{Uso normal}} | {{Padrao}} | {{Volume medio}} | {{Todas}} |
| {{Volume alto}} | {{`?scenario=bulk`}} | {{500+ registros}} | {{Paginacao, busca, virtualizacao}} |
| {{Falha de rede}} | {{`?scenario=offline`}} | {{Todas as chamadas falham}} | {{Estados de erro e retry}} |
| {{Lentidao}} | {{`?scenario=slow`}} | {{Latencia de 3s}} | {{Skeletons, timeouts}} |
| {{Sessao expirada}} | {{`?scenario=expired`}} | {{Toda chamada responde 401}} | {{Refresh e redirect para login}} |

<!-- APPEND:cenarios -->

---

## Caminho para o Seed do Backend

> As fixtures nao sao descartadas na integracao. Elas migram.

| Fixture do prototipo | Vira | Onde |
| --- | --- | --- |
| Personas | {{Usuarios de seed de dev e staging}} | {{`docs/backend/04-data-layer.md` — seeds}} |
| Casos de borda | {{Fixtures de teste}} | {{`docs/backend/14-tests.md`}} |
| Cenario de volume alto | {{Dataset de teste de carga}} | {{`blueprint/12-testing_strategy.md` — load}} |
| Distribuicao de estados | {{Verificacao da maquina de estados}} | {{`docs/backend/03-domain.md`}} |

> **Regra do repositorio:** seed nunca em producao (`docs/backend/04-data-layer.md`). As personas existem em dev e staging; em producao, ninguem.

> (ver [03-api-requirements.md](03-api-requirements.md) para o contrato que estas chamadas mockadas revelaram)
