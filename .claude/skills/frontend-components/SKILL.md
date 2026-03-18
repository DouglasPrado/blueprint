---
name: frontend-components
description: Preenche a secao de Componentes (04-components.md) do frontend blueprint a partir do PRD.
---

# Frontend Blueprint — Componentes

Preenche `docs/frontend/04-components.md` com base no PRD e no contexto do projeto.

## Leitura de Contexto

1. Leia `docs/prd.md` — fonte primaria
2. Leia `docs/frontend/04-components.md` — template a preencher

## Analise de Lacunas

A partir do PRD, identifique o que esta disponivel para cada subsecao:

- **Hierarquia de Componentes (Primitive, Composite, Feature)**: Quais niveis de componentes existem e como se relacionam?
- **Template de Documentacao**: Qual o padrao de documentacao para cada componente (props, exemplos, variantes)?
- **Padroes de Composicao**: Quais padroes de composicao sao utilizados (compound components, render props, slots)?
- **Quando Criar vs Reutilizar**: Quais criterios definem se um componente deve ser criado do zero ou reutilizado?

Se houver lacunas criticas que NAO podem ser inferidas do PRD, faca ate 3 perguntas pontuais ao usuario antes de gerar.

> **Versões atualizadas:** Ao referenciar tecnologias específicas com versões, use o MCP context7 para consultar documentação atualizada. Primeiro chame `mcp__context7__resolve-library-id` para obter o ID da biblioteca, depois `mcp__context7__query-docs` para consultar versões e exemplos.

## Geracao

> **Modo de escrita:**
> - Se o documento contem apenas `{{placeholders}}` (primeira vez): use Write para preencher tudo.
> - Se o documento ja tem conteudo real (reexecucao): use **Edit** para atualizar APENAS o que mudou. Preserve conteudo existente. Insira novo conteudo antes dos marcadores `<!-- APPEND:... -->`.
> - Para adicionar uma feature especifica sem reescrever, prefira `/frontend-increment`.

Preencha `docs/frontend/04-components.md` substituindo TODOS os `{{placeholders}}`. Mantenha a estrutura. Use:
- Informacoes explicitas do PRD
- Respostas do usuario (se houve perguntas)
- Inferencias logicas quando seguro (marque com `<!-- inferido do PRD -->`)

## Revisao

Apresente o documento preenchido ao usuario. Aplique ajustes solicitados. Salve o arquivo final.

## Proxima Etapa

> "Componentes preenchido. Rode `/frontend-state` para preencher Gerenciamento de Estado."
