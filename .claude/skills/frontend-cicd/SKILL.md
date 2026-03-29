---
name: frontend-cicd
description: Preenche a secao de CI/CD e Convencoes (13-cicd-conventions.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — CI/CD e Convencoes

Preenche `docs/frontend/{client}/13-cicd-conventions.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/13-cicd-conventions.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/06-system-architecture.md` — pipeline CI/CD e deploy
2. Leia `docs/frontend/{client}/13-cicd-conventions.md` — template a preencher
3. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Pipeline CI/CD**: Quais etapas compoe o pipeline (lint, test, build, deploy) e quais ferramentas sao utilizadas?
- **Ambientes**: Quais ambientes existem (dev, staging, production) e como o deploy e promovido entre eles?
- **Convencoes de Codigo (Arquivos, Componentes, Commits)**: Quais padroes de nomenclatura, organizacao de arquivos e mensagens de commit sao adotados?
- **Ferramentas de Qualidade**: Quais ferramentas de linting, formatting e analise estatica sao configuradas?
- **Documentacao Viva**: Como a documentacao tecnica e mantida atualizada junto com o codigo?

Se houver lacunas criticas que NAO podem ser inferidas do PRD, faca ate 3 perguntas pontuais ao usuario antes de gerar.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Deploy via Vercel/Netlify; PR preview environments automaticos) | **mobile** (EAS Build para builds na nuvem; TestFlight (iOS) e Play Console (Android) para distribuicao) | **desktop** (electron-builder ou tauri-action para builds; Artefatos: DMG (macOS), NSIS (Windows), AppImage (Linux))

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/13-cicd-conventions.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes do blueprint tecnico (fonte primaria)
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: 06-system-architecture.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "CI/CD e Convencoes preenchidos para {client}. Rode `/frontend-copies {client}` para preencher os textos e copies de todas as telas."
