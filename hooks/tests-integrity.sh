#!/usr/bin/env bash
# Blueprint — integridade da suite de testes
#
# PreToolUse(Write|Edit). Bloqueia as tres formas de deixar a suite verde sem
# fazer o codigo funcionar:
#   1. pular teste (.skip / .only / xit / xdescribe / todo / @pytest.mark.skip / t.Skip)
#   2. baixar limiar de cobertura
#   3. desabilitar regra de lint com comentario de supressao
#
# Regra do /blueprint:build, literal:
#   "PROIBIDO — estas acoes invalidam o resultado: apagar, pular ou afrouxar
#    QUALQUER teste, novo ou existente, para deixar a suite verde."
#
# O portao de contagem do /blueprint:build pega teste apagado. Este hook pega
# teste silenciado, que a contagem nao ve.
#
# Na duvida, deixa passar.

payload=$(cat 2>/dev/null) || exit 0
[ -z "$payload" ] && exit 0

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

file=$(field file_path)
[ -z "$file" ] && exit 0

added=$(field new_string)
[ -z "$added" ] && added=$(field content)
[ -z "$added" ] && exit 0
previous=$(field old_string)

# Conta ocorrencias de um padrao no texto novo e no antigo. So reclama do que
# AUMENTOU — assim editar um arquivo que ja tinha um skip legitimo nao trava.
# grep -c imprime "0" E sai com status 1 quando nao acha. Um "|| printf 0" aqui
# concatena um segundo zero e quebra a comparacao numerica — por isso a contagem
# passa por wc -l, que nao tem esse comportamento.
count_matches() {
  printf '%s' "$2" | grep -oE "$1" 2>/dev/null | wc -l | tr -d ' \n'
}

grew() {
  local pattern="$1" n_new n_old
  n_new=$(count_matches "$pattern" "$added")
  n_old=$(count_matches "$pattern" "$previous")
  [ "${n_new:-0}" -gt "${n_old:-0}" ] 2>/dev/null
}

is_test_file=0
case "$file" in
  *.test.*|*.spec.*|*_test.*|*test_*.py|*/tests/*|*/test/*|*/__tests__/*|*/e2e/*|*.feature|*maestro/*) is_test_file=1 ;;
esac

# --- 1. Teste silenciado -------------------------------------------------
if [ "$is_test_file" = "1" ]; then
  SKIP='(\.skip\(|\.only\(|\bxit\(|\bxdescribe\(|\bfit\(|\bfdescribe\(|\.todo\(|@pytest\.mark\.skip|@unittest\.skip|\bt\.Skip\(|\bt\.SkipNow\(|#\[ignore\]|\bpending\()'
  if grew "$SKIP"; then
    found=$(printf '%s' "$added" | grep -oE "$SKIP" 2>/dev/null | sort -u | tr '\n' ' ')
    cat >&2 <<MSG
BLOQUEADO — a edicao silencia teste.

  $file
  introduz: $found

Um teste pulado nao falha e nao passa: ele desaparece do sinal. A suite fica
verde e a regressao fica viva.

O que fazer em vez disso:
  - o teste esta certo e o codigo nao passa   -> corrija o CODIGO
  - o teste esta errado                        -> corrija o TESTE, nao o silencie
  - o blueprint mudou e o teste ficou obsoleto -> atualize o blueprint com
      /blueprint:increment, depois reescreva o teste a partir dele
  - o teste nao consegue satisfazer o blueprint -> pare e reporte o conflito;
      e exatamente o caso que o /blueprint:build manda devolver como BLOCKED

Se este skip e temporario e deliberado, deixe o motivo e a condicao de remocao
no proprio codigo, num commit separado — assim ele aparece na revisao em vez de
entrar de carona numa mudanca de implementacao.
MSG
    exit 2
  fi
fi

# --- 2. Limiar de cobertura rebaixado ------------------------------------
case "$file" in
  *jest.config*|*vitest.config*|*package.json|*.nycrc*|*setup.cfg|*pyproject.toml|*.coveragerc|*sonar-project.properties|*codecov.yml|*.codecov.yml)
    lower_new=$(printf '%s' "$added"    | grep -oE '(branches|functions|lines|statements|fail_under|minimum_coverage|coverage)["'"'"']?\s*[:=]\s*[0-9]+' 2>/dev/null | grep -oE '[0-9]+$' | sort -n | head -1)
    lower_old=$(printf '%s' "$previous" | grep -oE '(branches|functions|lines|statements|fail_under|minimum_coverage|coverage)["'"'"']?\s*[:=]\s*[0-9]+' 2>/dev/null | grep -oE '[0-9]+$' | sort -n | head -1)
    if [ -n "$lower_new" ] && [ -n "$lower_old" ] && [ "$lower_new" -lt "$lower_old" ]; then
      cat >&2 <<MSG
BLOQUEADO — a edicao rebaixa o limiar de cobertura.

  $file
  de $lower_old% para $lower_new%

O limiar existe para falhar quando a cobertura cai. Baixa-lo transforma o portao
em enfeite: ele passa a medir o que ja existe em vez do que foi combinado.

Os limiares do Blueprint vivem em docs/blueprint/12-testing_strategy.md e
docs/backend/14-tests.md (dominio 95%, services 90%, fluxos criticos 100%).
Se a meta mudou de verdade, mude-a LA primeiro, com /blueprint:increment, e traga
a configuracao atras da decisao — nao a decisao atras da configuracao.
MSG
      exit 2
    fi
    ;;
esac

# --- 3. Supressao de lint nova em codigo de teste ------------------------
if [ "$is_test_file" = "1" ]; then
  SUPPRESS='(eslint-disable(-next-line)?\s|@ts-nocheck|@ts-ignore|# *type: *ignore|# *noqa(?![-:])|//nolint)'
  if grew "$SUPPRESS"; then
    cat >&2 <<MSG
AVISO — a edicao acrescenta supressao de lint ou de tipo em arquivo de teste.

  $file

Nao esta bloqueado, mas vale a pergunta: a supressao existe para o teste passar,
ou para o teste ser escrito? A primeira e a mesma familia de "afrouxar para ficar
verde"; a segunda costuma ser legitima (mock que o tipo nao alcanca).

Se for legitima, restrinja ao menor escopo possivel e diga por que na mesma linha.
MSG
    exit 0
  fi
fi

exit 0
