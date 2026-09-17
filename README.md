<div align="center">

# Blueprint

**Documentation-driven software engineering for Claude Code and Codex.**

Turn a product requirements document into a traceable technical blueprint, backend and frontend specifications, implementation backlog, typed scaffold and guarded build loop.

**A plugin for Claude Code and Codex · 3 blueprints + optional prototype · 58 documents · 26 skills · quality hooks**

```bash
# Claude Code
/plugin marketplace add DouglasPrado/blueprint
/plugin install blueprint@blueprint
```

```bash
# Codex
codex plugin marketplace add DouglasPrado/blueprint
codex plugin install blueprint@blueprint
```

Then, from the root of your project: **`/blueprint:init`** on Claude Code, **`blueprint-init`** on Codex — it installs the template library the skills fill in. Without it the other commands have nothing to write into.

</div>

---

## What is Blueprint?

Blueprint is a software engineering framework built around **structured Markdown templates + agent skills**, packaged as a plugin for both Claude Code and Codex.

It turns a PRD into an explicit engineering system that describes:

- product and system context
- domain and data models
- architecture and ADRs
- critical flows and use cases
- backend contracts and services
- frontend architecture and design system
- security, testing, scalability and observability
- implementation tasks
- code-generation context
- architectural verification

The documentation is not treated as a one-time artifact.

Blueprint is designed so the same specification can be **incremented, patched, converted into backlog and used as the source of truth for implementation**.

```text
PRD
 │
 ▼
Technical Blueprint
 │
 ├──────────────► Prototype (optional)
 │                 mocked frontend, built first
 │                      │
 │                      ▼
 │                 Discovered API contract
 │                      │
 ├──────────────► Backend Blueprint ◄──┘
 │
 ├──────────────► Frontend Blueprint
 │
 └──────────────► Shared Contracts
                      │
                      ▼
                 Implementation Specs
                      │
                      ▼
                 Typed Scaffold
                      │
                      ▼
                  Build Loop
                      │
                      ▼
               Architecture Verify
```

---

## Why Blueprint?

AI can generate code quickly.

The difficult part is keeping the generated system coherent when the project grows.

Without an explicit engineering model, AI-assisted development tends to accumulate:

- duplicated assumptions
- inconsistent domain language
- architecture drift
- endpoints that do not match frontend needs
- undocumented security decisions
- tests that validate implementation but not intent
- context windows filled with irrelevant documentation
- changes applied in one layer but forgotten in another

Blueprint moves the source of truth **before the code**.

Instead of repeatedly explaining the architecture to an agent, the framework creates a structured specification that future agents can query and follow.

> **The blueprint describes the system. The code implements the blueprint.**

---

## Core ideas

### Documentation as system state

Blueprint documentation is meant to evolve with the application.

It is not a frozen design document.

Changes can be applied incrementally and propagated across related specifications.

### Traceability

Requirements, domain concepts, backend contracts, frontend dependencies and implementation tasks are connected through explicit mappings.

### Bounded context for agents

Agents do not load the complete documentation set into every session.

Skills read only the documents required for the current task.

### Auditable assumptions

Autonomous generation does not silently turn missing information into facts.

Inferred values are marked and consolidated by risk.

### Independent verification

A green test suite proves internal consistency.

It does not prove that the implementation still matches the intended architecture.

Blueprint adds a separate code-vs-specification verification step.

---

# The system

Blueprint is composed of three primary specification layers plus shared cross-layer documents.

| Layer | Focus | Output |
| --- | --- | ---: |
| **Technical Blueprint** | Context, domain, architecture, quality attributes and delivery plan | 17 docs |
| **Prototype** *(optional)* | Screens, mock data, **discovered API contract**, interaction states, findings | 6 docs + running app |
| **Backend Blueprint** | Domain implementation, data, APIs, services, events and integrations | 15 docs |
| **Frontend Blueprint** | Design system, architecture, state, flows, quality and platform concerns | 3 shared + 13 per client |
| **Shared** | Cross-layer mappings and terminology | 4 docs |

With one frontend client, the standard flow produces **52 documents**; with the prototype phase, **58**.

> Those are the templates the repository ships. What `/blueprint:pipeline` actually *fills* is 48 (54 with the prototype): no skill generates the four cross-layer documents under `docs/shared/`, so the glossary and the two mapping files stay as templates until someone fills them by hand.

---

# Workflow

Blueprint supports two main ways of working.

## Autonomous workflow

For a detailed PRD and a fast first pass:

```text
/blueprint:pipeline docs/prd.md web ../my-app/
/blueprint:build
```

To discover the API contract by building the interface first:

```text
/blueprint:pipeline docs/prd.md web ../my-app/ --prototype
/blueprint:build
```

`/blueprint:pipeline` generates the documentation and typed scaffold.

`/blueprint:build` implements the planned features using guarded TDD loops.

```text
PRD
 │
 ▼
/blueprint:pipeline
 │
 ├── Technical Blueprint
 ├── Backend Blueprint
 ├── Frontend Blueprint
 ├── Shared mappings
 ├── Assumption report
 └── Typed scaffold
       │
       ▼
     /blueprint:build
       │
       ├── Feature
       ├── Tests
       ├── Architecture verification
       └── Commit
```

This mode favors automation.

It does **not** stop to ask the questions that individual skills normally ask.

Missing PRD information becomes explicit assumptions instead.

---

## Guided workflow

For critical systems or shallow PRDs, run the framework phase by phase.

```text
/blueprint:blueprint
/blueprint:blueprint-foundation
/blueprint:blueprint-domain
/blueprint:blueprint-architecture
/blueprint:blueprint-flows
/blueprint:blueprint-quality
/blueprint:blueprint-plan

/blueprint:backend

/blueprint:frontend
/blueprint:frontend-design-system
/blueprint:frontend-app web
/blueprint:frontend-quality web
```

With the prototype phase, the design system moves up and the backend moves down —
the interface is built first, and the contract comes out of it:

```text
/blueprint:blueprint  →  the six blueprint phases

/blueprint:frontend-design-system          tokens first — the prototype needs them

/blueprint:prototype web                   plan: screens, navigation, mock data
/blueprint:prototype-build web ../my-app/  code: the mocked app
/blueprint:prototype-api web ../my-app/    the discovered contract

/blueprint:backend                         now with a real consumer for every endpoint

/blueprint:frontend  →  /blueprint:frontend-app web  →  /blueprint:frontend-quality web
```

Individual skills can ask up to three grouped questions before generating their documents.

This mode gives the engineer more control over decisions before they become dependencies for later phases.

---

# Autonomous pipeline

`/blueprint:pipeline` runs the documentation phases in isolated subagents.

Each phase:

1. starts with a clean context
2. reads only its required inputs
3. writes its own documents
4. returns a compact summary to the orchestrator

The orchestrator keeps the summaries instead of loading all generated documents into its own context.

Conceptually:

```text
Orchestrator
    │
    ├──► Agent 01 → Foundation docs → summary
    │
    ├──► Agent 02 → Domain docs     → summary
    │
    ├──► Agent 03 → Architecture    → summary
    │
    ├──► ...
    │
    ├──► Agent 11 → Frontend quality
    │
    ├──► Agent 12 → Cross-layer connectors
    │
    └──► Agent 13 → Typed scaffold + objective gate
```

This is what allows the pipeline to produce a large specification without trying to fit the entire project model into one context window.

The final scaffold phase has an objective gate:

```text
typecheck
   +
lint
   +
schema validation
```

If the scaffold still fails after correction, the pipeline reports failure instead of declaring the phase successful.

---

## Resumable execution

The pipeline is designed to be rerunnable.

If a session ends halfway through, running `/blueprint:pipeline` again detects documents that already contain real generated content and skips completed phases.

---

# Assumptions are explicit

Autonomous generation always has a trade-off:

> If the PRD does not answer a question, the agent either has to stop or infer.

The pipeline chooses inference, but makes it visible.

An assumption is marked in the generated document:

```html
<!-- assumed: PostgreSQL — basis: relational data requirements -->
```

It is also consolidated into:

```text
docs/ASSUMPTIONS.md
```

Assumptions are classified by risk:

| Risk | Meaning | Example |
| --- | --- | --- |
| **High** | Numeric target, SLA or proper noun without PRD evidence | `p95 < 300ms` when latency was never specified |
| **Medium** | Plausible technical choice that was not explicitly requested | PostgreSQL inferred from relational requirements |
| **Low** | Direct logical derivation | `Order` entity derived from order requirements |

High-risk assumptions are surfaced in the final report.

Review `docs/ASSUMPTIONS.md` before treating an autonomous run as authoritative.

---

# 1. Technical Blueprint

The technical blueprint is the primary architectural source.

It contains 17 documents generated by seven skills.

| Skill | Documents | Focus |
| --- | --- | --- |
| `/blueprint:blueprint` | orchestration | PRD, coverage analysis, roadmap |
| `/blueprint:blueprint-foundation` | `00`, `01`, `02`, `03` | context, vision, principles, requirements |
| `/blueprint:blueprint-domain` | `04`, `05`, `09` | domain, data and state models |
| `/blueprint:blueprint-architecture` | `06`, `10` | system architecture and ADRs |
| `/blueprint:blueprint-flows` | `07`, `08` | critical flows and use cases |
| `/blueprint:blueprint-quality` | `12`, `13`, `14`, `15` | testing, security, scalability, observability |
| `/blueprint:blueprint-plan` | `11`, `16` | build plan and evolution |

The grouping follows dependency relationships.

For example, the data and state models derive from the domain model, while quality attributes consume architecture and critical flows rather than being generated in isolation.

---

# 2. Prototype — discovering the contract instead of inventing it

The prototype is an **optional phase that runs before the backend**. It produces a complete, navigable frontend backed entirely by mocked data.

Its purpose is narrow and specific:

> An API contract written before the interface is a prediction. A contract extracted from an interface that works is an observation.

| Without prototype | With prototype |
| --- | --- |
| The backend exposes what the domain model suggests | The backend exposes what the screen needs |
| Fields that are never consumed, and fields discovered missing at the end | Every field has a named consumer |
| Calls per screen discovered in production | Calls per screen known before the first line of backend |
| Error states invented | Error states derived from what the UI must display |
| Domain gaps surface during implementation | Domain gaps surface while wiring up a form |

Three skills, three distinct responsibilities:

| Skill | Produces | Reads |
| --- | --- | --- |
| `/blueprint:prototype` | `00-vision`, `01-screens`, `02-mock-data` | Technical blueprint + design system |
| `/blueprint:prototype-build` | **Code** — the mocked app | The plan above |
| `/blueprint:prototype-api` | `03-api-requirements`, `04-interaction-states`, `05-findings` | **The code**, not the plan |

The separation matters. `/blueprint:prototype-api` reads the source of the prototype — mock handlers, application calls, components that render fields — and cross-references three independent inventories:

```text
handler exists, nobody calls it   → endpoint without consumer, excluded from the contract
call exists, no handler           → broken call, a bug to fix before continuing
field returned, never rendered    → unnecessary payload, removal proposed
field rendered, never returned    → domain gap, high risk
```

Two rules give the phase its discipline:

- **Nothing enters the contract without a named consumer.** An endpoint with no screen calling it, or a field with no render site, is an idea — and ideas go to `05-findings.md`.
- **The mock answers, it does not decide.** Any business rule belongs to the backend. When a mock handler needs to compute in order to reply, that is a rule nobody had written down — and it gets recorded.

## The gate before the backend

No **high-risk** finding may remain open when `/blueprint:backend` runs. A contract built on a known gap propagates that gap into the schema, and a schema with data in it is not fixed with `/blueprint:increment`.

The gate holds in interactive mode, where someone can resolve the finding. `/blueprint:pipeline --prototype` disarms it explicitly: in an unattended run nobody resolves findings between phases, and a high-risk finding is the *expected product* of the phase, not an anomaly. Instead of stopping, the backend documents are generated with `<!-- construido sobre lacuna conhecida -->` at each affected point, and the final report says out loud how many were born that way.

## Cost

The prototype builds the UI twice — once mocked, once integrated. For a familiar CRUD with a detailed PRD, that likely does not pay for itself. For a new domain, long flows, or a SaaS with many screens, it usually does: the rework happens in disposable code rather than in a production schema.

What survives the phase: the design system implementation, the typed entities (which become `src/contracts/`), the fixtures (which become seeds and test fixtures), and the screens as a layout skeleton.

---

# 3. Backend Blueprint

`/blueprint:backend` reads the technical blueprint and produces 15 implementation-oriented documents.

```text
00-backend-vision
01-architecture
02-project-structure
03-domain
04-data-layer
05-api-contracts
06-services
07-controllers
08-middlewares
09-errors
10-validation
11-permissions
12-events
13-integrations
14-tests
```

The backend blueprint covers:

- architecture and dependency direction
- entities, value objects and aggregates
- repositories, migrations and queries
- endpoints and DTOs
- application services and use cases
- controllers and routing
- authentication and middleware
- validation and error contracts
- permissions and policies
- domain events, workers and queues
- external integrations
- test strategy

The technical blueprint remains the primary source.

The backend layer should specify implementation details without redefining the product model.

---

# 4. Frontend Blueprint

The frontend layer supports multiple application clients inside the same project.

Supported client categories include:

```text
web
mobile
desktop
```

Shared documents are generated once:

```text
docs/frontend/shared/
├── 03-design-system.md
├── 06-data-layer.md
└── 15-api-dependencies.md
```

Each client receives its own specification:

```text
docs/frontend/{client}/
├── 00-frontend-vision.md
├── 01-architecture.md
├── 02-project-structure.md
├── 04-components.md
├── 05-state.md
├── 07-routes.md
├── 08-flows.md
├── 09-tests.md
├── 10-performance.md
├── 11-security.md
├── 12-observability.md
├── 13-cicd-conventions.md
└── 14-copies.md
```

The skills adapt platform concerns to the selected client.

Examples include:

- web: CSP, browser architecture and Core Web Vitals
- mobile: secure storage and cold-start concerns
- desktop: IPC, signing and desktop security boundaries

---

# 5. Shared documentation

Cross-layer documents live under `docs/shared/`.

| Document | Purpose |
| --- | --- |
| `MAPPING.md` | Traceability between technical, backend and frontend blueprints |
| `glossary.md` | Unified project terminology |
| `error-ux-mapping.md` | Backend errors mapped to frontend behavior |
| `event-mapping.md` | Events that cross application layers |

These documents exist to prevent each blueprint from becoming an independent interpretation of the same product.

`MAPPING.md` describes the framework itself and ships complete. The other three are generated by `/blueprint:shared`, which runs after backend **and** frontend — they are projections of both layers, and crossing the two is the point. An event the backend emits that no frontend slice consumes, an error with no UX, a term that changes name between layers: none of those are visible inside a single blueprint, and all three surface here.

It runs before `codegen-setup` because the scaffold freezes names. A term corrected after `src/contracts/` exists was already born wrong in the types.

---

# Incremental evolution

Generating good documentation once is not enough.

Real systems change.

Blueprint provides separate operations for **local evolution** and **cross-system change**.

---

## `/blueprint:increment`

Use `/blueprint:increment` to add, correct, update or remove something without regenerating an entire blueprint.

Example:

```text
/blueprint:increment
target: all
"Add real-time chat"
```

A feature can affect multiple documents:

```text
Domain
  ├── entities
  └── events

Backend
  ├── services
  ├── API
  └── workers

Frontend
  ├── components
  ├── state
  └── routes
```

Templates include stable insertion markers:

```html
<!-- APPEND:primitives -->
```

New content is inserted around these anchors rather than replacing the whole document.

---

## `/blueprint:patch`

Use `/blueprint:patch` for a global change that needs impact analysis and propagation.

Examples:

```text
Booking → Appointment
/api/users → /api/v2/users
Zustand → Jotai
Next.js 16 → Next.js 17
```

The patch workflow:

```text
Global search
     │
     ▼
Impact analysis
     │
     ▼
Affected-file preview
     │
     ▼
Confirmation
     │
     ▼
Case-aware changes
     │
     ▼
Review markers for indirect impact
```

Direct replacements preserve forms such as:

- PascalCase
- camelCase
- kebab-case
- paths

Indirect effects that require human review are marked with:

```html
<!-- PATCH-REVIEW -->
```

`/blueprint:increment` evolves a feature.

`/blueprint:patch` propagates a systemic change.

---

# Implementation backlog

`/blueprint:specs` converts the specification into a full implementation backlog:

```text
docs/specs/TASKS.md
```

Tasks are derived primarily from the backend blueprint and validated against frontend and technical documentation.

The backlog is grouped into:

1. Setup & Infrastructure
2. Domain
3. Data Layer
4. Services
5. API & Controllers
6. Authentication & Permissions
7. Error Handling
8. Middlewares
9. Events & Workers
10. Integrations
11. Tests
12. Frontend Sync

Each task can include:

- source document
- layer
- entity
- priority
- dependencies
- files to create
- business rules
- acceptance criteria
- required tests

A final coverage pass checks questions such as:

```text
Does every functional requirement have implementation work?
Does every critical flow have a service and E2E coverage?
Does every use case map to endpoint + controller + service?
Does every documented threat have a mitigation?
```

---

# Code generation

Blueprint can move from specification to implementation through a set of code-generation skills.

```text
/blueprint:codegen-setup
      │
      ▼
Contracts + schema + scaffold + agent router
      │
      ▼
/blueprint:codegen
      │
      ▼
/blueprint:codegen-feature
      │
      ▼
RED → GREEN → REFACTOR
      │
      ▼
/blueprint:codegen-verify
```

`/blueprint:codegen-feature` implements vertical features using TDD.

`/blueprint:codegen-verify` independently evaluates whether the code still follows the blueprint.

---

# `/blueprint:build` — guarded implementation loop

`/blueprint:build` automates the feature loop.

```text
/blueprint:build
/blueprint:build ENT-001 ENT-002
/blueprint:build --max 5
```

Each feature runs in its own subagent and passes through two gates.

| Gate | Frequency | Failure condition |
| --- | --- | --- |
| **Full test suite** | every feature | any red test or reduced test count |
| **Blueprint verification** | every 3 features | adherence score below 90% |

A failing test run receives one retry with the real failure output.

If the suite remains red, the build loop stops.

Each feature receives its own commit so changes remain granular and revertible.

---

## Why the loop stops on failure

The documentation pipeline can skip a failed documentation phase because an incomplete document does not necessarily corrupt later generated text.

Implementation is different.

A bad early abstraction can become a dependency for every later feature.

```text
Wrong Feature 1
      │
      ▼
Wrong abstraction
      │
      ├──► Feature 4
      ├──► Feature 8
      └──► Feature 15
```

Stopping early is cheaper than allowing a coherent but architecturally incorrect codebase to emerge.

---

## Tests cannot be weakened to pass the gate

The build loop explicitly protects against making the suite green by deleting or bypassing tests.

The gate treats reductions in test count as a failure signal.

Patterns such as weakening, skipping or removing tests to make implementation pass are outside the intended workflow.

---

# Architecture verification

Tests written by the same agent that wrote the implementation are not an independent architecture check.

A green suite means:

> the implementation satisfies its tests.

It does not necessarily mean:

> the implementation satisfies the blueprint.

`/blueprint:codegen-verify` compares implementation against the specification and produces an adherence score.

That verification is intentionally separate from feature generation.

---

# Context strategy

A filled project blueprint can grow far beyond what should be loaded into a single model context.

Blueprint uses four mechanisms to keep implementation context bounded.

### 1. The agent router

A `CLAUDE.md` on Claude Code, an `AGENTS.md` on Codex — the file each agent reads on its own when it opens the project. It maps task types to the small set of documents most likely to be relevant.

```text
Task type
   │
   ▼
2–3 relevant documents
```

### 2. Context excerpting

Skills load relevant sections instead of entire large documents when possible.

### 3. Contracts as cache

`src/contracts/` acts as a compiled representation of important domain contracts.

### 4. Context budget

Implementation sessions target a bounded documentation context so enough room remains for reasoning and code generation.

The goal is not to make every agent know everything.

The goal is to make each agent read the **right things**.

---

# Quick start

## Prerequisites

You need:

1. **Claude Code** or **Codex**
2. a product requirements document
3. **Context7 MCP** for up-to-date technology documentation

Example Context7 configuration:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstreamapi/context7-mcp@latest"]
    }
  }
}
```

## Install

The repository is both the plugin and the marketplace that serves it, for both agents.

### Claude Code

```bash
# 1. add the marketplace
/plugin marketplace add DouglasPrado/blueprint

# 2. install the plugin
/plugin install blueprint@blueprint
```

### Codex

Same two steps, from a session or from the terminal:

```bash
# 1. add the marketplace
codex plugin marketplace add DouglasPrado/blueprint

# 2. install the plugin
codex plugin install blueprint@blueprint
```

`codex plugin marketplace list` and `codex plugin list` confirm both landed.

**The hooks do not run until you trust them.** Plugin-bundled hooks are non-managed hooks in Codex, so they stay inert until you review the definition and accept it. That is the right default — a hook runs as you. The four scripts are short and live in `plugins/blueprint/hooks/`.

Then, **from the root of your own project**:

```text
/blueprint:init        # Claude Code
blueprint-init         # Codex
```

`init` copies the template library into your project's `docs/`. That matters: the filled documents belong in **your** repository — your history, your code review. The plugin only supplies the initial shape.

It never overwrites a file that already exists, so it is safe to re-run after a plugin update: it installs only what is missing.

Place your PRD at `docs/prd.md` — `init` seeds it from the template if it is not there. The PRD is the one document the plugin cannot generate, because it carries business knowledge only you have.

Then choose an execution mode.

### Command namespace

On Claude Code, plugin skills are namespaced and every command in this documentation is invoked as `/blueprint:<skill>`:

```text
/blueprint:init          /blueprint:blueprint       /blueprint:backend
/blueprint:prototype     /blueprint:pipeline        /blueprint:build
```

Codex has no invocation namespace, so the prefix moves into the skill name itself — the same convention `openai/skills` uses. Drop the `/` and the `:` becomes a `-`:

```text
blueprint-init           blueprint-blueprint        blueprint-backend
blueprint-prototype      blueprint-pipeline         blueprint-build
```

The rest of this document uses the Claude Code form. The mapping is mechanical, and the skills you actually read inside Codex are already written in the Codex form — they are generated, not translated at read time.

### Developing on the plugin itself

```bash
git clone https://github.com/DouglasPrado/blueprint.git
claude --plugin-dir ./blueprint            # Claude Code: straight from disk, no install
codex plugin marketplace add ./blueprint   # Codex: local marketplace
```

Inside a Claude Code session, `/reload-plugins` picks up edits without restarting, and `claude plugin validate ./blueprint` checks the manifest and structure.

**One source, two plugins.** `skills/`, `docs/` and `hooks/` are the source. `plugins/blueprint/` and `.agents/plugins/marketplace.json` are **generated** by `tools/build-codex.py` and must not be edited — every generated file carries a header saying so. After changing a skill or a template:

```bash
python3 tools/build-codex.py          # regenerate
python3 tools/build-codex.py --check  # CI: fails if the generated tree drifted
```

The Codex hooks are the one thing that is *not* generated: the two agents disagree on tool names, on the shape of a file-edit payload, and on whether a `PreToolUse` deny is enforced. They are written by hand in `codex/hooks/`. `AGENTS.md` documents the differences.

### Fast autonomous pass

```text
/blueprint:pipeline docs/prd.md web ../my-app/
```

After reviewing the generated documentation and `docs/ASSUMPTIONS.md`:

```text
/blueprint:build
```

### Guided pass

Start with:

```text
/blueprint:blueprint
```

Then run the technical, backend and frontend phases in order.

---

# Quality hooks

The plugin ships five hooks on Claude Code and four on Codex. They exist because three of the framework's rules are stated in every skill and are exactly the ones an agent breaks under pressure: *Write only over a template*, *never weaken a test to go green*, *never leave a placeholder behind*.

A rule repeated in prose is a suggestion. A rule enforced at the tool call is a rule.

| Hook | Event | What it does |
| --- | --- | --- |
| `docs-integrity` | `PreToolUse(Write\|Edit)` | **Blocks** `Write` over a document that already holds real content, and **blocks** an `Edit` that would delete an `<!-- APPEND:... -->` marker |
| `tests-integrity` | `PreToolUse(Write\|Edit)` | **Blocks** a newly introduced `.skip` / `.only` / `xit` / `xdescribe` / `@pytest.mark.skip` / `t.Skip` in a test file, and **blocks** lowering a coverage threshold |
| `no-secrets` | `PreToolUse(Bash)` | Before `git commit` or `git push`, scans the **staged** diff for credentials and **blocks** on a hit |
| `docs-complete` | `PostToolUse(Write)` | Warns when a generated document still contains `{{placeholders}}` — cannot block, the write already happened |
| `status` | `SessionStart` | Reports where the project stands: which suites are filled, open high-risk findings and assumptions, documents built over a known gap, and the next command |

## On Codex, enforcement moves to `Stop`

The Codex hooks are not a port of the table above, because the enforcement point is different.

Codex edits files through `apply_patch`, and a `PreToolUse` deny **is not enforced for `apply_patch`** ([openai/codex#27833](https://github.com/openai/codex/issues/27833), open). `code_mode_exec` does not fire `PreToolUse` at all ([#23411](https://github.com/openai/codex/issues/23411)). A gate that only warns is not a gate.

So the rule is restated: instead of *you may not make this edit*, it becomes **you may not end the turn with the tree in this state**.

| Hook | Event | What it does |
| --- | --- | --- |
| `stop-gate` | `Stop` | **The gate.** Reads the working tree with `git`, and returns `decision: block` with the reason if a Blueprint document lost an `<!-- APPEND:... -->` marker or a test file gained a skip. Codex turns the reason into a new prompt and the agent keeps working |
| `apply-patch-guard` | `PreToolUse(apply_patch)` | Parses the patch text and says the same thing **early** — advisory, because the deny is not enforced. Undoing before the write is cheaper than after |
| `no-secrets` | `PreToolUse(Bash)` | Same as on Claude Code: scans the staged diff before `git commit` / `git push` |
| `status` | `SessionStart` | Same as on Claude Code |

Checking the *result* rather than the *call* is more robust in a second way: it catches the violation no matter which tool produced it — `apply_patch`, a shell heredoc, or `code_mode_exec`.

Two details that matter if you modify them. `Stop` decides by the **JSON on stdout**, not by the exit code, and invalid stdout becomes a hook error on *every* turn — so every path through `stop-gate.sh` prints valid JSON, error paths included. And it gives up after three consecutive blocks in the same turn: an unrepairable violation must not trap the agent in a loop.

## The design rule behind them

**A hook that produces false positives is a hook the user disables — along with every other hook in the plugin.** So each one blocks only what is unambiguously destructive, and every ambiguity resolves to *allow*:

- `tests-integrity` compares *before* and *after*: it only objects when a skip is **added**. Editing a file that already had one is fine.
- `no-secrets` ignores `process.env.X`, `{{placeholder}}`, `your-key-here` and every other shape that reads as an example.
- `docs-integrity` only speaks about `docs/` — your application code is not its business.
- Empty payload, malformed JSON, missing `jq` and missing `python3` all resolve to exit 0. A broken hook must never break a session.

Two of them enforce asymmetric costs, which is why they block rather than warn. A document overwritten by `Write` does not come back. A secret that reaches the history stays in the history, in every fork and every clone already taken — a later commit does not remove it, and rewriting published history is expensive and sometimes impossible. In both cases the only cheap moment is before.

## Testing them

```bash
bash hooks/test/run.sh          # 70 cases — Claude Code hooks
bash codex/hooks/test/run.sh    # 49 cases — Codex hooks, plus the generated tree's structure
```

Each suite covers what its hooks must block, what they must let through, and graceful degradation. Run them after changing a pattern: a malformed hook fails **silently** — it does not block, does not warn, and the plugin looks installed while doing nothing.

Both suites also assert mechanically that no pattern uses `\b`, `\s` or lookahead. Those are GNU extensions; under the BSD `grep` on macOS they do not error, they simply **stop matching** — and the hook quietly starts allowing everything.

## Turning one off

Hooks run as you, not sandboxed. Read them before installing any plugin, this one included — they are five short shell scripts under `hooks/`.

To disable one, remove its entry from `hooks/hooks.json` in your installed copy, or disable the plugin's hooks wholesale in your settings. On Codex they are inert until you explicitly trust them, so doing nothing is already the off switch.

---

# Command reference

## Automation

| Command | Purpose |
| --- | --- |
| `/blueprint:pipeline` | Generate the complete documentation set and scaffold through isolated phases (`--prototype` inserts the prototype phase and moves the backend after it) |
| `/blueprint:build` | Implement planned features in a guarded TDD loop |

## Technical Blueprint

| Command | Purpose |
| --- | --- |
| `/blueprint:blueprint` | PRD intake, coverage analysis and roadmap |
| `/blueprint:blueprint-foundation` | Context, vision, principles and requirements |
| `/blueprint:blueprint-domain` | Domain, data and state models |
| `/blueprint:blueprint-architecture` | System architecture and ADRs |
| `/blueprint:blueprint-flows` | Critical flows and use cases |
| `/blueprint:blueprint-quality` | Testing, security, scalability and observability |
| `/blueprint:blueprint-plan` | Build plan and evolution |

## Setup

| Command | Purpose |
| --- | --- |
| `/blueprint:init [suites]` | Install the template library into your project's `docs/` |

## Prototype

| Command | Purpose |
| --- | --- |
| `/blueprint:prototype {client}` | Plan the mocked frontend — screens, navigation, mock data |
| `/blueprint:prototype-build {client} {target}` | Build the mocked app, screen by screen, with a coverage gate |
| `/blueprint:prototype-api {client} {target}` | Extract the required API contract **from the code** |

## Backend

| Command | Purpose |
| --- | --- |
| `/blueprint:backend` | Generate the 15 backend specification documents |

## Frontend

| Command | Purpose |
| --- | --- |
| `/blueprint:frontend` | Frontend orchestration and shared data/API documents |
| `/blueprint:frontend-design-system` | Design tokens, typography, colors and iconography |
| `/blueprint:frontend-app {client}` | Client architecture, structure, state, routes and flows |
| `/blueprint:frontend-quality {client}` | Client testing, performance, security, observability and CI/CD |

## Cross-layer connectors

| Command | Purpose |
| --- | --- |
| `/blueprint:shared` | Glossary, event mapping and error-to-UX mapping, derived from backend + frontend |

## Evolution and backlog

| Command | Purpose |
| --- | --- |
| `/blueprint:increment` | Add, correct, update or remove scoped specification content |
| `/blueprint:patch` | Propagate a global change through the documentation graph |
| `/blueprint:specs` | Generate the implementation backlog |

## Code generation

| Command | Purpose |
| --- | --- |
| `/blueprint:codegen-setup` | Generate routing context, contracts, schema and scaffold |
| `/blueprint:codegen` | Present build-plan deliveries for implementation |
| `/blueprint:codegen-feature` | Implement one vertical feature with TDD |
| `/blueprint:codegen-verify` | Measure implementation adherence to the blueprint |

---

# Output structure

A generated project follows this documentation model:

```text
docs/
├── prd.md
│
├── blueprint/                 # 17 technical documents
│
├── prototype/                 # 6 documents (optional phase, runs before backend)
│
├── backend/                   # 15 backend documents
│
├── frontend/
│   ├── shared/                # shared frontend contracts
│   ├── web/                   # optional client
│   ├── mobile/                # optional client
│   └── desktop/               # optional client
│
├── shared/                    # cross-layer mappings
│
├── ASSUMPTIONS.md             # autonomous inference report
│
├── specs/
│   └── TASKS.md               # implementation backlog
│
├── diagrams/
├── templates/
└── adr/
```

The Blueprint repository itself currently contains:

```text
blueprint/
├── .claude-plugin/
│   ├── plugin.json            # plugin manifest
│   └── marketplace.json       # the repo serves itself as a marketplace
├── skills/                    # 26 skills — the source for both plugins
├── hooks/
│   ├── hooks.json             # quality gates (see below)
│   └── test/run.sh            # 70 cases
├── codex/hooks/               # Codex hooks, hand-written (see AGENTS.md)
├── tools/build-codex.py       # skills/ + docs/ -> the Codex plugin
├── plugins/blueprint/         # GENERATED — the Codex plugin, do not edit
├── .agents/plugins/           # GENERATED — Codex marketplace manifest
├── AGENTS.md                  # how to work on this repository
├── LICENSE                    # MIT
├── docs/
│   ├── adr/
│   ├── backend/
│   ├── blueprint/
│   ├── diagrams/
│   ├── frontend/
│   ├── prototype/
│   ├── shared/
│   └── templates/
└── README.md
```

---

# Skill contract

All Blueprint skills follow a common set of conventions.

### Write vs edit

A template containing only placeholders can be written as a new generated document.

A document containing real project content should be edited rather than blindly replaced.

### Traceability

Derived content can include source markers that identify which blueprint document produced it.

### Current technology information

Technology-specific guidance is queried through Context7 instead of assuming stale versions from model training.

### Numbers are evidence-sensitive

Skills should not invent:

- SLAs
- performance targets
- business metrics
- proper nouns
- numeric constraints

These values should come from the PRD, a source, a direct answer or be explicitly marked as assumptions in autonomous mode.

### Questions are bounded

Interactive skills group uncertainty into a maximum of three questions per skill rather than repeatedly interrupting generation.

---

# When to use Blueprint

Blueprint works best when:

- you already have a PRD
- several layers need to remain aligned
- AI agents will participate in implementation
- architecture decisions need to be explicit
- the project is large enough that repeated prompting becomes expensive
- backend and frontend contracts must remain traceable
- you want generated code to have an external specification to verify against

---

# When not to use it

Blueprint is intentionally heavyweight for very small work.

It may be unnecessary when:

- the project is a tiny experiment
- the architecture is disposable
- there is no meaningful product specification
- you are exploring a problem before defining requirements
- a single short-lived agent session is sufficient

The autonomous pipeline is also a poor fit for a **critical system with a shallow PRD**.

In that case, use the guided skills and resolve uncertainty before implementation.

---

# Trade-offs and limitations

### Output quality depends on input quality

A weak PRD creates more assumptions.

The framework can structure uncertainty, but it cannot recover business knowledge that was never provided.

### Automation costs context and tokens

Using isolated subagents is more expensive than asking one agent to do everything in one session.

The trade-off is better context isolation and less risk of overflowing a single context window.

### The pipeline produces a complete draft, not unquestionable truth

Generated documentation still requires engineering review.

### Scaffold decisions inherit assumptions

If an autonomous documentation phase infers a technology or architectural choice, the generated scaffold can inherit that choice.

Review high-risk assumptions before building on top of them.

### Tests are not architecture verification

A green suite is necessary but not sufficient.

Blueprint intentionally keeps specification adherence as a separate gate.

---

# Design principles

## Specification before implementation

Important system decisions should exist somewhere inspectable before becoming implicit in code.

## One primary source per decision

Backend and frontend documents derive from the technical blueprint instead of independently redefining product behavior.

## Context should be intentional

More context is not automatically better context.

Agents should receive the smallest coherent slice needed for a task.

## Changes should propagate

A renamed domain concept should not remain stale in another layer because the engineer forgot where it was referenced.

## Assumptions should be visible

Autonomy is useful only when uncertainty can still be audited.

## Verification should be independent

The agent producing a feature should not be the only mechanism deciding whether the feature respects the architecture.

---

# Repository status

Blueprint is under active development.

The current repository contains:

- distributed as an installable plugin for Claude Code and Codex, MIT licensed
- 3 blueprint layers plus an optional prototype phase
- 52 standard documents for a single-client flow, 58 with the prototype
- 26 skills, generated into both plugins from one source
- contract discovery through a mocked frontend built before the backend
- autonomous documentation pipeline
- resumable phases
- assumption tracking
- incremental updates
- global patch propagation
- implementation backlog generation
- typed scaffold generation
- guarded feature build loop
- architecture adherence verification

The framework, templates and skill contracts may evolve as the workflow is used on more projects.

---

# Philosophy

AI makes producing code cheaper.

That makes **clarity, traceability and architectural consistency** more important, not less.

A large model can generate thousands of lines quickly, but speed does not solve the harder questions:

- What is the system supposed to do?
- Which layer owns each rule?
- Which decisions are facts and which are assumptions?
- What depends on this change?
- Does the implementation still match the design?
- What context does the next agent actually need?

Blueprint exists to make those answers explicit.

> **Don't ask the agent to remember the architecture. Give it an architecture it can read.**
