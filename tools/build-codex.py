#!/usr/bin/env python3
"""Gera o plugin Codex a partir do plugin Claude.

    python3 tools/build-codex.py          # gera
    python3 tools/build-codex.py --check  # falha se o gerado estiver defasado

Existe uma fonte so: skills/ e hooks/ (Claude). A arvore do Codex em
plugins/blueprint/ e DERIVADA. Editar o gerado e perder a edicao no proximo
build — o cabecalho de cada arquivo gerado diz isso.

Diferencas que o gerador resolve:

  1. Nome das skills. O Codex nao tem namespace de invocacao como o
     /plugin:skill do Claude, entao o prefixo entra no proprio nome do
     diretorio: `backend` vira `blueprint-backend`. E a convencao do
     openai/skills (`gh-address-comments`).

  2. Frontmatter. O spec do Codex e explicito: "Do not include any other fields
     in YAML frontmatter" — so `name` e `description`. O `name` precisa bater
     com o diretorio.

  3. Referencias cruzadas. `/blueprint:backend` vira `blueprint-backend`.

  4. Manifesto. O Codex exige `version`, `description`, `author.name` e um bloco
     `interface` inteiro. O campo `hooks` fica de fora de proposito: no Codex um
     valor explicito no manifesto SUBSTITUI a descoberta por arquivo em vez de
     somar a ela, e hooks/hooks.json no lugar convencional ja e o que ele procura.

Os hooks NAO sao derivados: no Codex as ferramentas tem outros nomes, o payload
de edicao de arquivo tem outro formato, e o deny de PreToolUse nao e aplicado a
apply_patch. Eles sao escritos a mao em codex/hooks/ e apenas copiados aqui.
"""
import json, re, shutil, sys, hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_SKILLS = ROOT / "skills"
CODEX_HOOKS_SRC = ROOT / "codex" / "hooks"
OUT = ROOT / "plugins" / "blueprint"
MARKETPLACE = ROOT / ".agents" / "plugins" / "marketplace.json"
VERSION = "1.0.0"

BANNER = ("<!-- GERADO por tools/build-codex.py a partir de skills/{src}/SKILL.md.\n"
          "     Nao edite aqui: edite a fonte e rode `python3 tools/build-codex.py`. -->\n")


def codex_name(skill: str) -> str:
    """backend -> blueprint-backend; blueprint-domain fica como esta."""
    if skill == "blueprint" or skill.startswith("blueprint-"):
        return skill
    return f"blueprint-{skill}"


def translate(text: str, names: dict) -> str:
    """Traduz o vocabulario do Claude para o do Codex.

    Vale para SKILL.md e para os templates de docs/ — um template que manda
    rodar `/blueprint:increment` referencia um comando que nao existe no Codex,
    e um router chamado CLAUDE.md nao e lido pelo Codex, que le AGENTS.md.
    """
    # /blueprint:backend -> blueprint-backend (mais longos primeiro)
    for claude, codex in sorted(names.items(), key=lambda kv: -len(kv[0])):
        text = re.sub(rf'/blueprint:{re.escape(claude)}(?![\w-])', codex, text)

    text = text.replace("${CLAUDE_PLUGIN_ROOT}", "${PLUGIN_ROOT}")
    text = text.replace("Claude Code", "Codex")
    # O arquivo de instrucoes do agente: CLAUDE.md no Claude, AGENTS.md no Codex.
    text = text.replace("claudemd-template", "agentsmd-template")
    text = text.replace("CLAUDE.md", "AGENTS.md")
    return text


def convert(text: str, src_name: str, names: dict) -> str:
    """Traduz um SKILL.md do Claude para o Codex."""
    text = translate(text, names)

    # Frontmatter: so name e description, e name = diretorio
    m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
    if m:
        fm, body = m.group(1), text[m.end():]
        desc = ""
        dm = re.search(r'^description:\s*(.*)$', fm, re.M)
        if dm:
            desc = dm.group(1).strip()
        new_fm = f"---\nname: {names[src_name]}\ndescription: {desc}\n---\n"
        text = new_fm + BANNER.format(src=src_name) + body
    return text


def docs_dest(rel: Path) -> Path:
    """O template do router muda de nome junto com o arquivo que ele gera."""
    if rel.name == "claudemd-template.md":
        return rel.with_name("agentsmd-template.md")
    return rel


def build(check: bool):
    skills = sorted(p.name for p in SRC_SKILLS.iterdir() if (p / "SKILL.md").is_file())
    names = {s: codex_name(s) for s in skills}

    staged: dict[Path, str] = {}

    for s in skills:
        src = (SRC_SKILLS / s / "SKILL.md").read_text(encoding="utf-8")
        staged[OUT / "skills" / names[s] / "SKILL.md"] = convert(src, s, names)

    staged[OUT / ".codex-plugin" / "plugin.json"] = json.dumps({
        "name": "blueprint",
        "version": VERSION,
        "description": "Engenharia de software orientada a documentacao: transforma um PRD em blueprint tecnico rastreavel, prototipo mockado, especificacao de backend e frontend, backlog, scaffold tipado e loop de build com portoes.",
        "author": {"name": "Douglas Prado", "email": "douglas@oialbert.com.br"},
        "homepage": "https://github.com/DouglasPrado/blueprint",
        "repository": "https://github.com/DouglasPrado/blueprint",
        "license": "MIT",
        "keywords": ["documentation-driven", "architecture", "blueprint", "prd", "saas",
                     "prototype", "api-contract", "backend", "frontend", "adr", "c4",
                     "tdd", "codegen", "scaffold"],
        "skills": "./skills",
        "interface": {
            "displayName": "Blueprint",
            "shortDescription": "Do PRD ao codigo, com rastreabilidade e portoes de qualidade.",
            "longDescription": (
                "Blueprint transforma um PRD num sistema de engenharia explicito: blueprint "
                "tecnico de 17 documentos, prototipo mockado que descobre o contrato de API "
                "construindo a interface, especificacao de backend e frontend, backlog "
                "rastreavel, scaffold tipado e um loop de implementacao com portoes de teste "
                "e de aderencia. 25 skills e 58 documentos, com hooks que impedem "
                "documentacao preenchida de ser sobrescrita, teste de ser silenciado e "
                "segredo de entrar no historico."),
            "developerName": "Douglas Prado",
            "category": "development",
            "capabilities": ["skills", "hooks"],
            "defaultPrompt": [
                "Instale os templates do Blueprint neste projeto",
                "Gere o blueprint tecnico a partir do meu PRD",
                "Construa o prototipo mockado antes do backend",
            ],
        },
    }, indent=2, ensure_ascii=False) + "\n"

    staged[MARKETPLACE] = json.dumps({
        "name": "blueprint",
        "interface": {"displayName": "Blueprint"},
        "plugins": [{
            "name": "blueprint",
            "source": {"source": "local", "path": "./plugins/blueprint"},
            "policy": {"installation": "AVAILABLE", "authentication": "ON_USE"},
            "category": "development",
        }],
    }, indent=2, ensure_ascii=False) + "\n"

    # Hooks do Codex: escritos a mao, apenas copiados.
    if CODEX_HOOKS_SRC.is_dir():
        for f in sorted(CODEX_HOOKS_SRC.rglob("*")):
            rel = f.relative_to(CODEX_HOOKS_SRC)
            # A suite de testes e do repositorio, nao do plugin instalado.
            if not f.is_file() or rel.parts[0] == "test":
                continue
            staged[OUT / "hooks" / rel] = f.read_text(encoding="utf-8")

    # Biblioteca de templates: o plugin instalado precisa ser autocontido.
    # Os templates tambem passam pela traducao — eles citam skills e o router.
    for f in sorted((ROOT / "docs").rglob("*")):
        if f.is_file():
            rel = docs_dest(f.relative_to(ROOT / "docs"))
            staged[OUT / "docs" / rel] = translate(f.read_text(encoding="utf-8"), names)

    for extra in ("LICENSE",):
        staged[OUT / extra] = (ROOT / extra).read_text(encoding="utf-8")

    if check:
        stale = [p for p, c in staged.items()
                 if not p.is_file() or p.read_text(encoding="utf-8") != c]
        existing = {p for p in OUT.rglob("*") if p.is_file()} | ({MARKETPLACE} if MARKETPLACE.is_file() else set())
        orphan = sorted(existing - set(staged))
        if stale or orphan:
            print("A arvore do Codex esta defasada em relacao a fonte.\n")
            for p in sorted(stale)[:15]:
                print(f"  desatualizado: {p.relative_to(ROOT)}")
            for p in orphan[:15]:
                print(f"  orfao:         {p.relative_to(ROOT)}")
            print("\nRode: python3 tools/build-codex.py")
            return 1
        print(f"Codex em dia — {len(staged)} arquivos derivados de skills/ e docs/.")
        return 0

    if OUT.exists():
        shutil.rmtree(OUT)
    for p, content in staged.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8")
    for f in (OUT / "hooks").rglob("*.sh"):
        f.chmod(0o755)

    print(f"Plugin Codex gerado: {len(skills)} skills, {len(staged)} arquivos.")
    print(f"  {OUT.relative_to(ROOT)}")
    print(f"  {MARKETPLACE.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(build("--check" in sys.argv))
