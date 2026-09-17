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

# Arquivos tocados pelo patch: "*** Update File: x", "*** Add File: x", "*** Delete File: x"
files=$(printf '%s' "$patch" | sed -n 's/^\*\*\* \(Update\|Add\|Delete\) File: //p')
[ -z "$files" ] && exit 0

# Linhas acrescentadas pelo patch.
added=$(printf '%s' "$patch" | grep '^+' 2>/dev/null | sed 's/^+//')
removed=$(printf '%s' "$patch" | grep '^-' 2>/dev/null | sed 's/^-//')

problems=""
W='[^A-Za-z0-9_.]'

while IFS= read -r f; do
  [ -z "$f" ] && continue

  # --- documentacao do Blueprint ---
  case "$f" in
    *docs/blueprint/*|*docs/backend/*|*docs/frontend/*|*docs/prototype/*|*docs/shared/*|*docs/adr/*|*docs/specs/*)
      # So atua onde ha marca do framework — "docs/backend/" existe em projetos
      # que nunca ouviram falar deste plugin.
      marked=0
      [ -f "$f" ] && grep -q '<!-- APPEND:' "$f" 2>/dev/null && marked=1
      [ -d "docs/blueprint" ] && marked=1
      if [ "$marked" = "1" ]; then
        # Marcador de append removido e nao reposto?
        lost=$(printf '%s' "$removed" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
        while IFS= read -r m; do
          [ -z "$m" ] && continue
          printf '%s' "$added" | grep -qF "$m" 2>/dev/null \
            || problems="$problems  - $f remove o marcador <!-- $m --> sem repo-lo\n"
        done <<EOF
$lost
EOF
      fi
      ;;
  esac

  # --- testes ---
  case "$f" in
    *.test.*|*.spec.*|*_test.*|*test_*.py|*/tests/*|*/test/*|*/__tests__/*|*/e2e/*)
      SKIP="((^|$W)(it|test|describe|context|suite)\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|fit|fdescribe)\()|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])"
      n_add=$(printf '%s' "$added"   | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
      n_rem=$(printf '%s' "$removed" | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
      if [ "${n_add:-0}" -gt "${n_rem:-0}" ] 2>/dev/null; then
        problems="$problems  - $f silencia teste (skip/only/xit novo)\n"
      fi
      ;;
  esac
done <<EOF
$files
EOF

[ -z "$problems" ] && exit 0

printf 'Blueprint — este patch viola uma regra do framework:\n\n' >&2
printf "$problems" >&2
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
