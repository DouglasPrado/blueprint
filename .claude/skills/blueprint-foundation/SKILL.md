---
name: blueprint-foundation
description: Fase 1 do blueprint tecnico — gera 00-context, 01-vision, 02-principles e 03-requirements.
---

# Blueprint — Fase 1: Fundacao

Gera os 4 documentos que derivam diretamente do PRD: contexto, visao, principios e requisitos.

## Contexto (ler uma vez)

- `docs/prd.md` — fonte primaria de todos os 4 documentos
- Templates a preencher: `docs/blueprint/00-context.md`, `01-vision.md`, `02-architecture_principles.md`, `03-requirements.md`

## Convencoes

- **Escrita:** doc so com `{{placeholders}}` → Write. Doc com conteudo real → Edit, inserindo antes de `<!-- APPEND:... -->`. Alteracao pontual → `/increment`.
- **Origem:** marque conteudo derivado com `<!-- do PRD -->` ou `<!-- inferido do PRD -->`.
- **Versoes:** tecnologias com versao → `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`.
- **Nunca invente** numeros, metricas, SLAs ou nomes proprios — extraia do PRD ou pergunte.
- **Perguntas: maximo 3 nesta skill inteira** (nao por documento). Agrupe e faca de uma vez, antes de gerar qualquer doc.
- **Idioma:** identificadores tecnicos em ingles; descricoes em portugues.

## Analise de Lacunas (fazer antes de gerar)

Varra o PRD procurando os insumos dos 4 docs de uma so vez. Priorize as 3 perguntas nesta ordem de importancia:

1. **Limites do sistema e integracoes** (00) — o que esta fora do escopo e com quais sistemas externos ele fala
2. **Metricas de sucesso e nao-objetivos** (01) — o que o PRD raramente define
3. **SLAs e metas de performance** (03) — thresholds concretos dos requisitos nao funcionais

Se o PRD cobrir tudo isso, nao pergunte nada.

---

## 00 — Contexto do Sistema

Quem usa, com que sistemas externos fala, onde terminam as responsabilidades e o que restringe as decisoes.

Preencha:
- **Atores**: pessoas, sistemas e dispositivos que interagem com o sistema
- **Sistemas Externos**: integracoes necessarias
- **Limites do Sistema**: o que esta dentro e o que esta fora do escopo
- **Restricoes e Premissas**: tecnicas, de negocio e regulatorias

**Diagrama:** atualize `docs/diagrams/context/system-context.mmd` com os atores e sistemas externos, substituindo todos os placeholders.

---

## 01 — Visao do Sistema

Preencha:
- **Problema**: qual dor resolve e quem sofre com ela
- **Elevator Pitch**: siga exatamente o formato "Para [publico] que [necessidade], o [sistema] e um [categoria] que [beneficio]. Diferente de [alternativa], nosso sistema [diferencial]."
- **Objetivos**: resultados concretos e mensuraveis
- **Usuarios**: personas, necessidades, frequencia de uso
- **Valor Gerado**: valor tangivel por grupo de usuario
- **Metricas de Sucesso**: como medir se os objetivos estao sendo cumpridos
- **Nao-objetivos**: o que o sistema deliberadamente NAO faz

---

## 02 — Principios Arquiteturais

Principios sao as leis do sistema — toda decisao tecnica posterior deve ser compativel com eles. Um PRD raramente os declara; infira a partir dos sinais:

| Sinal no PRD | Principio sugerido |
|---|---|
| Requisitos de seguranca | Seguranca por padrao |
| Requisitos de disponibilidade | Sem ponto unico de falha |
| Requisitos de observabilidade | Observabilidade obrigatoria |
| Mencoes a escala | Design para escala horizontal |
| Mencoes a simplicidade | Simplicidade sobre complexidade |

Proponha **3-7 principios** e mostre ao usuario para ajuste antes de escrever. Para cada um:
- **Nome**: titulo curto e memoravel
- **Descricao**: 1-2 frases
- **Justificativa**: por que importa para ESTE sistema
- **Implicacoes praticas**: 2-3 consequencias concretas no dia-a-dia

---

## 03 — Requisitos

Preencha:
- **Requisitos Funcionais**: tabela com ID (RF-001, RF-002...), descricao, prioridade MoSCoW (Must/Should/Could/Won't) e status
- **Requisitos Nao Funcionais**: tabela com categoria, requisito, metrica e threshold concreto (performance, disponibilidade, seguranca, escalabilidade, manutenibilidade)
- **Matriz de Priorizacao**: valor de negocio (1-5), esforco tecnico (1-5), risco (1-5)

**Rastreabilidade:** cada requisito funcional deve se conectar a um objetivo de `01-vision.md`.

---

## Revisao e Proxima Etapa

Apresente os 4 documentos ao usuario em sequencia. Aplique ajustes. Salve os arquivos finais.

> "Fundacao completa (00, 01, 02, 03). Rode `/blueprint-domain` para modelar dominio, dados e estados."
