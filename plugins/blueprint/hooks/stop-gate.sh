#!/usr/bin/env bash
# GERADO por tools/build-codex.py a partir de hooks/stop-gate.sh.
# Nao edite aqui: edite a fonte e rode `python3 tools/build-codex.py`.
# Blueprint — o portao que de fato segura
#
# Stop. Roda quando o agente quer encerrar o turno. Compara a arvore com a
# BASE DA SESSAO e, se houver violacao, devolve decision:block com o motivo — o
# Codex transforma o motivo num novo prompt e o agente continua trabalhando.
#
# POR QUE A APLICACAO ESTA AQUI E NAO SO NO PreToolUse
# No Codex o deny de PreToolUse nao e aplicado a apply_patch (openai/codex#27833,
# aberta) — que e justamente por onde o agente edita arquivos. Um portao que so
# avisa nao e portao.
#
# No Codex o deny FUNCIONA, mas so alcanca Write e Edit. Um `sed -i`, um
# `cat > arquivo` ou um `rm` pela ferramenta Bash faz a mesma violacao por fora
# dos dois matchers. Sem este portao o plugin do Codex era estritamente mais
# forte que o do Claude nas duas regras centrais.
#
# Movendo a verificacao para o Stop, a regra passa a ser "voce nao termina o
# turno com a arvore nesse estado", o que nao depende de qual ferramenta editou.
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
raw=""
[ -n "$state" ] && [ -f "$state/.blueprint-base-$key" ] && \
  raw=$(cat "$state/.blueprint-base-$key" 2>/dev/null | tr -d ' \n')
if [ "$raw" = "EMPTY" ]; then
  # O repositorio nao tinha commit nenhum quando a sessao comecou: a base e a
  # arvore vazia, entao TUDO que existe hoje e trabalho desta sessao.
  base=$(git -C "$root" hash-object -t tree /dev/null 2>/dev/null)
else
  base=$(printf '%s' "$raw" | tr -cd '0-9a-f')
fi
# Base invalida (branch reescrito, commit removido) nao serve.
if [ -n "$base" ] && [ "$raw" != "EMPTY" ] && ! git -C "$root" cat-file -e "$base^{commit}" 2>/dev/null; then
  base=""
fi
# Base que NAO e ancestral do HEAD tambem nao serve: depois de um `git reset
# --hard` para tras dela, ou de uma troca de branch, `git diff <base>` mostra o
# INVERSO das mudancas — um marcador que a base tinha e o HEAD atual nao vira
# "perdeu o marcador", com a arvore limpa e nada para o agente desfazer.
if [ -n "$base" ] && [ "$raw" != "EMPTY" ] && ! git -C "$root" merge-base --is-ancestor "$base" HEAD 2>/dev/null; then
  base=""
  [ -n "$state" ] && rm -f "$state/.blueprint-base-$key"
fi
[ -z "$base" ] && base="HEAD"

# --relative: `git diff --name-only` devolve caminho relativo a RAIZ do
# repositorio. Com o projeto num subdiretorio (monorepo, app dentro de um repo
# maior), `apps/web/docs/...` nunca casava com `docs/*` e o pathspec por arquivo
# resolvia errado — as duas checagens viravam no-op silencioso.
diff=$(git -C "$root" diff --relative --no-color "$base" 2>/dev/null)
[ -z "$diff" ] && diff=$(git -C "$root" diff --relative --no-color 2>/dev/null)
[ -z "$diff" ] && diff=$(git -C "$root" ls-files --others --exclude-standard 2>/dev/null)
if [ -z "$diff" ]; then
  [ -n "$state" ] && rm -f "$state"/.blueprint-stop-"$key"
  ok
fi

changed=$(git -C "$root" diff --relative --name-only "$base" 2>/dev/null)
# `git diff` nunca lista arquivo novo nao rastreado. Um arquivo de teste NOVO
# cheio de it.skip passava inteiro — e as skills que escrevem no projeto-alvo
# mandam explicitamente nao commitar, entao arvore com untracked e o estado
# normal no Stop, nao a excecao.
untracked=$(git -C "$root" ls-files --others --exclude-standard 2>/dev/null)

# `git show <rev>:<path>` NAO aceita --relative: o caminho e sempre a partir
# da raiz do repositorio. Guarda-se o prefixo do subdiretorio para recompo-lo.
prefix=$(git -C "$root" rev-parse --show-prefix 2>/dev/null)

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
    # Compara o MARCADOR INTEIRO, nao so o token. Conferir `APPEND:entities`
    # deixava passar `<!-- APPEND:entities` (comentario sem fecho, que renderiza
    # como texto) e ate prosa solta com o token no meio: o token sobrevivia, o
    # ponto de insercao nao. E por marcador inteiro a colisao de prefixo
    # (APPEND:webhooks vs APPEND:webhooks-enviados) continua coberta.
    MK='<!--[[:space:]]*APPEND:[a-z0-9-]*[[:space:]]*-->'
    was=$(git -C "$root" show "$base:$prefix$f" 2>/dev/null | grep -oE "$MK" 2>/dev/null | sort -u)
    [ -z "$was" ] && continue
    now=$(grep -oE "$MK" "$root/$f" 2>/dev/null | sort -u)
    while IFS= read -r m; do
      [ -z "$m" ] && continue
      printf '%s\n' "$now" | grep -qxF "$m" 2>/dev/null \
        || problems="$problems  - $f perdeu o marcador $m$NL"
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
  d=$(git -C "$root" diff --relative --no-color "$base" -- "$f" 2>/dev/null)
  n_add=$(printf '%s' "$d" | grep '^+' | grep -v '^+++' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  n_rem=$(printf '%s' "$d" | grep '^-' | grep -v '^---' | grep -cE "$SKIP" 2>/dev/null | tr -d ' \n')
  if [ "${n_add:-0}" -gt "${n_rem:-0}" ] 2>/dev/null; then
    problems="$problems  - $f silencia teste (skip/only/xit acrescentado)$NL"
  fi
done <<EOF
$tests_changed
EOF

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    *.test.*|*.spec.*|*_test.*|*_spec.rb|*test_*.py|*/tests/*|*/test/*|*/__tests__/*|*/e2e/*) ;;
    *) continue ;;
  esac
  if grep -qE "$SKIP" "$root/$f" 2>/dev/null; then
    problems="$problems  - $f e um arquivo de teste NOVO ja nascendo silenciado$NL"
  fi
done <<EOF
$untracked
EOF

# --- 3. Teste APAGADO ----------------------------------------------------
# A regra do framework e "proibido apagar, pular ou afrouxar QUALQUER teste", e
# ate aqui so a parte do meio era verificada. Apagar e mais barato que silenciar
# e deixa a suite igualmente verde — sem teste nenhum, nada falha.
#
# O saldo e LIQUIDO sobre toda a sessao, e e por isso que esta checagem vive
# aqui e nao no PreToolUse: mover um teste de arquivo e uma remocao seguida de
# uma adicao, e no resultado as duas se cancelam. Chamada a chamada, a remocao
# pareceria uma perda.
DECL="((^|$W)(it|test|describe|context|specify|scenario)[[:space:]]*\()|((^|$W)def[[:space:]]+test_)|((^|$W)func[[:space:]]+Test[A-Z])|(#\[test\])|((^|$W)(it|describe|context)[[:space:]]+[\"'][^\"']*[\"'][[:space:]]+do)"
testfiles=$(printf '%s\n%s\n' "$changed" "$untracked" \
  | grep -E '(\.test\.|\.spec\.|_test\.|_spec\.rb|test_.*\.py|/tests/|/test/|/__tests__/|/e2e/)' 2>/dev/null | sort -u)
net_before=0; net_after=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  b=$(git -C "$root" show "$base:$prefix$f" 2>/dev/null | grep -cE "$DECL" 2>/dev/null | tr -d ' \n')
  a=0
  [ -f "$root/$f" ] && a=$(grep -cE "$DECL" "$root/$f" 2>/dev/null | tr -d ' \n')
  net_before=$((net_before + ${b:-0}))
  net_after=$((net_after + ${a:-0}))
done <<EOF
$testfiles
EOF
if [ "$net_after" -lt "$net_before" ] 2>/dev/null; then
  problems="$problems  - a sessao termina com $((net_before - net_after)) teste(s) a menos do que comecou$NL"
fi

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

Teste apagado e mais barato que teste silenciado e da no mesmo: sem teste, nada falha. Se ele cobre algo que deixou de existir, remova-o num commit proprio, para que a perda fique visivel na revisao em vez de vir junto com a feature.

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
