---
name: opensource
description: Transforma blueprint proprietario em projeto opensource. Adapta os 4 blueprints.
---

# Opensource — Transform Blueprint into an Opensource Project

Transform a project with proprietary blueprints into a complete opensource project. Adapt all 4 blueprints (technical, backend, frontend, business) in-place and generate OSS root files. All generated content MUST be in English.

## Step 1: Read All Blueprints

| Blueprint | Path | Key files to focus on |
|-----------|------|-----------------------|
| Technical | `docs/blueprint/` | 00-context, 01-vision, 06-architecture, 11-build_plan, 12-testing, 13-security, 14-scalability, 15-observability, 17-communication |
| Backend | `docs/backend/` | 00-vision, 01-architecture, 02-structure, 03-domain, 05-api-contracts, 09-errors, 11-permissions, 12-events, 13-integrations, 14-tests |
| Frontend | `docs/frontend/` | 01-architecture, 03-design-system, 13-cicd-conventions |
| Business | `docs/business/` | All 10 files (00 to 09) |

If any blueprint is missing, warn: "Run `/blueprint`, `/backend`, `/frontend`, or `/business` to generate. Can continue partially."

Present status table: Blueprint | Docs found | Status (Complete/Partial/Missing).

## Step 2: User Questions

Ask 5 questions (pre-fill from blueprint when available):

1. **OSS Model**: Open-core | Community-driven | Dev tool | Foundation-backed
2. **License**: MIT | Apache-2.0 | GPL-3.0 | AGPL-3.0 | Dual
3. **Governance**: BDFL | Committee | Foundation | Meritocracy
4. **Project Name**: (check blueprint 01-vision.md)
5. **Community Channels**: GitHub Discussions | Discord | Slack | Forum | Other

Store as `{{OSS_MODEL}}`, `{{LICENSE}}`, `{{GOVERNANCE}}`, `{{PROJECT_NAME}}`, `{{CHANNELS}}`.

## Step 3: Transform Business Blueprint (Edit)

Adapt EACH of the 10 business docs in-place using **Edit** (NEVER Write). Preserve existing content. Insert before `<!-- APPEND:... -->`. Mark with `<!-- updated: opensource — {{OSS_MODEL}} -->`. Rewrite all content in English.

### 3.1 `00-business-context.md` — Ecosystem Context
- Title → "Opensource Ecosystem Context". Stage → OSS stages (pre-release/alpha/beta/stable/mature/LTS)
- TAM/SAM/SOM → Total Addressable Developers, Active Ecosystem Users, Target Contributors
- Competition → "Ecosystem Alternatives": replace Pricing→License, Market Share→GitHub Stars/Downloads
- SWOT: Strengths (community, transparency), Weaknesses (burnout, funding), Opportunities (corporate adoption), Threats (hostile fork, sponsor abandonment)

### 3.2 `01-value-proposition.md` — Why Use / Why Contribute
- Split into **Users** (freedom, no lock-in, customization, auditability) and **Contributors** (learning, portfolio, networking, impact)
- Differentials: compare with proprietary AND other OSS projects

### 3.3 `02-segments-personas.md` — OSS Personas
- Segments: Individual Developers, Companies (users), Companies (sponsors), Maintainers, Occasional Contributors
- ICP → "Ideal Contributor Profile" + "Ideal Adopter Profile"
- Personas: Hobbyist contributor, Corporate developer, DevRel, First-time contributor, Power user
- TAM/SAM/SOM → Total Developer Market, Reachable Community, Active Contributors Target

### 3.4 `03-channels-distribution.md` — Community Channels
- Channels: GitHub (primary), Package registries, Documentation site, Blog/Content, Conferences, {{CHANNELS}}, Social media
- Sales funnel → Contribution funnel: Discovery → First Use → First Issue → First PR → Regular Contributor
- Partnerships → Ecosystem integrations

### 3.5 `04-relationships.md` — Community Engagement
- Lifecycle: Newcomer → Contributor → Committer → Maintainer → TSC Member
- Retention: good-first-issues, mentoring, recognition (README credits, swag), Hacktoberfest
- Churn: inactivity, frustration with review, ignored PRs, burnout
- Support: Issues (bug), Discussions (Q&A), Docs (self-service), {{CHANNELS}}

### 3.6 `05-revenue-model.md` — Sustainability Model

**Per `{{OSS_MODEL}}`:**
- **Open-core**: Free core + paid enterprise features, free self-hosted + paid hosted, feature table Community/Pro/Enterprise
- **Community-driven**: GitHub Sponsors, OpenCollective, Grants (GSoC, NLnet, Sovereign Tech Fund), Bounties
- **Dev tool**: Plugin marketplace, premium extensions, enterprise license, training/certification
- **Foundation-backed**: Membership fees (Silver/Gold/Platinum), corporate sponsors, grants, events

Common: MRR → "Monthly Funding", unit economics → sustainability metrics, pricing → sponsorship tiers. **NEVER invent numbers** — use `{{placeholder}}`.

### 3.7 `06-cost-structure.md` — Project Costs
- Fixed: CI/CD, hosting (docs, demo), domain/CDN, maintainer stipend, tools
- Variable: cloud infra (open-core), build minutes, download bandwidth
- "Burn rate" → "Sustainability runway", "Break-even" → "Self-sustainability point"
- **NEVER invent numbers**

### 3.8 `07-metrics-kpis.md` — OSS Metrics
- North Star per model: Open-core→Monthly Active Enterprise Users, Community→Active Contributors/Month, Dev tool→Weekly Downloads, Foundation→Production Deployments
- AARRR → Awareness (stars, visits), Adoption (installs), Activation (first use/contribution), Retention (returning contributors), Referral (forks, mentions)
- Dashboard: stars trend, open issues, PR merge time, active contributors (30d), downloads, time to first response, bus factor

### 3.9 `08-marketing-strategy.md` — Positioning & Awareness
- Positioning: "The open-source alternative to {{proprietary}}"
- GTM: Pre-launch (private beta, RFC), Launch (PH, HN, Reddit, Twitter), Post-launch (talks, tutorials)
- Growth loops: Use→Feedback→Improvement→More Users | Use→Blog→Discovery→More Users | Contribute→Learn→Tell Others
- Remove paid media → "community investment"

### 3.10 `09-operational-plan.md` — Community Operations
- Processes: Release (semver, changelog, migration), RFC process, Code review SLA (48h), Security response, Issue triage
- Team: Contributor → Committer → Maintainer → TSC Member (criteria + responsibilities per level)
- Governance: Apply {{GOVERNANCE}} model rules
- Timeline: launch → alpha → beta → RC → v1.0 → LTS
- Risks: maintainer burnout, hostile fork, license compliance (CLA/DCO), supply chain attack (signing, SLSA), sponsor abandonment

## Step 4: Adapt Technical Blueprint (Edit)

Add OSS sections to technical blueprint using **Edit**. Insert before `<!-- APPEND:... -->`. Mark `<!-- added: opensource -->`. All in English.

| Doc | Section to Add | Content |
|-----|---------------|---------|
| `13-security.md` | Vulnerability Disclosure Policy | Channel (email/GitHub Security Advisories), timeline (48h response, 7-30d patch), coordinated disclosure 90d, CVE, supply chain (Dependabot, SBOM, signing) |
| `06-system-architecture.md` | Contribution Architecture | Plugin points, extension API, module boundaries, public API surface (stable vs experimental) |
| `11-build_plan.md` | Public Roadmap | GitHub Projects board, RFC process, community feature voting, release cadence |
| `12-testing_strategy.md` | Contributor Testing Guide | Running tests locally, adding tests (conventions, placement), CI checks on PRs, coverage rules |
| `15-observability.md` | Operational Transparency | Status page, incident post-mortems, open metrics dashboard |
| `17-communication.md` | Community Communication Templates | Release announcement, breaking change notice, deprecation notice, security advisory |

## Step 5: Adapt Backend Blueprint (Edit)

Add OSS sections to backend blueprint using **Edit**. Mark `<!-- added: opensource -->`. All in English.

| Doc | Section to Add | Content |
|-----|---------------|---------|
| `00-backend-vision.md` | Opensource Backend Principles | Extensibility (plugins, hooks), config over code, DB agnosticism, API stability (semver) |
| `01-architecture.md` | Contributor Architecture Guide | Layer boundaries, dependency injection, module creation guide, ADR links |
| `02-project-structure.md` | Contributor Directory Guide | Where to add features, file naming, generated files, monorepo navigation |
| `05-api-contracts.md` | API Contribution Guidelines | Endpoint conventions, breaking changes (RFC required), OpenAPI updates, backwards compat (2 minor versions), rate limiting config |
| `09-errors.md` | Error Handling for Contributors | Adding error codes, i18n (translatable messages), error catalog, HTTP status mapping |
| `11-permissions.md` | Auth for Self-Hosted | Auth providers (OAuth, SAML, LDAP), API keys, custom roles, security defaults |
| `12-events.md` | Event System for Contributors | Adding events (naming, schema), event handlers, queue adapters, webhook support |
| `13-integrations.md` | Integration Development Guide | Adapter pattern, plugin system, testing (mocks, contract tests), registry |
| `14-tests.md` | Testing Guide for Contributors | Running tests, writing tests (conventions), fixtures/factories, DB tests (containers), CI pipeline, coverage |

## Step 6: Adapt Frontend Blueprint (Edit)

Add OSS sections using **Edit**. Mark `<!-- added: opensource -->`. All in English.

| Doc | Section to Add | Content |
|-----|---------------|---------|
| `01-architecture.md` | Contributor Setup Guide | Prerequisites, clone+install, dev server, env variables, troubleshooting |
| `13-cicd-conventions.md` | CI for Contributors | PR checks (lint, typecheck, tests, build), preview deploys, auto labels, stale bot, Dependabot auto-merge |
| `03-design-system.md` | Design System for Contributors | Adding components (path, story, tests), Storybook, design tokens, visual regression |

## Step 7: Generate Root Files (Write)

Create NEW files at project root using **Write**. If README.md or LICENSE exists, ask user: Replace / Merge / Skip.

| File | Structure |
|------|-----------|
| `README.md` | Badges (license, CI, npm), description, Features, Quick Start, Documentation, Contributing link, Community ({{CHANNELS}}), License, Sponsors |
| `CONTRIBUTING.md` | Code of Conduct link, Prerequisites, Dev Setup, How to Contribute (bugs, features, PRs), Code Style, Testing, Review Process, {{GOVERNANCE}} decision making, Recognition |
| `CODE_OF_CONDUCT.md` | Contributor Covenant v2.1 (full text), fill contact method |
| `LICENSE` | Full license text for {{LICENSE}}, current year, {{PROJECT_NAME}}. If Dual: LICENSE-OSS + LICENSE-COMMERCIAL |
| `SECURITY.md` | Supported versions, reporting channel (email + GitHub Security Advisories), what to include, response timeline (48h ack, 7d assess, 14d critical, 30d high, 90d disclosure) |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Frontmatter (name, labels: bug+triage), Description, Steps to Reproduce, Expected/Actual, Environment, Screenshots |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Frontmatter (name, labels: enhancement), Problem, Proposed Solution, Alternatives, Context |
| `.github/ISSUE_TEMPLATE/config.yml` | blank_issues_enabled: false, contact_links (Discussions, Docs) |
| `.github/PULL_REQUEST_TEMPLATE.md` | Description, Type of Change checkboxes, Checklist (contributing guide, tests, docs), Related Issues, Screenshots |

## Step 8: Review

Present summary table: Type | File | Action | Description (all 30+ files). Show OSS Model, License, Governance. Ask for adjustments.

## Step 9: Next Steps

> "Blueprint transformed! Next: 1) Review `docs/business/05-revenue-model.md` (most critical), 2) Fill `{{placeholders}}`, 3) Customize README badges, 4) Configure GitHub templates, 5) First release. For adjustments: `/patch`, `/blueprint-increment`, `/frontend-increment`, `/business-increment`."

---

## Critical Rules

1. **Edit** for existing docs, **Write** ONLY for new root files
2. **NEVER invent numbers** — use `{{placeholder}}` or ask
3. **Mark ALL changes** with `<!-- updated: opensource — {{OSS_MODEL}} -->` or `<!-- added: opensource -->`
4. **Insert before `<!-- APPEND:... -->`** — NEVER remove/move APPEND markers
5. **Preserve ALL existing content** — only add/adapt
6. **DO NOT modify** generic examples inside `<details>` or existing `{{...}}` template placeholders
7. **Language**: ALL generated content in **English**

## OSS Model Adaptation Reference

| Aspect | Open-core | Community-driven | Dev tool | Foundation-backed |
|---------|-----------|-----------------|----------|-------------------|
| Revenue | Enterprise features + hosted | Sponsors + grants + donations | Marketplace + premium + training | Membership + sponsors + events |
| Personas | Users + Enterprise buyers | Contributors + power users | Plugin devs + end users | Corporate adopters + members |
| Metrics | Conversion free→paid | Active contributors | Downloads + installs | Production deployments |
| Governance | Company-led + community input | Community-led | Company-led + ecosystem | Foundation charter |
| Marketing | Comparison pages + enterprise sales | Community evangelism | DX + docs + tutorials | Case studies + conferences |
| Risks | Community trust erosion | Maintainer burnout | Ecosystem fragmentation | Bureaucracy overhead |
