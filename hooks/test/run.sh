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
  stage 'AWS_KEY = "AKIAIOSFODNN7EXAMPLE"'
  run "AWS access key bloqueia" 2 "$CMT" no-secrets.sh
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
  stage 'AWS_KEY = "AKIAIOSFODNN7EXAMPLE"'
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

printf '\n  passou: %d   falhou: %d\n\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
