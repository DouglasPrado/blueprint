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
mkdir -p "$T/pipe/docs/blueprint" "$T/pipe/docs/backend" "$T/pipe/docs/shared"
for i in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16; do
  printf '# %s\n\nconteudo real do projeto.\n\n<!-- APPEND:x -->\n' "$i" > "$T/pipe/docs/blueprint/$i-doc.md"
done
printf '# B\n\nconteudo real.\n' > "$T/pipe/docs/backend/00-backend-vision.md"
printf '# Glossario\n\n| {{Termo}} | {{Definicao}} |\n' > "$T/pipe/docs/shared/glossary.md"
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
  # Segredo apenas STAGED nao vai a lugar nenhum num push — bloquear ali era
  # falso positivo. O push varre o que ele de fato publica: os commits que
  # ainda nao estao no remoto (ver o caso M4 do ciclo 4).
  run "git push com segredo so staged, sem commit, passa" 0 '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' no-secrets.sh
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

echo "== regressao: achados da auditoria =="
# Cada caso abaixo PASSAVA antes da correcao. Sao bypasses reais, nao hipoteses.

mkdir -p "$T/docs/backend"
printf '# Integracoes\n\n<!-- APPEND:webhooks -->\n\n<!-- APPEND:webhooks-enviados -->\n' > "$T/docs/backend/13-integrations.md"
run "remover APPEND:webhooks mantendo APPEND:webhooks-enviados bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/backend/13-integrations.md\",\"old_string\":\"<!-- APPEND:webhooks -->\",\"new_string\":\"fim\\n<!-- APPEND:webhooks-enviados -->\"}}" docs-integrity.sh

printf '# Copies\n\n<!-- do blueprint: 01-vision.md -->\n\n| welcome | Ola, {{nome}}! |\n\n<!-- APPEND:copies -->\n' > "$T/docs/blueprint/14-copies.md"
run "Write sobre doc preenchido que usa {{chave}} de i18n bloqueia" 2 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/14-copies.md\",\"content\":\"x\"}}" docs-integrity.sh

# Payloads com aspas por dentro: montados com python para nao depender de escape.
mk() { python3 -c 'import json,sys; print(json.dumps({"tool_name":sys.argv[1],"tool_input":{"file_path":sys.argv[2],"old_string":sys.argv[3],"new_string":sys.argv[4]}}))' "$@"; }

run "rebaixar o global escondido atras de outro bloco bloqueia" 2 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'coverageThreshold: { global: { lines: 80, branches: 80 } },' \
      'coverageThreshold: {
  "./src/novo/": { lines: 100, branches: 100 },
  global: { lines: 20, branches: 20 },
},')" tests-integrity.sh

run "xit do RSpec (sem parenteses) bloqueia" 2 \
  "$(mk Edit "$T/proj/spec/user_spec.rb" "it 'soma' do" "xit 'soma' do")" tests-integrity.sh

run "metodo do dominio chamado xitem nao e skip" 0 \
  "$(mk Edit "$T/proj/spec/user_spec.rb" 'x' 'expect(cart.xitems).to eq 2')" tests-integrity.sh

if command -v git >/dev/null 2>&1; then
  ORIG3=$PWD; cd "$G" || exit 1
  stage 'DATABASE_URL=postgres://admin:Pr0dP4ssw0rd2024@${DB_HOST}/app' env
  run "senha de producao com \${VAR} na mesma linha bloqueia" 2 "$CMT" no-secrets.sh
  stage 'const awsKey = "AKIAZZZZYYYYXXXXWWWW"; // conta demo'
  run "AWS key com a palavra demo no comentario bloqueia" 2 "$CMT" no-secrets.sh
  stage 'AWS_KEY=AKIAIOSFODNN7EXAMPLE' env
  run "chave de exemplo oficial da AWS continua passando" 0 "$CMT" no-secrets.sh
  stage 'const key = process.env.API_KEY'
  run "leitura de env continua passando" 0 "$CMT" no-secrets.sh
  git reset -q; rm -f f.*
  cd "$ORIG3" || exit 1
fi

mkdir -p "$T/handlebars/docs/backend"
printf '# Handlebars\n\nTemplate: {{user.name}}\n' > "$T/handlebars/docs/backend/README.md"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"'"$T"'/handlebars/docs/backend/README.md"}}' | bash "$HOOKS/docs-complete.sh" 2>/dev/null)
if [ -z "$out" ]; then
  pass=$((pass+1)); printf '  ok    docs-complete fica calado em projeto alheio com {{handlebars}}\n'
else
  fail=$((fail+1)); printf '  FALHA docs-complete injetou contexto em projeto alheio\n'
fi

echo "== docs-complete: os testes olham o CONTEUDO, nao so o exit code =="
# docs-complete NUNCA sai diferente de 0. Testar so o exit code aprova um hook
# que avisa em tudo — inclusive em documento completo e em Edit.
dc() { printf '%s' "$1" | bash "$HOOKS/docs-complete.sh" 2>/dev/null; }
said() { printf '%s' "$1" | grep -q 'additionalContext' 2>/dev/null; }
o1=$(dc "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/05-data-model.md\"}}")
o2=$(dc "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\"}}")
o3=$(dc "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/05-data-model.md\"}}")
if said "$o1"; then pass=$((pass+1)); printf '  ok    avisa no documento com placeholder\n'
else fail=$((fail+1)); printf '  FALHA nao avisou onde havia placeholder\n'; fi
if said "$o2"; then fail=$((fail+1)); printf '  FALHA avisou em documento ja completo\n'
else pass=$((pass+1)); printf '  ok    fica calado no documento completo\n'; fi
if said "$o3"; then fail=$((fail+1)); printf '  FALHA disparou em Edit, que nao e o gatilho\n'
else pass=$((pass+1)); printf '  ok    nao dispara em Edit\n'; fi

echo "== tests-integrity: o ramo de AVISO de supressao existe e nao bloqueia =="
out=$(printf '%s' "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/proj/src/__tests__/u.test.ts\",\"old_string\":\"x\",\"new_string\":\"// @ts-nocheck\"}}" | bash "$HOOKS/tests-integrity.sh" 2>&1); rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'AVISO'; then
  pass=$((pass+1)); printf '  ok    supressao de tipo em teste avisa sem bloquear\n'
else
  fail=$((fail+1)); printf '  FALHA ramo de aviso nao disparou (exit %s)\n' "$rc"
fi

echo "== status: o hook do Claude fala a linguagem do Claude =="
out=$(CLAUDE_PROJECT_DIR="$T/vazio-sem-docs" CLAUDE_PLUGIN_ROOT="$HOOKS/.." bash "$HOOKS/status.sh" 2>&1)
if printf '%s' "$out" | grep -q 'blueprint-init'; then
  fail=$((fail+1)); printf '  FALHA status.sh do Claude manda rodar blueprint-init (comando do Codex)\n'
else
  pass=$((pass+1)); printf '  ok    status.sh do Claude nao cita comando do Codex\n'
fi

echo "== regressao: achados do ciclo 2 =="

# #7 + #11: o ramo que compara com o TEMPLATE PRISTINO nao tinha teste nenhum —
# e por isso o bug do ${#*/docs/} passou. Projeto dentro de um .../docs/.
PR="$T/dd/docs/proj"
mkdir -p "$PR"
cp -r "$HOOKS/../docs" "$PR/docs"
CP="$PR/docs/frontend/web/14-copies.md"
run "template pristino aceita Write (comparado com o do plugin)" 0 \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$PR/docs/blueprint/05-data-model.md\",\"content\":\"x\"}}" docs-integrity.sh
printf '# Copies\n\n| {{auth.login.title}} | Entrar |\n\n<!-- APPEND:copies -->\n' > "$CP"
outp=$(printf '{"tool_name":"Write","tool_input":{"file_path":"'"$CP"'","content":"x"}}' \
  | CLAUDE_PLUGIN_ROOT="$HOOKS/.." bash "$HOOKS/docs-integrity.sh" 2>&1); rcp=$?
if [ "$rcp" = 2 ]; then
  pass=$((pass+1)); printf '  ok    projeto dentro de .../docs/ ainda resolve o template certo\n'
else
  fail=$((fail+1)); printf '  FALHA caminho com /docs/ duplicado comparou com o template errado (exit %s)\n' "$rcp"
fi

# #8: o token sobrevive, o ponto de insercao nao.
printf '# D\n\nreal\n\n<!-- APPEND:entities -->\n' > "$T/docs/blueprint/04-domain-model.md"
run "quebrar o comentario do marcador bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"old_string\":\"<!-- APPEND:entities -->\",\"new_string\":\"<!-- APPEND:entities\"}}" docs-integrity.sh
run "virar o marcador em prosa bloqueia" 2 \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$T/docs/blueprint/04-domain-model.md\",\"old_string\":\"<!-- APPEND:entities -->\",\"new_string\":\"antes tinha APPEND:entities aqui\"}}" docs-integrity.sh

# #4/#5/#6: o limiar que importa e o global.
run "global 80->20 com bloco permissivo ja presente bloqueia" 2 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'coverageThreshold: { global: { lines: 80 }, "./src/gen/": { lines: 10 } }' \
      'coverageThreshold: { global: { lines: 20 }, "./src/gen/": { lines: 10 } }')" tests-integrity.sh
run "acrescentar bloco permissivo para codigo gerado passa" 0 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'coverageThreshold: { global: { branches: 80, lines: 80 } }' \
      'coverageThreshold: { global: { branches: 80, lines: 80 }, "./src/generated/": { branches: 0, lines: 0 } }')" tests-integrity.sh
run "apertar max-lines no setup.cfg nao e cobertura" 0 \
  "$(mk Edit "$T/proj/setup.cfg" 'max-lines = 300' 'max-lines = 200')" tests-integrity.sh
run "apertar max-lines no pyproject.toml nao e cobertura" 0 \
  "$(mk Edit "$T/proj/pyproject.toml" 'max-lines = 300' 'max-lines = 200')" tests-integrity.sh
run "fail_under 90->50 bloqueia" 2 \
  "$(mk Edit "$T/proj/setup.cfg" 'fail_under = 90' 'fail_under = 50')" tests-integrity.sh

# #1: caminho com espaco zerava a varredura de credenciais em silencio.
if command -v git >/dev/null 2>&1; then
  SP="$T/my app"; mkdir -p "$SP"
  ( cd "$SP" && git init -q . && git config user.email t@t && git config user.name t \
    && printf 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"\n' > leak.js && git add -A )
  for form in "cd \"$SP\" && git commit -m x" "git -C \"$SP\" commit -m x"; do
    run "credencial em caminho com espaco bloqueia: ${form%% *}..." 2 \
      "$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$form")" no-secrets.sh
  done
fi

# #13/#22: o ruido vale para o VALOR, nao para a linha nem para o usuario da URL.
if command -v git >/dev/null 2>&1; then
  ORIG4=$PWD; cd "$G" || exit 1
  stage 'const password = "Tr0ub4dor3-9x7Qmz" // demo account'
  run "senha real com // demo no comentario bloqueia" 2 "$CMT" no-secrets.sh
  stage 'const xxx_password = "Tr0ub4dor3-9x7Qmz"'
  run "senha real com xxx no NOME da variavel bloqueia" 2 "$CMT" no-secrets.sh
  stage 'DB=postgres://sample_user:Tr0ub4dor3xyz@db.prod:5432/app' env
  run "URL cujo USUARIO contem sample bloqueia" 2 "$CMT" no-secrets.sh
  stage 'password: "LocalDevPassword2024" # seed de desenvolvimento'
  run "senha de seed de desenvolvimento continua passando" 0 "$CMT" no-secrets.sh
  stage 'const key = process.env.API_KEY'
  run "referencia a env continua passando" 0 "$CMT" no-secrets.sh
  git reset -q; rm -f f.*
  cd "$ORIG4" || exit 1
fi

# #17: a fase shared some do "proximo passo"?
outs=$(CLAUDE_PROJECT_DIR="$T/pipe" bash "$HOOKS/status.sh" 2>&1)
if printf '%s' "$outs" | grep -q 'blueprint:shared'; then
  pass=$((pass+1)); printf '  ok    status aponta /blueprint:shared antes do scaffold\n'
else
  fail=$((fail+1)); printf '  FALHA status pula a fase shared e manda direto para o scaffold\n'
  printf '%s\n' "$outs" | head -6 | sed 's/^/          /'
fi

echo "== regressao: achados do ciclo 3 =="

# A1: `git commit -a` commita arquivo rastreado sem passar pelo indice.
if command -v git >/dev/null 2>&1; then
  AR="$T/commit-a"; mkdir -p "$AR"
  ( cd "$AR" && git init -q . && git config user.email t@t && git config user.name t \
    && printf 'x = 1\n' > s.py && git add -A && git commit -qm init \
    && printf 'AWS_KEY="AKIAYYYYYYYYYYYYYYYY"\n' >> s.py )
  for f in "cd $AR && git commit -am leak" "cd $AR && git commit -a -m leak"; do
    run "credencial nao-staged em 'git commit -a' bloqueia" 2 \
      "$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$f")" no-secrets.sh
  done
  # M1: flags com '='
  ( cd "$AR" && git add -A )
  for f in "cd $AR && git -c user.name=x commit -m y" "cd $AR && git --git-dir=$AR/.git commit -m y"; do
    run "commit com flag '=' e reconhecido como commit" 2 \
      "$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$f")" no-secrets.sh
  done
  # M2: o ULTIMO cd antes do git decide o alvo
  run "o ultimo cd antes do git decide o repositorio varrido" 2 \
    "$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "cd /tmp && cd $AR && git commit -m x")" no-secrets.sh

  # M9 (vacuidade): o filtro de VALOR do sig() nao tinha teste proprio. Os casos
  # do ciclo 2 usavam "demo", que so existe em VALUE_NOISE_GEN — exercitavam a
  # regra generica, nunca as assinaturas.
  ORIG5=$PWD; cd "$G" || exit 1
  stage 'const k = "AKIAZZZZYYYYXXXXWWWW" // sample de producao'
  run "assinatura real com palavra de exemplo no COMENTARIO bloqueia" 2 "$CMT" no-secrets.sh
  stage 'const k = "AKIAIOSFODNN7EXAMPLE"'
  run "assinatura de exemplo no proprio VALOR continua passando" 0 "$CMT" no-secrets.sh
  git reset -q; rm -f f.*
  cd "$ORIG5" || exit 1
fi

# M5: apagar o limiar afrouxa mais que rebaixa-lo.
run "apagar o coverageThreshold bloqueia" 2 \
  "$(mk Edit "$T/proj/jest.config.js" 'coverageThreshold: { global: { lines: 80, branches: 80 } },' '')" tests-integrity.sh
run "apagar fail_under bloqueia" 2 \
  "$(mk Edit "$T/proj/setup.cfg" 'fail_under = 90' '')" tests-integrity.sh

# B1: chaves aninhadas dentro do bloco global.
run "global com bloco aninhado, 80->20, bloqueia" 2 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'coverageThreshold: { global: { nested: { lines: 90 }, lines: 80 } }' \
      'coverageThreshold: { global: { nested: { lines: 90 }, lines: 20 } }')" tests-integrity.sh

# B5: variantes reais de Jest/Vitest e exclusao de caminho.
run "test.concurrent.skip bloqueia" 2 \
  "$(mk Edit "$T/proj/src/__tests__/u.test.ts" 'test.concurrent("a")' 'test.concurrent.skip("a")')" tests-integrity.sh
run "describe.each([]).skip bloqueia" 2 \
  "$(mk Edit "$T/proj/src/__tests__/u.test.ts" 'describe.each([])("a")' 'describe.each([]).skip("a")')" tests-integrity.sh
run "testPathIgnorePatterns novo bloqueia" 2 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'module.exports = { coverageThreshold: { global: { lines: 80 } } }' \
      'module.exports = { coverageThreshold: { global: { lines: 80 } }, testPathIgnorePatterns: ["flaky"] }')" tests-integrity.sh
run "item.list.skip() do dominio nao e skip de teste" 0 \
  "$(mk Edit "$T/proj/src/__tests__/u.test.ts" 'x' 'expect(item.list.skip(2)).toBe(1)')" tests-integrity.sh

# M6 + B2 (vacuidade): as duas derivacoes do rel divergiam, e o ramo do template
# pristino nao tinha teste nenhum — nenhum caso exportava CLAUDE_PLUGIN_ROOT.
mkdir -p "$T/rel/docs/frontend/web"
printf '# Copies\n\n| {{auth.login.title}} | Entrar |\n\n<!-- APPEND:copies -->\n' > "$T/rel/docs/frontend/web/14-copies.md"
mkdir -p "$T/rel/docs/blueprint"
relcase() { # descricao, esperado, file_path, cwd
  local o r
  o=$(cd "$4" && printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$3" \
        | CLAUDE_PLUGIN_ROOT="$HOOKS/.." bash "$HOOKS/docs-integrity.sh" 2>&1); r=$?
  if [ "$r" = "$2" ]; then pass=$((pass+1)); printf '  ok    %s\n' "$1"
  else fail=$((fail+1)); printf '  FALHA %s (esperado %s, veio %s)\n' "$1" "$2" "$r"; fi
}
relcase "doc preenchido com {{i18n}}, file_path RELATIVO, bloqueia" 2 "docs/frontend/web/14-copies.md" "$T/rel"
relcase "doc preenchido com {{i18n}}, file_path absoluto, bloqueia" 2 "$T/rel/docs/frontend/web/14-copies.md" "$T/rel"
cp "$HOOKS/../docs/blueprint/05-data-model.md" "$T/rel/docs/blueprint/05-data-model.md"
relcase "template pristino comparado com o do plugin aceita Write" 0 "$T/rel/docs/blueprint/05-data-model.md" "$T/rel"
printf 'conteudo real, sem placeholder e sem marca de procedencia\n' >> "$T/rel/docs/blueprint/05-data-model.md"
relcase "template que deixou de bater com o do plugin bloqueia" 2 "$T/rel/docs/blueprint/05-data-model.md" "$T/rel"

echo "== stop-gate (Claude): o portao de resultado que faltava =="
if command -v git >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  SG="$T/sg"; mkdir -p "$SG/docs/blueprint" "$SG/src/__tests__"
  printf '# D\n\nreal.\n\n<!-- APPEND:entities -->\n' > "$SG/docs/blueprint/04-domain-model.md"
  printf "it('a',()=>{})\nit('b',()=>{})\n" > "$SG/src/__tests__/u.test.ts"
  ( cd "$SG" && git init -q . && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm base )
  sgd() { ( cd "$2" && CLAUDE_PROJECT_DIR="$2" bash "$HOOKS/stop-gate.sh" 2>/dev/null ) \
            | python3 -c 'import sys,json;print(json.load(sys.stdin).get("decision") or "ok")'; }
  sgcase() { local d; rm -f "$3"/.git/.blueprint-stop-*; d=$(sgd "" "$3")
    if [ "$d" = "$2" ]; then pass=$((pass+1)); printf '  ok    %s\n' "$1"
    else fail=$((fail+1)); printf '  FALHA %s (esperado %s, veio %s)\n' "$1" "$2" "$d"; fi; }
  ( cd "$SG" && CLAUDE_PROJECT_DIR="$SG" bash "$HOOKS/status.sh" >/dev/null 2>&1 )
  sgcase "arvore limpa deixa o turno terminar" ok "$SG"
  # M8: escrita por Bash passa por fora de Write|Edit — e so o Stop pega.
  ( cd "$SG" && sed -i "s/it('a'/it.skip('a'/" src/__tests__/u.test.ts )
  sgcase "sed -i que silencia teste bloqueia (nao passa por Write|Edit)" block "$SG"
  ( cd "$SG" && git checkout -q -- . )
  # A3: apagar e esvaziar.
  rm "$SG/src/__tests__/u.test.ts"
  sgcase "apagar o arquivo de teste bloqueia" block "$SG"
  ( cd "$SG" && git checkout -q -- . )
  printf '' > "$SG/src/__tests__/u.test.ts"
  sgcase "esvaziar o arquivo de teste bloqueia" block "$SG"
  ( cd "$SG" && git checkout -q -- . )
  printf "it('a',()=>{})\n" > "$SG/src/__tests__/u.test.ts"
  sgcase "remover UM teste de dois bloqueia" block "$SG"
  ( cd "$SG" && git checkout -q -- . )
  ( cd "$SG" && git mv src/__tests__/u.test.ts src/__tests__/v.test.ts )
  sgcase "MOVER o teste de arquivo nao bloqueia" ok "$SG"
  ( cd "$SG" && git reset -q --hard HEAD )
  printf "it('a',()=>{})\nit('b',()=>{})\nit('c',()=>{})\n" > "$SG/src/__tests__/u.test.ts"
  sgcase "acrescentar teste nao bloqueia" ok "$SG"
  ( cd "$SG" && git checkout -q -- . )
  # A2: projeto num subdiretorio do repositorio.
  MO="$T/mono"; mkdir -p "$MO/apps/web/docs/blueprint" "$MO/apps/web/src/__tests__"
  printf '# D\n\nreal.\n\n<!-- APPEND:entities -->\n' > "$MO/apps/web/docs/blueprint/04-domain-model.md"
  printf "it('a',()=>{})\n" > "$MO/apps/web/src/__tests__/u.test.ts"
  ( cd "$MO" && git init -q . && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm base )
  ( cd "$MO/apps/web" && CLAUDE_PROJECT_DIR="$MO/apps/web" bash "$HOOKS/status.sh" >/dev/null 2>&1 )
  printf '# D\n\nsem marcador\n' > "$MO/apps/web/docs/blueprint/04-domain-model.md"
  sgcase "projeto em subdiretorio do repo: marcador perdido bloqueia" block "$MO/apps/web"
  ( cd "$MO" && git checkout -q -- . )
  printf "it.skip('a',()=>{})\n" > "$MO/apps/web/src/__tests__/u.test.ts"
  sgcase "projeto em subdiretorio do repo: teste silenciado bloqueia" block "$MO/apps/web"
  ( cd "$MO" && git checkout -q -- . )
fi

echo "== status: a ordem do proximo passo e a do pipeline =="
mkfull() { mkdir -p "$1/docs/blueprint" "$1/docs/backend" "$1/docs/frontend/web" "$1/docs/shared"
  for i in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16; do
    printf '# %s\n\nreal.\n' "$i" > "$1/docs/blueprint/$i-d.md"; done
  for i in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
    printf '# %s\n\nreal.\n' "$i" > "$1/docs/backend/$i-d.md"; done; }
nx() { CLAUDE_PROJECT_DIR="$1" bash "$HOOKS/status.sh" 2>/dev/null | sed -n 's/^Proximo: //p'; }
ordcase() { local g; g=$(nx "$2")
  case "$g" in *"$3"*) pass=$((pass+1)); printf '  ok    %s\n' "$1" ;;
  *) fail=$((fail+1)); printf '  FALHA %s (veio: %s)\n' "$1" "${g:-vazio}" ;; esac; }
ST="$T/ord"; mkfull "$ST"
printf '# f\n\n{{placeholder}}\n' > "$ST/docs/frontend/web/00-d.md"
printf '# g\n\n{{placeholder}}\n' > "$ST/docs/shared/glossary.md"
ordcase "frontend em template vem antes de shared" "$ST" "frontend-app"
printf '# f\n\nreal.\n' > "$ST/docs/frontend/web/00-d.md"
ordcase "com frontend pronto, shared vem antes do scaffold" "$ST" "blueprint:shared"
printf '# g\n\nreal.\n' > "$ST/docs/shared/glossary.md"
ordcase "so entao specs/codegen-setup" "$ST" "codegen-setup"
mkdir -p "$ST/docs/prototype"; printf '# p\n\n{{placeholder}}\n' > "$ST/docs/prototype/00-d.md"
ordcase "prototipo em template com backend PRONTO nao e mais sugerido" "$ST" "codegen-setup"

echo "== regressao: achados do ciclo 4 =="

if command -v git >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  Q="$T/acentos"; mkdir -p "$Q/docs/blueprint" "$Q/src/__tests__" "$Q/e2e"
  printf '# D\n\nreal.\n\n<!-- APPEND:entities -->\n' > "$Q/docs/blueprint/04-domínio.md"
  printf "it('a',()=>{})\nit('b',()=>{})\n"           > "$Q/src/__tests__/sessão.test.js"
  printf "test.describe('login',()=>{})\n"            > "$Q/e2e/login.spec.ts"
  printf 'module.exports = { preset: "ts-jest", globals: { "ts-jest": { isolatedModules: true } }, coverageThreshold: { global: { lines: 90, branches: 90 } } }\n' > "$Q/jest.config.js"
  ( cd "$Q" && git init -q . && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm base && CLAUDE_PROJECT_DIR="$Q" bash "$HOOKS/status.sh" >/dev/null 2>&1 )
  qd() { ( cd "$Q" && CLAUDE_PROJECT_DIR="$Q" bash "$HOOKS/stop-gate.sh" 2>/dev/null ) \
           | python3 -c 'import sys,json;print(json.load(sys.stdin).get("decision") or "ok")'; }
  qcase() { local d; d=$(qd); rm -f "$Q"/.git/.blueprint-stop-*
    if [ "$d" = "$2" ]; then pass=$((pass+1)); printf '  ok    %s\n' "$1"
    else fail=$((fail+1)); printf '  FALHA %s (esperado %s, veio %s)\n' "$1" "$2" "$d"; fi
    ( cd "$Q" && git checkout -q -- . 2>/dev/null; git clean -qfd 2>/dev/null ); rm -f "$Q"/.git/.blueprint-stop-*; }

  # A1: core.quotepath devolve o nome entre aspas e com escapes octais.
  sed -i '/APPEND/d' "$Q/docs/blueprint/04-domínio.md"
  qcase "A1 marcador perdido em arquivo com ACENTO bloqueia" block
  printf "it.skip('a',()=>{})\n" > "$Q/src/__tests__/sessão.test.js"
  qcase "A1 skip em arquivo de teste com ACENTO bloqueia" block
  rm "$Q/src/__tests__/sessão.test.js"
  qcase "A1 teste apagado em arquivo com ACENTO bloqueia" block

  # A3: comentar e a forma mais barata de apagar.
  printf "// it('a',()=>{})\n// it('b',()=>{})\n" > "$Q/src/__tests__/sessão.test.js"
  qcase "A3 comentar todos os testes bloqueia" block

  # M6: refatoracao legitima nao pode bloquear.
  printf "it.each([[1,2]])('soma %%i',(a,b)=>{})\nit('b',()=>{})\n" > "$Q/src/__tests__/sessão.test.js"
  qcase "M6 refatorar it( para it.each( NAO bloqueia" ok

  # M2: apagar o documento inteiro e pior que perder um marcador.
  rm "$Q/docs/blueprint/04-domínio.md"
  qcase "M2 apagar o documento do Blueprint bloqueia" block

  # A4 + M1: limiar de cobertura no portao de resultado, com a chave globals.
  sed -i 's/lines: 90, branches: 90/lines: 10, branches: 10/' "$Q/jest.config.js"
  qcase "A4 rebaixar o limiar com 'globals:' do ts-jest presente bloqueia" block
  rm "$Q/jest.config.js"
  qcase "M1 apagar o arquivo de config de cobertura bloqueia" block

  # A5: a cadeia do SKIP tem de valer nos tres hooks.
  printf "test.describe.skip('login',()=>{})\n" > "$Q/e2e/login.spec.ts"
  qcase "A5 test.describe.skip do Playwright bloqueia no stop-gate" block
  qcase "arvore limpa continua liberando" ok
fi

# A4 tambem no PreToolUse.
run "A4 rebaixar limiar com 'globals:' presente bloqueia (tests-integrity)" 2 \
  "$(mk Edit "$T/proj/jest.config.js" \
      'globals: { "ts-jest": { isolatedModules: true } }, coverageThreshold: { global: { lines: 90 } }' \
      'globals: { "ts-jest": { isolatedModules: true } }, coverageThreshold: { global: { lines: 10 } }')" tests-integrity.sh

# B1: a alternativa nao ancorada saiu; chamada fluente nao e skip de teste.
run "B1 .skip() de query fluente nao e skip de teste" 0 \
  "$(mk Edit "$T/proj/src/__tests__/u.test.ts" 'x' 'const r = await col.find(q).limit(10).skip()')" tests-integrity.sh

# A5 (drift): os tres SKIP precisam ser o MESMO padrao.
s1=$(sed -n 's/.*SKIP="\(.*\)"$/\1/p' "$HOOKS/tests-integrity.sh")
s2=$(sed -n 's/.*SKIP="\(.*\)"$/\1/p' "$HOOKS/stop-gate.sh")
s3=$(sed -n 's/.*SKIP="\(.*\)"$/\1/p' "$HOOKS/../codex/hooks/apply-patch-guard.sh")
if [ -n "$s1" ] && [ "$s1" = "$s2" ] && [ "$s1" = "$s3" ]; then
  pass=$((pass+1)); printf '  ok    o padrao SKIP e identico nos tres hooks\n'
else
  fail=$((fail+1)); printf '  FALHA os tres hooks divergiram no padrao SKIP\n'
fi

# A6 + M4: no-secrets.
if command -v git >/dev/null 2>&1; then
  NS="$T/nosec"; mkdir -p "$NS/sub"
  ( cd "$NS" && git init -q . && git config user.email t@t && git config user.name t \
    && printf 'limpo = 1\n' > ok.txt && git add -A && git commit -qm init \
    && printf 'AWS_KEY="AKIAABCDEFGHIJKLMNOP"\n' >> ok.txt \
    && printf 'x = 1\n' > sub/f.txt && git add sub/f.txt )
  nsc() { python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$2"; }
  for m in 'corrige flag -a do parser' 'docs: explica a flag --all' 'fix: trata -amount negativo'; do
    run "A6 ' -a' na MENSAGEM nao liga o modo -a" 0 "$(nsc x "cd $NS && git commit -m \"$m\"")" no-secrets.sh
  done
  run "A6 '-a' de verdade continua ligando" 2 "$(nsc x "cd $NS && git commit -a -m x")" no-secrets.sh
  run "A6 '-am' de verdade continua ligando" 2 "$(nsc x "cd $NS && git commit -am x")" no-secrets.sh
  ( cd "$NS" && git add -A && git commit -qm "leak commitado" )
  run "M4 git push varre os commits ainda nao publicados" 2 "$(nsc x "cd $NS && git push origin main")" no-secrets.sh
fi

# M3: docs/frontend/shared/ era invisivel na cadeia do proximo passo.
FS="$T/fshared"; mkfull "$FS"
mkdir -p "$FS/docs/frontend/shared" "$FS/docs/frontend/web" "$FS/docs/shared"
printf '# ds\n\n{{placeholder}}\n' > "$FS/docs/frontend/shared/03-design-system.md"
printf '# f\n\nreal.\n' > "$FS/docs/frontend/web/00-d.md"
printf '# g\n\nreal.\n' > "$FS/docs/shared/glossary.md"
ordcase "M3 frontend/shared em template vem antes de tudo que depende dele" "$FS" "frontend-design-system"
printf '# ds\n\nreal.\n' > "$FS/docs/frontend/shared/03-design-system.md"
ordcase "M3 com frontend/shared pronto, segue para o scaffold" "$FS" "codegen-setup"

echo "== A7: o registro dos hooks e o proprio contrato =="
# Sabotar hooks.json passava nas duas suites: o plugin ficava sem portao de
# resultado nenhum e 119/119 continuava verde.
hj="$HOOKS/hooks.json"
chkhook() { # evento, script esperado
  if python3 - "$hj" "$1" "$2" <<'PYEOF' 2>/dev/null
import json, sys
d = json.load(open(sys.argv[1]))["hooks"]
ev, want = sys.argv[2], sys.argv[3]
assert ev in d, f"evento {ev} nao registrado"
assert any(want in h.get("command", "") for g in d[ev] for h in g.get("hooks", [])), \
    f"{want} nao registrado em {ev}"
PYEOF
  then pass=$((pass+1)); printf '  ok    %s registrado em %s\n' "$2" "$1"
  else fail=$((fail+1)); printf '  FALHA %s NAO esta registrado em %s\n' "$2" "$1"; fi
}
chkhook Stop         stop-gate.sh
chkhook SessionStart status.sh
chkhook PreToolUse   docs-integrity.sh
chkhook PreToolUse   tests-integrity.sh
chkhook PreToolUse   no-secrets.sh
chkhook PostToolUse  docs-complete.sh
# Todo script referenciado existe, e todo script existente e referenciado.
miss=""; orf=""
for s in "$HOOKS"/*.sh; do
  b=$(basename "$s")
  grep -q "$b" "$hj" || orf="$orf $b"
done
for b in $(python3 -c 'import json,re,sys;print(" ".join(sorted(set(re.findall(r"([a-z-]+\.sh)", open(sys.argv[1]).read())))))' "$hj"); do
  [ -f "$HOOKS/$b" ] || miss="$miss $b"
done
if [ -z "$miss" ] && [ -z "$orf" ]; then
  pass=$((pass+1)); printf '  ok    hooks.json e hooks/ estao em correspondencia exata\n'
else
  fail=$((fail+1)); printf '  FALHA hooks.json: ausentes:%s orfaos:%s\n' "${miss:- nenhum}" "${orf:- nenhum}"
fi

echo "== portabilidade: sem extensoes GNU nos padroes =="
# Comentario pode citar \b e \s para explicar por que nao se usa; o que importa
# e o codigo. Por isso tudo a partir do primeiro # e descartado antes do teste.
for h in docs-integrity tests-integrity no-secrets docs-complete status stop-gate; do
  offenders=$(sed 's/#.*//' "$HOOKS/$h.sh" | grep -nE '\\b|\\s|\(\?[!=]|sed[^|]*\\\\\|' 2>/dev/null)
  if [ -n "$offenders" ]; then
    fail=$((fail+1)); printf '  FALHA %s.sh usa \\b, \\s ou lookahead (falha calado no BSD grep)\n' "$h"
    printf '%s\n' "$offenders" | head -3 | sed 's/^/          /'
  else
    pass=$((pass+1)); printf '  ok    %s.sh sem extensao GNU de regex no codigo\n' "$h"
  fi
done

printf '\n  passou: %d   falhou: %d\n\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
