---
name: frontend-app
description: Gera os 8 docs de aplicacao de um cliente frontend — visao, arquitetura, estrutura, componentes, estado, rotas, fluxos e copies.
---

# Frontend — Aplicacao ({client})

Gera os 8 documentos que descrevem **como o cliente e construido**: da visao ate os textos das telas.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte.
Saida: `docs/frontend/{client}/`.

## Contexto (ler uma vez)

Do blueprint tecnico:
- `00-context.md`, `01-vision.md`, `02-architecture_principles.md` — atores, problema, principios
- `04-domain-model.md` — entidades que viram tipos, componentes e formularios
- `06-system-architecture.md` — componentes, comunicacao, deploy
- `07-critical_flows.md`, `08-use_cases.md` — jornadas que viram telas e rotas
- `09-state-models.md` — transicoes que a UI precisa refletir
- `10-architecture_decisions.md` — ADRs que restringem a stack

Dos compartilhados: `docs/frontend/shared/03-design-system.md`, `06-data-layer.md`, `15-api-dependencies.md`

Se `docs/backend/13-integrations.md` existir, leia a secao de canais de comunicacao — ela alimenta os copies de notificacao.

Templates a preencher (8): `00-frontend-vision.md`, `01-architecture.md`, `02-project-structure.md`, `04-components.md`, `05-state.md`, `07-routes.md`, `08-flows.md`, `14-copies.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca invente** nomes de rota, endpoint ou componente que contradigam o blueprint.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento). Agrupe e faca antes de gerar.

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Stack e framework do cliente** (00/01) — se os ADRs de `10` nao definem
2. **Estrategia de estado global** (05) — store, context ou signals
3. **Tom de voz e suporte a i18n** (14) — idioma padrao e se ha traducao

---

## Adaptacao por plataforma

| Doc | web | mobile | desktop |
|---|---|---|---|
| 00 Visao | Next.js, Remix, SPA (Vite+React). SSR/SSG, hidratacao, SEO, responsividade | React Native, Expo. Navegacao nativa, gestos, push, offline-first | Electron, Tauri. Integracao com SO, menu bar, system tray, auto-update |
| 01 Arquitetura | Camadas SSR/SSG, React Server Components, API routes, middleware no edge | Bridge para modulos nativos (camera, GPS, biometria); arquitetura de navegacao stack/tab/drawer | Processo main vs renderer (Electron) ou core vs webview (Tauri); IPC entre processos |
| 02 Estrutura | `app/` router (Next.js) ou `routes/` (Remix); `public/`, middleware, API routes | Expo Router com `app/` ou `screens/` tradicional; `assets/`, navegacao | Separacao `main/` e `renderer/`; `ipc/` para comunicacao entre processos |
| 04 Componentes | Base DOM (div, button, input); shadcn/ui, Radix, Headless UI | React Native Views (View, Text, Pressable, ScrollView); listas performaticas FlatList, FlashList, SectionList | Base web + TitleBar, SystemTray, MenuBar, ContextMenu |
| 05 Estado | SSR hydration (sincronizacao servidor↔cliente); URL state via searchParams, shallow routing | Persistencia background/foreground (AppState listener); cold start, warm start, resume | Sincronizacao main↔renderer via IPC (invoke/handle); estado em disco (electron-store, tauri fs) |
| 07 Rotas | App Router file-based; guards via middleware | React Navigation (stacks, tabs, drawers); deep linking via URL schemes e universal links | Window-based navigation; menu bar e system tray com context menu |
| 08 Fluxos | Page transitions, forms, modals; navegacao por URL e browser history | Gestos (swipe, pull-to-refresh, swipe actions); haptic feedback em acoes criticas | Drag-and-drop de arquivos; keyboard shortcuts para acoes frequentes |
| 14 Copies | i18next, next-intl, react-intl; SEO (meta titles, descriptions, OpenGraph) | expo-localization, react-native-localize; push notifications, app store listing, onboarding | i18next/next-intl + strings de menu bar, system tray e dialogs nativos do SO |

---

## 00 — Visao do Frontend

- **Objetivo do Frontend**: proposito da interface e experiencia a entregar
- **Principios Arquiteturais**: performance-first, acessibilidade, offline-first
- **Plataformas e Dispositivos**: suportados e minimos
- **Stack Tecnologico**: framework, linguagem, build e runtime
- **Tipos de Usuarios**: perfis (derive dos atores de `00-context.md`) e necessidades

## 01 — Arquitetura

- **Camadas**: presentation, application, domain, infrastructure
- **Regras de Dependencia**: o que pode importar o que
- **Fronteiras de Dominio**: como os bounded contexts de `04-domain-model.md` aparecem na organizacao
- **Diagrama de Arquitetura**: visao geral das conexoes

**Diagrama:** crie `docs/diagrams/{client}/{client}-architecture.mmd` com as camadas e conexoes.

## 02 — Estrutura do Projeto

- **Estrutura de Pastas**: arvore de diretorios com o papel de cada uma
- **Organizacao por Feature**: como features sao isoladas
- **Monorepo**: workspaces e estrategia de compartilhamento
- **Regras de Importacao**: convencoes e restricoes entre modulos

## 04 — Componentes

- **Hierarquia**: Primitive, Composite, Feature — niveis e relacao entre eles
- **Template de Documentacao**: padrao por componente (props, exemplos, variantes)
- **Padroes de Composicao**: compound components, render props, slots
- **Quando Criar vs Reutilizar**: criterios objetivos

Use os tokens ja definidos em `shared/03-design-system.md` — nao redefina cores ou espacamentos aqui.

## 05 — Gerenciamento de Estado

- **Tipos de Estado**: local, global, server, URL, form
- **Server State**: caching, revalidacao, optimistic updates
- **Global State**: estrategia e quando usar
- **Event Bus**: padrao de comunicacao entre componentes, se houver
- **Anti-patterns**: praticas a evitar neste projeto

As maquinas de estado de `09-state-models.md` definem quais estados a UI precisa representar — mapeie-as explicitamente.

## 07 — Rotas

- **Estrutura de Rotas**: paginas e hierarquia (derive dos casos de uso de `08-use_cases.md`)
- **Protecao de Rotas**: quais exigem autenticacao/autorizacao (coerente com `13-security.md`)
- **Layouts Compartilhados**: reutilizacao e composicao
- **Navegacao**: menus, breadcrumbs, caminhos entre telas

## 08 — Fluxos de Interface

- **Fluxos Criticos**: 3-5 fluxos com passos detalhados e tratamento de erro por etapa. Derive de `07-critical_flows.md` — mesma numeracao e mesmos nomes
- **Microfrontends**: se aplicavel, como os fluxos se distribuem

**Diagramas:** para cada fluxo, crie `docs/diagrams/{client}/fluxo-{n}.mmd` a partir de `docs/diagrams/sequences/template-flow.mmd`.

## 14 — Copies

- **Estrategia de Copy**: idioma padrao, suporte i18n, tom de voz, glossario de termos do produto
- **Copies por Tela**: titulos, labels, placeholders, CTAs, links, empty states
- **Mensagens de Feedback**: sucesso, erro, validacao, aviso, informacao
- **Componentes Globais**: navbar, sidebar, footer, modais genericos
- **Convencoes**: capitalizacao, pontuacao, voz ativa/passiva, tamanho maximo

**Checklist de cobertura** — verifique antes de fechar:
- [ ] Toda rota de `07` tem subsecao em "Copies por Tela"
- [ ] Todo fluxo critico de `08` tem mensagens de feedback mapeadas
- [ ] Glossario cobre os termos de dominio de `04-domain-model.md`
- [ ] Mensagens de erro cobrem os cenarios de erro dos endpoints de `shared/15-api-dependencies.md`
- [ ] Empty states definidos para todas as listas e telas com dados dinamicos

---

## Revisao e Proxima Etapa

Apresente os 8 documentos ao usuario em sequencia. Aplique ajustes. Salve os arquivos finais.

> "Aplicacao documentada para {client} (00, 01, 02, 04, 05, 07, 08, 14). Rode `/frontend-quality {client}` para testes, performance, seguranca, observabilidade e CI/CD."
