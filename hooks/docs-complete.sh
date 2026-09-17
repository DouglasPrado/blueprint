#!/usr/bin/env bash
# Blueprint — documento gerado deve sair completo
#
# PostToolUse(Write). Avisa quando um documento do Blueprint acabou de ser
# escrito e ainda tem {{placeholders}}.
#
# Regra do framework: "Preencha TODOS os {{placeholders}}. Nenhum pode sobrar no
# arquivo final."
#
# So observa Write — a operacao que gera o documento inteiro. Edit tem
# placeholder no meio do caminho por construcao, e avisar ali seria ruido.
# PostToolUse nao bloqueia: a escrita ja aconteceu. Isto e feedback, nao portao.

payload=$(cat 2>/dev/null) || exit 0
[ -z "$payload" ] && exit 0

read_json() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$payload" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        if not k: continue
        d = (d or {}).get(k)
    sys.stdout.write(d if isinstance(d, str) else "")
except Exception:
    pass
' "$2" 2>/dev/null
  fi
}

tool=$(read_json '.tool_name' 'tool_name')
[ "$tool" = "Write" ] || exit 0

file=$(read_json '.tool_input.file_path' 'tool_input.file_path')
[ -n "$file" ] && [ -f "$file" ] || exit 0

case "$file" in
  */docs/blueprint/*|*/docs/backend/*|*/docs/frontend/*|*/docs/prototype/*|*/docs/shared/*) ;;
  docs/blueprint/*|docs/backend/*|docs/frontend/*|docs/prototype/*|docs/shared/*) ;;
  *) exit 0 ;;
esac

n=$(grep -o '{{[^}]*}}' "$file" 2>/dev/null | wc -l | tr -d ' ')
[ "${n:-0}" -eq 0 ] && exit 0

sample=$(grep -o '{{[^}]*}}' "$file" 2>/dev/null | sort -u | head -5 | tr '\n' ' ')

# PostToolUse com exit 0 manda stdout para o transcript, nao para o modelo. Para
# que o aviso chegue ao Claude, ele precisa vir como JSON em additionalContext —
# caso contrario o hook carrega, roda, gasta timeout e nao muda nada.
msg="Blueprint: $file foi escrito com $n {{placeholder}}(s) ainda no texto. Amostra: $sample

A regra do framework e que nenhum placeholder sobre no arquivo final — um documento meio preenchido parece pronto e engana a fase seguinte, que vai consumi-lo como se fosse fato.

Se a informacao nao existe no PRD nem nos documentos anteriores, o caminho e inferir e MARCAR a inferencia com <!-- assumido: {o que} — base: {de onde} --> e classificar o risco. Deixar {{placeholder}} nao e admitir a lacuna: e esconde-la atras de algo que parece template esquecido."

if command -v python3 >/dev/null 2>&1; then
  MSG="$msg" python3 -c '
import json, os
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": os.environ["MSG"],
}}))
'
else
  printf '%s\n' "$msg"
fi
exit 0
