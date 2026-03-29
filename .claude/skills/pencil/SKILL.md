---
name: pencil
description: Cria design visual no Pencil (pencil.dev) a partir do frontend blueprint.
---

# Pencil — Design Visual a partir do Blueprint

Cria designs visuais no Pencil (pencil.dev) via MCP. Fluxo em 5 passos:

1. **Variables & Temas** — tokens via `set_variables` com temas light/dark + representacao visual no DS
2. **Planejamento de Telas** — mapa de paginas, componentes, acoes e ordem de construcao
3. **Componentes Nativos** — componentes reutilizaveis (`reusable: true`) com variantes e slots no DS
4. **Composicao de Paginas** — monta paginas usando instancias (`ref`) dos componentes do DS
5. **Fluxos de Interacao** — duplica frames com estados alterados para simular experiencia do usuario

**Escopo:** Apenas visual no Pencil. NAO gera codigo.
**Terminologia:** No Pencil, artboard = **frame**. Toda a skill usa "frame".

---

## Regras Pencil MCP (OBRIGATORIAS)

### Nomes das ferramentas

| Tool curto | Tool MCP completo | Uso |
|------------|-------------------|-----|
| `batch_design` | `mcp__pencil__batch_design` | Criar/modificar/mover/deletar elementos via linguagem natural |
| `batch_get` | `mcp__pencil__batch_get` | Inspecionar hierarquia, listar componentes, buscar elementos |
| `get_screenshot` | `mcp__pencil__get_screenshot` | Verificacao visual em milestones (fim de fase/pagina) |
| `snapshot_layout` | `mcp__pencil__snapshot_layout` | Verificacao automatica por grupo — detecta problemas de posicionamento |
| `get_editor_state` | `mcp__pencil__get_editor_state` | Confirmar contexto (arquivo ativo, selecao) e conexao MCP |
| `get_variables` | `mcp__pencil__get_variables` | Ler variables existentes |
| `set_variables` | `mcp__pencil__set_variables` | Registrar tokens (cores, tipografia, spacing, radius) com temas |

### Regras de uso

| Regra | Detalhe |
|-------|---------|
| Linguagem natural | Prompts do `batch_design` descrevem aparencia referenciando shadcn/ui + Tailwind |
| `snapshot_layout` | Apos cada grupo logico (todos primitivos, layout de pagina), NAO a cada chamada |
| `get_screenshot` | Apenas em milestones: fim de fase, fim de pagina |
| Review checklist | Nos milestones: Spacing, Typography, Contrast, Alignment, Clipping, Repetition |
| `get_editor_state` | No inicio do trabalho para confirmar contexto e conexao |
| `batch_get` | Inspecionar hierarquia antes de modificar elementos existentes |
| Componentes | Sempre `reusable: true` com nomes semanticos |
| Instancias | Via `ref` — nunca duplicar manualmente conteudo de componente |
| Slots | Frame vazio dentro de componente marcado como slot. Na `batch_design`: "cria frame vazio marcado como slot para conteudo" |
| Context7 | Consultar shadcn/ui e Tailwind v4 via Context7 MCP para referencia visual |
| Arquivo unico | Um `.pen` por projeto — DS + paginas no mesmo arquivo |
| Fontes | Pencil usa fontes do sistema. Se nao instalada, usar fallback (`system-ui`/`monospace`) |
| Variables | Sempre referenciar (`$color-primary`, `$space-md`) — nunca hardcoded apos registra-las |

### Tratamento de erros

| Erro | Acao |
|------|------|
| `batch_design` falha | Ler erro, simplificar prompt (dividir operacoes), tentar novamente. Se persistir, reportar. |
| `snapshot_layout` detecta problemas | Listar, corrigir via `batch_design`, executar `snapshot_layout` novamente. |
| Conexao MCP cai | Instruir usuario a verificar Pencil aberto + `.pen` ativo. `get_editor_state` para confirmar. |
| `set_variables` falha parcial | `get_variables` para estado atual, re-enviar apenas as nao criadas. |

---

## Passo 1: Verificar Ambiente Pencil

1. `get_editor_state` para confirmar conexao e `.pen` ativo. Se nao houver `.pen`: instruir usuario a criar.
2. `get_variables` para verificar variables existentes. Se ja existirem: perguntar se continuar ou comecar do zero.

---

## Passo 2: Ler Frontend Blueprint

| Documento | O que extrair |
|-----------|---------------|
| `docs/frontend/03-design-system.md` | Tokens: cores, tipografia, espacamento, breakpoints |
| `docs/frontend/04-components.md` | Hierarquia de componentes, variantes e props |
| `docs/frontend/07-routes.md` | Rotas, layouts, tipos (publica/protegida/admin) |
| `docs/frontend/08-flows.md` | Fluxos de UI e interacoes por pagina |
| `docs/frontend/05-state.md` | Estado gerenciado por pagina |
| `docs/frontend/14-copies.md` | Textos/copies por pagina (se disponiveis) |

### 2.1: Consultar Context7

Resolver library IDs para shadcn/ui e Tailwind v4 via `mcp__context7__resolve-library-id`, depois `mcp__context7__query-docs` para variantes/props/estados de cada componente e escala de cores/spacing/tipografia/radius/shadows.

### 2.2: Montar Conjuntos de Referencia

Montar conjuntos internos: **TOKENS**, **COMPONENTES** (primitivos/compostos com variantes shadcn/ui), **ROTAS** (layout, tipo), **FLUXOS**, **COPIES**.

---

## Passo 3: Variables & Temas

### 3.1: Registrar Variables Nativas

Via `set_variables`, tokens por categoria:

| Categoria | Exemplos | Temas |
|-----------|----------|-------|
| Cores | `$color-primary`, `$color-secondary`, `$color-background`, `$color-foreground`, `$color-muted`, `$color-error`, `$color-warning`, `$color-success` | light + dark |
| Tipografia | `$font-family-sans`, `$font-family-mono`, `$font-size-xs`(12) a `$font-size-4xl`(36) | — |
| Spacing | `$space-xs`(4), `$space-sm`(8), `$space-md`(16), `$space-lg`(24), `$space-xl`(32), `$space-2xl`(48) | — |
| Radius | `$radius-sm`(2), `$radius-md`(6), `$radius-lg`(8), `$radius-xl`(12) | — |

Temas light/dark: cores suportam valores por tema. Paginas usam light por padrao. NAO duplicar frames para dark — variables trocam automaticamente.

### 3.2: Design Brief

Apresentar resumo dos tokens (cores hex, tipografia, espacamento, breakpoints, frame 1440px, direcao visual). Aguardar confirmacao.

### 3.3: Criar Frame "Design System"

Via `batch_design`: frame 'Design System' 1440px, layout vertical, padding 48px, gap 48px, fundo $color-background. Titulo + subtitulo.

### 3.4: Construir Secoes de Tokens

Cada secao via `batch_design` separado:

**A) Paleta de Cores** — Rows de swatches (cor + hex + nome variable). Row 1: primary, secondary, background, foreground. Row 2: muted, error, warning, success. `snapshot_layout`.

**B) Escala Tipografica** — Samples empilhados: Heading 1 (700/36px), Heading 2 (600/24px), Body (400/16px), Caption (400/14px), Code (mono 400/14px).

**C) Espacamento** — Barras horizontais proporcionais ao valor de cada token com labels. `snapshot_layout`.

**D) Breakpoints** — Indicadores lado a lado: sm(640/Mobile), md(768/Tablet), lg(1024/Desktop), xl(1280/Wide) com labels.

### 3.5: Milestone

`get_screenshot` do DS. Review checklist. Resumo dos tokens registrados.

---

## Passo 4: Planejamento de Telas

### 4.1: Mapear Componentes por Tela

Cruzar ROTAS + FLUXOS + COMPONENTES. Para cada rota: Layout, Componentes (primitivos/compostos/feature), Estados (loading/empty/error/success), Acoes (evento + destino/efeito).

### 4.2: Apresentar Plano

Tabela: # | Rota | Layout | Componentes Layout | Componentes Pagina | Estados.
Mapa de acoes: Componente | Acao | Destino/Efeito (por rota).
Lista de componentes: Componente | Tipo | Variantes | Usado em.
Ordem de construcao (maximiza reuso). Aguardar aprovacao.

### 4.3: Milestone

Usuario aprova plano antes de prosseguir. Iterar ate aprovacao.

---

## Passo 5: Criar Componentes no Design System

TODOS os componentes antes de qualquer pagina.

### 5.1: Expandir Frame do DS

Criar sub-frames dentro do DS com layout vertical gap 24px:

```
Design System (frame raiz)
+-- Tokens (Passo 3)
+-- Primitivos (Button, Input, Badge...)
+-- Compostos (Card, Modal, DataTable...)
+-- Layout (Sidebar, Navbar, AppLayout, AuthLayout...)
+-- Feature (StatsCard, UserRow...)
```

### 5.2: Titulo da Secao

Entre Tokens e Primitivos: titulo 'Componentes' ($font-size-4xl) + subtitulo '{{N}} componentes . {{N}} variantes' ($font-size-sm $color-muted).

### 5.3: Renderizar Componentes por Grupo

Para cada componente: `batch_design` referenciando shadcn/ui, marcar `reusable: true`, criar variantes lado a lado com labels, incluir "Usado em: {{rotas}}".

**A) Primitivos** — Botoes, inputs, badges etc. com variantes. `snapshot_layout` apos todos.
**B) Compostos** — Usam instancias dos primitivos + slots para areas substituiveis. `snapshot_layout` apos todos.
**C) Layout** — Componentes estruturais com slots (AppLayout, AuthLayout). `snapshot_layout` apos todos.
**D) Feature** — Combinam primitivos/compostos via instancias. `snapshot_layout` apos todos.

### 5.4: Milestone — Componentes

`get_screenshot` do DS. Review checklist. `batch_get` para listar componentes. Resumo: tokens + tabela Componente | Variantes | Usado em. Confirmar antes de compor paginas.

---

## Passo 6: Composicao de Paginas

Montar paginas USANDO instancias (`ref`) dos componentes do DS.

### 6.1: Anunciar Pagina

Informar: pagina N/total, nome, rota, componentes DS que serao usados.

### 6.2: Design Brief da Pagina

Layout, frame 1440x900, componentes (todos do DS), estados, conteudo (flows + copies). Tabela de acoes. Aguardar confirmacao.

### 6.3: Criar Frame

Frame 'Page — {{rota}}' 1440x900, posicionado a direita do anterior com gap 100px, fundo $color-background.

### 6.4: Construir com Instancias

Ordem: 1) Shell do layout (instancia), 2) Preencher slots (Sidebar, Navbar), 3) Conteudo (instancias pagina/feature), 4) Textos (copies ou placeholder realista). `snapshot_layout` -> corrigir.

### 6.5: Milestone

`get_screenshot`. Review checklist. Apresentar ao usuario.

### 6.6: Componentes Nao Previstos

Se surgir componente nao planejado: informar, adicionar ao DS como `reusable: true`, usar instancia na pagina.

### 6.7: Proxima Pagina

Informar progresso N/total. Voltar ao 6.1.

---

## Passo 7: Fluxos de Interacao

Frames sequenciais representando estados antes/durante/depois de cada acao.

### 7.1: Identificar Fluxos

Por pagina (Passo 4 + `08-flows.md`): **happy path** (obrigatorio), **erro mais comum** (obrigatorio), estados intermediarios se relevantes. Apresentar fluxos com N frames. Aguardar confirmacao.

### 7.2: Criar Frames de Fluxo

Duplicar frame base, renomear (`Page — /login -> Loading`), posicionar a direita (gap 60px entre frames do mesmo fluxo, 100px entre paginas), modificar elementos que mudam.

### 7.3: Anotacoes

Labels entre frames descrevendo a acao (12px $color-muted). NAO simular: navegacao simples se destino ja existe, estados identicos a outra tela.

### 7.4: Verificacao

`snapshot_layout` apos frames de fluxo. `get_screenshot` do conjunto. Review checklist. Resumo com lista de frames e conexoes.

---

## Passo 8: Resumo Final

Apresentar:
- Tabela: Frame | Rota | Tipo (DS/Pagina/Fluxo) | Dimensao
- DS: N cores (light/dark), N tipografia, N espacamento, N breakpoints, N radius + N primitivos, N compostos, N layout, N feature
- Paginas: N/total. Fluxos: N frames (happy paths + erros). Paginas restantes (se houver).
- Notas: `.pen` salvo via Git. Para ajustar: selecionar e descrever. Para mais paginas: `/pencil`.
