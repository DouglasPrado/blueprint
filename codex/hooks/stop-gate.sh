#!/usr/bin/env bash
# Blueprint (Codex) — o portao que de fato segura
#
# Stop. Roda quando o agente quer encerrar o turno. Compara a arvore com a
# BASE DA SESSAO e, se houver violacao, devolve decision:block com o motivo — o
# Codex transforma o motivo num novo prompt e o agente continua trabalhando.
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
# POR QUE A BASE E DA SESSAO E NAO O HEAD
# Olhar so `git diff HEAD` deixa o commit contornar o portao: o agente silencia
# um teste, commita, a arvore fica limpa e o Stop nao ve nada. E nao e hipotese —
# o loop do blueprint-build commita por feature e termina o turno com a arvore
# limpa. A base da sessao e gravada pelo status.sh (SessionStart); comparando
# contra ela, o que foi commitado no meio do caminho continua visivel.
#
# CONTRATO DE SAIDA: o Stop do Codex exige JSON valido no stdout SEMPRE. Stdout
# vazio e erro de hook a cada turno. Por isso todo caminho termina imprimindo {}.

ok() { printf '{}\n'; exit 0; }

# NAO ler stdin. O Stop nao precisa do payload aqui, e um `cat` sem entrada
# disponivel trava o hook — que no Stop significa travar o turno.

command -v git >/dev/null 2>&1 || ok
root="${CODEX_PROJECT_DIR:-$PWD}"
git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || ok

gitdir=$(git -C "$root" rev-parse --absolute-git-dir 2>/dev/null)
key=$(printf '%s' "$root" | cksum | cut -d' ' -f1)

# Onde guardar estado. O .git do proprio repositorio e gravavel sempre que o git
# funciona; TMPDIR pode nao ser. Se nenhum dos dois aceitar escrita, o portao
# ABRE — um contador que nao persiste vira bloqueio infinito, que e pior do que
# nao bloquear: prende o agente sem saida.
state=""
for d in "$gitdir" "${TMPDIR:-/tmp}"; do
  [ -n "$d" ] && [ -d "$d" ] || continue
  if : > "$d/.blueprint-probe-$key" 2>/dev/null; then
    rm -f "$d/.blueprint-probe-$key"; state="$d"; break
  fi
done

base=""
[ -n "$state" ] && [ -f "$state/.blueprint-base-$key" ] && \
  base=$(cat "$state/.blueprint-base-$key" 2>/dev/null | tr -cd '0-9a-f')
# Base invalida (branch reescrito, commit removido) nao serve.
[ -n "$base" ] && ! git -C "$root" cat-file -e "$base^{commit}" 2>/dev/null && base=""
[ -z "$base" ] && base="HEAD"

diff=$(git -C "$root" diff --no-color "$base" 2>/dev/null)
[ -z "$diff" ] && diff=$(git -C "$root" diff --no-color 2>/dev/null)
if [ -z "$diff" ]; then
  [ -n "$state" ] && rm -f "$state"/.blueprint-stop-"$key"
  ok
fi

changed=$(git -C "$root" diff --name-only "$base" 2>/dev/null)

problems=""
W='[^A-Za-z0-9_.]'
NL='
'

# --- 1. Marcador de append perdido em documento do Blueprint -------------
if [ -d "$root/docs/blueprint" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in docs/*) ;; *) continue ;; esac
    [ -f "$root/$f" ] || continue
    was=$(git -C "$root" show "$base:$f" 2>/dev/null | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
    [ -z "$was" ] && continue
    # Comparacao por TOKEN: "APPEND:webhooks" e substring de
    # "APPEND:webhooks-enviados", e docs/backend/13-integrations.md tem os dois.
    now=$(grep -o 'APPEND:[a-z0-9-]*' "$root/$f" 2>/dev/null | sort -u)
    while IFS= read -r m; do
      [ -z "$m" ] && continue
      printf '%s\n' "$now" | grep -qx "$m" 2>/dev/null \
        || problems="$problems  - $f perdeu o marcador <!-- $m -->$NL"
    done <<EOF
$was
EOF
  done <<EOF
$changed
EOF
fi

# --- 2. Teste silenciado -------------------------------------------------
SKIP="((^|$W)(it|test|describe|context|suite)\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|xcontext|xspecify|fit|fdescribe)[[:space:]]*[('\"])|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])"
tests_changed=$(printf '%s\n' "$changed" \
  | grep -E '(\.test\.|\.spec\.|_test\.|_spec\.rb|test_.*\.py|/tests/|/test/|/__tests__/|/e2e/)' 2>/dev/null)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  d=$(git -C "$root" diff --no-color "$base" -- "$f" 2>/dev/null)
  n_add=$(printf '%s' "$d" | grep '^+' | grep -v '^+++' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  n_rem=$(printf '%s' "$d" | grep '^-' | grep -v '^---' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  if [ "${n_add:-0}" -gt "${n_rem:-0}" ] 2>/dev/null; then
    problems="$problems  - $f silencia teste (skip/only/xit acrescentado)$NL"
  fi
done <<EOF
$tests_changed
EOF

if [ -z "$problems" ]; then
  [ -n "$state" ] && rm -f "$state"/.blueprint-stop-"$key"
  ok
fi

# Evita laco infinito: o Codex reenvia o motivo como novo prompt, e se a violacao
# for irreparavel o agente ficaria preso. Tres bloqueios bastam — mas contados
# POR VIOLACAO, nao por projeto: um contador global liberava uma violacao nova a
# cada quatro, so porque tres outras, ja resolvidas, tinham gastado o limite.
[ -z "$state" ] && ok
sig=$(printf '%s' "$problems" | cksum | cut -d' ' -f1)
marker="$state/.blueprint-stop-$key"
tries=0
if [ -f "$marker" ]; then
  prev_sig=$(sed -n '1p' "$marker" 2>/dev/null | tr -cd '0-9')
  [ "$prev_sig" = "$sig" ] && tries=$(sed -n '2p' "$marker" 2>/dev/null | tr -cd '0-9')
fi
[ -z "$tries" ] && tries=0
if [ "$tries" -ge 3 ] 2>/dev/null; then rm -f "$marker"; ok; fi
tries=$((tries+1))
printf '%s\n%s\n' "$sig" "$tries" > "$marker" 2>/dev/null || ok

reason="O turno nao pode terminar com a arvore neste estado — o Blueprint tem duas regras que valem mais que a entrega:

$problems
Documento preenchido que perde <!-- APPEND:... --> deixa blueprint-increment sem ponto de insercao: a proxima adicao vai parar no fim do arquivo ou no meio de outra secao.

Teste silenciado nao falha e nao passa: some do sinal. A suite fica verde e a regressao fica viva. Se o teste esta certo e o codigo nao passa, corrija o CODIGO; se o blueprint mudou, atualize o blueprint com blueprint-increment e reescreva o teste a partir dele; se o teste nao consegue satisfazer o blueprint, PARE e reporte o conflito em vez de forcar.

Commitar nao resolve: a comparacao e contra a base da sessao, entao a violacao continua visivel depois do commit. Desfaca essas mudancas especificas e termine. (Bloqueio $tries de 3.)"

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
