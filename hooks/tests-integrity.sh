#!/usr/bin/env bash
# Blueprint — integridade da suite de testes
#
# PreToolUse(Write|Edit). Bloqueia deixar a suite verde sem fazer o codigo
# funcionar: teste silenciado ou limiar de cobertura rebaixado.
#
# Regra do blueprint-build, literal: "PROIBIDO — apagar, pular ou afrouxar
# QUALQUER teste, novo ou existente, para deixar a suite verde."
#
# DOIS CUIDADOS QUE DEFINEM ESTE SCRIPT:
#
# 1. Os padroes sao ancorados a IDENTIFICADOR DE TESTE. `fit(` solto casa com
#    `model.fit(X_train, y_train)`; `.todo(` casa com `repo.todo(1)`; `pending(`
#    casa com `order.pending()`. Bloquear ML e os dois dominios mais comuns de
#    SaaS, dentro do loop autonomo do build, e o caminho curto para o usuario
#    desligar tudo.
#
# 2. Em Write, a comparacao e contra o ARQUIVO EM DISCO, nao contra string
#    vazia. Senao reescrever um teste que ja tinha um skip legitimo e
#    documentado seria sempre bloqueado.
#
# PORTABILIDADE: sem \b, sem \s, sem lookahead — sao extensoes GNU e falham
# calado no BSD grep do macOS.

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
if [ -z "$added" ]; then
  added=$(field content)
  # Write: o "antes" e o arquivo como esta no disco.
  previous=""
  [ -f "$file" ] && previous=$(cat "$file" 2>/dev/null)
else
  previous=$(field old_string)
fi
[ -z "$added" ] && exit 0

W='[^A-Za-z0-9_.]'   # nao-identificador, usado no lugar de \b

count() { printf '%s' "$2" | grep -oE "$1" 2>/dev/null | wc -l | tr -d ' \n'; }
grew()  { local n o; n=$(count "$1" "$added"); o=$(count "$1" "$previous"); [ "${n:-0}" -gt "${o:-0}" ] 2>/dev/null; }

is_test=0
case "$file" in
  *.test.*|*.spec.*|*_test.*|*_spec.rb|*test_*.py|*/tests/*|*/test/*|*/__tests__/*|*/e2e/*|*.feature) is_test=1 ;;
  tests/*|test/*|__tests__/*|e2e/*) is_test=1 ;;   # caminho relativo a raiz
esac

# --- 1. Teste silenciado -------------------------------------------------
if [ "$is_test" = "1" ]; then
  # Cada padrao exige o identificador do runner: it/test/describe/context/suite.
  SKIP="((^|$W)(it|test|describe|context|suite)\.(skip|only|todo)\()|((^|$W)(xit|xtest|xdescribe|xcontext|xspecify|fit|fdescribe)[[:space:]]*[('\"])|(@pytest\.mark\.skip)|(@unittest\.skip)|((^|$W)t\.Skip(Now)?\()|(#\[ignore\])|(\.skip\(\)[[:space:]]*$)"
  if grew "$SKIP"; then
    found=$(printf '%s' "$added" | grep -oE "$SKIP" 2>/dev/null | sed "s/^[^A-Za-z@#.]//" | sort -u | tr '\n' ' ')
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
      blueprint-increment, depois reescreva o teste a partir dele
  - o teste nao consegue satisfazer o blueprint -> pare e reporte o conflito;
      e o caso que o blueprint-build manda devolver como BLOCKED

Se este skip e temporario e deliberado, deixe o motivo e a condicao de remocao
no proprio codigo, num commit separado — assim ele aparece na revisao em vez de
entrar de carona numa mudanca de implementacao.
MSG
    exit 2
  fi
fi

# --- 2. Limiar de cobertura rebaixado ------------------------------------
# So chaves que sao MESMO de cobertura, comparadas uma a uma. A versao ingenua
# (menor numero de qualquer chave chamada "lines") trata apertar a regra de lint
# `max-lines: 300 -> 200` como afrouxar cobertura.
case "$file" in
  *jest.config*|*vitest.config*|*.nycrc*|*setup.cfg|*pyproject.toml|*.coveragerc|*codecov.yml|*.codecov.yml|*package.json)
    KEYS='(coverageThreshold|fail_under|minimum_coverage|min_coverage|branches|functions|statements|lines)'
    # Em package.json/config so olha se ha bloco de cobertura por perto.
    case "$file" in
      *package.json)
        printf '%s' "$added$previous" | grep -qE 'coverageThreshold' 2>/dev/null || exit 0 ;;
    esac
    # MINIMO, nao primeira ocorrencia. Com head -1 bastava acrescentar um bloco
    # por diretorio com valor alto ANTES do global para o portao ler so o novo
    # bloco e nunca ver o global caindo de 80 para 20.
    lowest() { printf '%s' "$2" | grep -oE "\"?$1\"?[[:space:]]*[:=][[:space:]]*[0-9]+" 2>/dev/null \
                 | grep -oE '[0-9]+$' | sort -n | head -1; }
    for key in branches functions statements lines fail_under minimum_coverage min_coverage; do
      vn=$(lowest "$key" "$added")
      vo=$(lowest "$key" "$previous")
      if [ -n "$vn" ] && [ -n "$vo" ] && [ "$vn" -lt "$vo" ] 2>/dev/null; then
        cat >&2 <<MSG
BLOQUEADO — a edicao rebaixa o limiar de cobertura.

  $file
  $key: de $vo para $vn

O limiar existe para falhar quando a cobertura cai. Baixa-lo transforma o portao
em enfeite: ele passa a medir o que ja existe em vez do que foi combinado.

Os limiares do Blueprint vivem em docs/blueprint/12-testing_strategy.md e
docs/backend/14-tests.md (dominio 95%, services 90%, fluxos criticos 100%).
Se a meta mudou de verdade, mude-a LA primeiro, com blueprint-increment, e traga
a configuracao atras da decisao — nao a decisao atras da configuracao.
MSG
        exit 2
      fi
    done
    ;;
esac

# --- 3. Supressao de lint nova em codigo de teste (aviso) ----------------
if [ "$is_test" = "1" ]; then
  SUPPRESS='(eslint-disable(-next-line)?[[:space:]])|(@ts-nocheck)|(@ts-ignore)|(#[[:space:]]*type:[[:space:]]*ignore)|(#[[:space:]]*noqa([^-:]|$))|(//nolint)'
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
