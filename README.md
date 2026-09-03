# lets-engineer

> A [Claude Code](https://claude.com/claude-code) plugin of opinionated, compounding engineering workflows — **brainstorm → plan → build → review → ship** — where each stage leaves durable artifacts that make the next one sharper.

[![License: MIT](https://img.shields.io/badge/License-MIT-6366f1)](LICENSE)
![Claude Code plugin](https://img.shields.io/badge/Claude_Code-plugin-D97757?logo=claude&logoColor=white)

`lets-engineer` is a toolkit of **28 workflow skills** (backed by **46 specialized review and research agents**) that turn a coding agent into a disciplined engineering partner. Instead of one-shot prompts, each skill runs a real workflow: it asks the right questions, produces a durable artifact — a requirements doc, a plan, a learning — and hands off cleanly to the next stage. Knowledge accrues in your repo, so the work *compounds*.

## The pipeline

```mermaid
flowchart LR
    strategize["lets-strategize"] --> ideate["lets-ideate"]
    ideate --> brainstorm["lets-brainstorm"]
    brainstorm --> plan["lets-plan"]
    plan --> work["lets-work"]
    work --> review["lets-review-code"]
    review --> ship["lets-commit-push-pr"]
    review --> compound["lets-compound"]
    compound -. "learnings feed the next cycle" .-> brainstorm
```

Each arrow is a handoff. `lets-brainstorm` writes a requirements doc that `lets-plan` consumes; `lets-plan` writes a plan that `lets-work` executes; `lets-review-code` and `lets-compound` feed learnings back so the next cycle starts smarter. Every skill also works standalone — start wherever the work is.

> This plugin eats its own dog food: the `lets-explain` skill was built end-to-end through the pipeline above — see [`docs/brainstorms/`](docs/brainstorms) and [`docs/plans/`](docs/plans) for its requirements doc and plan.

## Install

Requires [Claude Code](https://claude.com/claude-code). In a Claude Code session:

```
/plugin marketplace add williamzelesny/lets-engineer
/plugin install lets-engineer@lets-engineer
```

Then check your environment and optional CLI dependencies:

```
/lets-setup
```

Skills run as slash commands (e.g. `/lets-brainstorm`, `/lets-plan`, `/lets-work`) and also activate automatically when your request matches what a skill is for.

## Quick start

```
/lets-brainstorm a feature you're considering   # → docs/brainstorms/<topic>-requirements.md
/lets-plan                                       # → docs/plans/<dated>-plan.md
/lets-work                                       # implements, tests, reviews, and ships it
```

Each step reads the previous step's artifact, so you confirm scope once and let the chain carry it forward.

## Skills

Every skill you invoke is named to finish the sentence its prefix starts: `lets-review-code` is *"let's review code."* Two kinds of skill are deliberately noun-shaped instead — the stack styles below, which describe how to write rather than a task to run, and the review and research agents, which the skills dispatch and you never type.

**Strategy & ideation**

| Skill | What it does |
|---|---|
| `lets-strategize` | Create/maintain `STRATEGY.md`: target problem, approach, users, metrics, tracks of work |
| `lets-ideate` | Generate and pressure-test grounded ideas before committing to one |
| `lets-take-pulse` | Time-windowed pulse report on usage, quality, errors, and signals worth investigating |

**Define — brainstorm & plan**

| Skill | What it does |
|---|---|
| `lets-brainstorm` | Collaborative requirements dialogue → a right-sized requirements doc |
| `lets-plan` | Turn requirements into a structured, reviewable implementation plan (with optional deepening pass) |
| `lets-review-docs` | Multi-persona review of requirements or plan documents |

**Build**

| Skill | What it does |
|---|---|
| `lets-work` | Execute a plan (or a bare prompt) to a finished, tested, reviewed feature |
| `lets-branch-off` | Spin up an isolated git worktree for parallel work or PR review |
| `lets-debug` | Systematically find root causes from errors, test failures, or issue references |
| `lets-optimize` | Metric-driven iterative optimization loops with parallel experiments |

**Frontend & design**

| Skill | What it does |
|---|---|
| `lets-design-frontend` | Build web interfaces with genuine design quality, verified by screenshots |
| `lets-generate-images` | Generate and edit images via the Gemini API (Nano Banana Pro) |
| `lets-polish-beta` | _[beta]_ Launch the dev server and iterate on a feature live in the browser |

**Review & ship**

| Skill | What it does |
|---|---|
| `lets-review-code` | Tiered persona code review with confidence-gated, deduplicated findings |
| `lets-explain` | Orientation-first, teaching-depth walkthrough of a change — explains, doesn't critique |
| `lets-resolve-pr-feedback` | Evaluate and fix PR review threads in parallel, then reply and resolve |
| `lets-commit` | Create a clear, value-communicating commit |
| `lets-commit-push-pr` | Commit, push, and open a PR with an adaptive, value-first description |
| `lets-record-demo` | Capture GIFs, terminal recordings, or screenshots as PR evidence |

**Compound — knowledge that accrues**

| Skill | What it does |
|---|---|
| `lets-compound` | Document a solved problem so your team's knowledge compounds |
| `lets-refresh-learnings` | Refresh and consolidate stale learnings under `docs/solutions/` |
| `lets-document` | Document how the app works — architecture, functionality, business processes — as durable team reference in `docs/how-it-works/` |
| `lets-model-domain` | Build the shared domain language — a `CONTEXT.md` glossary plus decision records under `docs/decisions/` |
| `lets-search-sessions` | Search and query past coding-agent session history (Claude Code, Codex, Cursor) |

**Stack styles & meta**

| Skill | What it does |
|---|---|
| `lets-dhh-rails-style` | Write Ruby/Rails in DHH's 37signals style |
| `lets-agent-native-architecture` | Build applications where agents are first-class citizens |
| `lets-setup` | Diagnose and configure your lets-engineer environment and CLI dependencies |
| `lets-update` | Check whether the plugin is up to date and recommend the update command |

## How it compounds

Skills write durable artifacts into your repo, and later runs read them back:

- `docs/brainstorms/` — requirements docs from `lets-brainstorm`
- `docs/plans/` — implementation plans from `lets-plan`
- `docs/solutions/` — learnings from `lets-compound`, kept current by `lets-refresh-learnings`
- `docs/how-it-works/` — architecture and process docs from `lets-document`
- `docs/decisions/` — decision records from `lets-model-domain`
- `STRATEGY.md` — product direction from `lets-strategize`
- `CONTEXT.md` — the domain glossary from `lets-model-domain`, read by every skill that names things

The more you use the pipeline, the more context the agent has about your codebase and decisions — so each cycle starts further ahead than the last.

## Harness support

Built for **Claude Code** — install, the plugin cache, and slash commands assume it. The skill instructions are written harness-aware (they reference equivalents on Codex, Gemini, and Pi), but Claude Code is the supported, tested path.

## License

Licensed under the [MIT License](LICENSE).
