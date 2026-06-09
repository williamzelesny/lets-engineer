# Codebase Research and Drafting

Loaded by `SKILL.md` at the start of Phase 1. This is where the doc's **code-derived** content comes from — the `generated` regions. It produces a draft grounded in the actual source; the interview (`interview.md`) fills in the rest.

The output of this phase is a draft of the architecture and functionality sections, ready to be wrapped in `generated` markers in Phase 3. Do not write the file here — draft the content.

## Overall Rules

1. **Verify before claiming.** Every structural claim — a component, a flow, a boundary, a dependency — must be traceable to a file you actually read. Open the source; do not infer architecture from names, directory layout, or memory.
2. **Mark what you grounded.** When you state a structural fact, you should be able to point at the file (and ideally the symbol) it came from. Record the source paths you relied on — they become the doc's `sources:` frontmatter and tell a future refresh what to re-read.
3. **A gap beats a guess.** If you cannot ground a claim, leave it out or write it as an open question for the interview. Hallucinated architecture is the one failure this skill must never ship.
4. **Repo-relative paths only.** Reference files as `app/services/billing.rb`, never as absolute paths.

## Scope: topic vs survey

The route from Phase 0 decides how wide to read.

**Topic mode** (`<topic>` given) — document one subsystem, feature, or business process:

- Find the entry points for the topic (routes, controllers, services, jobs, models, CLI commands — whatever the stack uses). Grep for the topic's vocabulary; follow imports and calls outward.
- Trace the **main flow** end to end: what triggers it, what it touches, what it produces. Note the components it crosses and the boundaries between them (a service call, a queue, an external API, a DB write).
- Read enough to be correct about the happy path and the obvious branches. You do not need every edge case — you need a true map a contributor can navigate from.

**Survey mode** (no topic) — document the whole application:

- Establish the **architecture overview**: the top-level components, how they relate, and the request/data lifecycle from entry to persistence.
- Identify the **major subsystems and flows** — the handful that matter for understanding how the app works — and name each in a sentence or two, with a pointer to where it lives.
- Stay at altitude. A survey is a map of the territory, not an exhaustive per-file inventory. Resist documenting every module; name the ones a newcomer needs first.

## What to draft

For the topic (or for each major subsystem, in survey mode), draft:

- **Architecture** — the components involved, their responsibilities, and the boundaries between them. This is the natural place for a diagram.
- **How it works** — the key flow(s) in prose: trigger → steps → outcome. Teaching depth (per Core Principle 3): explain enough that a reader understands the mechanism, not just the call sequence.

Leave the *why* — rationale, constraints, business rules — to the interview. If, while reading, you find a "why" question the code raises but cannot answer (e.g., why a retry is capped at 3, why an order can't be split), note it as a prompt for Phase 2 rather than guessing.

## Diagrams

Include a mermaid diagram when it makes structure or flow clearer than prose alone:

- **Component / boundary relationships** → a `flowchart` or component graph.
- **A multi-step or multi-service flow** → a `sequenceDiagram` or `flowchart`.
- **A lifecycle with states** → a `stateDiagram`.

Skip the diagram when prose already carries it — a single linear flow with three steps does not need a picture. A diagram that merely restates a sentence is noise. When you do include one, keep its labels grounded in real component and method names so a refresh can tell whether it drifted.

## Handing off to the interview

When the draft is grounded and the open "why" questions are noted, Phase 2 (`interview.md`) takes over. Carry forward the list of open questions so the interview asks only those — never re-asking what the draft already established.
