---
name: frontend-design-system
description: Gera o design system compartilhado (shared/03-design-system.md) — tokens, tipografia, cores e iconografia.
---

# Frontend — Design System (compartilhado)

Gera `docs/frontend/shared/03-design-system.md`. Documento **compartilhado** entre web, mobile e desktop.

## Contexto (ler uma vez)

- `docs/blueprint/01-vision.md` — visao e identidade do produto (define a personalidade visual)
- `docs/blueprint/04-domain-model.md` — entidades e termos do dominio
- `docs/prd.md` — complemento
- Template a preencher: `docs/frontend/shared/03-design-system.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do blueprint: XX-arquivo.md -->`.
- **Versoes:** bibliotecas de UI → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Perguntas:** as escolhas de tipografia e paleta **sao** as perguntas desta skill — apresente opcoes em vez de decidir sozinho.

## Cobertura

- **Design Tokens**: cores, tipografia, espacamento, breakpoints
- **Temas**: light/dark/custom — implementacao e alternancia
- **Ferramentas**: Figma, Storybook
- **Catalogo de Componentes Base**: primitivos (Button, Input, Typography, ...)

---

## Tipografia — Google Fonts via Fontpair

Escolha um par (heading + body) em https://www.fontpair.co/all usando Google Fonts.

1. Analise a **visao e identidade do produto** (`docs/blueprint/01-vision.md`)
2. Escolha a **categoria** que representa a personalidade do produto:

| Categoria | Quando usar | Exemplos de pares (Heading / Body) |
|---|---|---|
| **Serif + Sans** | Editorial, premium, confianca | Playfair Display / Source Sans 3, Lora / Open Sans, Merriweather / Montserrat, Libre Baskerville / Roboto, Cinzel / Raleway |
| **Sans + Sans** | Moderno, limpo, tech | Montserrat / Lato, Raleway / Open Sans, Josefin Sans / Roboto, Chivo / Lato, Inter / Inter |
| **Display + Sans** | Bold, criativo, impactante | Abril Fatface / Raleway, Alfa Slab One / Montserrat, Anton / Roboto, Concert One / Open Sans |
| **Slab Serif + Sans** | Solido, editorial moderno | Arvo / Lato, Bitter / Source Sans Pro, Crete Round / Open Sans, Bree Serif / Raleway |
| **Monospace + Sans** | Tecnico, developer tools | JetBrains Mono / Inter, Fira Code / Open Sans, Space Mono / Work Sans |

3. **Apresente 2-3 opcoes da categoria escolhida e pergunte ao usuario** qual representa melhor o produto
4. Documente com o import do Google Fonts:

```css
@import url('https://fonts.googleapis.com/css2?family={HeadingFont}:wght@400;500;600;700&family={BodyFont}:wght@300;400;500;600&display=swap');
```

Tokens a definir no documento:

| Token | Uso | Exemplo |
|---|---|---|
| `--font-heading` | Titulos h1-h3, hero, destaque | `'{HeadingFont}', serif` |
| `--font-body` | Corpo de texto, paragrafos, labels | `'{BodyFont}', sans-serif` |
| `--font-mono` | Codigo, dados tecnicos | `'JetBrains Mono', monospace` |
| `font-size` scale | Sistema de tamanhos | `xs(12) sm(14) base(16) lg(18) xl(20) 2xl(24) 3xl(30) 4xl(36)` |
| `font-weight` scale | Pesos disponiveis | `light(300) regular(400) medium(500) semibold(600) bold(700)` |
| `line-height` scale | Alturas de linha | `tight(1.25) normal(1.5) relaxed(1.75)` |

---

## Paleta de Cores — Coolors

Escolha uma paleta de 5 cores em https://coolors.co/palettes/trending e mapeie para CSS variables (padrao shadcn/ui + extensoes).

1. Analise a identidade visual desejada no blueprint
2. Proponha uma paleta que represente o produto. Referencias:

| Paleta | Cores | Vibe |
|---|---|---|
| Earth Tones | `#264653` `#2A9D8F` `#E9C46A` `#F4A261` `#E76F51` | Natural, organico |
| Bold Primary | `#003049` `#D62828` `#F77F00` `#FCBF49` `#EAE2B7` | Energetico, direto |
| Beautiful Blues | `#011F4B` `#03396C` `#005B96` `#6497B1` `#B3CDE0` | Corporativo, confiavel |
| Blueberry Basket | `#FFFFFF` `#D0E1F9` `#4D648D` `#283655` `#1E1F26` | Elegante, tech |
| Pastel Rainbow | `#A8E6CF` `#DCEDC1` `#FFD3B6` `#FFAAA5` `#FF8B94` | Leve, amigavel |
| Metro UI | `#D11141` `#00B159` `#00AEDB` `#F37735` `#FFC425` | Vibrante, app |
| Beach Towels | `#FE4A49` `#2AB7CA` `#FED766` `#E6E6EA` `#F4F4F8` | Fresco, divertido |

3. O usuario pode colar o link direto do Coolors (ex: `coolors.co/palette/264653-2a9d8f-e9c46a-f4a261-e76f51`)
4. Derive toda a paleta semantica a partir das 5 cores

### Mapeamento das 5 cores (formato oklch — converter de hex)

```
Cor 1 (mais escura/ancora)  → --primary       (botoes, links, CTA principal)
Cor 2 (complementar)        → --accent        (destaque secundario, hover states)
Cor 3 (neutra/suave)        → --secondary     (backgrounds alternativos, badges)
Cor 4 (quente/atencao)      → --warning       (alertas, atencao)
Cor 5 (vibrante/contraste)  → --destructive   (erros, acoes destrutivas)
```

### Estrutura completa do globals.css

Documente TODAS as variables (light + dark):

```css
:root {
  --radius: 0.625rem;

  /* Backgrounds */
  --background: oklch(...);        /* Fundo principal da pagina */
  --foreground: oklch(...);        /* Texto principal */

  /* Cards e Popovers */
  --card: oklch(...);              /* Fundo de cards */
  --card-foreground: oklch(...);   /* Texto em cards */
  --popover: oklch(...);           /* Fundo de popovers/dropdowns */
  --popover-foreground: oklch(...);

  /* Cores semanticas */
  --primary: oklch(...);           /* CTA, botoes principais, links — Cor 1 */
  --primary-foreground: oklch(...);
  --secondary: oklch(...);         /* Backgrounds secundarios — Cor 3 */
  --secondary-foreground: oklch(...);
  --accent: oklch(...);            /* Destaques, hovers — Cor 2 */
  --accent-foreground: oklch(...);
  --muted: oklch(...);             /* Textos e areas desabilitadas */
  --muted-foreground: oklch(...);

  /* Status */
  --destructive: oklch(...);       /* Erros, delete — Cor 5 */
  --destructive-foreground: oklch(...);
  --success: oklch(...);
  --success-foreground: oklch(...);
  --warning: oklch(...);           /* Alertas — Cor 4 */
  --warning-foreground: oklch(...);
  --info: oklch(...);
  --info-foreground: oklch(...);

  /* Bordas e inputs */
  --border: oklch(...);
  --input: oklch(...);
  --ring: oklch(...);              /* Focus ring */

  /* Charts */
  --chart-1 a --chart-5: oklch(...);

  /* Sidebar (se aplicavel) */
  --sidebar, --sidebar-foreground, --sidebar-primary, --sidebar-primary-foreground,
  --sidebar-accent, --sidebar-accent-foreground, --sidebar-border, --sidebar-ring
}

.dark {
  /* Mesmas variables com valores invertidos */
}
```

### Regras de derivacao

- **background/foreground**: tons neutros derivados da cor mais escura (dessaturar)
- **card/popover**: levemente mais claro que background
- **muted**: tom neutro dessaturado
- **border/input**: intermediario entre background e foreground
- **ring**: mesmo valor que primary
- **chart-1 a chart-5**: as 5 cores da paleta diretamente
- **Dark mode**: inverter lightness (L) no oklch, manter chroma (C) e hue (H)

---

## Iconografia

**Lucide Animated** (https://lucide-animated.com/) — fonte **primaria** para icones animados. Usar em loading states, transicoes, feedback visual, onboarding, empty states. Importar via `lucide-react` com wrapper de animacao.

**shadcn/ui Icons** (https://www.shadcn.io/icons) — fonte **complementar** para icones estaticos. Usar em navegacao, botoes, menus, labels, badges, tabelas. Mesmo pacote base (`lucide-react`).

| Token | Valor | Uso |
|---|---|---|
| `icon-size-sm` | 16px | Inline em texto, badges |
| `icon-size-md` | 20px | Botoes, menus, nav |
| `icon-size-lg` | 24px | Headers, destaque |
| `icon-size-xl` | 32px | Empty states, hero |
| `icon-stroke` | 1.5-2px | Espessura padrao |

Regras: todos os icones usam `currentColor` para herdar a cor do contexto; animados para feedback e transicoes, estaticos para UI estrutural; nao misturar outros icon packs alem destes dois.

---

## Revisao e Proxima Etapa

Apresente o documento ao usuario. Aplique ajustes. Salve o arquivo final.

> "Design System definido (compartilhado entre todos os clientes). Rode `/frontend-app {client}` para documentar a aplicacao do cliente desejado."
