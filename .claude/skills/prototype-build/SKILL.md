---
name: prototype-build
description: Fase B do prototipo — constroi o frontend completo e mockado no projeto-alvo, tela por tela, com portao de cobertura.
---

# Prototipo — Fase B: Construcao

Constroi o app mockado no projeto-alvo, seguindo o plano de `docs/prototype/`. Produz **codigo**, nao documento.

```
/prototype-build [cliente] [projeto-alvo]

/prototype-build web ../meu-saas/
/prototype-build web ../meu-saas/ --telas OrdersPage,OrderDetail   # subconjunto
```

## Pre-requisitos

| Verificacao | Se falhar |
|---|---|
| `docs/prototype/01-screens.md` sem `{{placeholders}}` | "Rode `/prototype` primeiro." **pare** |
| `docs/prototype/02-mock-data.md` sem `{{placeholders}}` | "Rode `/prototype` primeiro." **pare** |
| `docs/frontend/shared/03-design-system.md` preenchido | "Rode `/frontend-design-system` primeiro." **pare** |
| Projeto-alvo informado | Pergunte uma vez: "Onde o prototipo deve ser gerado? (ex: `../meu-saas/`)" |
| `git status` limpo no projeto-alvo | "Commite ou de stash — o build commita por tela e precisa de base limpa." **pare** |

## Contexto

- `docs/prototype/00-prototype-vision.md` — stack e o que e mockado
- `docs/prototype/01-screens.md` — **o plano de construcao**
- `docs/prototype/02-mock-data.md` — personas, fixtures, cenarios
- `docs/frontend/shared/03-design-system.md` — tokens, tipografia, componentes base
- `docs/blueprint/04-domain-model.md` — tipos das entidades
- `docs/blueprint/09-state-models.md` — estados e transicoes a representar
- `docs/shared/glossary.md` — linguagem ubiqua: nomes de componente e de campo saem daqui

> **Versoes:** toda tecnologia com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`. Framework desatualizado gera prototipo que nao compila.

---

## Passo 1: Scaffold

Crie a estrutura no projeto-alvo:

```
src/
├── app/ (ou routes/)     rotas conforme o mapa de navegacao de 01-screens
├── components/ui/        primitivos do design system
├── features/{dominio}/   por feature, conforme os dominios do blueprint
├── api/                  CAMADA DE DADOS — toda chamada HTTP passa por aqui
│   └── {recurso}.ts      um arquivo por recurso, com os tipos de src/types/
├── mocks/
│   ├── handlers/         um arquivo por recurso
│   ├── fixtures/         um arquivo por entidade, TIPADO
│   ├── personas.ts       seletor de persona
│   ├── scenarios.ts      conta nova, volume, offline, lento, expirado
│   └── browser.ts        registro do worker
├── types/                tipos das entidades — viram src/contracts/ depois
└── styles/               tokens do design system
```

**Quatro regras inegociaveis:**

1. **Nenhum componente chama `fetch` direto.** Toda chamada HTTP vive em `src/api/{recurso}.ts` e chega ao componente por hook. Esta e a regra que torna a fase seguinte possivel: `/prototype-api` monta o inventario "chamadas feitas" lendo **este diretorio**. Chamada espalhada por componente nao e inventariavel, e sem o inventario o cruzamento que da valor a fase nao acontece.
2. **Os tipos das entidades saem de `04-domain-model.md`, com os nomes do glossario.** Eles viram `src/contracts/` no `/codegen-setup` — divergir aqui custa um rename depois.
3. **O mock vive na camada de rede.** A aplicacao faz `fetch` real; o worker intercepta. Mock dentro do componente transforma a integracao numa reescrita.
4. **Fixtures sao tipadas.** Fixture com `any` nao acusa divergencia de contrato, e acusar divergencia e metade do valor da fase.

## Passo 2: Design System

Implemente os tokens de `03-design-system.md` (cores em `oklch`, tipografia, espacamento, breakpoints, light e dark) e os primitivos do catalogo.

Os componentes construidos aqui **sao reaproveitados** na implementacao final — e o unico artefato do prototipo que nao e descartavel. Trate-os como codigo de producao: props tipadas, variantes, acessibilidade do checklist do design system.

## Passo 3: Camada de Mock

- **Handlers por recurso**, com latencia simulada (a faixa definida em `02-mock-data.md`) — sem latencia os estados de loading nunca aparecem e ninguem os implementa
- **Fixtures** com a distribuicao de estados e **todos os casos de borda** de `02-mock-data.md`
- **Seletor de persona** visivel em desenvolvimento, trocando a sessao mockada
- **Cenarios** acionaveis por query param (`?scenario=offline`, `?scenario=slow`, `?scenario=expired`, `?scenario=bulk`)

> **O mock responde, ele nao decide.** Toda regra de negocio pertence ao backend. Quando um handler precisar calcular para responder, pare e registre em `docs/prototype/05-findings.md` (§regras de negocio descobertas, com **Edit** — o arquivo tem tres autores) — voce achou uma regra que ninguem tinha escrito.

## Passo 4: Loop de Telas

Para cada tela de `01-screens.md`, em ordem de dependencia (autenticacao e layout primeiro):

```
1. Rota e guard        conforme o mapa de navegacao
2. Layout              conforme a coluna Layout
3. Estados PRIMEIRO    carregando → vazio → erro → sucesso, nessa ordem
                       + parcial e sem-permissao quando a tela os admitir
4. Dados               campo a campo, so o que 01-screens lista
5. Acoes               cada acao dispara a transicao de 09-state-models
6. Validacao           na borda, erro por campo
7. Verificar           percorrer a tela com CADA persona
```

**Por que os estados vem antes dos dados:** implementar "sucesso" primeiro e o caminho conhecido para nunca implementar os outros tres. O estado vazio construido depois vira `if (!data) return null`.

**Regra da tela pronta:** os quatro estados existem, todas as personas conseguem percorre-la, e nenhum dado vem de fora do que `01-screens.md` lista. Campo extra na tela e campo que entrou no contrato sem consumidor.

**Commit por tela:**

```
feat(prototype): {NomeDaTela} — {N} estados, {M} acoes
```

## Passo 5: Portao de Cobertura

Antes de declarar o prototipo pronto, verifique **contra o codigo**, nao contra a intencao:

| Portao | Como verificar | Falha se |
|---|---|---|
| **Telas** | Toda tela de `01-screens.md` tem rota que responde | Falta tela |
| **Casos de uso** | Todo `UC` com tela e executavel ponta a ponta | `UC` nao executavel |
| **Fluxos criticos** | Cada fluxo de `blueprint/07` percorrivel do inicio ao fim | Fluxo interrompido |
| **Estados** | Toda tela tem os quatro estados alcancaveis por cenario | Estado faltando |
| **Transicoes** | Toda transicao de `09-state-models` ou tem gatilho na UI, ou tem causa registrada (acao de sistema / backoffice fora de escopo / lacuna) | Transicao sem gatilho **e** sem causa |
| **Personas** | Cada persona navega e ve apenas o permitido | Persona travada ou vendo demais |
| **Build** | Type check e lint passam | Qualquer erro |

Falha em portao: **corrija, nao documente como limitacao**. Prototipo incompleto produz contrato incompleto, e o contrato incompleto vira schema incompleto.

## Passo 6: Relatorio

> "**Prototipo construido** — {{N}} telas, {{M}} casos de uso, {{K}} fluxos criticos.
>
> | Portao | Resultado |
> |---|---|
> | Telas | {{N}}/{{N}} |
> | Casos de uso executaveis | {{N}}/{{M}} |
> | Fluxos criticos percorriveis | {{N}}/{{M}} |
> | Estados por tela | {{completo / faltam N}} |
> | Transicoes disparaveis | {{N}}/{{M}} |
> | Type check · lint | {{ok / falhou}} |
>
> **Achados registrados durante a construcao:** {{N}} — {{n}} de risco alto.
>
> Rode `/prototype-api {client} {projeto-alvo}` para extrair o contrato que o backend precisa implementar."

## Limites conhecidos

- **O prototipo nao prova performance.** Dados em memoria com latencia simulada nao dizem nada sobre o banco real.
- **Autorizacao mockada nao e autorizacao.** O seletor de persona exercita a matriz; a imposicao real e do backend, sempre.
- **Componentes sao reaproveitaveis; telas nem sempre.** A integracao costuma mudar a forma dos dados o bastante para mexer no layout.
