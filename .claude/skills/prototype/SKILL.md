---
name: prototype
description: Fase de prototipo — planeja o frontend completo mockado que antecede o backend. Gera 00-vision, 01-screens e 02-mock-data.
---

# Prototipo — Fase A: Plano

Planeja o **frontend completo e mockado** que roda **antes** do backend. O prototipo existe para descobrir o contrato de API construindo a interface, em vez de inventa-lo antes dela.

Esta skill produz o **plano**: o que sera construido, quais telas, com quais dados. O codigo vem em `/prototype-build`; o contrato descoberto vem em `/prototype-api`.

```
/prototype [cliente]

/prototype              # infere o cliente do blueprint
/prototype web          # explicito
```

## Por que esta fase existe

| Sem prototipo | Com prototipo |
|---|---|
| O contrato de API e uma previsao | O contrato e uma observacao |
| Campos sobrando e faltando | Cada campo tem consumidor nomeado |
| Lacuna do dominio aparece na implementacao | Lacuna aparece ao montar o formulario |
| Estados de erro inventados | Estados derivados do que a UI exibe |

O custo e construir a UI duas vezes. O retorno e que o retrabalho acontece em codigo descartavel, nao em schema com dados.

## Pre-requisitos

| Verificacao | Se falhar |
|---|---|
| `docs/blueprint/04-domain-model.md` preenchido | "Rode `/blueprint-domain` primeiro — sem entidades nao ha o que exibir." **pare** |
| `docs/blueprint/08-use_cases.md` preenchido | "Rode `/blueprint-flows` primeiro — os casos de uso definem as telas." **pare** |
| `docs/frontend/shared/03-design-system.md` preenchido | "Rode `/frontend-design-system` primeiro — sem tokens o prototipo nasce sem identidade." **pare** |

> `docs/backend/` **nao** e pre-requisito. Se ja existir preenchido, o prototipo esta rodando fora de ordem: avise que o valor da fase cai — o contrato ja foi inventado e o prototipo vira validacao, nao descoberta.

## Contexto (ler uma vez)

- `docs/blueprint/00-context.md` — atores viram personas e perfis de acesso
- `docs/blueprint/04-domain-model.md` — entidades viram dados de tela e fixtures
- `docs/blueprint/07-critical_flows.md` — fluxos viram sequencias percorriveis
- `docs/blueprint/08-use_cases.md` — **fonte primaria das telas**
- `docs/blueprint/09-state-models.md` — estados viram badges, filtros e acoes
- `docs/blueprint/13-security.md` — roles viram personas de teste
- `docs/frontend/shared/03-design-system.md` — tokens, tipografia, componentes base
- Templates a preencher: `docs/prototype/00-prototype-vision.md`, `01-screens.md`, `02-mock-data.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca invente** tela, campo ou regra que nao derive de um caso de uso. Caso de uso ambiguo vira pergunta ou entrada em `05-findings.md` — nunca uma decisao silenciosa.
- **Perguntas: maximo 3 nesta skill inteira**, agrupadas e feitas antes de gerar.
- **Idioma:** identificadores em ingles; descricoes em portugues.

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Escopo do prototipo** — todos os casos de uso, ou so os `Must` de `03-requirements.md`? Prototipo integral e mais caro e revela mais.
2. **Ferramenta de mock** — proponha interceptacao HTTP (MSW ou equivalente) e confirme. A escolha decide se a integracao e "desligar o mock" ou "reescrever a camada de dados".
3. **Profundidade das personas** — quantos perfis de acesso o prototipo precisa exercitar de verdade.

---

## Passo 1: Determinar o Cliente

Se o usuario passou o cliente, use-o. Caso contrario, infira de `docs/frontend/` (o cliente que ja tem docs) ou dos sinais do PRD, com a mesma tabela de `/pipeline`. Registre a escolha.

> O prototipo e de **um** cliente. Prototipar web e mobile ao mesmo tempo duplica o custo e triplica a chance de os dois divergirem antes mesmo de existir backend. Escolha o cliente que mais exercita o dominio — normalmente `web`.

## Passo 2: Inventario de Telas

Para cada `UC-XXX` de `08-use_cases.md`, determine as telas que o realizam.

- Um `UC` pode gerar varias telas (wizard); uma tela pode servir varios `UC` (dashboard)
- Derive rota, ator e nivel de acesso de `00-context.md` e `13-security.md`
- Para cada tela, liste **campo por campo** o que aparece. "Dados do usuario" nao serve — `name`, `email`, `avatarUrl` serve. **E desta lista que o contrato de API nasce.**
- Liste as acoes e, para cada uma, a transicao de estado correspondente em `09-state-models.md`

**Cobertura obrigatoria:** todo `UC` precisa de tela ou de justificativa explicita (API-only, fora de escopo, esquecido). A terceira opcao vira entrada em `05-findings.md`.

Preencha `01-screens.md`: mapa UC → tela, detalhamento por tela, mapa de navegacao com guards, deep links e a lista de fluxos criticos percorriveis.

## Passo 3: Dataset

Preencha `02-mock-data.md`:

- **Personas** — uma por perfil de acesso de `13-security.md`, mais uma por estado relevante da entidade `User` (conta nova, suspensa). O prototipo precisa de um seletor de persona; e assim que a matriz de permissoes e exercitada sem login real.
- **Fixtures por entidade** — quantidade suficiente para encher duas paginas e distribuicao que cubra todos os estados de `09-state-models.md`
- **Casos de borda obrigatorios** — texto no limite, campo nulo, numero extremo, caractere especial, data limite, relacionamento vazio. Sao eles que quebram layout e revelam suposicao.
- **Cenarios** — conta nova, uso normal, volume alto, falha de rede, lentidao, sessao expirada, cada um com forma de acionar

## Passo 4: Visao e Criterios de Saida

Preencha `00-prototype-vision.md`: o que e real e o que e mockado, a stack (**a mesma da implementacao final**, exceto a camada de mock), os criterios de saida e os nao-objetivos.

> **A regra que mais protege esta fase:** o mock responde, ele nao decide. Se o mock precisar calcular para responder, a regra pertence ao backend — registre em `05-findings.md`.

> **`05-findings.md` ja comeca a ser preenchido aqui.** Caso de uso ambiguo, transicao sem tela, entidade sem atributo suficiente para a interface — tudo isso aparece ao planejar, antes de escrever uma linha de codigo. Use **Edit** (o arquivo tera outros dois autores: `/prototype-build` e `/prototype-api`).

## Passo 5: Revisao

Apresente os 3 documentos. Aplique ajustes. Feche com a cobertura:

| Metrica | Valor |
|---|---|
| Casos de uso com tela | {{N}} de {{M}} |
| Telas planejadas | {{N}} |
| Fluxos criticos percorriveis | {{N}} de {{M}} |
| Personas | {{N}} |
| Transicoes de estado disparaveis pela UI | {{N}} de {{M}} |

> "Plano do prototipo pronto ({{N}} telas, {{M}} casos de uso cobertos). Rode `/prototype-build {client} {projeto-alvo}` para construir o app mockado."

## Limites conhecidos

- **O prototipo nao substitui o blueprint.** Ele testa o blueprint. Onde os dois discordam, o blueprint e corrigido com `/increment` — nunca o contrario em silencio.
- **Prototipo de um cliente nao prova os outros.** Gestos, IPC e navegacao nativa nao aparecem no web.
- **Custo real.** Duas construcoes da UI. Para um CRUD pequeno com PRD detalhado, provavelmente nao compensa; para um dominio novo ou um SaaS com fluxos longos, compensa quase sempre.
