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
case "$file" in
  */docs/blueprint/*|*/docs/backend/*|*/docs/frontend/*|*/docs/prototype/*|*/docs/shared/*|*/docs/adr/*|*/docs/specs/*) ;;
  docs/blueprint/*|docs/backend/*|docs/frontend/*|docs/prototype/*|docs/shared/*|docs/adr/*|docs/specs/*) ;;
  *) exit 0 ;;
esac

# --- 1. Write sobre documento preenchido ---------------------------------
if [ "$tool" = "Write" ] && [ -f "$file" ]; then
  # Template intocado tem {{placeholders}}. Sem eles, alguem ja preencheu.
  if ! grep -q '{{' "$file" 2>/dev/null; then
    lines=$(wc -l < "$file" 2>/dev/null | tr -d ' ')
    cat >&2 <<MSG
BLOQUEADO — Write sobre documento ja preenchido.

  $file ($lines linhas, nenhum {{placeholder}} restante)

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
    lost=""
    while IFS= read -r marker; do
      [ -z "$marker" ] && continue
      printf '%s' "$new" | grep -qF "$marker" 2>/dev/null || lost="$lost  $marker\n"
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
