# Blueprint — instruções para agentes que trabalham NESTE repositório

Este repositório é o plugin Blueprint, publicado em duas plataformas a partir de
uma fonte só. Ele não é um projeto que *usa* o Blueprint — é o Blueprint.

Se você chegou aqui querendo *aplicar* o framework a um produto, você está no
repositório errado: instale o plugin e rode `blueprint-init` na raiz do **seu**
projeto.

---

## A regra que mais se quebra aqui

**`plugins/` e `.agents/plugins/marketplace.json` são gerados. Não edite nada lá.**

```
skills/           ← FONTE (Claude Code)
docs/             ← FONTE (biblioteca de templates)
hooks/            ← FONTE (hooks do Claude Code)
codex/hooks/      ← FONTE (hooks do Codex, escritos à mão)
tools/build-codex.py
        │
        └──► plugins/blueprint/**            DERIVADO
             .agents/plugins/marketplace.json DERIVADO
```

Toda edição em `plugins/` é perdida no próximo `python3 tools/build-codex.py`.
Cada arquivo gerado carrega um cabeçalho dizendo isso. Edite a fonte.

```bash
python3 tools/build-codex.py          # regenera
python3 tools/build-codex.py --check  # falha se o gerado estiver defasado
```

Rode o gerador sempre que mexer em `skills/`, `docs/` ou `codex/hooks/`, e
**commite o resultado junto**: o marketplace do Codex serve `plugins/` direto do
repositório, então gerado defasado é plugin quebrado para quem instala.

## Os hooks do Codex não são derivados dos do Claude

`tools/build-codex.py` traduz skills e templates, mas **copia** `codex/hooks/`
sem traduzir. Isso é proposital — as duas plataformas divergem no que importa.

**Só `apply-patch-guard.sh` é escrito à mão.** `no-secrets.sh`, `status.sh` e
`stop-gate.sh` são **derivados** dos de `hooks/`: nada neles depende de nome de
ferramenta, formato de payload ou evento — os dois agentes usam o mesmo contrato
de `SessionStart` e de `Stop`. Manter cópias à mão só produziu drift: a do
`no-secrets` ficou para trás de correções de segurança, e ninguém percebeu
porque as duas suítes passavam. Se um hook do Codex virar tradução pura de um do
Claude, mova-o para o gerador em vez de copiar.

| | Claude Code | Codex |
| --- | --- | --- |
| Ferramenta de edição | `Write` / `Edit`, com `file_path` e `content` | `apply_patch`, com o texto do patch em `tool_input.command` |
| `PreToolUse` deny | aplicado | **não aplicado a `apply_patch`** (openai/codex#27833, aberta) |
| `code_mode_exec` | não existe | **não dispara `PreToolUse`** (openai/codex#23411) |
| Variável de projeto | `CLAUDE_PROJECT_DIR` | `CODEX_PROJECT_DIR` |
| Raiz do plugin | `${CLAUDE_PLUGIN_ROOT}` | `${PLUGIN_ROOT}` |
| Declaração dos hooks | campo `hooks` no manifesto | `hooks/hooks.json`, descoberto por convenção |
| Confiança nos hooks | ativos após instalar | o usuário precisa **revisar e confiar** antes de rodarem |
| Peso do `Stop` | defesa em profundidade (o `PreToolUse` já pega `Write`/`Edit`) | **a única aplicação** — nada impede a escrita |
| Arquivo de instruções do projeto | `CLAUDE.md` | `AGENTS.md` |

No manifesto do Codex o campo `hooks` fica **fora de propósito**: um valor
explícito ali *substitui* a descoberta por arquivo em vez de somar a ela, e
`hooks/hooks.json` no lugar convencional já é o que o Codex procura sozinho.
Declarar nos dois lugares só cria um jeito de os dois discordarem.

Consequência de projeto: **no Codex a aplicação vive no evento `Stop`**, não no
`PreToolUse`. Um portão que só avisa não é portão, e o deny do `PreToolUse` não
chega em `apply_patch`. `codex/hooks/stop-gate.sh` verifica o *resultado* na
árvore com o git e devolve `decision:block` — o que funciona independente de
qual ferramenta produziu a mudança. `apply-patch-guard.sh` continua existindo
como aviso antecipado (sai mais barato desfazer antes), mas não é o portão.

Se a issue #27833 fechar, o `apply-patch-guard` pode virar bloqueio de verdade —
o `stop-gate` continua valendo de qualquer forma, por causa do `code_mode_exec`.

**Limite conhecido do `stop-gate`:** a base da sessão é um arquivo em `.git/`.
Um `rm -f .git/.blueprint-base-*` restabelece o bypass por commit. Isso não tem
conserto dentro do modelo: o hook roda como o usuário, com as permissões do
usuário, sobre o repositório do usuário. O portão existe para impedir que um
agente sob pressão afrouxe a suíte sem querer, não para resistir a alguém que
queira desligá-lo — para isso serve o CI, que roda onde o agente não escreve.

**Contrato do `Stop`:** o exit code não decide nada; quem decide é o JSON no
stdout, e stdout inválido vira erro de hook em **todo** turno. Por isso todo
caminho de `stop-gate.sh` termina imprimindo JSON válido, inclusive os caminhos
de erro. Se você mexer nesse script, o teste que verifica isso é obrigatório.

## Antes de commitar

```bash
bash hooks/test/run.sh          # 119 casos — hooks do Claude Code
bash codex/hooks/test/run.sh    # 57 casos — hooks do Codex + estrutura do gerado
python3 tools/build-codex.py --check
```

Hook mal formado **falha em silêncio**: não bloqueia, não avisa, e o plugin
parece instalado enquanto não faz nada. As suítes existem por causa disso, e
cobrem tanto o que cada hook deve bloquear quanto o que ele **não** pode
bloquear — falso positivo é o que faz o usuário desligar o plugin inteiro.

## Portabilidade de shell

Os hooks rodam no macOS, onde `grep` é BSD. `\b`, `\s` e lookahead são extensões
GNU: no BSD elas não dão erro, elas simplesmente **não casam** — o hook passa a
aceitar tudo, calado. Use classes POSIX (`[[:space:]]`, `[^A-Za-z0-9_.]`).

As duas suítes têm um teste mecânico que falha se esses padrões reaparecerem no
código (comentários são descartados antes da verificação, então explicar o
problema em comentário é permitido).

Outras armadilhas já encontradas aqui:

- `grep -c` imprime `0` **e** sai com status 1. `n=$(grep -c ... || printf 0)`
  produz `"0\n0"`, que quebra a comparação numérica seguinte.
- Subshell come contador: `( cd "$d" && run ... )` perde `pass`/`fail`.

## Estilo

Documentação e comentários em português, sem acentuação nos scripts de shell.
Mensagens de commit em português, no formato `tipo(escopo): descrição`.
