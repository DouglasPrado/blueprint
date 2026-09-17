#!/usr/bin/env bash
# Blueprint — o portao que de fato segura
#
# Stop. Roda quando o agente quer encerrar o turno. Compara a arvore com a
# BASE DA SESSAO e, se houver violacao, devolve decision:block com o motivo — o
# Codex transforma o motivo num novo prompt e o agente continua trabalhando.
#
# POR QUE A APLICACAO ESTA AQUI E NAO SO NO PreToolUse
#
# Este arquivo e a fonte dos dois plugins e o gerador traduz nome de produto,
# entao a explicacao abaixo nao cita nenhum: cita o comportamento.
#
# Num dos agentes o deny de PreToolUse NAO e aplicado a ferramenta de patch
# (openai/codex#27833, aberta) — que e justamente por onde ele edita arquivos.
# Um portao que so avisa nao e portao.
#
# No outro o deny funciona, mas so alcanca as ferramentas Write e Edit. Um
# `sed -i`, um `cat > arquivo` ou um `rm` pela ferramenta de shell faz a mesma
# violacao por fora dos dois matchers.
#
# Movendo a verificacao para o Stop, a regra passa a ser "voce nao termina o
# turno com a arvore nesse estado", o que nao depende de qual ferramenta editou
# nem de o bloqueio de ferramenta funcionar.
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

# -c core.quotepath=false em TODA invocacao que lista nomes: por padrao o git
# devolve `"docs/blueprint/04-dom\303\255nio.md"` — entre aspas e com escapes
# octais — para qualquer caractere nao-ASCII. O nome literal nao casava com
# `docs/*`, nao existia no disco e nao existia no `git show`: as tres checagens
# desligavam juntas, caladas. Num framework escrito em portugues, `sessao` com
# til e `dominio` com acento sao nomes normais.

# NAO ler stdin. O Stop nao precisa do payload aqui, e um `cat` sem entrada
# disponivel trava o hook — que no Stop significa travar o turno.

command -v git >/dev/null 2>&1 || ok
root="${CLAUDE_PROJECT_DIR:-$PWD}"
git -c core.quotepath=false -C "$root" rev-parse --git-dir >/dev/null 2>&1 || ok

gitdir=$(git -c core.quotepath=false -C "$root" rev-parse --absolute-git-dir 2>/dev/null)
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
  base=$(git -c core.quotepath=false -C "$root" hash-object -t tree /dev/null 2>/dev/null)
else
  base=$(printf '%s' "$raw" | tr -cd '0-9a-f')
fi
# Base invalida (branch reescrito, commit removido) nao serve.
if [ -n "$base" ] && [ "$raw" != "EMPTY" ] && ! git -c core.quotepath=false -C "$root" cat-file -e "$base^{commit}" 2>/dev/null; then
  base=""
fi
# Base que NAO e ancestral do HEAD tambem nao serve: depois de um `git reset
# --hard` para tras dela, ou de uma troca de branch, `git diff <base>` mostra o
# INVERSO das mudancas — um marcador que a base tinha e o HEAD atual nao vira
# "perdeu o marcador", com a arvore limpa e nada para o agente desfazer.
if [ -n "$base" ] && [ "$raw" != "EMPTY" ] && ! git -c core.quotepath=false -C "$root" merge-base --is-ancestor "$base" HEAD 2>/dev/null; then
  base=""
  [ -n "$state" ] && rm -f "$state/.blueprint-base-$key"
fi
[ -z "$base" ] && base="HEAD"

# --relative: `git diff --name-only` devolve caminho relativo a RAIZ do
# repositorio. Com o projeto num subdiretorio (monorepo, app dentro de um repo
# maior), `apps/web/docs/...` nunca casava com `docs/*` e o pathspec por arquivo
# resolvia errado — as duas checagens viravam no-op silencioso.
diff=$(git -c core.quotepath=false -C "$root" diff --relative --no-color "$base" 2>/dev/null)
[ -z "$diff" ] && diff=$(git -c core.quotepath=false -C "$root" diff --relative --no-color 2>/dev/null)
[ -z "$diff" ] && diff=$(git -c core.quotepath=false -C "$root" ls-files --others --exclude-standard 2>/dev/null)
if [ -z "$diff" ]; then
  [ -n "$state" ] && rm -f "$state"/.blueprint-stop-"$key" "$state"/.blueprint-base-"$key"
  ok
fi

changed=$(git -c core.quotepath=false -C "$root" diff --relative --name-only "$base" 2>/dev/null)
# `git diff` nunca lista arquivo novo nao rastreado. Um arquivo de teste NOVO
# cheio de it.skip passava inteiro — e as skills que escrevem no projeto-alvo
# mandam explicitamente nao commitar, entao arvore com untracked e o estado
# normal no Stop, nao a excecao.
untracked=$(git -c core.quotepath=false -C "$root" ls-files --others --exclude-standard 2>/dev/null)

# `git show <rev>:<path>` NAO aceita --relative: o caminho e sempre a partir
# da raiz do repositorio. Guarda-se o prefixo do subdiretorio para recompo-lo.
prefix=$(git -c core.quotepath=false -C "$root" rev-parse --show-prefix 2>/dev/null)

problems=""
W='[^A-Za-z0-9_.]'
NL='
'

# --- 1. Marcador de append perdido em documento do Blueprint -------------
if [ -d "$root/docs/blueprint" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in docs/*) ;; *) continue ;; esac
    if [ ! -f "$root/$f" ]; then
      # Documento APAGADO perde TODOS os marcadores de uma vez — e passava,
      # enquanto perder um so bloqueava. Perder o arquivo e estritamente pior.
      if git -c core.quotepath=false -C "$root" show "$base:$prefix$f" 2>/dev/null \
           | grep -qE '<!--[[:space:]]*APPEND:' 2>/dev/null; then
        problems="$problems  - $f foi apagado, e era um documento do Blueprint$NL"
      fi
      continue
    fi
    # Compara o MARCADOR INTEIRO, nao so o token. Conferir `APPEND:entities`
    # deixava passar `<!-- APPEND:entities` (comentario sem fecho, que renderiza
    # como texto) e ate prosa solta com o token no meio: o token sobrevivia, o
    # ponto de insercao nao. E por marcador inteiro a colisao de prefixo
    # (APPEND:webhooks vs APPEND:webhooks-enviados) continua coberta.
    MK='<!--[[:space:]]*APPEND:[a-z0-9-]*[[:space:]]*-->'
    was=$(git -c core.quotepath=false -C "$root" show "$base:$prefix$f" 2>/dev/null | grep -oE "$MK" 2>/dev/null | sort -u)
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
SKIP="((^|$W)(it|test|describe|context|suite)(\.[a-z]+(\([^)]*\))?)*\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|xcontext|xspecify|fit|fdescribe)[[:space:]]*[('\"])|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])"
tests_changed=$(printf '%s\n' "$changed" \
  | grep -E '(\.test\.|\.spec\.|_test\.|_spec\.rb|test_.*\.py|/tests/|/test/|/__tests__/|/e2e/)' 2>/dev/null)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  d=$(git -c core.quotepath=false -C "$root" diff --relative --no-color "$base" -- "$f" 2>/dev/null)
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
# (\.[a-z]+(\([^)]*\))?)* : `it.each([...])('...')` e UM teste, nao zero.
# Sem isso, refatorar `it(` para `it.each(` era contado como teste apagado e o
# agente levava bloqueio por uma refatoracao legitima.
DECL="((^|$W)(it|test|describe|context|specify|scenario)(\.[a-z]+(\([^)]*\))?)*[[:space:]]*\()|((^|$W)def[[:space:]]+test_)|((^|$W)func[[:space:]]+Test[A-Z])|(#\[test\])|((^|$W)(it|describe|context)[[:space:]]+[\"'][^\"']*[\"'][[:space:]]+do)"

# Linha comentada nao conta como teste. Comentar e a forma mais barata de
# apagar: `// it('x')` casava o DECL (o caractere antes do `it` e espaco), o
# saldo nao mudava, e a suite ficava verde rodando zero teste.
#
# O filtro vale so para a CONTAGEM de declaracoes. O SKIP nao passa por ele, e
# de proposito: `#[ignore]` do Rust comeca com `#`.
nocomment() { sed 's|^[[:space:]]*//.*||; s|^[[:space:]]*\*.*||; s|^[[:space:]]*/\*.*||; s|^[[:space:]]*#[^[].*||' 2>/dev/null; }
testfiles=$(printf '%s\n%s\n' "$changed" "$untracked" \
  | grep -E '(\.test\.|\.spec\.|_test\.|_spec\.rb|test_.*\.py|/tests/|/test/|/__tests__/|/e2e/)' 2>/dev/null | sort -u)
net_before=0; net_after=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  b=$(git -c core.quotepath=false -C "$root" show "$base:$prefix$f" 2>/dev/null | nocomment | grep -cE "$DECL" 2>/dev/null | tr -d ' \n')
  a=0
  [ -f "$root/$f" ] && a=$(nocomment < "$root/$f" 2>/dev/null | grep -cE "$DECL" 2>/dev/null | tr -d ' \n')
  net_before=$((net_before + ${b:-0}))
  net_after=$((net_after + ${a:-0}))
done <<EOF
$testfiles
EOF
if [ "$net_after" -lt "$net_before" ] 2>/dev/null; then
  problems="$problems  - a sessao termina com $((net_before - net_after)) teste(s) a menos do que comecou$NL"
fi

# --- 4. Limiar de cobertura rebaixado ou apagado -------------------------
# O cabecalho deste arquivo diz que o portao existe porque um `sed -i` faz a
# mesma violacao por fora dos matchers de Write|Edit. Valia para duas das tres
# regras: o limiar de cobertura ficava de fora — e num dos agentes nao existe
# hook de PreToolUse para testes, entao la a protecao de limiar nao existia em
# evento nenhum.
CFG='(jest\.config|vitest\.config|\.nycrc|setup\.cfg|pyproject\.toml|\.coveragerc|codecov\.yml)'
cfgs=$(printf '%s\n' "$changed" | grep -E "$CFG" 2>/dev/null)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  was_cfg=$(git -c core.quotepath=false -C "$root" show "$base:$prefix$f" 2>/dev/null)
  [ -z "$was_cfg" ] && continue
  now_cfg=""
  [ -f "$root/$f" ] && now_cfg=$(cat "$root/$f" 2>/dev/null)
  gblk() { printf '%s' "$1" | tr '\n' ' ' | awk '
    { s = $0
      if (match(s, /(^|[^A-Za-z0-9_])["'"'"']?global["'"'"']?[ \t]*[:=][ \t]*\{/) == 0) exit
      s = substr(s, RSTART)
      j = index(s, "{"); if (j == 0) exit
      d = 0; out = ""
      for (k = j; k <= length(s); k++) {
        c = substr(s, k, 1); out = out c
        if (c == "{") d++
        else if (c == "}") { d--; if (d == 0) break }
      }
      print out }' 2>/dev/null; }
  cpick() { printf '%s' "$2" \
      | grep -oE "(^|[^A-Za-z0-9_-])\"?$1\"?[[:space:]]*[:=][[:space:]]*[0-9]+" 2>/dev/null \
      | grep -oE '[0-9]+$' | sort -n | head -1; }
  cval() { g=$(gblk "$2"); if [ -n "$g" ]; then cpick "$1" "$g"; else cpick "$1" "$2"; fi; }
  for key in branches functions statements lines fail_under minimum_coverage min_coverage; do
    vo=$(cval "$key" "$was_cfg"); vn=$(cval "$key" "$now_cfg")
    [ -z "$vo" ] && continue
    if [ -z "$vn" ]; then
      problems="$problems  - $f: o limiar de cobertura \`$key\` ($vo) deixou de existir$NL"
      break
    fi
    if [ "$vn" -lt "$vo" ] 2>/dev/null; then
      problems="$problems  - $f: limiar de cobertura \`$key\` caiu de $vo para $vn$NL"
      break
    fi
  done
done <<EOF
$cfgs
EOF

if [ -z "$problems" ]; then
  [ -n "$state" ] && rm -f "$state"/.blueprint-stop-"$key" "$state"/.blueprint-base-"$key"
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

Limiar de cobertura rebaixado ou apagado faz o portao medir o que ja existe em vez do que foi combinado; apagado, ele deixa de medir. Os limiares vivem em docs/blueprint/12-testing_strategy.md — se a meta mudou, mude-a la primeiro.

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
