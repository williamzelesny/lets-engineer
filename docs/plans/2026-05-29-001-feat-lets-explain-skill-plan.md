---
title: "feat: Add lets-explain change-walkthrough skill"
type: feat
status: completed
date: 2026-05-29
origin: docs/brainstorms/2026-05-29-explain-walkthrough-skill-requirements.md
---

# feat: Add lets-explain change-walkthrough skill

## Summary

Build a new auto-discovered skill, `lets-explain`, that produces an explanatory walkthrough of a change the reader did not write — reviewer orientation first, teaching depth below. It mirrors `lets-code-review`'s input resolution (blank branch / PR / commit range) but stays read-only and never switches the working tree, renders the walkthrough in chat, and offers opt-in save and PR-comment delivery plus a handoff into `lets-code-review`.

---

## Problem Frame

The suite can critique a change (`lets-code-review`), act on review feedback (`lets-resolve-pr-feedback`), and review planning docs (`lets-doc-review`), but nothing helps a reader *understand* a change they did not author — a reviewer orienting to an unfamiliar PR, or a teammate learning the patterns and reasoning. See origin (`docs/brainstorms/2026-05-29-explain-walkthrough-skill-requirements.md`) for the full problem framing.

---

## Requirements

**Invocation & input**
- R1. `lets-explain` is invocable as a skill and accepts three input forms: blank (current branch vs base), a GitHub PR link/number, or a commit range.
- R2. PR input resolves the diff and metadata via `gh`; blank input diffs the current branch against its merge base.

**Walkthrough content**
- R3. Orientation layer: change intent (what + why, brief), a map of the areas/files touched and how they connect, and a suggested reading order.
- R4. Orientation calls out where attention should concentrate — load-bearing changes, risk, edge cases, anything non-obvious.
- R5. Teaching layer: notable patterns, the reasoning/trade-offs behind key decisions, and how new code fits existing structure.
- R6. The two layers are visually separable so a reviewer can stop after orientation and a learner can read on; no reviewer/learner mode flag.
- R7. Depth scales with change size; an optional simple diagram appears only when it materially aids comprehension.
- R8. Explain, do not critique — no findings, severity ratings, or fix recommendations.

**Delivery**
- R9. Render the walkthrough in chat by default.
- R10. After rendering, offer to save as a markdown file and/or post as a PR comment; neither happens without explicit opt-in.
- R11. On completion, offer a handoff to `lets-code-review` (understand → critique).

**Origin actors:** A1 (reviewer), A2 (learner/onboarding reader), A3 (the skill agent)
**Origin flows:** F1 (explain a change)
**Origin acceptance examples:** AE1 (covers R1, R2), AE2 (covers R2), AE3 (covers R6), AE4 (covers R8), AE5 (covers R10)

---

## Scope Boundaries

- No bug-hunting, severity ratings, or fix recommendations — that is `lets-code-review`.
- No author-side, value-first PR description generation — that is `lets-commit-push-pr`.
- No acting on or resolving review comments — that is `lets-resolve-pr-feedback`.
- No auto-saving to disk or auto-posting to GitHub — both are opt-in after the walkthrough renders.
- No switching the user's checkout or checking out the PR branch — resolution is read-only.

### Deferred to Follow-Up Work

- Subagent fan-out for very large diffs (chunk by area, parallel reader agents): future iteration — v1 is single-pass.
- Reverse rich cross-linking / a suite-wide skill index: no README or skill index exists today; revisit if one is added. (A one-line "see also" in `lets-code-review` is in scope here; a broader index is not.)

---

## Context & Research

### Relevant Code and Patterns

- `plugins/lets-engineer/skills/lets-code-review/SKILL.md` — **Stage 1: Determine scope** (lines ~189-325) is the authoritative pattern for resolving diff scope across blank / PR / branch / `base:` inputs, including fork-safe base resolution, clean-worktree checks, and untracked-file handling. `lets-explain` adapts a read-only subset of this.
- `plugins/lets-engineer/skills/lets-code-review/SKILL.md` — **Interactive mode rules** (the `AskUserQuestion` eager-preload pattern) and **## After Review → Step 5: Final next steps** (the post-run menu shape) are the patterns for the opt-in save/post prompts and the `lets-code-review` handoff.
- `plugins/lets-engineer/skills/lets-resolve-pr-feedback/SKILL.md` — frontmatter shape for a read-only-ish skill (`allowed-tools: Bash(gh *), Bash(git *), Read`).
- `plugins/lets-engineer/skills/lets-code-review/references/` — convention for per-skill bundled reference files (each skill bundles its own; references are not shared across skills).
- Skills are **auto-discovered** from `plugins/lets-engineer/skills/` — no `.claude-plugin/plugin.json` or `marketplace.json` edit is needed to register the new skill (verified).

### Institutional Learnings

- No `docs/solutions/` directory exists yet; no institutional learnings apply.

### External References

- None. Local patterns (the existing 25-skill suite, `lets-code-review` as a direct analogue) are sufficient; no external research was warranted.

---

## Key Technical Decisions

- **Name `lets-explain`** (not `lets-walkthrough`): "walkthrough" already denotes the interactive per-finding flow in `lets-code-review` (`references/walkthrough.md`); reusing it would collide. `lets-explain` also covers non-PR inputs (branch, range).
- **Read-only, no-checkout posture:** resolve the diff via `git diff` against the merge base and `gh pr diff`/`gh pr view` for PR targets; never run `git checkout`/`gh pr checkout` on the shared working tree. Rationale: a comprehension tool should not disturb the user's checkout, and read-only is materially simpler than `lets-code-review`'s checkout dance. Trade-off: reading full surrounding-file context at a PR ref is more limited — mitigated by fetching the ref or reading files via `gh` when the teaching layer needs context.
- **Single-pass generation for v1:** the main agent reads the diff and writes the walkthrough directly. Unlike review, comprehension does not benefit from diverse-persona parallelism, so subagent fan-out is deferred.
- **One layered output, no mode flag** (carried from origin): orientation on top, teaching below, visually separated so the reader self-selects depth.
- **Bundle own reference files:** `lets-explain` ships its own `input-resolution.md` (read-only adaptation) and `walkthrough-template.md`; it does not depend on `lets-code-review`'s references.
- **`allowed-tools`:** `Bash(git *), Bash(gh *), Read, Grep, Glob, Write` — `Write` is used only for the opt-in save.
- **Verification by dogfooding:** the repo has **no automated test harness** for skills (skills are instruction-prose; no test/spec directories exist — verified). Each unit's "Test scenarios" are concrete dogfood invocations validated by running the skill, not an automated suite. This is why unit `**Files:**` lists carry no `Test:` path.
- **Save destination `docs/walkthroughs/`** (created on demand) for the opt-in save — this resolves the origin's deferred "save location" open question. It deliberately introduces a new `docs/` artifact class (no prior convention exists); the location is revisitable if a different home emerges as more artifacts appear.

---

## Open Questions

### Resolved During Planning

- Should large diffs fan out reader subagents? **Resolved:** No for v1 — single-pass with depth scaling and reading-order prioritization; fan-out deferred to follow-up.
- Default save location for the saved walkthrough? **Resolved:** `docs/walkthroughs/<descriptive-slug>.md`, repo-relative, directory created on demand at save time.

### Deferred to Implementation

- Exact `gh`/`git` invocation details for reading full-file context at a PR ref when the teaching layer needs surrounding code — settle against real `gh` behavior during implementation.
- Precise diff-size thresholds that trigger "scale depth down / prioritize reading order" — tune by dogfooding on real diffs.

---

## Output Structure

    plugins/lets-engineer/skills/lets-explain/
    ├── SKILL.md
    └── references/
        ├── input-resolution.md       # read-only scope resolution (branch / PR / range)
        └── walkthrough-template.md    # orientation + teaching output skeleton

---

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce.*

Rendered walkthrough skeleton — the two layers are visually separated so a reviewer can stop after Orientation (R6):

    ## Orientation
    **What & why:** <1-2 sentence intent of the change>
    **Map:** <areas/files touched and how they connect>
    **Read first:** <suggested reading order>
    **Where to focus:** <load-bearing changes, risk, edge cases>

    ---

    ## How it works (teaching)
    <patterns used; reasoning/trade-offs behind key decisions; how new code fits existing structure>
    <optional diagram — only when it materially aids comprehension>

End-of-run delivery flow: render in chat → ask (opt-in) save to `docs/walkthroughs/` and/or post as PR comment → offer `lets-code-review` handoff.

---

## Implementation Units

### U1. Skill scaffold & invocation contract

**Goal:** Create the skill directory and `SKILL.md` with frontmatter, when-to-use, argument parsing, and the read-only contract — the skeleton the later units fill in.

**Requirements:** R1, R8

**Dependencies:** None

**Files:**
- Create: `plugins/lets-engineer/skills/lets-explain/SKILL.md`

**Approach:**
- Frontmatter: `name: lets-explain`; a `description` rich with trigger phrases ("explain this PR", "walk me through this change", "help me understand this diff", "what does this change do") so auto-invocation fires; `argument-hint: "[blank for current branch, or a PR link/number, branch, or commit range]"`; `allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob, Write`.
- Sections: title, "When to Use" (reviewer prep + onboarding/learning; explicitly NOT critique), "Argument Parsing" (recognize PR number/URL, branch name, commit range, or blank), and a stage map pointing to U2/U3/U4 stages.
- State the read-only, no-checkout, explain-not-critique contract up front (R8).

**Patterns to follow:**
- `plugins/lets-engineer/skills/lets-resolve-pr-feedback/SKILL.md` frontmatter; `plugins/lets-engineer/skills/lets-code-review/SKILL.md` "When to Use" / "Argument Parsing" shape.

**Test scenarios:**
- Happy path (dogfood): invoking `/lets-explain` is recognized and the skill loads; frontmatter `description` contains the trigger phrases.
- Edge case (dogfood): bare invocation with no argument is accepted and routes to current-branch resolution (handed to U2).

**Verification:**
- The skill is discoverable and loads; frontmatter is valid; the read-only/explain-not-critique contract is stated.

---

### U2. Read-only input & scope resolution

**Goal:** Resolve the diff and metadata for all three input forms without mutating the checkout.

**Requirements:** R1, R2

**Dependencies:** U1

**Files:**
- Modify: `plugins/lets-engineer/skills/lets-explain/SKILL.md` (add the scope-resolution stage)
- Create: `plugins/lets-engineer/skills/lets-explain/references/input-resolution.md`

**Approach:**
- Blank/branch/range: diff against the merge base, but **never** `git checkout`. `references/input-resolution.md` must *reproduce* `lets-code-review` Stage 1's base-detection chain (it bundles its own copy — references are not shared across skills): default-branch discovery via `git symbolic-ref` → `gh repo view --json defaultBranchRef` fallback → probing `main`/`master`/`develop`/`trunk`, then `git merge-base HEAD <base-ref>`, with a shallow-clone `git fetch --unshallow` and retry when the merge-base comes back empty.
- PR link/number: use `gh pr view` for metadata and `gh pr diff` for the diff; do **not** `gh pr checkout`. The `git diff`-against-merge-base path from Stage 1 is **not** usable for PR mode — it computes the merge-base against `HEAD`, which is the PR head *only after* `gh pr checkout`; with no checkout `HEAD` is the user's current branch and the scope is wrong. `gh pr diff` is the correct read-only PR source (it reflects remote PR state — acceptable here since `lets-explain` explains the PR as proposed, not local fix commits). When the teaching layer needs full-file context, read files at the ref via `gh`/`git` rather than switching the tree (exact mechanism deferred to implementation).
- `references/input-resolution.md` documents the read-only tier rules adapted from `lets-code-review/references/diff-scope.md` and Stage 1, with the PR-mode caveat above called out explicitly.

**Patterns to follow:**
- `plugins/lets-engineer/skills/lets-code-review/SKILL.md` Stage 1 (base detection, fork-safe resolution, untracked handling); `plugins/lets-engineer/skills/lets-code-review/references/diff-scope.md`.

**Test scenarios:**
- Covers AE1. Happy path (dogfood): on a feature branch with no argument, resolution diffs the branch against its merge base.
- Covers AE2. Happy path (dogfood): given a GitHub PR link, metadata and diff are fetched via `gh` with no checkout/branch switch.
- Edge case (dogfood): a commit range argument resolves to exactly that range's diff.
- Error path (dogfood): when no base can be resolved, the skill stops with a clear message rather than falling back to `git diff HEAD`.
- Integration (dogfood): after resolving a PR target, the working tree is unchanged (`git status` clean / branch unchanged).

**Verification:**
- All three input forms produce the correct diff; the working tree is never switched or mutated during resolution.

---

### U3. Walkthrough generation (orientation + teaching)

**Goal:** Turn the resolved diff into the layered explanatory walkthrough.

**Requirements:** R3, R4, R5, R6, R7, R8

**Dependencies:** U2

**Files:**
- Modify: `plugins/lets-engineer/skills/lets-explain/SKILL.md` (add the generation stage)
- Create: `plugins/lets-engineer/skills/lets-explain/references/walkthrough-template.md`

**Approach:**
- Orientation layer (R3, R4): intent (what + why), area/file map and connections, suggested reading order, where to focus (load-bearing/risk/edge cases).
- Teaching layer (R5): patterns used, reasoning/trade-offs behind decisions, how new code fits existing structure.
- Layers visually separated (R6) per the `walkthrough-template.md` skeleton; no mode flag.
- Depth scales with diff size; optional diagram only when it aids comprehension (R7).
- Explain-not-critique guardrail (R8): describe behavior; do not flag defects, assign severity, or recommend fixes.
- Single-pass only for v1: the main agent reads the diff and writes the walkthrough directly — do not spawn subagents or chunk by area (fan-out is deferred).

**Technical design:** *(optional — see the output skeleton in High-Level Technical Design; directional guidance, not implementation specification.)*

**Patterns to follow:**
- `plugins/lets-engineer/skills/lets-code-review/references/review-output-template.md` for the template-as-reference convention (not its content).

**Test scenarios:**
- Covers AE3. Happy path (dogfood): on a small change, both layers render and are clearly separated so a reviewer can stop after Orientation.
- Covers AE4. Error path / guardrail (dogfood): on code containing an apparent bug, the walkthrough explains what the code does without flagging it as a defect or recommending a fix.
- Happy path (dogfood): Orientation names the reading order and the highest-attention area for a multi-file change.
- Edge case (dogfood): on a large diff, depth scales down and reading-order prioritization keeps the orientation concise.
- Edge case (dogfood): a diagram appears only when it materially helps (absent for a trivial change).

**Verification:**
- The walkthrough contains both layers, visually separated; it teaches without critiquing; depth and diagram use are proportional to the change.

---

### U4. Delivery, opt-in persistence & handoff

**Goal:** Render in chat, offer opt-in save and PR-comment delivery, and offer the `lets-code-review` handoff.

**Requirements:** R9, R10, R11

**Dependencies:** U3

**Files:**
- Modify: `plugins/lets-engineer/skills/lets-explain/SKILL.md` (add the delivery/handoff stage)
- Modify: `plugins/lets-engineer/skills/lets-code-review/SKILL.md` (one-line "see also: lets-explain to understand a change first" in When to Use)

**Approach:**
- Render in chat by default (R9).
- After rendering, ask via `AskUserQuestion` (eager-preload pattern) whether to save to `docs/walkthroughs/<slug>.md` and/or post as a PR comment via `gh` (R10). Neither runs without explicit opt-in. Create `docs/walkthroughs/` on demand at save time.
- Offer a handoff to `lets-code-review` for the same target (R11), framed as understand → critique.
- Add a light reverse cross-link in `lets-code-review` so the pairing is discoverable from both sides.

**Patterns to follow:**
- `plugins/lets-engineer/skills/lets-code-review/SKILL.md` Interactive-mode `AskUserQuestion` eager-preload rule and `## After Review → Step 5: Final next steps` menu shape.

**Test scenarios:**
- Covers AE5. Happy path (dogfood): after the walkthrough renders, nothing is written to disk or posted until the user opts in.
- Happy path (dogfood): choosing "save" writes `docs/walkthroughs/<slug>.md` (creating the dir if absent) with the rendered walkthrough.
- Happy path (dogfood): choosing "post" adds a PR comment via `gh` for a PR target; the option is unavailable/declined gracefully when there is no PR.
- Integration (dogfood): selecting the handoff launches `lets-code-review` against the same target.
- Edge case (dogfood): declining all options ends cleanly with the walkthrough left in chat only.

**Verification:**
- Default render is chat-only; save and post happen only on opt-in; the `lets-code-review` handoff works; the reverse cross-link is present and does not alter `lets-code-review` behavior.

---

## System-Wide Impact

- **Interaction graph:** New, self-contained, auto-discovered skill. The only cross-skill touch is the one-line cross-link added to `lets-code-review` and the runtime handoff into it.
- **API surface parity:** Adds a new `/lets-explain` command surface; no existing skill's behavior changes (the `lets-code-review` edit is a doc-only "see also").
- **State lifecycle risks:** Read-only by contract — no checkout switching, no commits, no pushes. The only write is the opt-in save to `docs/walkthroughs/`.
- **Unchanged invariants:** `lets-code-review`, `lets-commit-push-pr`, and `lets-resolve-pr-feedback` keep their responsibilities; `lets-explain` deliberately does not overlap (no critique, no PR description, no comment resolution).

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Read-only/no-checkout limits full-file context at a PR ref | Read files at the ref via `gh`/`git` when the teaching layer needs surrounding code; accept a modest limitation vs. the simplicity/safety gain |
| Users confuse `lets-explain` with `lets-code-review` | Explicit explain-not-critique contract (R8) plus bidirectional cross-link and handoff |
| Very large diffs strain single-pass generation | Depth scaling + reading-order prioritization in v1; subagent fan-out deferred to follow-up |
| Auto-invocation misfires on review-style prompts | Tune the `description` trigger phrases toward comprehension intent ("understand", "walk me through"), distinct from review intent |

---

## Documentation / Operational Notes

- No README/skill index exists to update (skills auto-discover); the in-suite cross-link in `lets-code-review` is the discoverability surface for now.
- `docs/walkthroughs/` is introduced as a new artifact directory, created on demand at first save.

---

## Sources & References

- **Origin document:** [docs/brainstorms/2026-05-29-explain-walkthrough-skill-requirements.md](docs/brainstorms/2026-05-29-explain-walkthrough-skill-requirements.md)
- Related code: `plugins/lets-engineer/skills/lets-code-review/SKILL.md`, `plugins/lets-engineer/skills/lets-code-review/references/diff-scope.md`, `plugins/lets-engineer/skills/lets-resolve-pr-feedback/SKILL.md`
