---
name: frontend-components
description: Preenche a secao de Componentes (04-components.md) do frontend blueprint a partir do blueprint tecnico.
---

# Frontend Blueprint — Componentes

Preenche `docs/frontend/{client}/04-components.md` com base no blueprint tecnico e no contexto do projeto.

## Cliente

Parametro: `web` | `mobile` | `desktop`. Se nao fornecido, pergunte ao usuario.
Saida: `docs/frontend/{client}/04-components.md`. Leia tambem `docs/frontend/shared/`.

## Leitura de Contexto

1. Leia `docs/blueprint/04-domain-model.md` — entidades para mapear em componentes
2. Leia `docs/blueprint/08-use_cases.md` — casos de uso para features
3. Leia `docs/frontend/{client}/03-design-system.md` — design system (ja preenchido)
4. Leia `docs/frontend/{client}/04-components.md` — template a preencher
5. Leia `docs/prd.md` — complemento se necessario

## Analise de Lacunas

A partir do blueprint tecnico, identifique o que esta disponivel para cada subsecao:

- **Hierarquia de Componentes (Primitive, Composite, Feature)**: Quais niveis de componentes existem e como se relacionam?
- **Template de Documentacao**: Qual o padrao de documentacao para cada componente (props, exemplos, variantes)?
- **Padroes de Composicao**: Quais padroes de composicao sao utilizados (compound components, render props, slots)?
- **Quando Criar vs Reutilizar**: Quais criterios definem se um componente deve ser criado do zero ou reutilizado?

Lacunas criticas nao inferiveis → ate 3 perguntas ao usuario.

> **Versoes:** Para tecnologias com versao, consulte via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.

## Plataformas

Adapte o conteudo conforme o cliente: **web** (Componentes baseados em DOM (div, button, input); Bibliotecas de componentes: shadcn/ui, Radix, Headless UI) | **mobile** (Componentes baseados em React Native Views (View, Text, Pressable, ScrollView); Listas performaticas: FlatList, FlashList, SectionList) | **desktop** (Mesma base web + componentes especificos de desktop; Componentes nativos: TitleBar, SystemTray, MenuBar, ContextMenu)

## Geracao

> **Escrita:** Primeira vez (so placeholders) → Write. Reexecucao (conteudo real) → Edit (preservar existente, inserir antes de `<!-- APPEND:... -->`). Feature isolada → `/frontend-increment`.

Preencha `docs/frontend/{client}/04-components.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do blueprint tecnico
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- do blueprint: XX-arquivo.md -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Componentes preenchido para {client}. Rode `/frontend-state {client}` para preencher Gerenciamento de Estado."
