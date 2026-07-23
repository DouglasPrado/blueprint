---
name: frontend-quality
description: Gera os 5 docs de qualidade de um cliente frontend — testes, performance, seguranca, observabilidade e CI/CD.
---

# Frontend — Qualidade ({client})

Gera os 5 documentos de atributos nao funcionais do cliente. Todos sao a projecao no frontend do que ja foi decidido em `/blueprint-quality`.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte.
Saida: `docs/frontend/{client}/`.

## Contexto (ler uma vez)

Do blueprint tecnico:
- `12-testing_strategy.md` — piramide e cobertura do sistema
- `13-security.md` — STRIDE, autenticacao, autorizacao, OWASP
- `14-scalability.md` — cache e estrategias de escala
- `15-observability.md` — logs, metricas, traces, alertas
- `06-system-architecture.md` — pipeline CI/CD e deploy
- `03-requirements.md` — RNFs de latencia e throughput

Do cliente (ja preenchidos por `/frontend-app`): `07-routes.md`, `08-flows.md`, `01-architecture.md`
Dos compartilhados: `docs/frontend/shared/06-data-layer.md`

Templates a preencher (5): `09-tests.md`, `10-performance.md`, `11-security.md`, `12-observability.md`, `13-cicd-conventions.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** ferramentas de teste, monitoramento e build → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca contradiga** os thresholds do blueprint tecnico — o frontend detalha, nao redefine.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento).

## Analise de Lacunas (fazer antes de gerar)

Priorize as 3 perguntas nesta ordem:

1. **Metas de Core Web Vitals / startup time** (10) — se `03-requirements.md` nao define
2. **Plataforma de CI/CD e ambientes** (13) — se `06-system-architecture.md` nao define
3. **Ferramenta de error tracking** (12) — proponha coerente com a stack de observabilidade do backend

---

## Adaptacao por plataforma

| Doc | web | mobile | desktop |
|---|---|---|---|
| 09 Testes | Playwright (E2E); Testing Library (componentes) | Detox ou Maestro (E2E); React Native Testing Library | Playwright + Electron (E2E); testes de IPC handlers (main↔renderer) |
| 10 Performance | Core Web Vitals (LCP, INP, CLS) como metricas primarias; code splitting e lazy loading de rotas | App startup time (cold e warm start); frame rate alvo de 60fps | Startup time da aplicacao; uso de memoria (main process + renderer) |
| 11 Seguranca | CSP headers; protecao contra XSS e CSRF | Keychain (iOS) e Keystore (Android); certificate pinning | Code signing do app; verificacao de integridade de auto-updates |
| 12 Observabilidade | Sentry; Web Vitals RUM (Real User Monitoring) | Sentry React Native; Firebase Crashlytics (crash reporting) | Sentry Electron; crash reporting nativo do processo main |
| 13 CI/CD | Deploy via Vercel/Netlify; PR preview environments automaticos | EAS Build (builds na nuvem); TestFlight (iOS) e Play Console (Android) | electron-builder ou tauri-action; artefatos DMG (macOS), NSIS (Windows), AppImage (Linux) |

---

## 09 — Estrategia de Testes

- **Piramide de Testes**: proporcao unit / integration / E2E, coerente com `12-testing_strategy.md`
- **Padroes por Tipo de Componente**: paginas, formularios, hooks, servicos
- **Cobertura e Metas**: metas por area; areas criticas com cobertura obrigatoria
- **Integracao com CI**: em que etapa rodam e quais gates bloqueiam merge

Cada fluxo de `08-flows.md` deve ter ao menos um teste E2E nomeado.

## 10 — Performance

- **Estrategias de Otimizacao**: code splitting, lazy loading, tree shaking, caching
- **Metricas-alvo**: valores concretos (ver tabela de plataforma acima)
- **Budget de Performance**: tamanho maximo de bundle, tempo de carregamento, numero de requests
- **Monitoramento**: como medir em producao e quais alertas configurar

## 11 — Seguranca

- **Modelo de Autenticacao**: mecanismo (JWT, session, OAuth) e gestao de tokens no cliente
- **Protecao de Rotas**: client-side, espelhando o que `07-routes.md` marcou como protegido
- **Protecao contra Vulnerabilidades**: XSS, CSRF, injection
- **Content Security Policy**: politica e headers de seguranca
- **Checklist de Seguranca**: verificacoes antes de cada release

A autorizacao real vive no backend — este doc documenta a camada de defesa do cliente, nunca a unica.

## 12 — Observabilidade

- **Error Tracking**: captura, categorizacao e reporte de erros
- **Logging Estruturado**: estrategia e envio ao backend
- **Metricas de API**: latencia, taxa de erro, volume por endpoint
- **User Flow Monitoring**: rastreio dos fluxos de `08-flows.md` para detectar abandono
- **Feature Flags**: gestao e integracao com rollouts graduais

## 13 — CI/CD e Convencoes

- **Pipeline CI/CD**: etapas (lint, test, build, deploy) e ferramentas
- **Ambientes**: dev, staging, production e como o deploy e promovido
- **Convencoes de Codigo**: nomenclatura de arquivos e componentes, mensagens de commit
- **Ferramentas de Qualidade**: linting, formatting, analise estatica
- **Documentacao Viva**: como a doc tecnica acompanha o codigo

---

## Revisao e Proxima Etapa

Apresente os 5 documentos ao usuario. Aplique ajustes. Salve os arquivos finais.

> "Qualidade documentada para {client} (09, 10, 11, 12, 13). O frontend blueprint deste cliente esta completo.
>
> - Outro cliente? Rode `/frontend-app {outro-cliente}`
> - Nova feature? Rode `/increment`
> - Backlog de tasks? Rode `/specs`"
