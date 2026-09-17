#!/usr/bin/env bash
# Blueprint — segredo nao entra no historico
#
# PreToolUse(Bash). Antes de um commit ou push, varre o que esta STAGED em busca
# de credencial. Bloqueia se achar.
#
# Regra do checklist de seguranca do framework (blueprint/13-security.md e os
# tres 11-security.md de frontend): "Secrets nunca commitados no repositorio."
#
# Segredo commitado nao se remove com um novo commit — ele fica no historico,
# nos forks e nos clones de quem ja puxou. O unico momento barato de impedir e
# antes do commit. Dai o portao estar aqui.
#
# Padroes deliberadamente estreitos: falso-positivo aqui trava o trabalho.

payload=$(cat 2>/dev/null) || exit 0
[ -z "$payload" ] && exit 0

cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | python3 -c '
import sys, json
try:
    sys.stdout.write((json.load(sys.stdin).get("tool_input") or {}).get("command") or "")
except Exception:
    pass
' 2>/dev/null)
fi
[ -z "$cmd" ] && exit 0

printf '%s' "$cmd" | grep -qE '\bgit\b.*\b(commit|push)\b' 2>/dev/null || exit 0
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

staged=$(git diff --cached --no-color 2>/dev/null | grep '^+' | grep -v '^+++' 2>/dev/null)
[ -z "$staged" ] && exit 0

hits=""
add_hit() { hits="$hits  - $1\n"; }

# Prefixos de provedor: praticamente nao dao falso-positivo.
printf '%s' "$staged" | grep -qE 'AKIA[0-9A-Z]{16}'                 2>/dev/null && add_hit "AWS Access Key ID (AKIA...)"
printf '%s' "$staged" | grep -qE 'ASIA[0-9A-Z]{16}'                 2>/dev/null && add_hit "AWS temporary key (ASIA...)"
printf '%s' "$staged" | grep -qE 'gh[pousr]_[A-Za-z0-9]{36,}'        2>/dev/null && add_hit "GitHub token (ghp_/gho_/ghu_/ghs_/ghr_)"
printf '%s' "$staged" | grep -qE 'github_pat_[A-Za-z0-9_]{50,}'      2>/dev/null && add_hit "GitHub fine-grained PAT"
printf '%s' "$staged" | grep -qE '\bsk-[A-Za-z0-9_-]{20,}'           2>/dev/null && add_hit "chave de API no formato sk-..."
printf '%s' "$staged" | grep -qE '\b(sk|rk)_(live|test)_[A-Za-z0-9]{16,}' 2>/dev/null && add_hit "chave Stripe (sk_live/sk_test)"
printf '%s' "$staged" | grep -qE 'xox[baprs]-[A-Za-z0-9-]{10,}'      2>/dev/null && add_hit "token Slack (xox...)"
printf '%s' "$staged" | grep -qE 'AIza[0-9A-Za-z_-]{35}'             2>/dev/null && add_hit "chave Google API (AIza...)"
printf '%s' "$staged" | grep -qE 'SG\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}' 2>/dev/null && add_hit "chave SendGrid"
printf '%s' "$staged" | grep -qE 'BEGIN [A-Z ]*PRIVATE KEY'          2>/dev/null && add_hit "bloco de chave privada (PEM)"
printf '%s' "$staged" | grep -qE '(postgres|postgresql|mysql|mongodb(\+srv)?|redis|amqp)://[^:/@[:space:]]+:[^@[:space:]]{6,}@' 2>/dev/null && add_hit "URL de conexao com senha embutida"

# Atribuicao generica: exige valor longo e sem cara de placeholder.
printf '%s' "$staged" \
  | grep -iE '(api[_-]?key|secret|password|passwd|token|private[_-]?key|access[_-]?key)["'"'"']?\s*[:=]\s*["'"'"'][^"'"'"']{16,}["'"'"']' 2>/dev/null \
  | grep -ivE '(example|sample|dummy|placeholder|changeme|your[_-]|xxx+|\*{4,}|\{\{|\$\{|<[a-z_]+>|process\.env|os\.environ|getenv|redacted|fake|test[_-]?only)' 2>/dev/null \
  | grep -q . 2>/dev/null && add_hit "atribuicao de segredo com valor literal longo"

[ -z "$hits" ] && exit 0

files=$(git diff --cached --name-only 2>/dev/null | head -12 | sed 's/^/  /')

printf 'BLOQUEADO — ha credencial no que esta staged para commit.\n\n' >&2
printf "$hits" >&2
cat >&2 <<MSG

Arquivos staged:
$files

Segredo commitado nao se remove com outro commit: ele permanece no historico, nos
forks e em cada clone ja feito. Reescrever historico publicado e caro e nem sempre
possivel. O unico momento barato de impedir e agora.

O que fazer:
  1. git restore --staged <arquivo>   para tirar do commit
  2. mova o valor para variavel de ambiente e referencie por nome
  3. registre a variavel em .env.example — SEM o valor
  4. se a credencial ja foi exposta em algum lugar, ROTACIONE-A; um segredo que
     passou por um arquivo nao versionado com backup ja e um segredo gasto

O framework tem lugar para isto:
  docs/backend/13-integrations.md  — variaveis por integracao
  docs/blueprint/13-security.md    — gestao e rotacao de chaves

Falso-positivo? Comite com --no-verify se o seu fluxo permitir, ou ajuste o
padrao em hooks/no-secrets.sh. Prefira conferir duas vezes: o custo dos dois
caminhos nao e simetrico.
MSG
exit 2
