---
name: paper
description: Cria paginas visuais no Paper (paper.design) a partir do frontend blueprint — design system e telas de cada rota.
---

# Paper — Design Visual a partir do Blueprint

Cria paginas visuais no Paper (paper.design) usando as ferramentas MCP. Le o frontend blueprint preenchido e produz artboards visuais — primeiro o design system como referencia, depois paginas de cada rota sob demanda.

**Escopo:** Apenas visual no Paper. NAO gera codigo para o projeto.

---

## Regras Paper MCP (OBRIGATORIAS)

> Siga estas regras em TODAS as interacoes com o Paper MCP:

- Sempre chame `mcp__paper__get_font_family_info` antes de usar qualquer fonte
- Use `px` para font-size, `em` para letter-spacing
- Um grupo visual por `mcp__paper__write_html` (max ~15 linhas HTML)
- Screenshot OBRIGATORIO a cada 2-3 modificacoes via `mcp__paper__get_screenshot`
- Review Checkpoints apos cada screenshot: **Spacing, Typography, Contrast, Alignment, Clipping, Repetition**
- Apenas inline styles com `display: flex` para layout
- NAO use `display: grid`, margins, tabelas HTML
- NAO use emojis como icones — use SVG ou omita
- Sempre chame `mcp__paper__finish_working_on_nodes` ao finalizar cada artboard
- Conversao rem→px (base 16px): 2.25rem=36px, 1.5rem=24px, 1rem=16px, 0.875rem=14px

---

## Passo 1: Verificar Ambiente Paper

1. Chame `mcp__paper__get_basic_info` para confirmar conexao e ver artboards existentes.
2. Chame `mcp__paper__get_font_family_info` com as fontes do blueprint: `["Inter", "JetBrains Mono"]`.
   - Se alguma NAO estiver disponivel, use fallback (`system-ui` para Inter, `monospace` para JetBrains Mono) e informe ao usuario.
3. Se artboards do projeto ja existem, pergunte:
   > "Encontrei artboards existentes: {{lista}}. Deseja continuar adicionando ou comecar do zero?"

---

## Passo 2: Ler Frontend Blueprint

Leia os seguintes documentos para extrair os dados necessarios:

| Documento | O que extrair |
|-----------|---------------|
| `docs/frontend/03-design-system.md` | Tokens: cores, tipografia, espacamento, breakpoints, catalogo de componentes |
| `docs/frontend/04-components.md` | Hierarquia de componentes, variantes e props dos primitivos |
| `docs/frontend/07-routes.md` | Tabela de rotas, layouts, tipos (publica/protegida/admin) |

Monte tres conjuntos internos de referencia:
- **TOKENS**: mapa de cores, escala tipografica (convertida para px), escala de espacamento, breakpoints
- **COMPONENTES**: lista de primitivos com suas variantes
- **ROTAS**: lista de rotas com layout, tipo e nome da pagina

---

## Passo 3: Perguntar ao Usuario

Apresente as opcoes:

> "O que voce gostaria de criar no Paper?
>
> 1. **Design System** — paleta de cores, tipografia, espacamento e catalogo de componentes
> 2. **Pagina de Rota** — layout visual de uma pagina especifica
> 3. **Ambos** — design system primeiro, depois paginas
>
> Qual opcao?"

Aguarde a resposta. Se "Ambos", execute Passo 4 seguido do Passo 5.

---

## Passo 4: Fase 1 — Design System (artboard unico)

### 4.1: Design Brief

Apresente o brief ao usuario antes de criar qualquer coisa:

> "**Design Brief — Design System**
>
> - **Cores**: {{N}} tokens extraidos do blueprint (listar com hex)
> - **Tipografia**: {{font-family}} (headings {{weight}}, body {{weight}}) + {{code font}}
> - **Espacamento**: grid de 8px ({{listar tokens}})
> - **Componentes**: {{N}} primitivos ({{listar nomes}})
> - **Artboard**: 1440 x 3200px (desktop, altura para todas as secoes)
> - **Fundo**: #FFFFFF
> - **Direcao visual**: clean, minimalista, foco em documentacao
>
> Confirma? Quer ajustar algo?"

Aguarde confirmacao.

### 4.2: Criar Artboard

```
mcp__paper__create_artboard({
  name: "Design System",
  styles: {
    width: "1440px",
    height: "3200px",
    backgroundColor: "#FFFFFF",
    display: "flex",
    flexDirection: "column",
    padding: "48px",
    gap: "48px"
  }
})
```

Guarde o ID retornado como `DS_ID`.

### 4.3: Construir Secao por Secao

Construa cada secao com multiplos `write_html` (um grupo visual por chamada). Faca screenshot a cada 2-3 chamadas.

**A) Header**
- Titulo "Design System" (font 700, 36px, color texto principal)
- Subtitulo com nome do projeto (font 400, 16px, color texto secundario)
- Screenshot checkpoint

**B) Paleta de Cores**
- Titulo da secao "Cores"
- Row 1: 4 swatches (primary, secondary, background, surface) — cada swatch = retangulo colorido (80x80px) + hex value + token name
- Row 2: 4 swatches (text, error, warning, success)
- Screenshot checkpoint → Review: Contrast, Alignment, Spacing

**C) Escala Tipografica**
- Titulo da secao "Tipografia"
- Sample heading-1: "Heading 1 — {{font}} 700 / 36px"
- Sample heading-2: "Heading 2 — {{font}} 600 / 24px"
- Sample body: "Body text — {{font}} 400 / 16px"
- Sample caption: "Caption — {{font}} 400 / 14px"
- Sample code: "const example = true; — {{code font}} 400 / 14px"
- Screenshot checkpoint → Review: Typography, Spacing

**D) Sistema de Espacamento**
- Titulo da secao "Espacamento"
- Para cada token (xs=4px, sm=8px, md=16px, lg=24px, xl=32px, 2xl=48px): barra horizontal colorida com largura proporcional + label
- Screenshot checkpoint → Review: Alignment

**E) Breakpoints**
- Titulo da secao "Breakpoints"
- 4 indicadores visuais: sm (640px/Mobile), md (768px/Tablet), lg (1024px/Desktop), xl (1280px/Wide)
- Screenshot checkpoint

**F) Catalogo de Componentes**

Para cada componente primitivo, renderize as variantes lado a lado:

| Componente | O que renderizar |
|------------|-----------------|
| Button | primary, secondary, ghost, destructive (tamanhos sm, md, lg) |
| Input | text, password, search + estado de erro |
| Select | single, searchable |
| Card | default, outlined, elevated |
| Modal | frame estatico (estado aberto) |
| Toast | success, error, warning, info |
| Badge | default, dot, count |
| Avatar | placeholder circular, initials |
| Tooltip | indicador direcional (top, right) |
| Skeleton | text lines, card shape |

- Agrupe 2-3 componentes por screenshot checkpoint
- Review apos cada grupo: Spacing, Typography, Contrast, Alignment, Clipping, Repetition
- Se o conteudo ultrapassar a altura do artboard, use `mcp__paper__update_styles` para ajustar height para `fit-content`

### 4.4: Finalizar Design System

1. Chame `mcp__paper__finish_working_on_nodes` com o ID do artboard
2. Screenshot final completo
3. Apresente resumo:

> "Design System criado no Paper:
>
> - {{N}} cores documentadas
> - {{N}} niveis tipograficos
> - {{N}} tokens de espacamento
> - {{N}} breakpoints
> - {{N}} componentes com variantes
>
> Deseja ajustar algo ou seguir para as paginas de rota?"

---

## Passo 5: Fase 2 — Paginas de Rota

### 5.1: Apresentar Rotas

Leia `docs/frontend/07-routes.md` e apresente a lista:

> "Paginas disponiveis para criar no Paper:
>
> | # | Rota | Layout | Tipo | Pagina |
> |---|------|--------|------|--------|
> | 1 | `/` | MainLayout | Publica | HomePage |
> | 2 | `/login` | AuthLayout | Publica | LoginPage |
> | 3 | `/register` | AuthLayout | Publica | RegisterPage |
> | 4 | `/dashboard` | AppLayout | Protegida | DashboardPage |
> | 5 | `/settings` | AppLayout | Protegida | SettingsPage |
> | 6 | `/admin/users` | AdminLayout | Admin | AdminUsersPage |
>
> Qual pagina quer criar? (numero ou nome)"

Aguarde escolha.

### 5.2: Ler Contexto Complementar

Para a pagina escolhida, leia docs adicionais:

| Documento | O que buscar |
|-----------|-------------|
| `docs/frontend/08-flows.md` | Fluxos de UI relevantes para esta pagina |
| `docs/frontend/05-state.md` | Estado gerenciado nesta pagina |
| `docs/frontend/14-copies.md` | Textos/copies para esta pagina (se disponiveis) |
| `docs/frontend/04-components.md` | Componentes do layout (Sidebar, Navbar, etc.) |

Se algum documento ainda contem `{{placeholders}}`, use conteudo placeholder realista.

### 5.3: Design Brief da Pagina

> "**Design Brief — {{PageName}} ({{rota}})**
>
> - **Layout**: {{LayoutName}} ({{componentes: sidebar, navbar, footer, etc.}})
> - **Artboard**: 1440 x 900px (desktop)
> - **Componentes na pagina**: {{lista baseada nos fluxos e componentes}}
> - **Conteudo principal**: {{descricao baseada nos flows}}
> - **Consistente com**: Design System criado
>
> Confirma?"

### 5.4: Criar Artboard

```
mcp__paper__create_artboard({
  name: "Page — {{rota}}",
  styles: {
    width: "1440px",
    height: "900px",
    backgroundColor: "#FFFFFF",
    display: "flex"
  }
})
```

### 5.5: Construir Layout Incrementalmente

Siga a ordem:

1. Shell do layout (ex: para AppLayout = sidebar 240px + area principal flex-grow)
2. Navbar (logo, links de navegacao, user menu)
3. Sidebar (itens de navegacao com icones/labels)
4. **Screenshot checkpoint**
5. Header da pagina (titulo, breadcrumbs se aplicavel)
6. Secoes do conteudo principal (1 grupo visual por `write_html`)
7. **Screenshot a cada 2-3 writes**
8. **Review completa**: Spacing, Typography, Contrast, Alignment, Clipping, Repetition

### 5.6: Finalizar Pagina

1. `mcp__paper__finish_working_on_nodes`
2. Screenshot final
3. Apresentar ao usuario

### 5.7: Sugerir Proxima Pagina

> "Pagina **{{nome}}** ({{rota}}) criada no Paper.
>
> Proxima sugestao: **{{proxima rota da lista}}** ({{layout}}).
> Deseja criar? Ou escolha outra da lista."

Se o usuario quiser, volte ao passo 5.2 para a proxima pagina.

---

## Passo 6: Resumo Final

Quando o usuario encerrar:

> "Paginas criadas no Paper:
>
> | Artboard | Rota | Dimensao |
> |----------|------|----------|
> | Design System | — | 1440x3200 |
> | {{pagina}} | {{rota}} | 1440x900 |
> | ... | ... | ... |
>
> Para revisar ou ajustar, selecione elementos no Paper e descreva as alteracoes.
> Para criar mais paginas, rode `/paper` novamente."
