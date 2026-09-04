<div align="center">

# Blueprint

**Documentation-driven software engineering for Claude Code.**

Turn a product requirements document into a traceable technical blueprint, backend and frontend specifications, implementation backlog, typed scaffold and guarded build loop.

**3 blueprints · 52 documents · 21 Claude Code skills**

</div>

---

## What is Blueprint?

Blueprint is a software engineering framework built around **structured Markdown templates + Claude Code skills**.

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
 ├──────────────► Backend Blueprint
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
| **Backend Blueprint** | Domain implementation, data, APIs, services, events and integrations | 15 docs |
| **Frontend Blueprint** | Design system, architecture, state, flows, quality and platform concerns | 3 shared + 13 per client |
| **Shared** | Cross-layer mappings and terminology | 4 docs |

With one frontend client, the standard flow produces **52 documents**.

---

# Workflow

Blueprint supports two main ways of working.

## Autonomous workflow

For a detailed PRD and a fast first pass:

```text
/pipeline docs/prd.md web ../my-app/
/build
```

`/pipeline` generates the documentation and typed scaffold.

`/build` implements the planned features using guarded TDD loops.

```text
PRD
 │
 ▼
/pipeline
 │
 ├── Technical Blueprint
 ├── Backend Blueprint
 ├── Frontend Blueprint
 ├── Shared mappings
 ├── Assumption report
 └── Typed scaffold
       │
       ▼
     /build
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
/blueprint
/blueprint-foundation
/blueprint-domain
/blueprint-architecture
/blueprint-flows
/blueprint-quality
/blueprint-plan

/backend

/frontend
/frontend-design-system
/frontend-app web
/frontend-quality web
```

Individual skills can ask up to three grouped questions before generating their documents.

This mode gives the engineer more control over decisions before they become dependencies for later phases.

---

# Autonomous pipeline

`/pipeline` runs the documentation phases in isolated subagents.

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
    └──► Agent 12 → Typed scaffold + objective gate
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

If a session ends halfway through, running `/pipeline` again detects documents that already contain real generated content and skips completed phases.

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
| `/blueprint` | orchestration | PRD, coverage analysis, roadmap |
| `/blueprint-foundation` | `00`, `01`, `02`, `03` | context, vision, principles, requirements |
| `/blueprint-domain` | `04`, `05`, `09` | domain, data and state models |
| `/blueprint-architecture` | `06`, `10` | system architecture and ADRs |
| `/blueprint-flows` | `07`, `08` | critical flows and use cases |
| `/blueprint-quality` | `12`, `13`, `14`, `15` | testing, security, scalability, observability |
| `/blueprint-plan` | `11`, `16` | build plan and evolution |

The grouping follows dependency relationships.

For example, the data and state models derive from the domain model, while quality attributes consume architecture and critical flows rather than being generated in isolation.

---

# 2. Backend Blueprint

`/backend` reads the technical blueprint and produces 15 implementation-oriented documents.

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

# 3. Frontend Blueprint

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

# 4. Shared documentation

Cross-layer documents live under `docs/shared/`.

| Document | Purpose |
| --- | --- |
| `MAPPING.md` | Traceability between technical, backend and frontend blueprints |
| `glossary.md` | Unified project terminology |
| `error-ux-mapping.md` | Backend errors mapped to frontend behavior |
| `event-mapping.md` | Events that cross application layers |

These documents exist to prevent each blueprint from becoming an independent interpretation of the same product.

---

# Incremental evolution

Generating good documentation once is not enough.

Real systems change.

Blueprint provides separate operations for **local evolution** and **cross-system change**.

---

## `/increment`

Use `/increment` to add, correct, update or remove something without regenerating an entire blueprint.

Example:

```text
/increment
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

## `/patch`

Use `/patch` for a global change that needs impact analysis and propagation.

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

`/increment` evolves a feature.

`/patch` propagates a systemic change.

---

# Implementation backlog

`/specs` converts the specification into a full implementation backlog:

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
/codegen-setup
      │
      ▼
Contracts + schema + scaffold + CLAUDE.md router
      │
      ▼
/codegen
      │
      ▼
/codegen-feature
      │
      ▼
RED → GREEN → REFACTOR
      │
      ▼
/codegen-verify
```

`/codegen-feature` implements vertical features using TDD.

`/codegen-verify` independently evaluates whether the code still follows the blueprint.

---

# `/build` — guarded implementation loop

`/build` automates the feature loop.

```text
/build
/build ENT-001 ENT-002
/build --max 5
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

`/codegen-verify` compares implementation against the specification and produces an adherence score.

That verification is intentionally separate from feature generation.

---

# Context strategy

A filled project blueprint can grow far beyond what should be loaded into a single model context.

Blueprint uses four mechanisms to keep implementation context bounded.

### 1. `CLAUDE.md` router

Maps task types to the small set of documents most likely to be relevant.

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

1. **Claude Code**
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

Clone Blueprint:

```bash
git clone https://github.com/DouglasPrado/blueprint.git
cd blueprint
```

Place your PRD at:

```text
docs/prd.md
```

Then choose an execution mode.

### Fast autonomous pass

```text
/pipeline docs/prd.md web ../my-app/
```

After reviewing the generated documentation and `docs/ASSUMPTIONS.md`:

```text
/build
```

### Guided pass

Start with:

```text
/blueprint
```

Then run the technical, backend and frontend phases in order.

---

# Command reference

## Automation

| Command | Purpose |
| --- | --- |
| `/pipeline` | Generate the complete documentation set and scaffold through isolated phases |
| `/build` | Implement planned features in a guarded TDD loop |

## Technical Blueprint

| Command | Purpose |
| --- | --- |
| `/blueprint` | PRD intake, coverage analysis and roadmap |
| `/blueprint-foundation` | Context, vision, principles and requirements |
| `/blueprint-domain` | Domain, data and state models |
| `/blueprint-architecture` | System architecture and ADRs |
| `/blueprint-flows` | Critical flows and use cases |
| `/blueprint-quality` | Testing, security, scalability and observability |
| `/blueprint-plan` | Build plan and evolution |

## Backend

| Command | Purpose |
| --- | --- |
| `/backend` | Generate the 15 backend specification documents |

## Frontend

| Command | Purpose |
| --- | --- |
| `/frontend` | Frontend orchestration and shared data/API documents |
| `/frontend-design-system` | Design tokens, typography, colors and iconography |
| `/frontend-app {client}` | Client architecture, structure, state, routes and flows |
| `/frontend-quality {client}` | Client testing, performance, security, observability and CI/CD |

## Evolution and backlog

| Command | Purpose |
| --- | --- |
| `/increment` | Add, correct, update or remove scoped specification content |
| `/patch` | Propagate a global change through the documentation graph |
| `/specs` | Generate the implementation backlog |

## Code generation

| Command | Purpose |
| --- | --- |
| `/codegen-setup` | Generate routing context, contracts, schema and scaffold |
| `/codegen` | Present build-plan deliveries for implementation |
| `/codegen-feature` | Implement one vertical feature with TDD |
| `/codegen-verify` | Measure implementation adherence to the blueprint |

---

# Output structure

A generated project follows this documentation model:

```text
docs/
├── prd.md
│
├── blueprint/                 # 17 technical documents
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
├── .claude/
│   └── skills/                # 21 Claude Code skills
├── docs/
│   ├── adr/
│   ├── backend/
│   ├── blueprint/
│   ├── diagrams/
│   ├── frontend/
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

- 3 blueprint layers
- 52 standard documents for a single-client flow
- 21 Claude Code skills
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
