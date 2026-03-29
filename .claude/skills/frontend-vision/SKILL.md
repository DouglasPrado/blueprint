---
name: frontend-vision
description: Preenche a secao de Visao do Frontend (00-frontend-vision.md) a partir do blueprint tecnico.
---

# Frontend Blueprint — Visao do Frontend

Preenche `docs/frontend/{client}/00-frontend-vision.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/00-frontend-vision.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/00-context.md` — atores e limites do sistema
2. Leia `docs/blueprint/01-vision.md` — problema, metricas, nao-objetivos
3. Leia `docs/blueprint/02-architecture_principles.md` — principios e restricoes
4. Leia `docs/frontend/{client}/00-frontend-vision.md` — template a preencher
5. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Objetivo do Frontend**: Qual o proposito principal da interface e que experiencia ela deve entregar?
- **Principios Arquiteturais**: Quais principios guiam as decisoes de frontend (performance-first, acessibilidade, offline-first)?
- **Plataformas e Dispositivos**: Quais plataformas (web, mobile, desktop) e dispositivos sao suportados?
- **Stack Tecnologico**: Quais frameworks, linguagens, ferramentas de build e runtime serao utilizados?
- **Tipos de Usuarios**: Quais perfis de usuario interagem com o frontend e quais suas necessidades?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Frameworks tipicos: Next.js, Remix, SPA (Vite + React); Considere SSR/SSG, hidratacao, SEO, responsividade) | **mobile** (Frameworks tipicos: React Native, Expo; Considere navegacao nativa, gestos, notificacoes push, offline-first) | **desktop** (Frameworks tipicos: Electron, Tauri; Considere integracao com sistema operacional, menu bar, system tray, auto-update)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/00-frontend-vision.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Visao do Frontend preenchida para {client}. Rode `/frontend-architecture {client}` para preencher Arquitetura do Frontend."
