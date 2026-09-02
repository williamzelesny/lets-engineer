# Drift Audit: Reconciling the Glossary Against the Code

Loaded by `SKILL.md` at the start of Phase 4. Defines the drift categories, the reconciliation procedure, and the rules that keep an audit from quietly destroying the user's language.

**Drift is a finding, not a fix.** The glossary and the code disagreeing is information: sometimes the code moved on and the glossary should follow, sometimes the glossary is right and the code is the bug. Only the user knows which. Classify, present, and let them decide.

## Procedure

1. **Read `CONTEXT.md`** and list every term, with its `_Avoid_` synonyms.
2. **Search the code for each term** and for each of its rejected synonyms — models, types, functions, columns, event names, test descriptions.
3. **Classify each term** into one of the categories below.
4. **Search the reverse direction**: prominent domain nouns in the code with no glossary entry.
5. **Present the findings grouped by category**, not term by term. A user can rule on eight renames in one pass; eight separate questions exhausts the session.
6. **Apply what the user confirms**, editing entries in place.

## Categories

- **Renamed** — the glossary's term is absent from the code, and a rejected synonym is everywhere. Either the code drifted and needs correcting, or the team changed its mind and the glossary is stale. Ask which.
- **Split** — one glossary entry, two distinct concepts in the code. The entry's definition usually shows the strain already: it needs an "or" to stay true. Propose two entries with the boundary drawn.
- **Merged** — two glossary entries, one concept in the code. Either the distinction was never real, or it was real and got flattened by accident. The second case is a bug worth surfacing loudly.
- **Dead** — the term appears nowhere in the code and nowhere in recent conversation or docs. Candidate for deletion, after confirmation.
- **Never implemented** — defined but never built. Distinct from dead: check `docs/plans/` and `docs/brainstorms/` before proposing removal, because an aspirational term with live planning behind it is doing its job.
- **Undefined** — a domain noun carrying real weight in the code with no entry. The reverse drift, and often the most valuable category in an audit.

## Rules

- **Never delete a term unilaterally.** Every removal is confirmed. A term the user wrote is theirs.
- **Preserve wording on survivors.** An audit rewrites only the entries whose meaning actually changed. Rephrasing untouched definitions is churn, and it erases the user's voice from their own glossary.
- **When the glossary wins, hand the fix off.** A term that is right and code that is wrong is a `lets-work` task, not something to fix here. Note it in the report and move on.
- **Absence from code is weak evidence.** A term may live in the UI, in support conversations, or in a partner's contract without appearing in a single identifier. Check the repo's prose before calling anything dead.
- **A split or merge may deserve a decision record.** When reconciliation settles a boundary that was genuinely contested and is now expensive to move, check it against the bar in `decision-records.md`.

## Reporting

Close with a short summary: terms checked, changes applied by category, and anything left open. When the audit surfaced code that contradicts a confirmed term, list those separately as handoff items — they are the audit's most actionable output.
