---
name: frontend-security
description: Preenche a secao de Seguranca (11-security.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Seguranca

Preenche `docs/frontend/{client}/11-security.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/11-security.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/13-security.md` — STRIDE, autenticacao, autorizacao, OWASP
2. Leia `docs/frontend/{client}/11-security.md` — template a preencher
3. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Modelo de Autenticacao**: Qual o mecanismo de autenticacao (JWT, session, OAuth) e como tokens sao gerenciados no frontend?
- **Protecao de Rotas**: Quais rotas exigem autenticacao ou autorizacao e como o acesso e controlado no client-side?
- **Protecao contra Vulnerabilidades**: Quais medidas existem contra XSS, CSRF, injection e outras vulnerabilidades comuns?
- **Content Security Policy**: Qual a politica CSP adotada e como headers de seguranca sao configurados?
- **Checklist de Seguranca**: Quais verificacoes de seguranca devem ser feitas antes de cada release?

Se houver lacunas criticas que NAO podem ser inferidas do PRD, faca ate 3 perguntas pontuais ao usuario antes de gerar.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Content Security Policy (CSP) headers; Protecao contra XSS, CSRF) | **mobile** (Keychain (iOS) e Keystore (Android) para armazenamento seguro; Certificate pinning para comunicacao com API) | **desktop** (Code signing do aplicativo; Verificacao de integridade de auto-updates)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/11-security.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes do blueprint tecnico (fonte primaria)
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: 13-security.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Seguranca preenchida para {client}. Rode `/frontend-observability {client}` para preencher Observabilidade."
