#!/usr/bin/env bash
# Blueprint — estado do projeto no inicio da sessao
#
# SessionStart. Imprime em stdout (que o Codex injeta no contexto) onde o
# projeto esta na cadeia do Blueprint: o que ja foi preenchido, o que falta, o
# que esta pendente de revisao, e qual e o proximo comando.
#
# Nao bloqueia nada. Se nao houver Blueprint neste projeto, nao diz nada.

root="${CODEX_PROJECT_DIR:-$PWD}"
docs="$root/docs"

# Projeto sem docs/ e justamente o estado em que o SessionStart tem algo util a
# dizer: o plugin esta instalado e os templates ainda nao. Sair calado aqui era
# deixar sem resposta quem mais precisa dela.
if [ ! -d "$docs" ]; then
  if [ -n "${PLUGIN_ROOT:-${PLUGIN_ROOT:-}}" ]; then
    echo "== Blueprint =="
    echo "Plugin instalado, templates ainda nao. Rode blueprint-init na raiz deste projeto para instalar a biblioteca de documentos em docs/."
  fi
  exit 0
fi

# Um documento conta como PREENCHIDO quando nao tem mais {{placeholders}}.
# README.MD e README.md sao referencia do framework, nao documento a preencher:
# contados na suite, davam "2/18 preenchidos" num projeto recem-instalado e
# faziam o ramo de "nada gerado ainda" nunca casar — o hook jamais sugeria o
# comando de entrada da cadeia.
suite_state() {
  local dir="$1" total=0 done_=0 f base
  [ -d "$dir" ] || { printf 'ausente'; return; }
  for f in "$dir"/*.md "$dir"/*.MD; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    case "$base" in README.md|README.MD) continue ;; esac
    total=$((total+1))
    grep -q '{{' "$f" 2>/dev/null || done_=$((done_+1))
  done
  [ "$total" -eq 0 ] && { printf 'ausente'; return; }
  printf '%d/%d' "$done_" "$total"
}

blueprint=$(suite_state "$docs/blueprint")
[ "$blueprint" = "ausente" ] && exit 0   # sem Blueprint aqui; fica quieto

prototype=$(suite_state "$docs/prototype")
backend=$(suite_state "$docs/backend")
shared=$(suite_state "$docs/shared")

echo "== Blueprint =="
printf 'blueprint tecnico: %s' "$blueprint"
[ "$prototype" != "ausente" ] && printf ' | prototipo: %s' "$prototype"
[ "$backend"   != "ausente" ] && printf ' | backend: %s'   "$backend"
[ "$shared"    != "ausente" ] && printf ' | shared: %s'    "$shared"

for c in web mobile desktop; do
  s=$(suite_state "$docs/frontend/$c")
  [ "$s" != "ausente" ] && printf ' | frontend/%s: %s' "$c" "$s"
done
echo

# --- PRD: o teto de qualidade de tudo que vem depois ---------------------
if [ ! -f "$docs/prd.md" ]; then
  echo "PRD ausente (docs/prd.md). E a entrada de toda a cadeia — sem ele as skills inferem, e inferencia sobre vacuo vira suposicao de risco alto."
elif grep -q '{{' "$docs/prd.md" 2>/dev/null; then
  echo "PRD ainda e template. Preencha docs/prd.md antes de gerar: a qualidade do blueprint e limitada pela dele."
fi

# --- Pendencias que bloqueiam decisao ------------------------------------
if [ -f "$root/docs/ASSUMPTIONS.md" ]; then
  n=$(grep -iE '^\|.*\|[[:space:]]*(alto|high)[[:space:]]*\|' "$root/docs/ASSUMPTIONS.md" 2>/dev/null | wc -l | tr -d ' ')
  [ "${n:-0}" -gt 0 ] && echo "ASSUMPTIONS.md: $n suposicao(oes) de risco alto sem revisao. Foram inferidas, nao extraidas do PRD."
fi

if [ -f "$docs/prototype/05-findings.md" ] && ! grep -q '{{' "$docs/prototype/05-findings.md" 2>/dev/null; then
  n=$(grep -iE '^\|.*\|[[:space:]]*alto[[:space:]]*\|' "$docs/prototype/05-findings.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -gt 0 ]; then
    echo "prototype/05-findings.md: $n achado(s) de risco alto. Vem de evidencia de codigo, nao de inferencia — resolva com blueprint-increment ANTES de blueprint-backend."
  fi
fi

n=$(grep -rl 'construido sobre lacuna conhecida' "$docs" 2>/dev/null | wc -l | tr -d ' ')
[ "${n:-0}" -gt 0 ] && echo "$n documento(s) marcados como construidos sobre lacuna conhecida. Resolva antes de blueprint-build — implementar propaga a lacuna para o schema."

n=$(grep -rl 'PATCH-REVIEW' "$docs" 2>/dev/null | wc -l | tr -d ' ')
[ "${n:-0}" -gt 0 ] && echo "$n arquivo(s) com PATCH-REVIEW pendente de revisao humana."

# --- Proximo passo -------------------------------------------------------
next=""
case "$blueprint" in
  0/*) next="blueprint-blueprint  (analise de cobertura do PRD e roteiro das 6 fases)" ;;
  *)
    if [ "${blueprint%%/*}" != "${blueprint##*/}" ]; then
      falta=$(( ${blueprint##*/} - ${blueprint%%/*} )); if [ "$falta" -eq 1 ]; then next="continuar o blueprint tecnico — falta 1 documento"; else next="continuar o blueprint tecnico — faltam $falta documentos"; fi
    elif [ "$prototype" != "ausente" ] && [ "${prototype%%/*}" != "${prototype##*/}" ]; then
      next="blueprint-prototype  (o contrato de API sai da interface, nao o contrario)"
    elif [ "$backend" != "ausente" ] && [ "${backend%%/*}" != "${backend##*/}" ]; then
      next="blueprint-backend"
    elif [ -f "$root/docs/specs/TASKS.md" ]; then
      next="blueprint-build"
    else
      next="blueprint-specs  (backlog integral) ou blueprint-codegen-setup"
    fi
    ;;
esac
[ -n "$next" ] && echo "Proximo: $next"

echo "Convencao: documento com {{placeholders}} -> Write. Documento preenchido -> Edit ou blueprint-increment."
exit 0
