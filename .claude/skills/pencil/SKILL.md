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
| Fontes | Pencil usa fontes do sistema. Se nao instalada, instruir usuario ou usar fallback (`system-ui`/`monospace`) |
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

1. `mcp__pencil__get_editor_state` para confirmar conexao e `.pen` ativo.
2. Se nao houver `.pen`: instruir usuario a criar (Pencil > New File > salvar `design.pen` na raiz).
3. `mcp__pencil__get_variables` para verificar variables existentes.
4. Se ja existirem variables/componentes: perguntar se continuar adicionando ou comecar do zero.

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

### 2.1: Consultar shadcn/ui e Tailwind v4 via Context7

**shadcn/ui:** `mcp__context7__resolve-library-id` (query "shadcn/ui"), depois `mcp__context7__query-docs` para cada componente do blueprint — variantes, props, estados, aparencia, composicao.

**Tailwind v4:** `mcp__context7__resolve-library-id` (query "tailwindcss"), depois `mcp__context7__query-docs` — escala de cores, espacamento, tipografia (text-xs..text-xl), border-radius (rounded-sm=2px, md=6px, lg=8px, xl=12px), shadows.

### 2.2: Montar Conjuntos de Referencia

Monte conjuntos internos: **TOKENS** (cores light/dark, tipografia px, espacamento, breakpoints), **COMPONENTES** (primitivos/compostos com variantes shadcn/ui), **ROTAS** (layout, tipo, pagina), **FLUXOS** (por rota), **COPIES** (textos por pagina).

---

## Passo 3: Variables & Temas

### 3.1: Registrar Variables Nativas

Via `mcp__pencil__set_variables`, tokens por categoria:

| Categoria | Exemplos | Temas |
|-----------|----------|-------|
| Cores | `$color-primary`, `$color-secondary`, `$color-background`, `$color-foreground`, `$color-muted`, `$color-error`, `$color-warning`, `$color-success` | light + dark |
| Tipografia | `$font-family-sans`, `$font-family-mono`, `$font-size-xs`(12) a `$font-size-4xl`(36) | — |
| Spacing | `$space-xs`(4), `$space-sm`(8), `$space-md`(16), `$space-lg`(24), `$space-xl`(32), `$space-2xl`(48) | — |
| Radius | `$radius-sm`(2), `$radius-md`(6), `$radius-lg`(8), `$radius-xl`(12) | — |

**Temas light/dark:** Cores suportam valores por tema. Paginas usam light por padrao. Dark verificavel alternando no Pencil. NAO duplicar frames para dark — variables trocam automaticamente.

### 3.2: Design Brief

Apresentar resumo dos tokens (cores com hex, tipografia, espacamento, breakpoints, frame 1440px, fundo $color-background, direcao visual). Aguardar confirmacao.

### 3.3: Criar Frame "Design System"

Via `batch_design`: frame 'Design System' 1440px largura, layout vertical, padding 48px, gap 48px, fundo $color-background. Titulo + subtitulo com nome do projeto.

### 3.4: Construir Secoes de Tokens

Cada secao com chamadas separadas ao `batch_design`:

**A) Paleta de Cores** — Secao com titulo, rows de swatches (80x80px cada, cor + hex + nome variable). Primeira row: primary, secondary, background, foreground. Segunda: muted, error, warning, success. `snapshot_layout`.

**B) Escala Tipografica** — Samples empilhados: Heading 1 (700/36px), Heading 2 (600/24px), Body (400/16px), Caption (400/14px), Code (mono 400/14px), todos renderizados no tamanho real.

**C) Espacamento** — Barras horizontais proporcionais ao valor de cada token (altura 12px, cor $color-primary) com labels. `snapshot_layout`.

**D) Breakpoints** — 4 indicadores lado a lado: sm(640/Mobile), md(768/Tablet), lg(1024/Desktop), xl(1280/Wide). Retangulos outline com largura representativa e labels.

### 3.5: Milestone — Tokens

`get_screenshot` do DS. Review checklist. Resumo: N cores (light/dark), N tipografia, N espacamento, N breakpoints, N radius. Seguir para planejamento.

---

## Passo 4: Planejamento de Telas

Planejar TODAS as telas antes de criar componentes ou paginas.

### 4.1: Mapear Componentes por Tela

Cruzar ROTAS + FLUXOS + COMPONENTES. Para cada rota identificar: Layout (componentes), Componentes de pagina (primitivos/compostos), Componentes de feature (dominio), Estados (loading/empty/error/success), Acoes por componente (evento + destino/efeito).

### 4.2: Apresentar Plano ao Usuario

Tabela com: #, Rota, Layout, Componentes de Layout, Componentes de Pagina, Estados.

Mapa de Acoes por Tela: tabela Componente | Acao | Destino/Efeito para cada rota.

Lista completa de componentes a criar: Componente | Tipo | Variantes | Usado em.

Ordem sugerida de construcao (maximiza reuso). Aguardar aprovacao — usuario pode ajustar componentes, ordem, adicionar/remover telas.

### 4.3: Milestone

Usuario aprova plano antes de prosseguir. Iterar ate aprovacao.

---

## Passo 5: Criar Componentes no Design System

TODOS os componentes antes de montar qualquer pagina.

### 5.1: Expandir Frame do DS

Via `batch_design`, criar sub-frames dentro do DS: 'Primitivos', 'Compostos', 'Layout', 'Feature'. Cada um com titulo e layout vertical gap 24px. Estrutura:

```
Design System (frame raiz)
+-- Tokens (Passo 3)
+-- Primitivos (Button, Input, Badge...)
+-- Compostos (Card, Modal, DataTable...)
+-- Layout (Sidebar, Navbar, AppLayout, AuthLayout...)
+-- Feature (StatsCard, UserRow...)
```

### 5.2: Titulo da Secao de Componentes

Entre Tokens e Primitivos: titulo 'Componentes' ($font-size-4xl) + subtitulo '{{N}} componentes . {{N}} variantes' ($font-size-sm $color-muted).

### 5.3: Renderizar Componentes por Grupo

**A) Primitivos** — Para cada, usar `batch_design` referenciando shadcn/ui. Marcar `reusable: true`. Criar variantes lado a lado com labels. Incluir "Usado em: {{rotas}}" abaixo do nome.

Exemplo Button: 'Button/Primary/md' (padding $space-sm $space-md, fundo $color-primary, radius $radius-md, texto branco). Variantes: Secondary (borda, transparente), Ghost (sem borda), Destructive ($color-error).

Exemplo Input: 'Input/Default' (borda $color-muted, radius $radius-md, 36px altura, 280px largura). Variante 'Input/Error' (borda $color-error + mensagem).

Exemplo Badge: 'Badge/Default' (padding 2px $space-sm, radius 9999px, fundo $color-primary 10%, texto $color-primary).

`snapshot_layout` apos todos os primitivos.

**B) Compostos** — Usam instancias dos primitivos + slots para areas substituiveis.

Exemplo Card: layout vertical, padding $space-lg, gap $space-md, borda $color-muted, radius $radius-lg. Header + slot conteudo.
Exemplo Modal: 480px, shadow-lg, radius $radius-xl. Header (titulo + X), slot conteudo, footer (Button/Secondary + Button/Primary).

`snapshot_layout` apos todos os compostos.

**C) Layout** — Componentes estruturais com slots.

Exemplo AppLayout (1440x900): horizontal — Sidebar esquerda (240px, borda direita) + direita vertical (Navbar 64px + slot conteudo com padding).
Exemplo AuthLayout (1440x900): horizontal — metade esquerda (fundo $color-primary 5%, logo) + metade direita (centralizado, slot formulario).

`snapshot_layout` apos todos os layouts.

**D) Feature** — Combinam primitivos/compostos via instancias.

Exemplo StatsCard: instancia Card, no slot: label muted, valor numerico bold, indicador variacao $color-success.

`snapshot_layout` apos todas as features.

### 5.4: Milestone — Componentes

`get_screenshot` do DS completo. Review checklist. `batch_get` para listar componentes (confirmacao). Resumo: tokens + tabela Componente | Variantes | Usado em. Confirmar antes de compor paginas.

---

## Passo 6: Composicao de Paginas

Montar paginas USANDO instancias (`ref`) dos componentes do DS.

### 6.1: Anunciar Pagina

Informar: pagina N/total, nome, rota, componentes DS que serao usados (Layout, Pagina, Feature).

### 6.2: Design Brief da Pagina

Layout, frame 1440x900, componentes (todos do DS), estados, conteudo (flows + copies), tokens. Tabela de acoes: Componente | Acao | Destino/Efeito. Aguardar confirmacao.

### 6.3: Criar Frame da Pagina

Frame 'Page — {{rota}}' de 1440x900, posicionado a direita do anterior com gap 100px, fundo $color-background.

### 6.4: Construir com Instancias

Ordem: 1) Shell do layout (instancia), 2) Preencher slots do layout (Sidebar, Navbar com conteudo), 3) Conteudo da pagina (instancias componentes pagina/feature), 4) Textos e dados (copies ou placeholder realista).

`snapshot_layout` apos construir -> corrigir problemas.

### 6.5: Milestone — Pagina

`get_screenshot`. Review checklist. Apresentar ao usuario.

### 6.6: Verificar Componentes Nao Previstos

Se surgir componente nao planejado: informar usuario, adicionar ao DS como `reusable: true`, `snapshot_layout` no DS, usar instancia na pagina.

### 6.7: Proxima Pagina

Informar progresso N/total. Proxima na fila ou escolha do usuario. Voltar ao 6.1.

---

## Passo 7: Fluxos de Interacao

Frames sequenciais representando estados antes/durante/depois de cada acao.

### 7.1: Identificar Fluxos por Pagina

Baseado no plano (Passo 4) e `docs/frontend/08-flows.md`:
- **Happy path** — obrigatorio
- **Erro mais comum** — obrigatorio
- Estados intermediarios (loading, empty) — se relevantes

Apresentar fluxos com N frames cada. Aguardar confirmacao.

### 7.2: Criar Frames de Fluxo

Duplicar frame base via `batch_design`, renomear, posicionar a direita (gap 60px), modificar elementos que mudam.

**Nomenclatura:** `Page — /login` (base), `Page — /login -> Form preenchido`, `Page — /login -> Loading`, `Page — /login -> Erro validacao`, `Page — /login -> Sucesso`.

### 7.3: Posicionamento

Gap 60px entre frames do mesmo fluxo, 100px entre paginas diferentes:
```
[DS] --100-- [/login] --60-- [/login -> Form] --60-- [/login -> Loading] --100-- [/dashboard] ...
```

### 7.4: Anotacoes de Conexao

Labels entre frames descrevendo a acao (fonte 12px $color-muted).

**NAO simular:** Navegacao simples (Link -> outra rota) se destino ja existe como frame. Estados identicos a outra tela ja simulada.

### 7.5: Verificacao

`snapshot_layout` apos frames de fluxo de uma pagina. Milestone: `get_screenshot` do conjunto. Review checklist.

### 7.6: Resumo do Fluxo

Resumo com lista de frames e conexoes. Seguir para proxima pagina (7.1) ou encerrar.

---

## Passo 8: Resumo Final

Ao encerrar, apresentar:

- Tabela: Frame | Rota | Tipo (DS/Pagina/Fluxo) | Dimensao
- DS final: N cores (light/dark), N tipografia, N espacamento, N breakpoints, N radius + N primitivos, N compostos, N layout, N feature
- Paginas compostas: N/total
- Fluxos: N frames (N happy paths + N erros)
- Paginas restantes (se houver)
- Notas: `.pen` salvo e versionado via Git. Para ajustar: selecionar elementos e descrever. Para mais paginas: `/pencil`.
