---
date: 2026-06-09
topic: documentation-skill
---

# Application Documentation Skill

## Summary

A new lets-engineer skill that documents how an application works — its architecture, functionality, and business processes — as durable in-repo reference for teammates and contributors. It drafts each doc from the codebase, then interviews the user for the intent and process context that code can't reveal, writing per-topic docs plus a maintained index. Naming a topic scopes one focused doc; omitting one produces a broader survey. Re-running refreshes an existing doc in place.

---

## Problem Frame

The lets-engineer suite can explain a *change* (`lets-explain`), capture a *solved problem* (`lets-compound`), and keep those learnings fresh (`lets-compound-refresh`) — but nothing documents the application *as it currently stands* so a teammate or contributor can understand how it functions. Today that knowledge lives in people's heads or in scattered, ad-hoc notes; when someone needs to understand the architecture, a subsystem, or a business process, they reconstruct it by reading source and asking whoever remembers.

Two failure shapes follow. Code-legible structure (architecture, flows) is recoverable from the source but expensive to reconstruct repeatedly and easy to get subtly wrong. Business "why" — the domain rules, the process context, the reasons a thing is built the way it is — often isn't in the code at all, so even a careful code read can't recover it. The result is onboarding friction and tribal knowledge that doesn't compound.

---

## Actors

- A1. Documenter: the person invoking the skill; knows the system's intent and answers the targeted interview questions.
- A2. Contributor / reader: a teammate or external contributor learning how the application works; reads the generated docs and index.
- A3. The skill agent: reads the codebase, drafts the doc, runs the targeted interview, writes per-topic docs and the index, and refreshes existing docs.

---

## Key Flows

- F1. Document a topic (or survey)
  - **Trigger:** User invokes the skill, optionally with a topic (subsystem, feature, or business process).
  - **Actors:** A1 (documenter), A3 (agent)
  - **Steps:** Resolve scope (named topic → focused doc; none → broader survey) → read the codebase and draft the code-legible content → run a targeted interview for the gaps code can't fill → weave answers in → write the per-topic doc and update the index.
  - **Outcome:** A durable doc a contributor can read to understand how that part works and why; the index links it into the growing map.
  - **Covered by:** R1, R2, R3, R4, R5, R6, R8, R9, R10, R11

- F2. Refresh an existing doc
  - **Trigger:** User re-runs the skill for a topic that already has a doc.
  - **Actors:** A1 (documenter), A3 (agent)
  - **Steps:** Locate the existing doc → re-read current code → update the code-derived sections → preserve the human-authored interview content → if code changes contradict a human-authored section, surface the conflict rather than overwrite silently.
  - **Outcome:** The doc reflects current code without losing previously captured human context.
  - **Covered by:** R12, R13, R14

---

## Requirements

**Invocation and scope**
- R1. The skill accepts an optional topic argument. When a topic is named, it produces one focused doc for that topic (subsystem, feature, or business process).
- R2. When invoked with no topic, it produces a broader survey of how the application works — an architecture overview plus the major subsystems/flows — suitable for cold-start onboarding.
- R3. The skill covers three content kinds: architecture (structure, components, boundaries), functionality (what it does and its key flows), and business processes (domain rules and the "why").

**Content sourcing**
- R4. The skill reads the codebase to draft the code-legible content (architecture, functionality) before involving the user.
- R5. After drafting, the skill interviews the user for content code cannot reveal — business rationale, process context, constraints, the reasons behind decisions — and weaves the answers into the doc.
- R6. The interview is targeted: it asks only about gaps the code couldn't fill, not a full questionnaire, and follows the suite's one-question-at-a-time interaction style.
- R7. Any claim about the codebase in a generated doc must be grounded in the actual source; the skill verifies structural claims (components, flows, boundaries) against the code rather than guessing.

**Output and structure**
- R8. Output is markdown, one doc per topic, written to an in-repo docs home.
- R9. The skill maintains an index/overview doc that links the per-topic docs, giving contributors a navigable map that grows as topics accumulate.
- R10. Docs include mermaid diagrams where a diagram aids understanding of structure or flow; prose-only is acceptable where a diagram would not help.
- R11. Docs are written at teaching/onboarding depth — oriented to a reader learning the system and explaining the why — not as a terse reference.

**Refresh lifecycle**
- R12. Re-running the skill for an existing topic refreshes that doc in place rather than creating a duplicate.
- R13. On refresh, the skill updates code-derived sections from the current codebase while preserving the human-authored interview content; it does not silently discard previously captured answers.
- R14. When a refresh detects that code has changed in a way that contradicts a human-authored section, it surfaces the conflict to the user instead of overwriting silently.

**Packaging and positioning**
- R15. Shipped as a new skill in the lets-engineer plugin, following existing SKILL.md conventions (frontmatter: name, description, argument-hint, allowed-tools; phased body).
- R16. The skill's description positions it distinctly from `lets-explain` (documents changes) and `lets-compound` (captures solved problems): this skill documents the system as it currently stands.

---

## Acceptance Examples

- AE1. **Covers R1, R2.** Given the skill is invoked, when a topic is named it produces a single focused doc for that topic; when no topic is given it produces a broader survey of the whole application.
- AE2. **Covers R12, R13.** Given a topic doc already exists with human interview answers, when the skill is re-run for that topic, it updates the code-derived sections from current code and leaves the previously captured human answers intact.
- AE3. **Covers R5, R6.** Given the code draft leaves a process's business rationale unclear, when the skill reaches the interview step, it asks the user specifically about that rationale rather than re-asking what the code already showed.
- AE4. **Covers R14.** Given a refresh finds that code has changed in a way that contradicts a human-authored section, when it updates the doc, it flags the conflict to the user instead of silently overwriting.

---

## Success Criteria

- A contributor unfamiliar with the app can read a generated topic doc (or the survey + index) and correctly explain how that part works and why, without reading the source first.
- Generated architecture/functionality claims match the actual code — no hallucinated components, flows, or boundaries.
- Re-running on an evolving codebase keeps docs current without losing previously captured human context.
- A downstream planner/implementer can build the skill from this brainstorm without inventing scope, sourcing strategy, output structure, or refresh behavior.

---

## Scope Boundaries

- No drift-aware or auto-staleness tracking and no manifest — refresh is user-initiated (that behavior overlaps `lets-compound-refresh`).
- No publishing to an external doc site, wiki, or hosted portal; output is in-repo markdown only.
- No API-reference generation from code annotations or docstrings.
- Not documenting changes/diffs (`lets-explain`) or solved problems (`lets-compound`).
- No README or changelog authoring.
- Not auto-invoked on commit or in CI — it runs when the user invokes it.

---

## Key Decisions

- Adaptive scope (topic or survey): chosen over a fixed unit of work for flexibility on an evolving codebase, accepting more design surface as the cost.
- Code draft + targeted interview: chosen over pure code-reading (misses business "why") and over pure interview (weak on code accuracy).
- Refresh-in-place: chosen over one-shot overwrite and over living/drift-aware docs — current-enough without staleness machinery to build and maintain.
- Per-topic docs + maintained index: chosen over a single growing document and over unstructured output, to give contributors a navigable map.
- Teaching/onboarding depth with mermaid diagrams as the default doc style.

---

## Dependencies / Assumptions

- Follows existing lets-engineer SKILL.md conventions and plugin structure.
- Per repo convention, adding the skill triggers a version bump of `plugin.json` and `marketplace.json` on merge to main.
- Assumes the target application is a local repo the agent can read; documenting external or remote systems is not assumed.
- Assumes teaching-depth tone and mermaid diagrams are acceptable defaults (confirmed at synthesis).

---

## Outstanding Questions

### Deferred to Planning

- [Affects R8, R9][Technical] Exact docs home path and the index file's location and format (e.g., `docs/architecture/` with an `index.md`, vs a configurable path).
- [Affects R13][Technical] Mechanism for distinguishing code-derived from human-authored content within a doc so refresh can preserve the human parts (e.g., section markers or anchored regions).
- [Affects R15][User decision] Final skill name (`lets-document` is the working name).
