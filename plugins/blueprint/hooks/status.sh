#!/usr/bin/env bash
# GERADO por tools/build-codex.py a partir de hooks/status.sh.
# Nao edite aqui: edite a fonte e rode `python3 tools/build-codex.py`.
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

# Grava a BASE DA SESSAO para o stop-gate.sh.
#
# Sem ela o portao so consegue olhar `git diff HEAD`, e ai commitar o contorna:
# silencia o teste, commita, a arvore fica limpa, o Stop nao ve nada. E o loop
# do blueprint-build commita por feature justamente assim.
#
# Falha de escrita e silenciosa de proposito: o SessionStart nao pode quebrar a
# sessao. O stop-gate degrada para `diff HEAD` quando a base nao existe.
if command -v git >/dev/null 2>&1 && git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  _gd=$(git -C "$root" rev-parse --absolute-git-dir 2>/dev/null)
  _k=$(printf '%s' "$root" | cksum | cut -d' ' -f1)
  # --verify: num repositorio SEM commit nenhum, `git rev-parse HEAD` imprime a
  # string literal "HEAD" no stdout, que gravada como base nao e sha nenhum.
  _h=$(git -C "$root" rev-parse --verify --quiet HEAD 2>/dev/null)
  case "$_h" in *[!0-9a-f]*|"") _h="" ;; esac
  # Repositorio ainda sem commit: a base correta e "nada".
  [ -z "$_h" ] && _h="EMPTY"
  # SO GRAVA SE AINDA NAO HOUVER BASE VALIDA.
  #
  # O SessionStart dispara em startup, resume, clear E compact. Reescrever a
  # base a cada disparo faz um auto-compact no meio de um build longo mover a
  # base para o HEAD corrente — apagando do portao tudo que ja foi commitado no
  # turno, que e exatamente o bypass que a base existe para fechar.
  #
  # Base so e substituida quando nao existe ou quando deixou de ser ancestral do
  # HEAD (branch trocado, historico reescrito). O stop-gate APAGA a base quando
  # o turno termina com a arvore limpa, entao a proxima sessao comeca do zero
  # sem que uma base velha continue valendo.
  _existing=""
  for _d in "$_gd" "${TMPDIR:-/tmp}"; do
    [ -n "$_d" ] && [ -f "$_d/.blueprint-base-$_k" ] || continue
    _existing=$(cat "$_d/.blueprint-base-$_k" 2>/dev/null | tr -d ' \n'); break
  done
  _keep=0
  if [ "$_existing" = "EMPTY" ]; then
    _keep=1
  elif [ -n "$_existing" ] && git -C "$root" merge-base --is-ancestor "$_existing" HEAD 2>/dev/null; then
    _keep=1
  fi
  if [ "$_keep" = "0" ]; then
    for _d in "$_gd" "${TMPDIR:-/tmp}"; do
      [ -n "$_d" ] && [ -d "$_d" ] || continue
      printf '%s\n' "$_h" > "$_d/.blueprint-base-$_k" 2>/dev/null && break
    done
    for _d in "$_gd" "${TMPDIR:-/tmp}"; do
      [ -n "$_d" ] && rm -f "$_d/.blueprint-stop-$_k" 2>/dev/null
    done
  fi
fi

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

# docs/frontend/shared/ (design system, data layer, api-dependencies) sao as
# fases 8 e 9 do pipeline e eram invisiveis aqui: nao apareciam no painel e
# nunca viravam "Proximo". Tres skills param se elas nao estiverem preenchidas
# — prototype, frontend-app e codegen-setup —, entao o hook mandava seguir para
# um passo que ia abortar.
fshared=$(suite_state "$docs/frontend/shared")
[ "$fshared" != "ausente" ] && printf ' | frontend/shared: %s' "$fshared"

frontend_falta=""
for c in web mobile desktop; do
  s=$(suite_state "$docs/frontend/$c")
  [ "$s" = "ausente" ] && continue
  printf ' | frontend/%s: %s' "$c" "$s"
  [ "${s%%/*}" != "${s##*/}" ] && frontend_falta="${frontend_falta:+$frontend_falta, }$c"
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
    elif [ "$prototype" != "ausente" ] && [ "${prototype%%/*}" != "${prototype##*/}" ] \
         && { [ "$backend" = "ausente" ] || [ "${backend%%/*}" != "${backend##*/}" ]; } \
         && { [ "$fshared" = "ausente" ] || [ "${fshared%%/*}" = "${fshared##*/}" ]; }; then
      # So faz sentido ANTES do backend: a fase existe para o contrato de API
      # sair da interface. Com o backend ja preenchido, sugerir o prototipo
      # inverte a razao de ser dele — e no fluxo padrao de 13 fases ninguem
      # preenche docs/prototype/, entao a sugestao se repetia para sempre.
      next="blueprint-prototype  (o contrato de API sai da interface, nao o contrario)"
    elif [ "$backend" != "ausente" ] && [ "${backend%%/*}" != "${backend##*/}" ]; then
      next="blueprint-backend"
    elif [ "$fshared" != "ausente" ] && [ "${fshared%%/*}" != "${fshared##*/}" ]; then
      next="blueprint-frontend-design-system e blueprint-frontend  (docs/frontend/shared/ — o prototipo e o scaffold param sem eles)"
    elif [ -n "$frontend_falta" ]; then
      # O frontend era calculado e ignorado: o hook mandava gerar scaffold e
      # router sobre documentacao de cliente que ainda era template.
      next="blueprint-frontend-app $frontend_falta  (e depois blueprint-frontend-quality)"
    elif [ "$shared" != "ausente" ] && [ "${shared%%/*}" != "${shared##*/}" ]; then
      # Depois de backend E frontend, porque os tres documentos sao projecoes
      # das duas camadas. Antes do scaffold, porque o codegen-setup congela
      # nomes: termo corrigido depois de src/contracts/ ja nasceu errado.
      next="blueprint-shared  (glossario, eventos e erro->UX — antes do scaffold)"
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
