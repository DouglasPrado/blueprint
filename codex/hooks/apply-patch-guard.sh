#!/usr/bin/env bash
# Blueprint (Codex) — integridade de documentacao e de testes em apply_patch
#
# PreToolUse(apply_patch). O Codex edita arquivos por apply_patch, e o payload
# NAO tem file_path/content: vem como tool_input.command com o texto do patch.
# Este script le o patch, descobre os arquivos e o que esta sendo acrescentado.
#
# ATENCAO — LIMITE CONHECIDO DA PLATAFORMA
# No Codex, o deny de PreToolUse NAO e aplicado a apply_patch: o hook dispara, a
# mensagem chega, e a escrita acontece assim mesmo (openai/codex#27833, aberta).
# Por isso este hook e ADVISORY. A aplicacao de verdade esta em stop-gate.sh, que
# roda no evento Stop e impede o turno de terminar enquanto a violacao existir.
#
# Sem \b, \s ou lookahead: extensoes GNU falham calado no BSD grep do macOS.

payload=$(cat 2>/dev/null) || exit 0
[ -z "$payload" ] && exit 0

patch=""
if command -v jq >/dev/null 2>&1; then
  patch=$(printf '%s' "$payload" | jq -r '.tool_input.command // .tool_input.patch // .tool_input.input // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  patch=$(printf '%s' "$payload" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin).get("tool_input") or {}
    for k in ("command", "patch", "input"):
        v = d.get(k)
        if isinstance(v, str) and v:
            sys.stdout.write(v); break
except Exception:
    pass
' 2>/dev/null)
fi
[ -z "$patch" ] && exit 0

# O patch e analisado POR ARQUIVO. Coletar as linhas +/- do patch inteiro e
# depois compara-las dentro do laco por arquivo produz os dois erros de uma vez:
# um `it.skip(` citado na PROSA de um documento acusava o arquivo de teste vizinho
# (falso positivo), e remover um skip de um arquivo pagava pelo skip acrescentado
# noutro (falso negativo).
#
# awk prefixa cada linha do corpo com o arquivo a que ela pertence, separados por
# TAB. O shell corta no PRIMEIRO tab, entao tab dentro do codigo nao atrapalha.
NL='
'
TAB=$(printf '\t')

# Tres expressoes em vez de \( a\|b \): alternancia com \| e extensao GNU. No
# sed do BSD ela vira um | literal, nenhuma linha casa, `files` sai vazio e o
# hook inteiro vira no-op silencioso — o modo de falha que esta suite existe
# para impedir.
files=$(printf '%s' "$patch" \
  | sed -n -e 's/^\*\*\* Update File: //p' \
           -e 's/^\*\*\* Add File: //p' \
           -e 's/^\*\*\* Delete File: //p' | sort -u)
[ -z "$files" ] && exit 0

problems=""
W='[^A-Za-z0-9_.]'
SKIP="((^|$W)(it|test|describe|context|suite)\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|xcontext|xspecify|fit|fdescribe)[[:space:]]*[('\"])|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])"

tagged=$(printf '%s' "$patch" | awk -v t="$TAB" '
  /^\*\*\* (Update|Add|Delete) File: /{ f=substr($0, index($0,": ")+2); next }
  /^\*\*\* /{ f=""; next }
  f != "" { print f t $0 }
')

while IFS= read -r f; do
  [ -z "$f" ] && continue
  # [^TAB]* e nao .* : `.*` e guloso e cortaria no ULTIMO tab, fazendo a linha
  # perder o +/- inicial. Go e Makefile indentam com tab; um t.Skip() indentado
  # sumia de "added" e o hook nao via nada.
  body=$(printf '%s\n' "$tagged" | grep -F "$f$TAB" 2>/dev/null | sed "s|^[^$TAB]*$TAB||")
  added=$(printf '%s' "$body"   | grep '^+' 2>/dev/null | sed 's/^+//')
  removed=$(printf '%s' "$body" | grep '^-' 2>/dev/null | sed 's/^-//')

  # --- documentacao do Blueprint ---
  case "$f" in
    *docs/blueprint/*|*docs/backend/*|*docs/frontend/*|*docs/prototype/*|*docs/shared/*|*docs/adr/*|*docs/specs/*)
      # So atua onde ha marca do framework — "docs/backend/" existe em projetos
      # que nunca ouviram falar deste plugin.
      marked=0
      # Relativo ao projeto, nao ao CWD: o PreToolUse pode rodar de outro
      # diretorio, e ai a verificacao se desligava em silencio.
      pr="${CODEX_PROJECT_DIR:-$PWD}"
      [ -f "$pr/$f" ] && grep -q '<!-- APPEND:' "$pr/$f" 2>/dev/null && marked=1
      [ -f "$f" ] && grep -q '<!-- APPEND:' "$f" 2>/dev/null && marked=1
      { [ -d "$pr/docs/blueprint" ] || [ -d "docs/blueprint" ]; } && marked=1
      if [ "$marked" = "1" ]; then
        # Comparacao por TOKEN: "APPEND:webhooks" e substring de
        # "APPEND:webhooks-enviados", e os dois convivem em 13-integrations.md.
        kept=$(printf '%s' "$added" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
        while IFS= read -r m; do
          [ -z "$m" ] && continue
          printf '%s\n' "$kept" | grep -qx "$m" 2>/dev/null \
            || problems="$problems  - $f remove o marcador <!-- $m --> sem repo-lo$NL"
        done <<INNER
$(printf '%s' "$removed" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
INNER
      fi
      ;;
  esac

  # --- testes ---
  case "$f" in
    *.test.*|*.spec.*|*_test.*|*_spec.rb|*test_*.py|*/tests/*|*/test/*|*/__tests__/*|*/e2e/*)
      n_add=$(printf '%s' "$added"   | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
      n_rem=$(printf '%s' "$removed" | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
      if [ "${n_add:-0}" -gt "${n_rem:-0}" ] 2>/dev/null; then
        problems="$problems  - $f silencia teste (skip/only/xit novo)$NL"
      fi
      ;;
  esac
done <<EOF
$files
EOF

[ -z "$problems" ] && exit 0

printf 'Blueprint — este patch viola uma regra do framework:\n\n' >&2
printf '%s' "$problems" >&2
cat >&2 <<'MSG'

  Documento preenchido perde marcador de append -> blueprint-increment nao sabe
  mais onde inserir conteudo novo.
  Teste silenciado -> nao falha e nao passa: some do sinal. A suite fica verde e
  a regressao fica viva.

NOTA: no Codex o deny de PreToolUse nao e aplicado a apply_patch (openai/codex#27833),
entao esta escrita provavelmente vai acontecer mesmo. O portao real e o evento Stop:
o turno nao vai terminar enquanto a violacao existir na arvore. Desfaca agora e
sai mais barato.
MSG
exit 2
