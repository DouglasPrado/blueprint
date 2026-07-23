---
name: pipeline
description: Executa o pipeline completo de documentacao automaticamente — blueprint tecnico, backend e frontend, sem intervencao.
---

# Pipeline — Execucao Automatica de Toda a Documentacao

Roda as 11+ fases de documentacao em sequencia, **sem parar para perguntar**. Cada fase executa num subagente com contexto limpo, escreve seus documentos e devolve um resumo. Ao final, consolida todas as inferencias em `docs/ASSUMPTIONS.md` para revisao.

```
/pipeline [caminho-do-prd] [clientes] [projeto-alvo]

/pipeline                                      # usa docs/prd.md, infere os clientes
/pipeline docs/prd.md web,mobile               # explicito, para na documentacao
/pipeline docs/prd.md web ../meu-saas/         # inclui o scaffold do codigo
```

## Modo autonomo — o que isso significa

As skills individuais fazem ate 3 perguntas cada. No pipeline **nenhuma pergunta e feita**: cada fase infere do PRD e dos documentos ja preenchidos.

Isso tem um custo real: onde o PRD e vago, o conteudo gerado e uma suposicao, nao um fato. O pipeline compensa de tres formas:

1. Cada inferencia nao trivial e marcada no proprio documento com `<!-- assumido: ... -->`
2. Todas sao consolidadas em `docs/ASSUMPTIONS.md`, classificadas por risco
3. O relatorio final lista as de **risco alto** — as que provavelmente estao erradas

Trate o resultado como um rascunho completo, nao como documentacao final. Corrija com `/increment`.

---

## Passo 1: Pre-requisitos

Toda validacao acontece **antes** do run comecar. Depois disso, nenhuma interrupcao.

**PRD.** Verifique `docs/prd.md`. Se nao existir e o usuario nao passou um caminho, **pare**:

> "O pipeline precisa do PRD. Passe o caminho (`/pipeline caminho/do/prd.md`) ou crie `docs/prd.md` primeiro.
> Sem PRD nao ha de onde inferir — o resultado seria inteiramente inventado."

Se existir, leia o PRD **completo**. E o unico documento que o orquestrador carrega — todo o resto fica nos subagentes.

**Projeto-alvo.** A ultima fase (`codegen-setup`) escreve codigo fora deste repositorio e precisa saber onde. Se o usuario nao informou:

> "Onde o codigo deve ser gerado? (ex: `../meu-saas/`)
> Responda o caminho, ou `pular` para rodar so a documentacao."

Resolva isso **agora**, no kickoff — nunca no meio do run. Se o usuario responder `pular`, remova a fase final do plano.

## Passo 2: Determinar os Clientes Frontend

Se o usuario passou os clientes como argumento, use-os. Caso contrario, infira do PRD:

| Sinal no PRD | Cliente |
|---|---|
| "app", "iOS", "Android", "React Native", "Expo", "push notification", "offline" | `mobile` |
| "desktop", "Electron", "Tauri", "system tray", "menu bar" | `desktop` |
| "web", "SaaS", "dashboard", "painel", "SEO", "navegador" | `web` |
| Nenhum sinal claro | `web` (padrao) |

Registre a escolha como suposicao de risco **medio** se foi inferida.

## Passo 3: Detectar Progresso (retomada)

Verifique quais documentos ja tem conteudo real (sem `{{placeholders}}`). **Pule as fases ja concluidas.** Isso torna o pipeline retomavel: se a sessao cair no meio, rode `/pipeline` de novo e ele continua de onde parou.

Apresente o plano antes de comecar:

> "**Pipeline:** {{N}} fases · {{M}} documentos · clientes: {{lista}}
>
> | # | Fase | Docs | Status |
> |---|------|------|--------|
> | 1 | blueprint-foundation | 00, 01, 02, 03 | pendente / ja preenchido |
> | ... | ... | ... | ... |
>
> Modo autonomo: nenhuma pergunta sera feita. Comecando."

Nao aguarde confirmacao — o usuario ja optou pelo modo automatico ao rodar `/pipeline`.

---

## Passo 4: Executar as Fases

**Sequencialmente.** Cada fase le o que a anterior produziu — nao paralelize a cadeia do blueprint.

Para cada fase, use a ferramenta **Agent** com `subagent_type: general-purpose` e `run_in_background: false` (aguarde cada uma terminar antes da proxima).

### Ordem das fases

| # | Skill | Argumento | Docs gerados |
|---|-------|-----------|--------------|
| 1 | `blueprint-foundation` | — | blueprint 00, 01, 02, 03 |
| 2 | `blueprint-domain` | — | blueprint 04, 05, 09 |
| 3 | `blueprint-architecture` | — | blueprint 06, 10 |
| 4 | `blueprint-flows` | — | blueprint 07, 08 |
| 5 | `blueprint-quality` | — | blueprint 12, 13, 14, 15 |
| 6 | `blueprint-plan` | — | blueprint 11, 16 |
| 7 | `backend` | — | backend 00 a 14 (15 docs) |
| 8 | `frontend-design-system` | — | frontend shared/03 |
| 9 | `frontend` | clientes | frontend shared/06, shared/15 |
| 10 | `frontend-app` | `{client}` | frontend {client} 00,01,02,04,05,07,08,14 |
| 11 | `frontend-quality` | `{client}` | frontend {client} 09,10,11,12,13 |
| 12 | `codegen-setup` | `{projeto-alvo}` | CLAUDE.md, `src/contracts/`, schema, scaffold |

As fases 10 e 11 repetem para **cada** cliente selecionado, sempre `app` antes de `quality`.

> A fase 9 roda depois da 7 de proposito: `shared/15-api-dependencies.md` usa `docs/backend/05-api-contracts.md` como fonte autoritativa dos endpoints.

### A fase 12 e diferente das outras

`codegen-setup` escreve **codigo fora deste repositorio** e tem um portao objetivo: type check, lint e validacao de schema. As regras do modo autonomo mudam para ela:

- **Nao ha suposicao a marcar** — ela deriva mecanicamente dos documentos ja preenchidos. Se um documento estava suposto, o scaffold herda a suposicao; nao duplique no `ASSUMPTIONS.md`.
- **O portao e real.** Se type check, lint ou schema validate falhar, o subagente deve corrigir e rodar de novo. Se ainda falhar, deve **reportar a falha** — nunca declarar sucesso com o scaffold quebrado.
- **Nao commite** no projeto-alvo. Deixe as mudancas em working tree para o usuario revisar.

Acrescente ao prompt do subagente desta fase:

```
Esta fase escreve codigo em {projeto-alvo}, fora do repositorio de documentacao.

- Rode type check, lint e validacao de schema ao final. Corrija o que falhar.
- Se apos a correcao ainda houver erro, devolva-o em GAPS e NAO declare sucesso.
- Nao faca commit no projeto-alvo.
- ASSUMPTIONS fica vazio: esta fase deriva dos documentos, nao do PRD.

Acrescente ao retorno:
GATE:
  typecheck: ok|falhou — {resumo}
  lint:      ok|falhou — {resumo}
  schema:    ok|falhou — {resumo}
```

### Prompt de cada subagente

Monte exatamente assim, substituindo os campos entre chaves:

```
Voce executa a fase {N} de {TOTAL} do pipeline de documentacao no projeto {cwd}.

MODO AUTONOMO — estas regras SOBRESCREVEM o que a skill disser:

1. NAO faca perguntas. Nao ha usuario nesta sessao — perguntar trava o pipeline.
   Onde a skill mandar perguntar, INFIRA do PRD e dos documentos ja preenchidos.
2. NAO apresente documentos para revisao e NAO aguarde aprovacao. Escreva e siga.
3. Marque CADA inferencia nao trivial no proprio documento:
   <!-- assumido: {o que foi assumido} — base: {de onde inferiu} -->
   Inferencia trivial (derivada direta de um doc anterior) usa o marcador normal
   <!-- do blueprint: XX-arquivo.md --> e NAO entra no relatorio.
4. Preencha TODOS os {{placeholders}}. Nenhum pode sobrar no arquivo final.
5. NAO invente numeros que aparentem precisao (SLAs, percentuais, volumes, precos)
   sem base. Quando nao houver base, use faixa ou valor claramente generico e
   classifique a suposicao como risco ALTO.
6. Respeite as demais regras da skill: Write se o doc so tem placeholders, Edit se
   ja tem conteudo real, insercao antes de <!-- APPEND:... -->.

TAREFA: invoque a skill `{skill}` pela ferramenta Skill{, passando o argumento `{arg}`}
e execute-a integralmente ate o ultimo documento.

RETORNO — devolva SOMENTE neste formato, sem preambulo nem comentario:

DOCS:
<caminho de cada arquivo escrito, um por linha>

ASSUMPTIONS:
- {arquivo} | {o que foi assumido} | {base da inferencia} | {alto|medio|baixo}

GAPS:
- {o que o PRD nao cobre e onde a suposicao ficou fragil}
```

### Classificacao de risco

| Risco | Quando | Exemplo |
|-------|--------|---------|
| **alto** | Numero, SLA, metrica ou nome proprio sem nenhuma base no PRD | "p95 < 300ms" quando o PRD nao fala de latencia |
| **medio** | Escolha tecnica plausivel mas nao declarada | "PostgreSQL" inferido de "dados relacionais" |
| **baixo** | Derivacao logica direta de algo declarado | Entidade `Order` porque o PRD fala em pedidos |

### Entre as fases

Apos cada subagente retornar:

1. Acumule `DOCS`, `ASSUMPTIONS` e `GAPS` — **nao releia os documentos gerados**. E isso que mantem o contexto do orquestrador pequeno.
2. Emita uma linha de progresso: `[{N}/{TOTAL}] {skill} — {n} docs, {n} suposicoes ({n} de risco alto)`
3. Se um subagente falhar ou devolver formato invalido, **nao pare o pipeline**: registre a falha, pule para a proxima fase e reporte no final. Fases posteriores que dependiam dela vao inferir mais — marque isso como gap.

---

## Passo 5: Consolidar as Suposicoes

Escreva `docs/ASSUMPTIONS.md` a partir do que os subagentes devolveram. **O orquestrador escreve este arquivo** — subagentes nunca escrevem nele (evita conflito de escrita).

```markdown
# Suposicoes do Pipeline

> Gerado por `/pipeline` em modo autonomo. Cada item abaixo foi **inferido**, nao extraido
> do PRD. Revise os de risco alto antes de tratar a documentacao como definitiva.
>
> Para corrigir: `/increment` (um blueprint) ou `/patch` (mudanca global).

## Resumo

| Risco | Qtd | Significado |
|-------|-----|-------------|
| Alto | {{n}} | Provavelmente errado — revise |
| Medio | {{n}} | Plausivel — confirme |
| Baixo | {{n}} | Derivacao segura |

## Risco Alto

| # | Documento | Suposicao | Base | Como corrigir |
|---|-----------|-----------|------|---------------|
| 1 | blueprint/03-requirements.md | p95 < 300ms | nenhuma — valor padrao | `/increment` → blueprint |

## Risco Medio
{{mesma tabela}}

## Risco Baixo
{{mesma tabela}}

## Lacunas do PRD

O PRD nao cobre os pontos abaixo. Considere enriquece-lo e rodar `/increment`:

- {{gap}}
```

## Passo 6: Relatorio Final

> "**Pipeline concluido** — {{N}} fases, {{M}} documentos.
>
> | Fase | Docs | Suposicoes | Risco alto |
> |------|------|-----------|------------|
> | blueprint-foundation | 4 | {{n}} | {{n}} |
> | ... | ... | ... | ... |
> | **Total** | **{{M}}** | **{{n}}** | **{{n}}** |
>
> {{Se houve falhas: **Fases que falharam:** lista + o que ficou incompleto}}
>
> **Scaffold ({{projeto-alvo}}):** typecheck {{ok|falhou}} · lint {{ok|falhou}} · schema {{ok|falhou}}
>
> **{{n}} suposicoes de risco alto** precisam da sua revisao — estao no topo de
> `docs/ASSUMPTIONS.md`. As tres mais criticas:
> 1. {{documento}} — {{suposicao}}
> 2. ...
>
> **Proximos passos:**
> - Revise `docs/ASSUMPTIONS.md` e corrija com `/increment` — o scaffold herdou as suposicoes
> - `/specs` — backlog integral de tasks
> - `/build` — implementar as features em loop com portoes de teste"

---

## Limites conhecidos

- **Qualidade depende do PRD.** PRD raso gera documentacao rasa com muitas suposicoes de risco alto. O pipeline nao inventa contexto de negocio — ele extrapola o que existe.
- **Nao substitui as skills individuais.** Se o projeto e critico, rode fase a fase (`/blueprint-foundation`, `/blueprint-domain`, ...) e responda as perguntas. O pipeline e para primeira versao rapida e para projetos onde o PRD ja e detalhado.
- **Vai ate o scaffold, nao ate as features.** A fase 12 gera tipos, schema e estrutura — tudo derivavel mecanicamente dos documentos. Implementar features e outro loop, com outros portoes: `/build`.
- **O scaffold herda as suposicoes dos documentos.** Se `05-data-model.md` supos PostgreSQL, o schema nasce em PostgreSQL. Revise `ASSUMPTIONS.md` antes de construir em cima.
- **Custo.** Um subagente por fase multiplica o consumo de tokens em relacao a rodar tudo numa sessao — e o preco por nao estourar o contexto.
