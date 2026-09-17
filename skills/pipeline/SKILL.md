---
name: pipeline
description: Executa o pipeline completo de documentacao automaticamente — blueprint tecnico, backend e frontend, sem intervencao.
---

# Pipeline — Execucao Automatica de Toda a Documentacao

Roda as fases de documentacao em sequencia — 13 no fluxo padrao, 16 com `--prototype`, **sem parar para perguntar**. Cada fase executa num subagente com contexto limpo, escreve seus documentos e devolve um resumo. Ao final, consolida todas as inferencias em `docs/ASSUMPTIONS.md` para revisao.

```
/blueprint:pipeline [caminho-do-prd] [clientes] [projeto-alvo] [--prototype]

/blueprint:pipeline                                      # usa docs/prd.md, infere os clientes
/blueprint:pipeline docs/prd.md web,mobile               # explicito, para na documentacao
/blueprint:pipeline docs/prd.md web ../meu-saas/         # inclui o scaffold do codigo
/blueprint:pipeline docs/prd.md web ../meu-saas/ --prototype   # com fase de prototipo
```

## A flag `--prototype`

Insere a **fase de prototipo** — um frontend completo e mockado construido **antes** do backend, para que o contrato de API seja descoberto construindo a interface em vez de inventado antes dela.

| | Sem `--prototype` | Com `--prototype` |
|---|---|---|
| Fases | 13 | 16 |
| Ordem | backend → frontend | design system → **prototipo** → backend → frontend |
| Contrato de API | Derivado dos casos de uso | **Extraido de codigo com consumidor real** |
| Projeto-alvo | So na ultima fase | **Obrigatorio** — o prototipo e codigo |
| Custo | Base | Bem maior: constroi a UI duas vezes |
| Quando compensa | CRUD conhecido, PRD detalhado | Dominio novo, fluxos longos, SaaS com muitas telas |

**A flag exige projeto-alvo.** Sem ele, nao ha onde construir — pare e pergunte, no kickoff.

## Modo autonomo — o que isso significa

As skills individuais fazem ate 3 perguntas cada. No pipeline **nenhuma pergunta e feita**: cada fase infere do PRD e dos documentos ja preenchidos.

Isso tem um custo real: onde o PRD e vago, o conteudo gerado e uma suposicao, nao um fato. O pipeline compensa de tres formas:

1. Cada inferencia nao trivial e marcada no proprio documento com `<!-- assumido: ... -->`
2. Todas sao consolidadas em `docs/ASSUMPTIONS.md`, classificadas por risco
3. O relatorio final lista as de **risco alto** — as que provavelmente estao erradas

Trate o resultado como um rascunho completo, nao como documentacao final. Corrija com `/blueprint:increment`.

---

## Passo 1: Pre-requisitos

Toda validacao acontece **antes** do run comecar. Depois disso, nenhuma interrupcao.

**PRD.** Verifique `docs/prd.md`. Se nao existir e o usuario nao passou um caminho, **pare**:

> "O pipeline precisa do PRD. Passe o caminho (`/blueprint:pipeline caminho/do/prd.md`) ou crie `docs/prd.md` primeiro.
> Sem PRD nao ha de onde inferir — o resultado seria inteiramente inventado."

Se existir, leia o PRD **completo**. E o unico documento que o orquestrador carrega — todo o resto fica nos subagentes.

**Projeto-alvo.** As fases que escrevem codigo fora deste repositorio (`prototype-build` e `codegen-setup`) precisam saber onde. Se o usuario nao informou:

> "Onde o codigo deve ser gerado? (ex: `../meu-saas/`)
> Responda o caminho, ou `pular` para rodar so a documentacao."

Resolva isso **agora**, no kickoff — nunca no meio do run. Se o usuario responder `pular`, remova a fase final do plano.

**Com `--prototype`, o projeto-alvo e obrigatorio.** O prototipo *e* codigo; nao existe versao so-documentacao dele. Se a flag veio sem caminho e o usuario responder `pular`, **pare**:

> "`--prototype` precisa de um projeto-alvo — o prototipo e um app que roda, nao um documento.
> Informe o caminho, ou rode sem a flag para so a documentacao."

**Com `--prototype`, verifique tambem o custo.** A fase constroi a interface inteira; some-se a isso a implementacao final. Avise uma vez, no kickoff, e siga — o usuario ja optou ao passar a flag:

> "Modo prototipo: a UI sera construida duas vezes (mockada agora, integrada depois). O retorno e um contrato de API com consumidor real e as lacunas do dominio descobertas antes do schema."

**Escopo do prototipo.** Um cliente so — o primeiro da lista de clientes. Registre como suposicao de risco **baixo** se foi inferido.

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

Verifique quais documentos ja tem conteudo real (sem `{{placeholders}}`). **Pule as fases ja concluidas.** Isso torna o pipeline retomavel: se a sessao cair no meio, rode `/blueprint:pipeline` de novo e ele continua de onde parou.

Apresente o plano antes de comecar:

> "**Pipeline:** {{N}} fases · {{M}} documentos · clientes: {{lista}}
>
> | # | Fase | Docs | Status |
> |---|------|------|--------|
> | 1 | blueprint-foundation | 00, 01, 02, 03 | pendente / ja preenchido |
> | ... | ... | ... | ... |
>
> Modo autonomo: nenhuma pergunta sera feita. Comecando."

Nao aguarde confirmacao — o usuario ja optou pelo modo automatico ao rodar `/blueprint:pipeline`.

---

## Passo 4: Executar as Fases

**Sequencialmente.** Cada fase le o que a anterior produziu — nao paralelize a cadeia do blueprint.

Para cada fase, use a ferramenta **Agent** com `subagent_type: general-purpose` e `run_in_background: false` (aguarde cada uma terminar antes da proxima).

### Ordem das fases — padrao (13 fases)

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
| 12 | `shared` | — | shared glossary, event-mapping, error-ux-mapping |
| 13 | `codegen-setup` | `{projeto-alvo}` | CLAUDE.md, `src/contracts/`, schema, scaffold |

> A fase 9 roda depois da 7 de proposito: `shared/15-api-dependencies.md` usa `docs/backend/05-api-contracts.md` como fonte autoritativa dos endpoints.
>
> A fase 12 roda depois de backend **e** frontend porque os tres documentos que ela gera sao projecoes das duas camadas — e e exatamente por cruza-las que ela revela divergencia (evento sem consumidor, erro sem UX, termo que muda de nome). Roda antes da 13 porque o scaffold congela nomes: um termo corrigido depois do `codegen-setup` ja nasceu errado no `src/contracts/`.

### Ordem das fases — com `--prototype` (16 fases)

A ordem **inverte a relacao entre frontend e backend**: a interface vem primeiro, mockada, e o contrato de API nasce dela.

| # | Skill | Argumento | Saida |
|---|-------|-----------|-------|
| 1-6 | `blueprint-*` | — | os 17 docs do blueprint tecnico |
| **7** | **`frontend-design-system`** | — | frontend shared/03 — **antecipada: o prototipo precisa dos tokens** |
| **8** | **`prototype`** | `{client}` | prototype 00, 01, 02 — plano de telas e dados |
| **9** | **`prototype-build`** | `{client} {projeto-alvo}` | **codigo**: app mockado navegavel |
| **10** | **`prototype-api`** | `{client} {projeto-alvo}` | prototype 03, 04, 05 — **contrato descoberto** |
| 11 | `backend` | — | backend 00 a 14, agora com `prototype/03` como fonte do contrato |
| 12 | `frontend` | clientes | frontend shared/06, shared/15 |
| 13 | `frontend-app` | `{client}` | frontend {client} 00,01,02,04,05,07,08,14 |
| 14 | `frontend-quality` | `{client}` | frontend {client} 09,10,11,12,13 |
| 15 | `shared` | — | shared glossary, event-mapping, error-ux-mapping |
| 16 | `codegen-setup` | `{projeto-alvo}` | CLAUDE.md, `src/contracts/`, schema, scaffold |

As fases 13 e 14 repetem para **cada** cliente, sempre `app` antes de `quality`. O **prototipo e de um cliente so** — o primeiro da lista.

**Total (um cliente frontend):** 51 docs + 6 do prototipo = **57 documentos preenchidos**, mais o app mockado. Cada cliente adicional soma 13.

### As fases 9 e 10 sao diferentes das outras

Como a `codegen-setup`, a fase 9 escreve **codigo fora deste repositorio** e tem portao objetivo. A fase 10 le esse codigo.

- **Fase 9 (`prototype-build`)** — portao de cobertura: toda tela existe, todo fluxo critico e percorrivel, toda tela tem os quatro estados, toda persona navega, type check e lint passam. Falha no portao → corrigir e repetir; se persistir, **reportar falha**, nunca declarar sucesso.
  > **Honestidade sobre este portao:** so **type check e lint** sao mecanicamente verificaveis. Telas, fluxos, estados e personas sao autoavaliacao do subagente, sem artefato que prove. Exija a contagem explicita no retorno (`telas: {n}/{N}`) e trate o resto como declaracao — nao como prova. E o mesmo limite de `/blueprint:build`: o agente que produz nao e verificacao independente do que produziu.
- **Fase 10 (`prototype-api`)** — le o **codigo**, nao o plano. Se `03-api-requirements.md` sair identico a `01-screens.md`, a fase falhou: ela copiou a intencao em vez de extrair o fato.
- **`05-findings.md` tem tres autores.** `/blueprint:prototype` registra caso de uso ambiguo, `/blueprint:prototype-build` registra regra de negocio descoberta ao implementar, e `/blueprint:prototype-api` o preenche. As fases 8 e 9 escrevem nele mesmo sem declara-lo em `DOCS:` — a convencao Write/Edit evita perda, mas conte com isso ao consolidar.
- **Achados de risco alto** de `05-findings.md` sao reportados ao orquestrador. Em modo autonomo o pipeline **nao para** por causa deles — mas por um motivo diferente do das outras fases, explicado em "A fase 11 precisa de um override explicito" abaixo. Eles entram no relatorio final **acima** das suposicoes: sao evidencia, nao inferencia.
- **Nao commite** no projeto-alvo nestas fases.

Acrescente ao prompt do subagente da fase 9:

```
Esta fase escreve codigo em {projeto-alvo}, fora do repositorio de documentacao.

- Construa TODA tela de docs/prototype/01-screens.md. Nao reduza escopo.
- Os quatro estados (carregando, vazio, erro, sucesso) sao obrigatorios por tela.
- Rode type check e lint ao final. Corrija o que falhar.
- Se apos a correcao ainda houver erro, devolva-o em GAPS e NAO declare sucesso.
- Nao commite no projeto-alvo. Pelo mesmo motivo, o pre-requisito de `git status`
  limpo NAO se aplica: ele existe porque a skill commita por tela, e aqui ela nao
  commita. Projeto-alvo sem repositorio git tambem segue.

Acrescente ao retorno:
GATE:
  telas:     {n}/{N}
  fluxos:    {n}/{N} percorriveis
  estados:   completo|faltam {n}
  typecheck: ok|falhou — {resumo}
  lint:      ok|falhou — {resumo}
```

E ao da fase 10:

```
Extraia o contrato LENDO O CODIGO do prototipo em {projeto-alvo} — handlers de
mock, chamadas da aplicacao e componentes que renderizam os campos.
NAO copie docs/prototype/01-screens.md: aquele e o plano, voce documenta o fato.
Onde o codigo divergir do plano, o codigo vence e a divergencia vira achado.
Nenhum endpoint entra no contrato sem tela que o chame; nenhum campo, sem ponto
de renderizacao.

Acrescente ao retorno:
FINDINGS:
- {achado} | {risco alto|medio|baixo} | {destino}
```

### A fase 11 precisa de um override explicito

A skill `/blueprint:backend` tem um **portao**: se `docs/prototype/05-findings.md` tiver achado de risco alto em aberto, ela **para**. Esse portao existe para uso interativo, onde alguem resolve o achado com `/blueprint:increment` antes de seguir.

**Em modo autonomo nao ha quem resolva.** E achado de risco alto e o *produto esperado* da fase de prototipo — se ela nao achou nada, provavelmente nao olhou direito. Sem override, o caso **normal** do `--prototype` seria a fase 11 abortar, e o pipeline entregaria os documentos do prototipo sem backend nenhum.

As regras genericas 1 a 6 nao cobrem portao. Acrescente ao prompt da fase 11:

```
O portao de docs/prototype/05-findings.md NAO se aplica neste run: nao ha
usuario para resolver achado entre as fases, e achado de risco alto e o
resultado esperado da fase de prototipo, nao uma anomalia.

Em vez de parar:
1. Gere os 15 documentos normalmente.
2. Para CADA achado de risco alto ainda aberto, marque no documento afetado:
   <!-- construido sobre lacuna conhecida: {achado} — ver prototype/05-findings.md -->
3. Devolva todos eles em GAPS, e liste em DOCS quais arquivos receberam o
   marcador — o orquestrador nao rele os documentos gerados, entao o numero so
   existe no relatorio final se voce o devolver.

Isto NAO torna a lacuna aceitavel. Torna-a rastreavel: o contrato foi
construido em cima dela e o relatorio final vai dizer isso em voz alta.
```

> **Por que desarmar em vez de parar:** a regra do pipeline e que fase que falha nao interrompe a cadeia, porque documento incompleto nao corrompe o proximo. Aqui a regra e tensionada — contrato sobre lacuna conhecida **corrompe** o schema. A solucao nao e esconder: e construir marcando, e reportar de forma que ninguem implemente sem ler. O portao continua valendo integralmente no modo interativo, que e onde ele pode ser cumprido.

### A fase de `codegen-setup` e diferente das outras

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

> Gerado por `/blueprint:pipeline` em modo autonomo. Cada item abaixo foi **inferido**, nao extraido
> do PRD. Revise os de risco alto antes de tratar a documentacao como definitiva.
>
> Para corrigir: `/blueprint:increment` (um blueprint) ou `/blueprint:patch` (mudanca global).

## Resumo

| Risco | Qtd | Significado |
|-------|-----|-------------|
| Alto | {{n}} | Provavelmente errado — revise |
| Medio | {{n}} | Plausivel — confirme |
| Baixo | {{n}} | Derivacao segura |

## Risco Alto

| # | Documento | Suposicao | Base | Como corrigir |
|---|-----------|-----------|------|---------------|
| 1 | blueprint/03-requirements.md | p95 < 300ms | nenhuma — valor padrao | `/blueprint:increment` → blueprint |

## Risco Medio
{{mesma tabela}}

## Risco Baixo
{{mesma tabela}}

## Lacunas do PRD

O PRD nao cobre os pontos abaixo. Considere enriquece-lo e rodar `/blueprint:increment`:

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
> {{Se rodou com --prototype:}}
> **Prototipo ({{projeto-alvo}}):** {{n}} telas · {{n}}/{{N}} fluxos percorriveis · typecheck {{ok|falhou}} · lint {{ok|falhou}}
> **Contrato extraido:** {{n}} endpoints com consumidor · {{n}} campos sem consumidor propostos para remocao
>
> **Achados do prototipo — {{n}} de risco alto.** Estes vem de **evidencia de codigo**, nao de inferencia; leia-os antes das suposicoes:
> 1. {{achado}} → {{destino}}
>
> ⚠️ **{{n}} documentos de backend foram construidos sobre lacuna conhecida** (o portao foi desarmado para o run autonomo terminar). Cada um tem o marcador `<!-- construido sobre lacuna conhecida -->` no ponto afetado. Resolva os achados com `/blueprint:increment`, rode `/blueprint:prototype-api` para regenerar o contrato e `/blueprint:increment` no backend — **antes** de `/blueprint:build`. Implementar direto propaga a lacuna para o schema.
>
> **Scaffold ({{projeto-alvo}}):** typecheck {{ok|falhou}} · lint {{ok|falhou}} · schema {{ok|falhou}}
>
> **{{n}} suposicoes de risco alto** precisam da sua revisao — estao no topo de
> `docs/ASSUMPTIONS.md`. As tres mais criticas:
> 1. {{documento}} — {{suposicao}}
> 2. ...
>
> **Proximos passos:**
> - Revise `docs/ASSUMPTIONS.md` e corrija com `/blueprint:increment` — o scaffold herdou as suposicoes
> - `/blueprint:specs` — backlog integral de tasks
> - `/blueprint:build` — implementar as features em loop com portoes de teste"

---

## Limites conhecidos

- **Qualidade depende do PRD.** PRD raso gera documentacao rasa com muitas suposicoes de risco alto. O pipeline nao inventa contexto de negocio — ele extrapola o que existe.
- **Nao substitui as skills individuais.** Se o projeto e critico, rode fase a fase (`/blueprint:blueprint-foundation`, `/blueprint:blueprint-domain`, ...) e responda as perguntas. O pipeline e para primeira versao rapida e para projetos onde o PRD ja e detalhado.
- **Vai ate o scaffold, nao ate as features.** A fase final gera tipos, schema e estrutura — tudo derivavel mecanicamente dos documentos. Implementar features e outro loop, com outros portoes: `/blueprint:build`.
- **O prototipo custa caro e nao serve a todo projeto.** Ele constroi a UI inteira para depois reconstrui-la integrada. Para um CRUD conhecido com PRD detalhado, o retorno provavelmente nao paga; para um dominio novo ou um SaaS com fluxos longos, paga quase sempre — porque a alternativa e descobrir a lacuna do dominio com o schema ja em producao.
- **O prototipo e de um cliente so.** Gestos, offline, push e IPC nao aparecem num prototipo web, e o contrato extraido nao os cobre.
- **O scaffold herda as suposicoes dos documentos.** Se `05-data-model.md` supos PostgreSQL, o schema nasce em PostgreSQL. Revise `ASSUMPTIONS.md` antes de construir em cima.
- **Custo.** Um subagente por fase multiplica o consumo de tokens em relacao a rodar tudo numa sessao — e o preco por nao estourar o contexto.
