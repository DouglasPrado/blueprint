# Achados do Prototipo

O que construir a interface revelou sobre o blueprint tecnico. **Este e o segundo motivo de a fase existir:** um modelo de dominio so e testado de verdade quando alguem tenta montar um formulario com ele.

> **Regra:** achado nao se resolve aqui. Registra-se, classifica-se por risco e leva-se para `blueprint-increment` (correcao local) ou `blueprint-patch` (mudanca global). O prototipo **nao** e fonte de verdade — o blueprint tecnico e.

---

## Resumo

| Risco | Qtd | Significado |
| --- | --- | --- |
| **Alto** | {{n}} | {{Bloqueia o backend — precisa de decisao antes de `blueprint-backend`}} |
| **Medio** | {{n}} | {{Resolvivel durante a implementacao, mas melhor decidir agora}} |
| **Baixo** | {{n}} | {{Ajuste de documentacao}} |

> **Portao:** nenhum achado de risco **alto** pode permanecer aberto quando `blueprint-backend` rodar. Um contrato construido sobre uma lacuna conhecida propaga a lacuna para o schema.

---

## Lacunas do Dominio

> Campos, entidades ou relacionamentos que a interface precisou e o modelo nao tinha.

| # | Achado | Onde apareceu | O que falta | Risco | Acao |
| --- | --- | --- | --- | --- | --- |
| {{1}} | {{Lista precisa de "ativo ha 2h"}} | {{UsersPage}} | {{`User.lastSeenAt`}} | {{medio}} | {{`blueprint-increment` → `04-domain-model`}} |
| {{2}} | {{Pedido exibe nome do vendedor}} | {{OrderDetail}} | {{Relacao `Order → Seller`}} | {{alto}} | {{Decisao de produto}} |

<!-- APPEND:lacunas-dominio -->

---

## Casos de Uso que Nao Sobreviveram ao Contato com a UI

> `UC` que, ao virar tela, se mostrou incompleto, ambiguo ou impossivel.

| UC | Problema | Evidencia na tela | Risco | Acao |
| --- | --- | --- | --- | --- |
| {{UC-007}} | {{Nao diz o que acontece com itens ja pagos ao cancelar}} | {{Botao "Cancelar" sem comportamento definido}} | {{alto}} | {{`blueprint-increment` → `08-use_cases` + `09-state-models`}} |

<!-- APPEND:use-cases -->

---

## Estados Faltando ou Sobrando

> Confronto entre `09-state-models.md` e o que a interface precisou representar.

| Entidade | Achado | Tipo | Risco | Acao |
| --- | --- | --- | --- | --- |
| {{Order}} | {{UI precisa distinguir "pagamento processando" de "confirmado"}} | {{estado faltando}} | {{alto}} | {{`blueprint-increment` → `09-state-models`}} |
| {{User}} | {{`inactive` nunca aparece em tela nenhuma}} | {{estado orfao}} | {{baixo}} | {{Confirmar se e usado por worker}} |

<!-- APPEND:estados -->

---

## Regras de Negocio Descobertas

> Regras que ninguem tinha escrito e que a interface tornou obvias — normalmente ao decidir se um botao fica habilitado.

| Regra descoberta | Onde apareceu | Deve virar | Risco |
| --- | --- | --- | --- |
| {{Nao se cancela pedido ja enviado}} | {{Botao precisava de condicao}} | {{`RN-XX` em `04-domain-model` + invariante em `backend/03-domain`}} | {{alto}} |
| {{Email so editavel antes da verificacao}} | {{Campo precisava ficar readonly}} | {{`RN-XX` + validacao}} | {{medio}} |

<!-- APPEND:regras -->

> **Por que isto e valioso:** uma regra descoberta aqui custa uma linha de documento. A mesma regra descoberta depois do lancamento custa uma migracao, um incidente ou um cliente.

---

## Problemas de Desenho da API

> Descobertos ao consumir o contrato proposto.

| Problema | Evidencia | Proposta | Risco |
| --- | --- | --- | --- |
| {{Dashboard precisa de 5 chamadas}} | {{5 skeletons independentes piscando}} | {{Endpoint agregado ou BFF}} | {{medio}} |
| {{Lista devolve objeto completo mas usa 3 campos}} | {{Payload de 40KB para renderizar 3 colunas}} | {{DTO reduzido na listagem}} | {{medio}} |
| {{Sem ordenacao estavel}} | {{Item pula de pagina ao paginar}} | {{Ordenacao por chave unica como desempate}} | {{alto}} |

<!-- APPEND:api -->

---

## Contradicoes entre Documentos

> Onde dois documentos do blueprint discordam e a interface obrigou a escolher.

| Documento A | Documento B | Contradicao | Escolha do prototipo | Acao |
| --- | --- | --- | --- | --- |
| {{08-use_cases}} | {{09-state-models}} | {{UC cita gatilho que nao existe na maquina}} | {{Seguiu a maquina}} | {{`blueprint-increment` no UC}} |

<!-- APPEND:contradicoes -->

---

## Suposicoes do Prototipo

> Onde o prototipo decidiu algo por conta propria para poder seguir. Cada linha e uma decisao a confirmar — a mesma disciplina de `docs/ASSUMPTIONS.md`.

| Suposicao | Base | Risco | Quem confirma |
| --- | --- | --- | --- |
| {{Paginacao de 20 itens}} | {{Padrao do repositorio}} | {{baixo}} | {{Produto}} |
| {{Busca por nome e email}} | {{Inferido da tela}} | {{medio}} | {{Produto}} |

<!-- APPEND:suposicoes -->

---

## Encaminhamento

> Cada achado precisa de destino. Achado sem destino vira folclore.

| # | Achado | Destino | Comando | Status |
| --- | --- | --- | --- | --- |
| {{1}} | {{`User.lastSeenAt`}} | {{`blueprint/04-domain-model`}} | {{`blueprint-increment`}} | {{aberto}} |
| {{2}} | {{Renomear `Booking` → `Appointment`}} | {{todos os blueprints}} | {{`blueprint-patch`}} | {{aberto}} |

<!-- APPEND:encaminhamento -->

**Checklist antes de rodar `blueprint-backend`:**

- [ ] Todo achado de risco **alto** esta resolvido ou tem decisao registrada
- [ ] As lacunas de dominio viraram `blueprint-increment` aplicado, nao anotacao
- [ ] As regras de negocio descobertas estao em `04-domain-model.md` com `RN-XX`
- [ ] As contradicoes foram resolvidas no documento fonte, nao so no prototipo
- [ ] [`03-api-requirements.md`](03-api-requirements.md) foi regenerado apos as correcoes
