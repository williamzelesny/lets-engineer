---
name: lets-explain
description: "Explain a change you didn't write — produce an orientation-first, teaching-depth walkthrough of a diff, PR, or commit range. Use when asked to 'explain this PR', 'walk me through this change', 'help me understand this diff', 'what does this change do', when getting oriented before reviewing, or when learning how a change works. Explains, does not critique."
argument-hint: "[blank for current branch, or a PR link/number, branch name, or commit range]"
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob, Write
---

# Explain a Change

Produce an explanatory walkthrough of a change you did not write — **orientation first** (what changed, why, what to read first, where the risk is), **teaching depth second** (the patterns and the reasoning behind them). The walkthrough renders in chat; saving or posting it is opt-in.

> **Explain, don't critique.** This skill helps a reader *understand* a change. It never flags bugs, assigns severity, or recommends fixes — that is `lets-code-review`'s job. When you finish, offer the handoff: understand here, critique there.

## When to Use

- Orienting to an unfamiliar PR before reviewing it
- Onboarding to a change, or learning the patterns and reasoning behind it
- Understanding a branch or commit range you did not author
- Standalone, or as the comprehension step before `lets-code-review`

**Not for:** finding bugs or rating severity (`lets-code-review`), writing an author's value-first PR description (`lets-commit-push-pr`), or resolving review comments (`lets-resolve-pr-feedback`).

## Argument Parsing

Parse `$ARGUMENTS` to determine the change to explain:

| Argument | Scope |
|----------|-------|
| (blank) | The current branch diffed against its merge base |
| PR number or GitHub URL | That PR's diff and metadata, via `gh` |
| Branch name | That branch diffed against its merge base |
| Commit range (e.g. `abc123..def456`) | Exactly that range |

## Read-Only Contract

`lets-explain` never mutates the repository:

- **No checkout.** Never run `git checkout` or `gh pr checkout`. Resolve diffs in place; for PR targets use `gh pr diff` / `gh pr view`.
- **No commits, pushes, or edits** to the code under explanation.
- **No critique.** Describe what the code does and why; do not flag defects or recommend changes.

The one permitted write is the opt-in save in Stage 3, and only after the user agrees.

## How to Run

### Stage 1: Resolve scope (read-only)

Determine the input form from `$ARGUMENTS` and resolve the diff, changed-file list, and intent metadata **without switching the working tree**. Follow `references/input-resolution.md`.

Produce: the base marker, the changed-file list, the diff (with generous context), and — for PRs — title/body/URL for intent.

### Stage 2: Generate the walkthrough

Read the diff, and read surrounding files for context where the teaching layer needs them (via `Read`/`gh`, never by checking out). Produce one layered walkthrough following `references/walkthrough-template.md`:

- **Orientation** (always first): the intent (what + why), a map of the areas touched and how they connect, a suggested reading order, and where to concentrate attention.
- **How it works** (teaching): notable patterns, the reasoning and trade-offs behind key decisions, and how the new code fits the existing structure.

Scale depth to the size of the change. Include a small diagram only when it materially helps. Keep the two layers visually separated so a reviewer can stop after Orientation and a learner can read on. **Single pass** — do not spawn subagents or chunk by area (fan-out is a deferred future iteration).

Explain-not-critique guardrail: if you notice an apparent bug, describe what the code does; do not flag it as a defect or recommend a fix.

### Stage 3: Deliver and hand off

1. Render the walkthrough in chat.
2. Then ask the user what to do with it, using the platform's blocking question tool (in Claude Code, pre-load `AskUserQuestion` via `ToolSearch` with `select:AskUserQuestion` before asking; fall back to a numbered list only when no blocking tool exists or the call errors). Offer the compatible options:
   - **Save** to `docs/walkthroughs/<slug>.md` (create the directory on demand; derive `<slug>` from the change).
   - **Post** as a PR comment via `gh` (only when the target is a PR).
   - **Hand off to `lets-code-review`** for the same target — understand → critique.
   - **Nothing** — leave it in chat.

   Nothing is saved or posted without an explicit choice.
3. Act on the selection. If the user chose the handoff, invoke `lets-code-review` with the same target.

## Success Criteria

- The walkthrough leads with Orientation and continues into teaching, the two layers clearly separated.
- It explains without critiquing — no findings, severity, or fix recommendations.
- The working tree is never switched or mutated; saving and posting happen only on opt-in.
- A reader can orient to the change faster than from the raw diff, and a learner comes away understanding the patterns and the reasoning.
