#!/usr/bin/env bash
# Suite de testes dos hooks do Blueprint no Codex.
#
#   bash codex/hooks/test/run.sh
#
# Os hooks do Codex NAO sao derivados dos do Claude: as ferramentas tem outros
# nomes, o payload de edicao e o texto de um patch em vez de file_path/content,
# e o deny de PreToolUse nao vale para apply_patch. Codigo escrito a mao precisa
# de teste proprio — especialmente o stop-gate, que e onde a regra de fato pega.
#
# O contrato do Stop e mais estrito que o do PreToolUse: o exit code nao diz
# nada, quem decide e o JSON do stdout, e stdout invalido vira erro de hook em
# TODO turno. Por isso cada caso aqui verifica as duas coisas: que o JSON e
# valido e que a decisao dentro dele e a esperada.

set -u
HOOKS="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$HOOKS/../.." && pwd)"
pass=0; fail=0

okc()   { pass=$((pass+1)); printf '  ok    %s\n' "$1"; }
bad()   { fail=$((fail+1)); printf '  FALHA %s\n' "$1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | head -4 | sed 's/^/          /'; return 0; }

run() { # descricao, exit esperado, payload, script
  local out rc
  out=$(printf '%s' "$3" | bash "$HOOKS/$4" 2>&1); rc=$?
  if [ "$rc" = "$2" ]; then okc "$1"; else bad "$1  (esperado exit $2, veio $rc)" "$out"; fi
}

# O Stop responde por JSON, nao por exit code.
gate() { # descricao, block|ok, cwd
  local out dec
  rm -f "${TMPDIR:-/tmp}"/.blueprint-stop-*
  out=$(cd "$3" && CODEX_PROJECT_DIR="$3" bash "$HOOKS/stop-gate.sh" 2>/dev/null)
  dec=$(printf '%s' "$out" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("JSON-INVALIDO"); raise SystemExit
print(d.get("decision") or "ok")
' 2>/dev/null)
  if [ "$dec" = "$2" ]; then okc "$1"; else bad "$1  (esperado $2, veio ${dec:-vazio})" "$out"; fi
}

command -v python3 >/dev/null 2>&1 || { echo "python3 e necessario para esta suite"; exit 1; }
command -v git     >/dev/null 2>&1 || { echo "git e necessario para esta suite"; exit 1; }

T=$(mktemp -d); trap 'rm -rf "$T"; rm -f "${TMPDIR:-/tmp}"/.blueprint-stop-*' EXIT

G="$T/proj"
mkdir -p "$G/docs/blueprint" "$G/src/__tests__"
printf '# Dominio\n\nO usuario tem nome e email.\n\n<!-- APPEND:entities -->\n' > "$G/docs/blueprint/04-domain-model.md"
printf "it('soma', () => { expect(1).toBe(1) })\n"                             > "$G/src/__tests__/u.test.ts"
printf 'export const port = 3000\n'                                            > "$G/src/app.ts"
( cd "$G" && git init -q . && git config user.email t@t && git config user.name t \
  && git add -A && git commit -qm init )
reset() { ( cd "$G" && git checkout -q -- . ); }

echo "== stop-gate: o portao que segura de verdade =="
gate "arvore limpa deixa o turno terminar" ok "$G"

printf '# Dominio\n\nO usuario tem nome, email e telefone.\n' > "$G/docs/blueprint/04-domain-model.md"
gate "documento que perdeu o marcador APPEND bloqueia" block "$G"
reset

printf '# Dominio\n\nO usuario tem nome, email e telefone.\n\n<!-- APPEND:entities -->\n' > "$G/docs/blueprint/04-domain-model.md"
gate "documento editado preservando o marcador passa" ok "$G"
reset

printf "it.skip('soma', () => { expect(1).toBe(1) })\n" > "$G/src/__tests__/u.test.ts"
gate "teste silenciado com it.skip bloqueia" block "$G"
reset

printf "describe.only('U', () => {})\n" > "$G/src/__tests__/u.test.ts"
gate "describe.only bloqueia" block "$G"
reset

printf "it('soma', () => { expect(1).toBe(2) })\n" > "$G/src/__tests__/u.test.ts"
gate "editar a assercao do teste passa" ok "$G"
reset

printf 'export const port = 4000\n' > "$G/src/app.ts"
gate "mudar codigo de producao passa" ok "$G"
reset

printf 'export const a = items.only(1)\n' > "$G/src/app.ts"
gate "items.only() fora de arquivo de teste passa" ok "$G"
reset

echo "== stop-gate: nunca pode quebrar o turno =="
NG="$T/semgit"; mkdir -p "$NG"
gate "fora de repositorio git nao bloqueia" ok "$NG"

E="$T/vazio"; mkdir -p "$E"
( cd "$E" && git init -q . && git config user.email t@t && git config user.name t )
gate "repositorio sem commit nenhum nao bloqueia" ok "$E"

# Sem docs/blueprint/ nao ha Blueprint aqui — docs/backend/ e um nome comum.
AL="$T/alheio"; mkdir -p "$AL/docs/backend"
printf '# API\n\n<!-- APPEND:x -->\n' > "$AL/docs/backend/README.md"
( cd "$AL" && git init -q . && git config user.email t@t && git config user.name t \
  && git add -A && git commit -qm init )
printf '# API\n' > "$AL/docs/backend/README.md"
gate "projeto alheio sem docs/blueprint nao e assunto do hook" ok "$AL"

echo "== stop-gate: laco de bloqueio tem fim =="
printf '# Dominio\n\nSem marcador.\n' > "$G/docs/blueprint/04-domain-model.md"
rm -f "${TMPDIR:-/tmp}"/.blueprint-stop-*
for i in 1 2 3; do ( cd "$G" && CODEX_PROJECT_DIR="$G" bash "$HOOKS/stop-gate.sh" >/dev/null 2>&1 ); done
out=$(cd "$G" && CODEX_PROJECT_DIR="$G" bash "$HOOKS/stop-gate.sh" 2>/dev/null)
if printf '%s' "$out" | python3 -c 'import sys,json; d=json.load(sys.stdin); raise SystemExit(0 if not d.get("decision") else 1)' 2>/dev/null; then
  okc "o quarto bloqueio seguido libera (violacao irreparavel nao prende o agente)"
else
  bad "o laco de bloqueio nao tem saida" "$out"
fi
reset
rm -f "${TMPDIR:-/tmp}"/.blueprint-stop-*

echo "== apply-patch-guard: le o patch, nao um file_path =="
P() { printf '{"tool_name":"apply_patch","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1")"; }

cd "$G" || exit 1
run "patch que remove o marcador APPEND avisa" 2 \
  "$(P '*** Begin Patch
*** Update File: docs/blueprint/04-domain-model.md
-<!-- APPEND:entities -->
+fim
*** End Patch')" apply-patch-guard.sh

run "patch que reposiciona o marcador passa" 0 \
  "$(P '*** Begin Patch
*** Update File: docs/blueprint/04-domain-model.md
-<!-- APPEND:entities -->
+nova entidade
+<!-- APPEND:entities -->
*** End Patch')" apply-patch-guard.sh

run "patch que so acrescenta texto passa" 0 \
  "$(P '*** Begin Patch
*** Update File: docs/blueprint/04-domain-model.md
+O usuario tem telefone.
*** End Patch')" apply-patch-guard.sh

run "patch que acrescenta it.skip avisa" 2 \
  "$(P '*** Begin Patch
*** Update File: src/__tests__/u.test.ts
-it("soma", () => {})
+it.skip("soma", () => {})
*** End Patch')" apply-patch-guard.sh

run "patch que acrescenta @pytest.mark.skip avisa" 2 \
  "$(P '*** Begin Patch
*** Update File: tests/test_user.py
+@pytest.mark.skip
 def test_a():
*** End Patch')" apply-patch-guard.sh

run "model.fit() em arquivo de teste nao e skip" 0 \
  "$(P '*** Begin Patch
*** Update File: tests/test_model.py
+model.fit(X_train, y_train)
*** End Patch')" apply-patch-guard.sh

run "renomear um it.skip ja existente passa" 0 \
  "$(P '*** Begin Patch
*** Update File: src/__tests__/u.test.ts
-it.skip("a", () => {})
+it.skip("a renomeado", () => {})
*** End Patch')" apply-patch-guard.sh

run "patch em codigo de producao passa" 0 \
  "$(P '*** Begin Patch
*** Update File: src/app.ts
+export const port = 4000
*** End Patch')" apply-patch-guard.sh

echo "== degradacao: payload ruim nao pode matar a sessao =="
run "payload vazio no apply-patch-guard" 0 ""          apply-patch-guard.sh
run "payload invalido no apply-patch-guard" 0 "nao e json" apply-patch-guard.sh
run "payload sem tool_input no apply-patch-guard" 0 '{"tool_name":"apply_patch"}' apply-patch-guard.sh
run "payload vazio no no-secrets" 0 "" no-secrets.sh
run "payload invalido no no-secrets" 0 "nao e json" no-secrets.sh

out=$(printf 'nao e json' | CODEX_PROJECT_DIR="$G" bash "$HOOKS/stop-gate.sh" 2>/dev/null)
if printf '%s' "$out" | python3 -c 'import sys,json; json.load(sys.stdin)' 2>/dev/null; then
  okc "stop-gate imprime JSON valido mesmo com stdin lixo"
else
  bad "stop-gate imprimiu stdout nao-JSON (vira erro de hook todo turno)" "$out"
fi

echo "== no-secrets: credencial nao entra no historico =="
CMT='{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
stage() { git reset -q; rm -f f.*; printf '%s\n' "$1" > "f.${2:-js}"; git add "f.${2:-js}"; }
stage 'const port = 3000'
run "codigo limpo passa" 0 "$CMT" no-secrets.sh
stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
run "AWS access key bloqueia" 2 "$CMT" no-secrets.sh
stage 'const t = "ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789"'
run "token do GitHub bloqueia" 2 "$CMT" no-secrets.sh
stage 'API_KEY={{sua_chave}}' md
run "placeholder de template do Blueprint passa" 0 "$CMT" no-secrets.sh
stage 'AWS_KEY = "AKIAQQQQWWWWEEEERRRR"'
run "comando que nao e commit nem push passa" 0 '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' no-secrets.sh
run "git log | grep commit e leitura, nao commit" 0 \
  '{"tool_name":"Bash","tool_input":{"command":"git log --oneline | grep commit"}}' no-secrets.sh
git reset -q; rm -f f.*

echo "== status: informa sem nunca bloquear =="
out=$(CODEX_PROJECT_DIR="$NG" bash "$HOOKS/status.sh" 2>&1); rc=$?
if [ "$rc" = 0 ] && [ -z "$out" ]; then okc "projeto sem Blueprint nao diz nada"; else bad "status falou onde nao ha Blueprint (exit $rc)" "$out"; fi
out=$(CODEX_PROJECT_DIR="$G" bash "$HOOKS/status.sh" 2>&1); rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'Blueprint'; then okc "projeto com Blueprint recebe o estado"; else bad "status nao reportou o estado do projeto (exit $rc)" "$out"; fi
if printf '%s' "$out" | grep -q '/blueprint:'; then
  bad "status cita comando do Claude (/blueprint:) em vez do nome de skill do Codex"
else
  okc "status cita skills no formato do Codex"
fi
cd "$ROOT" || exit 1

echo "== portabilidade: sem extensoes GNU nos padroes =="
for h in apply-patch-guard stop-gate no-secrets status; do
  offenders=$(sed 's/#.*//' "$HOOKS/$h.sh" | grep -nE '\\b|\\s|\(\?[!=]' 2>/dev/null)
  if [ -n "$offenders" ]; then
    bad "$h.sh usa \\b, \\s ou lookahead (falha calado no BSD grep)" "$offenders"
  else
    okc "$h.sh sem extensao GNU de regex no codigo"
  fi
done

echo "== manifesto e skills gerados =="
python3 - "$ROOT" <<'PY' && okc "plugin.json, marketplace.json e frontmatter das skills conferem" || bad "estrutura do plugin Codex invalida"
import json, re, sys
from pathlib import Path
root = Path(sys.argv[1]); out = root / "plugins" / "blueprint"
m = json.loads((out / ".codex-plugin" / "plugin.json").read_text())
assert "hooks" not in m, "o Codex REJEITA o campo hooks no plugin.json"
for k in ("name", "version", "description", "author", "interface", "skills"):
    assert k in m, f"plugin.json sem {k}"
assert m["author"].get("name"), "author.name e obrigatorio"
json.loads((root / ".agents" / "plugins" / "marketplace.json").read_text())
json.loads((out / "hooks" / "hooks.json").read_text())
n = 0
for s in sorted((out / "skills").iterdir()):
    fm = re.match(r"^---\n(.*?)\n---\n", (s / "SKILL.md").read_text(), re.S)
    assert fm, f"{s.name}: sem frontmatter"
    keys = re.findall(r"^([a-z_]+):", fm.group(1), re.M)
    assert keys == ["name", "description"], f"{s.name}: frontmatter {keys}"
    assert re.search(r"^name:\s*(\S+)", fm.group(1), re.M).group(1) == s.name, \
        f"{s.name}: name do frontmatter nao bate com o diretorio"
    n += 1
assert n >= 20, f"so {n} skills geradas"
PY

printf '\n  passou: %d   falhou: %d\n\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
