#!/usr/bin/env bash
# Blueprint — segredo nao entra no historico
#
# PreToolUse(Bash). Antes de um commit ou push, varre o que esta STAGED no
# repositorio QUE VAI RECEBER o commit. Bloqueia se achar credencial.
#
# Regra do checklist de seguranca (blueprint/13-security.md): "Secrets nunca
# commitados no repositorio."
#
# Segredo commitado nao se remove com um novo commit: fica no historico, nos
# forks e em cada clone ja feito. O unico momento barato de impedir e antes.
#
# PORTABILIDADE: \b e \s sao extensoes GNU. No BSD grep do macOS \b nao e
# fronteira de palavra e \s casa com a letra "s" — um hook escrito com eles vira
# no-op silencioso justamente na plataforma onde mais se roda. Aqui tudo usa
# classes POSIX explicitas.
#
# Na duvida, deixa passar.

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

# --- 1. E mesmo um commit/push? -----------------------------------------
# Ancorado no SUBCOMANDO. "git log --oneline | grep commit" nao e commit, e
# bloquear leitura por causa do stage e o tipo de coisa que faz desligar o
# plugin. Tolera "cd X && git ...", "git -C X ..." e flags globais.
printf '%s' "$cmd" \
  | grep -qE '(^|[;&|][[:space:]]*)[[:space:]]*git([[:space:]]+(-C[[:space:]]+[^[:space:]]+|--[a-z-]+([[:space:]]+[^[:space:]]+)?|-[a-z]))*[[:space:]]+(commit|push)([[:space:]]|$)' 2>/dev/null \
  || exit 0

command -v git >/dev/null 2>&1 || exit 0

# --- 2. QUAL repositorio vai receber o commit? ---------------------------
# O fluxo documentado do framework roda a documentacao num repo e o codigo em
# outro (`/blueprint:pipeline docs/prd.md web ../my-app/`). Varrer o CWD
# protegeria o repo errado: falso-positivo no repo de docs e falso-negativo no
# de codigo, na mesma linha.
target=""
# "git -C <dir>"
t=$(printf '%s' "$cmd" | sed -n 's/.*git[[:space:]]\{1,\}-C[[:space:]]\{1,\}\([^[:space:]]\{1,\}\).*/\1/p' | head -1)
[ -n "$t" ] && target="$t"
# "cd <dir> && git ..."
if [ -z "$target" ]; then
  t=$(printf '%s' "$cmd" | sed -n 's/^[[:space:]]*cd[[:space:]]\{1,\}\([^[:space:]&;|]\{1,\}\).*/\1/p' | head -1)
  [ -n "$t" ] && target="$t"
fi
[ -z "$target" ] && target="${CLAUDE_PROJECT_DIR:-.}"

# Tira aspas simples/duplas do caminho, se houver.
target=$(printf '%s' "$target" | sed "s/^['\"]//; s/['\"]$//")
[ -d "$target" ] || exit 0
git -C "$target" rev-parse --git-dir >/dev/null 2>&1 || exit 0

staged=$(git -C "$target" diff --cached --no-color 2>/dev/null | grep '^+' | grep -v '^+++' 2>/dev/null)
[ -z "$staged" ] && exit 0

# --- 3. Descarta o que e claramente exemplo ------------------------------
# O filtro atua sobre o VALOR CASADO, nao sobre a linha inteira. Filtrar a linha
# derruba a varredura com uma palavra comum: `// conta demo` num comentario, ou
# um `${DB_HOST}` no fim da URL, fazia uma AWS key real e uma senha de producao
# real passarem inteiras. A assinatura ja e especifica; quem precisa parecer
# exemplo e a credencial, nao o texto ao redor dela.
VALUE_NOISE='(EXAMPLE|example|sample|dummy|placeholder|changeme|your[_-]|xxx+|\*\*\*\*|\{\{|\$\{|<[a-zA-Z_]+>|redacted|fake|wJalrXUtnFEMI)'

hits=""
hit() { hits="$hits  - $1\n"; }
# Assinatura especifica: casa, depois descarta a propria credencial se ela for
# obviamente de exemplo (AKIAIOSFODNN7EXAMPLE aparece em toda documentacao AWS).
sig() {
  printf '%s' "$staged" | grep -oE "$1" 2>/dev/null | grep -vqE "$VALUE_NOISE" 2>/dev/null && hit "$2"
}

sig 'AKIA[0-9A-Z]{16}'                        "AWS Access Key ID (AKIA...)"
sig 'ASIA[0-9A-Z]{16}'                        "AWS temporary key (ASIA...)"
sig 'gh[pousr]_[A-Za-z0-9]{36,}'              "GitHub token (ghp_/gho_/ghu_/ghs_/ghr_)"
sig 'github_pat_[A-Za-z0-9_]{50,}'            "GitHub fine-grained PAT"
sig '(^|[^A-Za-z0-9_])sk-[A-Za-z0-9_-]{20,}'  "chave de API no formato sk-..."
sig '(^|[^A-Za-z0-9_])(sk|rk)_(live|test)_[A-Za-z0-9]{16,}' "chave Stripe"
sig 'xox[baprs]-[A-Za-z0-9-]{10,}'            "token Slack (xox...)"
sig 'AIza[0-9A-Za-z_-]{35}'                   "chave Google API (AIza...)"
sig 'SG\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}' "chave SendGrid"
sig 'BEGIN [A-Z ]*PRIVATE KEY'                "bloco de chave privada (PEM)"
sig '(postgres|postgresql|mysql|mongodb(\+srv)?|redis|amqp)://[^:/@[:space:]]+:[^@[:space:]]{6,}@' \
                                              "URL de conexao com senha embutida"

# Atribuicao generica: aqui sim o contexto da LINHA decide, porque "valor longo
# entre aspas" sozinho nao e assinatura de nada — process.env.X, {{chave}} e
# seed de desenvolvimento casariam todos.
LINE_NOISE="$VALUE_NOISE"'|(process\.env|os\.environ|getenv|seed|fixture|mock|demo|test[_-]?only|local[_-]?dev)'
printf '%s' "$staged" | grep -vE "$LINE_NOISE" 2>/dev/null \
  | grep -iE '(api[_-]?key|secret|password|passwd|token|private[_-]?key|access[_-]?key)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{16,}["'"'"']' 2>/dev/null \
  | grep -q . 2>/dev/null && hit "atribuicao de segredo com valor literal longo"

[ -z "$hits" ] && exit 0

files=$(git -C "$target" diff --cached --name-only 2>/dev/null | head -12 | sed 's/^/  /')
where=$(cd "$target" 2>/dev/null && pwd)

printf 'BLOQUEADO — ha credencial no que esta staged para commit.\n\n' >&2
printf "$hits" >&2
cat >&2 <<MSG

Repositorio: $where
Arquivos staged:
$files

Segredo commitado nao se remove com outro commit: ele permanece no historico, nos
forks e em cada clone ja feito. Reescrever historico publicado e caro e nem sempre
possivel. O unico momento barato de impedir e agora.

O que fazer:
  1. git -C "$target" restore --staged <arquivo>
  2. mova o valor para variavel de ambiente e referencie por nome
  3. registre a variavel em .env.example — SEM o valor
  4. se a credencial ja foi exposta em algum lugar, ROTACIONE-A

O framework tem lugar para isto:
  docs/backend/13-integrations.md  — variaveis por integracao
  docs/blueprint/13-security.md    — gestao e rotacao de chaves

Se for falso-positivo: NAO adianta "git commit --no-verify" — essa flag pula os
hooks do proprio git, nao este portao, e o comando sera bloqueado de novo. Tire o
arquivo do stage, ou desative este hook removendo a entrada de no-secrets.sh em
hooks/hooks.json da sua copia instalada.
MSG
exit 2
