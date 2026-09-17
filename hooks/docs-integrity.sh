#!/usr/bin/env bash
# Blueprint — integridade dos documentos
#
# PreToolUse(Write|Edit). Bloqueia as duas formas de destruir documentacao em
# silencio:
#   1. Write sobre um documento que JA TEM conteudo real
#   2. Edit que remove um marcador <!-- APPEND:... -->
#
# Regra do framework, repetida em todas as skills:
#   "doc so com {{placeholders}} -> Write. Doc com conteudo real -> Edit."
#
# Filosofia: na duvida, DEIXA PASSAR. Hook que da falso-positivo e hook
# desligado. Qualquer falha interna sai com 0.

payload=$(cat 2>/dev/null) || exit 0
[ -z "$payload" ] && exit 0

# Extrai um campo de tool_input. jq se houver, senao python3, senao desiste.
field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r --arg k "$1" '.tool_input[$k] // empty' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$payload" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin).get("tool_input") or {}
    v = d.get(sys.argv[1])
    sys.stdout.write(v if isinstance(v, str) else "")
except Exception:
    pass
' "$1" 2>/dev/null
  fi
}

tool=""
if command -v jq >/dev/null 2>&1; then
  tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  tool=$(printf '%s' "$payload" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null)
fi
[ -z "$tool" ] && exit 0

file=$(field file_path)
[ -z "$file" ] && exit 0

# So opina sobre a documentacao do Blueprint.
#
# O caminho sozinho NAO basta: "docs/backend/" e "docs/frontend/" sao nomes
# genericos que existem em projetos que nunca ouviram falar deste framework, e um
# plugin instalado globalmente que bloqueia Write num docs/backend/README.md
# alheio e um plugin que sera desinstalado. Por isso exige-se marca do framework:
# ou o arquivo carrega um marcador <!-- APPEND: -->, ou existe um docs/blueprint/
# na arvore acima dele.
case "$file" in
  */docs/blueprint/*|*/docs/backend/*|*/docs/frontend/*|*/docs/prototype/*|*/docs/shared/*|*/docs/adr/*|*/docs/specs/*) ;;
  docs/blueprint/*|docs/backend/*|docs/frontend/*|docs/prototype/*|docs/shared/*|docs/adr/*|docs/specs/*) ;;
  *) exit 0 ;;
esac

is_blueprint=0
[ -f "$file" ] && grep -q '<!-- APPEND:' "$file" 2>/dev/null && is_blueprint=1
if [ "$is_blueprint" = "0" ]; then
  # Sobe ate encontrar o docs/ do caminho e checa se ha docs/blueprint/ ao lado.
  probe="$file"
  while [ "$probe" != "/" ] && [ "$probe" != "." ] && [ -n "$probe" ]; do
    probe=$(dirname "$probe")
    case "$probe" in
      */docs|docs)
        [ -d "$probe/blueprint" ] && is_blueprint=1
        break ;;
    esac
  done
fi
[ "$is_blueprint" = "1" ] || exit 0

# --- 1. Write sobre documento preenchido ---------------------------------
#
# "Preenchido" NAO pode ser definido por "nao tem {{". Documento legitimamente
# pronto pode conter chaves: docs/frontend/*/14-copies.md e o documento de copies
# e i18n, e o proprio template ensina chaves como {{auth.login.title}}. Pela
# regra antiga esse documento ficava marcado como template para sempre — Write
# sobrescrevia o trabalho inteiro sem bloquear.
#
# Quando o plugin esta instalado, existe resposta exata em vez de heuristica: o
# template pristino esta em ${CLAUDE_PLUGIN_ROOT}/docs/. Igual ao template =
# intocado. Diferente = alguem mexeu.
#
# Sem PLUGIN_ROOT (hook rodando fora da instalacao), ainda ha um sinal melhor que
# "tem {{": as marcas de procedencia que TODA skill escreve ao preencher —
# <!-- do blueprint: ... -->, <!-- assumido: ... -->, <!-- adicionado: ... -->.
# Arquivo que carrega uma delas foi preenchido, tenha chaves ou nao.
pristine() { # 0 = e o template intocado
  [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || return 1
  rel=${1#*/docs/}; [ "$rel" = "$1" ] && rel=${1#docs/}
  [ "$rel" = "$1" ] && return 1
  tpl="$CLAUDE_PLUGIN_ROOT/docs/$rel"
  [ -f "$tpl" ] || return 1
  cmp -s "$1" "$tpl" 2>/dev/null
}

if [ "$tool" = "Write" ] && [ -f "$file" ]; then
  filled=1
  if pristine "$file"; then
    filled=0
  elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$CLAUDE_PLUGIN_ROOT/docs/${file#*/docs/}" ]; then
    filled=1   # existe template correspondente e o arquivo difere dele
  elif grep -qE '<!-- (do blueprint|do backend|do frontend|assumido|adicionado|corrigido|atualizado|construido sobre lacuna):?' "$file" 2>/dev/null; then
    filled=1   # marca de procedencia: alguma skill ja escreveu aqui
  elif grep -q '{{' "$file" 2>/dev/null; then
    filled=0   # heuristica de fallback: ainda tem placeholder
  fi
  if [ "$filled" = "1" ]; then
    lines=$(wc -l < "$file" 2>/dev/null | tr -d ' ')
    cat >&2 <<MSG
BLOQUEADO — Write sobre documento ja preenchido.

  $file ($lines linhas, diferente do template original)

Este documento carrega conteudo real do projeto. Write o substitui inteiro e o
conteudo anterior nao volta.

A convencao do Blueprint, declarada em todas as skills:
  documento so com {{placeholders}}  ->  Write
  documento com conteudo real        ->  Edit, inserindo antes de <!-- APPEND:... -->
  alteracao pontual                  ->  /blueprint:increment
  mudanca global (renome, versao)    ->  /blueprint:patch

Se a intencao e mesmo recomecar este documento do zero, apague-o antes — assim a
decisao fica no historico do git em vez de dentro de uma chamada de ferramenta.
MSG
    exit 2
  fi
fi

# --- 2. Edit que remove marcador de append -------------------------------
if [ "$tool" = "Edit" ]; then
  old=$(field old_string)
  new=$(field new_string)
  if printf '%s' "$old" | grep -q 'APPEND:' 2>/dev/null; then
    # Comparacao por TOKEN, nao por substring: "APPEND:webhooks" e substring de
    # "APPEND:webhooks-enviados", e docs/backend/13-integrations.md tem os dois.
    # Com grep -F, apagar o primeiro passava despercebido porque o segundo
    # continuava no texto.
    new_markers=$(printf '%s' "$new" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
    lost=""
    while IFS= read -r marker; do
      [ -z "$marker" ] && continue
      printf '%s\n' "$new_markers" | grep -qx "$marker" 2>/dev/null || lost="$lost  $marker\n"
    done <<EOF
$(printf '%s' "$old" | grep -o 'APPEND:[a-z0-9-]*' 2>/dev/null | sort -u)
EOF
    if [ -n "$lost" ]; then
      printf 'BLOQUEADO — a edicao remove marcador(es) de append:\n\n' >&2
      printf "$lost" >&2
      cat >&2 <<MSG

  em $file

Os marcadores <!-- APPEND:... --> sao pontos de insercao estaveis. /blueprint:increment
insere conteudo novo ANTES deles; sem o marcador, a proxima adicao nao sabe onde
entrar e acaba no fim do arquivo ou no meio de outra secao.

Mantenha o marcador na string de substituicao. Se ele precisa mesmo sair — porque
a secao inteira deixou de existir —, remova a secao num commit proprio, para que a
perda do ponto de insercao fique visivel na revisao.
MSG
      exit 2
    fi
  fi
fi

exit 0
