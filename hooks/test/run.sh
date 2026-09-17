#!/usr/bin/env bash
# Suite de testes dos hooks do Blueprint.
#
#   bash hooks/test/run.sh
#
# Hook mal formado falha em SILENCIO: nao bloqueia, nao avisa, e o plugin parece
# instalado quando na verdade nao faz nada. Por isso cada hook e exercitado com
# payload real — incluindo os casos que ele NAO deve bloquear, que sao os que
# levam um usuario a desligar o plugin inteiro.

set -u
HOOKS="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0

run() { # descricao, exit esperado, payload json, script
  local out rc
  out=$(printf '%s' "$3" | bash "$HOOKS/$4" 2>&1); rc=$?
  if [ "$rc" = "$2" ]; then
    pass=$((pass+1)); printf '  ok    %s\n' "$1"
  else
    fail=$((fail+1)); printf '  FALHA %s  (esperado exit %s, veio %s)\n' "$1" "$2" "$rc"
    printf '%s\n' "$out" | head -4 | sed 's/^/          /'
  fi
}

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/docs/blueprint" "$T/docs/prototype" "$T/proj/src/__tests__" "$T/proj/tests"
printf '# Doc\nConteudo real do projeto.\n<!-- APPEND:entities -->\n' > "$T/docs/blueprint/04-domain-model.md"
printf '# Doc\n{{placeholder}}\n<!-- APPEND:tables -->\n'            > "$T/docs/blueprint/05-data-model.md"
printf '| # | Achado | Risco |\n| 1 | x | alto |\n| 2 | y | medio |\n' > "$T/docs/prototype/05-findings.md"

echo "== docs-integrity: protege documentacao preenchida =="
run "Write sobre documento preenchido bloqueia" 2 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"content\":\"x\"}}" docs-integrity.sh
run "Write sobre template ainda com placeholders passa" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/05-data-model.md\",\"content\":\"x\"}}" docs-integrity.sh
run "Write em documento inexistente passa" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/99-novo.md\",\"content\":\"x\"}}" docs-integrity.sh
run "Write fora de docs/ nao e assunto do hook" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/proj/src/app.ts\",\"content\":\"x\"}}" docs-integrity.sh
run "Edit que remove marcador APPEND bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"old_string\":\"a\\n<!-- APPEND:entities -->\",\"new_string\":\"b\"}}" docs-integrity.sh
run "Edit que preserva o marcador passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"old_string\":\"a\\n<!-- APPEND:entities -->\",\"new_string\":\"b\\n<!-- APPEND:entities -->\"}}" docs-integrity.sh
run "Edit sem marcador envolvido passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"old_string\":\"Conteudo\",\"new_string\":\"Conteudo novo\"}}" docs-integrity.sh

echo "== tests-integrity: a suite nao se afrouxa para ficar verde =="
run "it.skip novo bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/u.test.ts\",\"old_string\":\"it('a')\",\"new_string\":\"it.skip('a')\"}}" tests-integrity.sh
run "xdescribe novo bloqueia" 2 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/proj/src/u.spec.ts\",\"content\":\"xdescribe('U',()=>{})\"}}" tests-integrity.sh
run "@pytest.mark.skip novo bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/tests/test_user.py\",\"old_string\":\"def test_a\",\"new_string\":\"@pytest.mark.skip\\ndef test_a\"}}" tests-integrity.sh
run "t.Skip do Go bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/user_test.go\",\"old_string\":\"func TestA\",\"new_string\":\"func TestA(t *testing.T){ t.Skip() }\"}}" tests-integrity.sh
run "editar assercao normalmente passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/u.test.ts\",\"old_string\":\"toBe(1)\",\"new_string\":\"toBe(2)\"}}" tests-integrity.sh
run "skip pre-existente que nao aumenta passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/u.test.ts\",\"old_string\":\"it.skip('a')\",\"new_string\":\"it.skip('a renomeado')\"}}" tests-integrity.sh
run ".only fora de arquivo de teste passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/app.ts\",\"old_string\":\"x\",\"new_string\":\"items.only(1)\"}}" tests-integrity.sh
run "rebaixar cobertura de 80 para 50 bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/jest.config.js\",\"old_string\":\"lines: 80\",\"new_string\":\"lines: 50\"}}" tests-integrity.sh
run "elevar cobertura de 80 para 90 passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/jest.config.js\",\"old_string\":\"lines: 80\",\"new_string\":\"lines: 90\"}}" tests-integrity.sh

echo "== docs-complete: PostToolUse, avisa mas nunca bloqueia =="
run "documento escrito com placeholders avisa" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/05-data-model.md\"}}" docs-complete.sh
run "documento completo fica em silencio" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\"}}" docs-complete.sh
run "Edit nao dispara este hook" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/05-data-model.md\"}}" docs-complete.sh

echo "== no-secrets: credencial nao entra no historico =="
if command -v git >/dev/null 2>&1; then
  G="$T/repo"; mkdir -p "$G"
  ( cd "$G" && git init -q . && git config user.email t@t && git config user.name t )
  CMT='{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
  # O hook le o indice do git a partir do diretorio corrente, entao os testes
  # rodam DENTRO do repo — e sem subshell, senao os contadores (e um eventual
  # FALHA) morrem junto com ela.
  ORIG=$PWD; cd "$G" || exit 1
  stage() { git reset -q; rm -f f.*; printf '%s\n' "$1" > "f.${2:-js}"; git add "f.${2:-js}"; }

  stage 'const port = 3000'
  run "codigo limpo passa" 0 "$CMT" no-secrets.sh
  stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
  run "AWS access key real bloqueia" 2 "$CMT" no-secrets.sh
  stage 'const t = "ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789"'
  run "token do GitHub bloqueia" 2 "$CMT" no-secrets.sh
  stage '-----BEGIN RSA PRIVATE KEY-----' pem
  run "bloco de chave privada bloqueia" 2 "$CMT" no-secrets.sh
  stage 'DATABASE_URL=postgres://user:supersecret123@db.host/app' env
  run "URL de conexao com senha bloqueia" 2 "$CMT" no-secrets.sh
  stage 'API_KEY="your-api-key-here-placeholder"'
  run "placeholder obvio passa" 0 "$CMT" no-secrets.sh
  stage 'const key = process.env.API_KEY'
  run "leitura de variavel de ambiente passa" 0 "$CMT" no-secrets.sh
  stage 'API_KEY={{sua_chave}}' md
  run "placeholder de template do Blueprint passa" 0 "$CMT" no-secrets.sh
  stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
  run "comando que nao e commit nem push passa" 0 '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' no-secrets.sh
  run "git status passa" 0 '{"tool_name":"Bash","tool_input":{"command":"git status"}}' no-secrets.sh
  run "git push com segredo staged bloqueia" 2 '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' no-secrets.sh
  cd "$ORIG" || exit 1
else
  echo "  (pulado: git nao encontrado)"
fi

echo "== degradacao: nada pode quebrar a sessao =="
run "payload vazio nao quebra" 0 "" docs-integrity.sh
run "payload invalido nao quebra" 0 "nao e json" docs-integrity.sh
run "payload sem tool_input nao quebra" 0 '{"tool_name":"Write"}' docs-integrity.sh
run "payload vazio no hook de testes" 0 "" tests-integrity.sh
run "payload vazio no hook de segredos" 0 "" no-secrets.sh

echo "== falso-positivo: dominios reais que NAO podem ser bloqueados =="
# Cada um destes foi reproduzido bloqueando trabalho legitimo antes da correcao.
mkdir -p "$T/proj/tests"
run "model.fit() de ML nao e um teste silenciado" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/tests/test_model.py\",\"old_string\":\"x\",\"new_string\":\"model.fit(X_train, y_train)\"}}" tests-integrity.sh
run "repo.todo(1) do dominio Todo passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/t.test.ts\",\"old_string\":\"x\",\"new_string\":\"expect(repo.todo(1)).toBeDefined()\"}}" tests-integrity.sh
run "order.pending() do dominio Pedido passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/o.test.ts\",\"old_string\":\"x\",\"new_string\":\"expect(order.pending()).toBe(true)\"}}" tests-integrity.sh
run "items.only(1) fora de contexto de teste passa" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/i.test.ts\",\"old_string\":\"x\",\"new_string\":\"const a = items.only(1)\"}}" tests-integrity.sh
printf 'it.skip("flaky em CI, ver #123", () => {})\n' > "$T/proj/src/__tests__/legacy.test.ts"
run "Write sobre teste com skip pre-existente passa" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/legacy.test.ts\",\"content\":\"it.skip('flaky em CI, ver #123', () => {})\\nit('novo', () => {})\"}}" tests-integrity.sh
run "apertar max-lines no package.json nao e cobertura" 0 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/package.json\",\"old_string\":\"\\\"max-lines\\\": 300\",\"new_string\":\"\\\"max-lines\\\": 200\"}}" tests-integrity.sh
mkdir -p "$T/alheio/docs/backend"
printf '# API\nDocumentacao comum, sem relacao com o Blueprint.\n' > "$T/alheio/docs/backend/README.md"
run "docs/backend/ de projeto alheio nao e assunto do hook" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/alheio/docs/backend/README.md\",\"content\":\"x\"}}" docs-integrity.sh

echo "== no-secrets: repositorio certo e gatilho ancorado =="
if command -v git >/dev/null 2>&1; then
  A="$T/appdir"; mkdir -p "$A"
  ( cd "$A" && git init -q . && git config user.email t@t && git config user.name t )
  ORIG2=$PWD; cd "$G" || exit 1

  # Segredo no repo de DOCS, commit limpo no repo do APP: nao pode bloquear.
  stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
  printf 'const port = 3000\n' > "$A/clean.js"; ( cd "$A" && git add clean.js )
  run "commit em outro repo nao e barrado por segredo no CWD" 0 \
    "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cd $A && git commit -m x\"}}" no-secrets.sh

  # Segredo no repo do APP: tem de ser visto mesmo rodando do repo de docs.
  printf 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"\n' > "$A/leak.js"; ( cd "$A" && git add leak.js )
  run "segredo no repo-alvo e detectado de fora" 2 \
    "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cd $A && git commit -m x\"}}" no-secrets.sh
  run "git -C <dir> tambem resolve o repo-alvo" 2 \
    "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git -C $A commit -m x\"}}" no-secrets.sh

  stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
  run "git log | grep commit e leitura, nao commit" 0 \
    '{"tool_name":"Bash","tool_input":{"command":"git log --oneline | grep commit"}}' no-secrets.sh
  run "git diff --cached e leitura" 0 \
    '{"tool_name":"Bash","tool_input":{"command":"git diff --cached"}}' no-secrets.sh
  stage 'AWS_KEY=AKIAIOSFODNN7EXAMPLE' env
  run "chave de exemplo oficial da AWS passa" 0 "$CMT" no-secrets.sh
  stage 'password: "LocalDevPassword2024" # seed de desenvolvimento'
  run "senha de seed de desenvolvimento passa" 0 "$CMT" no-secrets.sh
  cd "$ORIG2" || exit 1
fi

echo "== docs-complete emite JSON que chega ao modelo =="
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"'"$T"'/docs/blueprint/05-data-model.md"}}' | bash "$HOOKS/docs-complete.sh" 2>/dev/null)
if printf '%s' "$out" | python3 -c 'import sys,json; d=json.load(sys.stdin); assert d["hookSpecificOutput"]["hookEventName"]=="PostToolUse"; assert d["hookSpecificOutput"]["additionalContext"]' 2>/dev/null; then
  pass=$((pass+1)); printf '  ok    aviso sai como additionalContext valido\n'
else
  fail=$((fail+1)); printf '  FALHA aviso nao e JSON valido com additionalContext\n'
fi

echo "== portabilidade: sem extensoes GNU nos padroes =="
# Comentario pode citar \b e \s para explicar por que nao se usa; o que importa
# e o codigo. Por isso tudo a partir do primeiro # e descartado antes do teste.
for h in docs-integrity tests-integrity no-secrets docs-complete status; do
  offenders=$(sed 's/#.*//' "$HOOKS/$h.sh" | grep -nE '\\b|\\s|\(\?[!=]' 2>/dev/null)
  if [ -n "$offenders" ]; then
    fail=$((fail+1)); printf '  FALHA %s.sh usa \\b, \\s ou lookahead (falha calado no BSD grep)\n' "$h"
    printf '%s\n' "$offenders" | head -3 | sed 's/^/          /'
  else
    pass=$((pass+1)); printf '  ok    %s.sh sem extensao GNU de regex no codigo\n' "$h"
  fi
done

printf '\n  passou: %d   falhou: %d\n\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
