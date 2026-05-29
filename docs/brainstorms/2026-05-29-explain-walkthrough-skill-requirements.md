---
date: 2026-05-29
topic: explain-walkthrough-skill
---

# Explanatory Change Walkthrough Skill

## Summary

A new lets-engineer skill that produces an explanatory walkthrough of a change the reader did not write. It leads with reviewer orientation (what changed, why, what to read first, where the risk concentrates) and continues into a teaching layer (patterns used, the reasoning behind decisions). The walkthrough renders in chat, then offers to save or post it.

---

## Problem Frame

The lets-engineer suite covers critiquing a change (`lets-code-review`), acting on review feedback (`lets-resolve-pr-feedback`), and reviewing planning docs (`lets-doc-review`) — but nothing helps a reader *understand* a change they did not author. Today that means reading the raw diff plus whatever the PR description happens to say, then reconstructing intent, structure, and the why by hand.

Two readers hit this. A reviewer opening an unfamiliar PR needs fast orientation — what the change does, what to read first, where the risk lives — before they can review well. A teammate onboarding or learning wants more: the patterns used and the reasoning behind the decisions. Boris's widely-followed Claude Code guide treats this "Explanatory / Learning" capability as a top technique, and it is one of the few items there that is cleanly packageable as a skill rather than a harness feature — confirming the gap is real and worth filling.

---

## Actors

- A1. Reviewer: opening an unfamiliar change; wants fast orientation to review it well.
- A2. Learner / onboarding reader: wants to understand the patterns and the reasoning, not just the surface change.
- A3. The skill agent: resolves the input, gathers the diff and metadata, and produces the walkthrough.

---

## Key Flows

- F1. Explain a change
  - **Trigger:** User invokes the skill, optionally with a PR link, branch, or commit range.
  - **Actors:** A1/A2 (reader), A3 (agent)
  - **Steps:** Resolve input → gather diff + metadata → produce the layered walkthrough (orientation first, teaching second) → render in chat → offer to save and/or post → offer handoff to `lets-code-review`.
  - **Outcome:** The reader understands what changed, why, what to read first, and where the risk concentrates.
  - **Covered by:** R1, R2, R3, R9, R10, R11

---

## Requirements

**Invocation & input**
- R1. Invocable as a lets-engineer skill. Accepts three input forms: blank (current branch diffed against its base), a GitHub PR link or number, or a commit range.
- R2. When given a PR link/number, fetch the diff and PR metadata via `gh`. When blank, diff the current branch against its merge base.

**Walkthrough content (layered)**
- R3. Lead with an orientation layer: the change's intent (what + why in brief), a map of the areas/files touched and how they connect, and a suggested reading order.
- R4. Within orientation, call out where attention should concentrate — load-bearing changes, risk, edge cases, anything non-obvious.
- R5. Follow with a teaching layer: notable patterns used, the reasoning and trade-offs behind key decisions, and how the new code fits the existing structure — depth aimed at a reader learning the change.
- R6. Keep the two layers visually separable so a reviewer can stop after orientation and a learner can read on. No reviewer/learner mode flag.
- R7. Scale depth with the size of the change. Include a simple diagram (e.g., an ASCII control/data-flow sketch) only when it makes the change materially easier to grasp.
- R8. Explain, do not critique — no bug findings, no severity ratings, no fix recommendations. (Structural boundary: critique is `lets-code-review`'s job.)

**Delivery**
- R9. Render the walkthrough in chat by default.
- R10. After rendering, offer to save it as a markdown file and/or post it as a PR comment. Neither happens without explicit user go-ahead.
- R11. On completion, offer a handoff to `lets-code-review` (understand → critique).

---

## Acceptance Examples

- AE1. **Covers R1, R2.** Given no argument, when invoked on a feature branch, the skill diffs the branch against its merge base and walks through those changes.
- AE2. **Covers R2.** Given a GitHub PR link, when invoked, the skill fetches the PR diff and metadata via `gh` and walks through it.
- AE3. **Covers R6.** Given a small change, when the walkthrough renders, both the orientation and teaching layers are present but clearly separated, so a reviewer can stop after orientation.
- AE4. **Covers R8.** Given code that contains an apparent bug, when the walkthrough renders, it explains what the code does without flagging it as a defect or recommending a fix.
- AE5. **Covers R10.** Given a rendered walkthrough, when it completes, nothing is written to disk or posted to GitHub until the user opts in.

---

## Success Criteria

- A reviewer can orient to an unfamiliar PR faster than by reading the raw diff plus its description.
- A learner comes away understanding the patterns and the reasoning, not just what changed.
- `lets-plan` can build the skill without inventing the audience, the output destination, or the explain-not-critique boundary.

---

## Scope Boundaries

- No bug-hunting, severity ratings, or fix recommendations — that is `lets-code-review`.
- No author-side, value-first PR description generation — that is `lets-commit-push-pr`.
- No acting on or resolving review comments — that is `lets-resolve-pr-feedback`.
- No auto-saving to disk or auto-posting to GitHub — both are opt-in after the walkthrough renders.

---

## Key Decisions

- Name leaning `lets-explain` (alternative: `lets-walkthrough`), not `lets-explain-pr` — input is not PR-only, so the name should not imply it.
- Single layered output over separate reviewer/learner modes — less to maintain, and the reader self-selects depth by how far they read.
- In-chat adaptive delivery (render, then offer save/post) — lowest friction for the common case.
- Positioned as the comprehension counterpart to `lets-code-review`: understand the change here, critique it there.

---

## Dependencies / Assumptions

- `gh` CLI available for PR-link/number input (mirrors `lets-code-review`).
- `git` available for branch and commit-range diffs.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R7][Technical] Whether large diffs should fan out reader subagents (as `lets-code-review` does with persona agents) to keep coverage thorough, or stay single-pass.
- [Affects R10][Technical] Default file location and naming convention for the saved walkthrough artifact.
