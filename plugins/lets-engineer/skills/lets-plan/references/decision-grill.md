# Decision Grill

This file contains the Decision Grill execution path (Phase 2.5.2–2.5.5). Load it only when the gate and offer at Phase 2.5.1 have fired and the user accepted the grill.

The grill walks unresolved decision forks one at a time, resolving them before the plan is written. It reuses the confidence-check checklists (`references/deepening-workflow.md`) as its fork bank, but runs them interactively against the *planning context* — research plus the Phase 2 question list — instead of against a written plan.

## 2.5.2 Build the Fork List

Detect forks by running the decision-bearing confidence-check checklists against the planning context. Draw candidates from:

- **Key Technical Decisions** — an obvious design fork exists but no path is chosen; a decision is stated without rationale; tradeoffs or rejected alternatives are unexamined
- **Implementation Units** — dependency order is unclear or likely wrong; the approach doesn't name the pattern to follow
- **System-Wide Impact** — interface, callback, or parity surfaces are unaccounted for; failure propagation is unexplored; a state-lifecycle, caching, or data-integrity choice is open
- **Risks & Dependencies** — an external-dependency assumption is weak or unstated
- **Open Questions** — a product blocker is hidden as an assumption

Apply two filters before anything reaches the user:

1. **Infer or scan first.** If repo context, documentation, or existing research can responsibly answer a fork, resolve it silently and drop it from the list. Only forks that genuinely cannot be inferred become questions. This preserves lets-plan's default bias toward inference — the grill raises the *ceiling* on questions for high-stakes work, it does not lower the *bar* for asking.
2. **Order by dependency.** Ask a fork whose answer reshapes downstream forks first (resolve dependencies progressively). Re-evaluate the remaining list after each answer — a resolved upstream fork may collapse, reshape, or remove later ones.

**Budget by stakes:** Deep plans cap at **5–8** forks; high-risk Standard plans cap at **3–5**. Forks below the cut are **not dropped silently** — record them in Open Questions with their detected branches so the confidence check and `lets-review-docs` still see them, and state plainly which forks fell through the budget.

## 2.5.3 Run the Grill

- **One question per turn** (Interaction Method). Never stack forks into a single message.
- Decision forks are discrete, so prefer **single-select** via the blocking question tool with the actual branches as the options — surfacing the real branches is the point, not anchoring. Include a free-text path for "none of these / here is the constraint I'm optimizing for."
- State your own lean **only after** the user answers, never before. This is where the grill diverges from grill-style interrogation that recommends an answer per question: a pre-loaded recommendation anchors the user onto your framing before they have reasoned, which conflicts with surfacing the genuine fork.
- After each answer, re-run the dependency ordering from 2.5.2 against the remaining forks.

## 2.5.4 Stop Condition

Stop when any of these holds:
- Every fork above the budget cut is resolved (answered or confidently inferred)
- The user says proceed, enough, or stop
- The budget is hit (remaining forks → Open Questions, per 2.5.2)

Before exiting, **replay the settled decisions as one compact list** — "Here's what we locked: A → X because…, B → Y because…" — and take a single confirmation. This delivers the shared-mental-model guarantee, bounded to one summary turn instead of a per-branch loop. Treat a correction here as a re-opened fork; otherwise continue.

## 2.5.5 Feed Forward

Resolved forks flow into Phase 3:
- Each becomes a **Key Technical Decision carrying its rationale and the rejected alternative** — not just the winning choice.
- Approach-level resolutions name the chosen pattern in the relevant unit's approach notes.
- Unresolved or budget-dropped forks land in **Open Questions** with their branches recorded.

Set frontmatter `grilled: YYYY-MM-DD` on the plan. The Phase 5.3.3 confidence scoring reads this marker and deprioritizes already-grilled sections, so the two passes compound instead of re-litigating the same decisions. Then return to SKILL.md Phase 3.
