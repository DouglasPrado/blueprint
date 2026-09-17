#!/usr/bin/env bash
# Blueprint (Codex) — o portao que de fato segura
#
# Stop. Roda quando o agente quer encerrar o turno. Varre a arvore de trabalho
# com o git e, se houver violacao, devolve decision:block com o motivo — o Codex
# transforma o motivo num novo prompt e o agente continua trabalhando.
#
# POR QUE A APLICACAO ESTA AQUI E NAO NO PreToolUse
# No Codex o deny de PreToolUse nao e aplicado a apply_patch (openai/codex#27833,
# aberta) — que e justamente por onde o agente edita arquivos. Um portao que so
# avisa nao e portao. Movendo a verificacao para o Stop, a regra passa a ser
# "voce nao termina o turno com a arvore nesse estado", o que nao depende de o
# bloqueio de ferramenta funcionar.
#
# E mais robusto de outra forma tambem: verifica o RESULTADO na arvore, entao
# pega a violacao independente de qual ferramenta a produziu — apply_patch,
# shell com heredoc, ou code_mode_exec (que nem dispara PreToolUse: openai/codex#23411).
#
# CONTRATO DE SAIDA: o Stop do Codex exige JSON valido no stdout SEMPRE. Stdout
# vazio e erro de hook a cada turno. Por isso todo caminho termina imprimindo {}.

ok() { printf '{}\n'; exit 0; }

command -v git >/dev/null 2>&1 || ok
root="${CODEX_PROJECT_DIR:-${PLUGIN_ROOT:+$PWD}}"
[ -z "$root" ] && root="$PWD"
git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || ok

# Evita laco infinito: o Codex reenvia o motivo como novo prompt, e se a violacao
# for irreparavel o agente ficaria preso. Tres bloqueios no mesmo turno bastam.
marker="${TMPDIR:-/tmp}/.blueprint-stop-$(printf '%s' "$root" | cksum | cut -d' ' -f1)"
tries=0
[ -f "$marker" ] && tries=$(cat "$marker" 2>/dev/null | tr -cd '0-9')
[ -z "$tries" ] && tries=0
if [ "$tries" -ge 3 ] 2>/dev/null; then rm -f "$marker"; ok; fi

diff=$(git -C "$root" diff --no-color HEAD 2>/dev/null)
[ -z "$diff" ] && diff=$(git -C "$root" diff --no-color 2>/dev/null)
[ -z "$diff" ] && { rm -f "$marker"; ok; }

problems=""
W='[^A-Za-z0-9_.]'

# --- 1. Marcador de append perdido em documento do Blueprint -------------
if [ -d "$root/docs/blueprint" ]; then
  changed=$(git -C "$root" diff --name-only HEAD 2>/dev/null | grep '^docs/' 2>/dev/null)
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -f "$root/$f" ] || continue
    base=$(git -C "$root" show "HEAD:$f" 2>/dev/null)
    [ -z "$base" ] && continue
    while IFS= read -r m; do
      [ -z "$m" ] && continue
      grep -qF "$m" "$root/$f" 2>/dev/null \
        || problems="$problems  - $f perdeu o marcador <!-- $m -->\n"
    done <<EOF
$(printf '%s' "$base" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
EOF
  done <<EOF
$changed
EOF
fi

# --- 2. Teste silenciado -------------------------------------------------
SKIP="((^|$W)(it|test|describe|context|suite)\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|fit|fdescribe)\()|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])"
tests_changed=$(git -C "$root" diff --name-only HEAD 2>/dev/null \
  | grep -E '(\.test\.|\.spec\.|_test\.|test_.*\.py|/tests/|/test/|/__tests__/|/e2e/)' 2>/dev/null)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  d=$(git -C "$root" diff --no-color HEAD -- "$f" 2>/dev/null)
  n_add=$(printf '%s' "$d" | grep '^+' | grep -v '^+++' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  n_rem=$(printf '%s' "$d" | grep '^-' | grep -v '^---' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  if [ "${n_add:-0}" -gt "${n_rem:-0}" ] 2>/dev/null; then
    problems="$problems  - $f silencia teste (skip/only/xit acrescentado)\n"
  fi
done <<EOF
$tests_changed
EOF

if [ -z "$problems" ]; then rm -f "$marker"; ok; fi

tries=$((tries+1)); printf '%s' "$tries" > "$marker" 2>/dev/null

reason="O turno nao pode terminar com a arvore neste estado — o Blueprint tem duas regras que valem mais que a entrega:

$(printf "$problems")

Documento preenchido que perde <!-- APPEND:... --> deixa blueprint-increment sem ponto de insercao: a proxima adicao vai parar no fim do arquivo ou no meio de outra secao.

Teste silenciado nao falha e nao passa: some do sinal. A suite fica verde e a regressao fica viva. Se o teste esta certo e o codigo nao passa, corrija o CODIGO; se o blueprint mudou, atualize o blueprint com blueprint-increment e reescreva o teste a partir dele; se o teste nao consegue satisfazer o blueprint, PARE e reporte o conflito em vez de forcar.

Desfaca essas mudancas especificas e termine. (Bloqueio $tries de 3.)"

if command -v python3 >/dev/null 2>&1; then
  REASON="$reason" python3 -c '
import json, os
print(json.dumps({"decision": "block", "reason": os.environ["REASON"]}))
'
elif command -v jq >/dev/null 2>&1; then
  jq -n --arg r "$reason" '{decision:"block", reason:$r}'
else
  # Sem interpolador seguro, melhor nao arriscar JSON invalido — que no Stop do
  # Codex vira erro de hook em todo turno.
  printf '{}\n'
fi
exit 0
