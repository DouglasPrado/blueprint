# Visao do Prototipo

Define o que o prototipo e, o que ele deliberadamente nao e, e quais criterios precisam ser satisfeitos antes de a fase de backend comecar.

> O prototipo e um **frontend completo e navegavel com dados mockados**. Ele existe para uma unica finalidade: **descobrir o contrato de API construindo a interface, em vez de inventa-lo antes dela**.

---

## Por que o prototipo vem antes do backend

> Qual problema esta fase resolve?

Um contrato de API escrito antes da interface e uma previsao. Um contrato extraido de uma interface que funciona e uma **observacao**.

| Sem prototipo | Com prototipo |
| --- | --- |
| O backend expoe o que o modelo de dominio sugere | O backend expoe o que a tela precisa |
| Campos sobrando (nunca consumidos) e faltando (descobertos no fim) | Cada campo tem um consumidor nomeado |
| Numero de chamadas por tela descoberto em producao | Numero de chamadas por tela conhecido antes da primeira linha de backend |
| Estados de erro inventados | Estados de erro derivados do que a UI precisa exibir |
| Lacuna do dominio aparece durante a implementacao | Lacuna do dominio aparece ao montar o formulario |

**Custo assumido:** construir a UI duas vezes — uma mockada, outra integrada. **Beneficio:** o backend nasce com consumidor real e o retrabalho acontece em codigo descartavel, nao em schema de producao.

---

## O que e real e o que e mockado

> Tudo que nao for explicitamente marcado como real deve ser mockado. A regra evita que o prototipo vire meio-produto.

| Camada | No prototipo | Justificativa |
| --- | --- | --- |
| Telas e navegacao | **Real** | E o objeto de estudo |
| Componentes e design system | **Real** | Reaproveitado na implementacao final |
| Estados de interface (loading, vazio, erro) | **Real** | Definem os erros que o backend precisa emitir |
| Validacao de formulario | **Real** | Vira `docs/backend/10-validation.md` |
| Dados | **Mockado** | {{MSW / fixtures em memoria / json-server}} |
| Autenticacao | **Mockado** | {{Sessao falsa com troca de persona}} |
| Autorizacao | **Mockado, mas exercida** | Cada persona ve o que sua role permite — define a matriz RBAC |
| Persistencia | **Mockado** | {{Estado em memoria, reset a cada reload}} |
| Integracoes externas | **Mockado** | {{Pagamento, email, storage — respostas fixas}} |
| Tempo real (WebSocket, push) | {{Mockado / fora de escopo}} | {{Justificativa}} |

<!-- APPEND:camadas -->

---

## Stack do Prototipo

> A stack do prototipo deve ser a **mesma** da implementacao final. Prototipo em outra stack nao produz componentes reaproveitaveis nem revela as restricoes reais do framework.

| Camada | Tecnologia | Igual a final? |
| --- | --- | --- |
| Framework | {{Next.js / Expo / Electron}} | {{sim}} |
| UI | {{React}} | {{sim}} |
| Estado | {{Zustand / TanStack Query}} | {{sim}} |
| Styling | {{Tailwind + design system}} | {{sim}} |
| Mock de API | {{MSW — Mock Service Worker}} | **nao — descartado na integracao** |
| Dados | {{Fixtures TypeScript tipadas}} | **nao — viram seed do backend** |

<!-- APPEND:stack -->

> **Por que MSW (ou equivalente que intercepta HTTP):** o mock vive na camada de rede, nao dentro dos componentes. Assim o codigo da aplicacao ja faz `fetch` real e a integracao consiste em **desligar o mock**, nao em reescrever a camada de dados.

---

## Criterios de Saida

> O prototipo esta pronto para a fase de backend quando TODOS os itens abaixo forem verdadeiros. Ate la, `blueprint-backend` nao deve rodar.

- [ ] Todo caso de uso `UC-XXX` de `blueprint/08-use_cases.md` tem tela correspondente em `01-screens.md`
- [ ] Todo fluxo critico de `blueprint/07-critical_flows.md` e percorrivel ponta a ponta no app
- [ ] Toda tela tem os quatro estados implementados: carregando, vazio, erro, sucesso
- [ ] Toda transicao de `blueprint/09-state-models.md` ou tem gatilho na interface, ou tem causa registrada em `04-interaction-states.md` (acao de sistema, backoffice fora de escopo, ou lacuna)
- [ ] Cada persona de `02-mock-data.md` consegue navegar e ve apenas o que sua role permite
- [ ] Todo formulario valida na borda e exibe erro por campo
- [ ] `03-api-requirements.md` foi extraido do codigo, nao escrito a mao
- [ ] `05-findings.md` esta preenchido e as lacunas de risco alto foram levadas ao `blueprint-increment`

---

## Nao-objetivos

> O que o prototipo deliberadamente NAO faz. Cada item aqui e uma tentacao real de escopo.

- {{Nao persiste dados entre sessoes — recarregar zera o estado}}
- {{Nao implementa regra de negocio no cliente — a regra e do backend; aqui so se exibe o resultado}}
- {{Nao otimiza performance — bundle, cache e lazy loading sao da fase final}}
- {{Nao cobre acessibilidade completa — so o que o design system ja entrega}}
- {{Nao tem testes E2E — os testes vem com a implementacao real}}
- {{Nao e deployado para usuario final — no maximo um preview interno}}

<!-- APPEND:nao-objetivos -->

> **A tentacao mais perigosa:** transformar o mock em backend. Se o mock comecar a ter regra de negocio, transacao ou calculo derivado, ele virou um segundo backend que ninguem vai manter. Quando isso acontecer, a regra pertence a `docs/backend/06-services.md`.

---

## Lugar na cadeia

```
blueprint tecnico (17 docs)        o QUE o sistema faz
        │
        ▼
frontend/shared/03-design-system   como o sistema se parece
        │
        ▼
PROTOTIPO  ──────────────────────► docs/prototype/ (6 docs)
  frontend completo, mockado              │
        │                                 │
        │                                 ▼
        │                    03-api-requirements.md
        │                    o contrato DESCOBERTO
        │                                 │
        ▼                                 ▼
docs/backend/ (15 docs)  ◄────────────────┘
  agora com consumidor real para cada endpoint
        │
        ▼
docs/frontend/ (especificacao da implementacao final)
```

> (ver [01-screens.md](01-screens.md) para o inventario de telas)
