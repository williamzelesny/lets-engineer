# Targeted Interview

Loaded by `SKILL.md` at the start of Phase 2, after the codebase draft exists. This phase captures what code cannot reveal — the **why** — and produces the doc's `authored` regions.

The interview is gap-driven, not a fixed questionnaire. Most of it is the open "why" questions the Phase 1 draft raised; a few standing prompts catch what the draft didn't think to ask.

## Overall Rules

1. **Ask only what the code couldn't tell you.** Never re-ask something the draft already established. If the draft shows that orders go through a `FraudCheck` service, do not ask "is there a fraud check?" — ask "why does fraud check run before payment capture rather than after?" Re-asking what the code showed wastes the user's time and signals the draft wasn't read.
2. **One question at a time.** Ask, wait, capture, move on. Stacking questions produces thin answers. Use the platform's blocking question tool (see SKILL.md Interaction Method) — usually free-form, since "why" answers are narrative.
3. **Push back once, maybe twice — then capture and move on.** If an answer is too thin to document ("because it's better that way"), name the gap and ask a sharper question. If the second answer is still thin, capture what you have, mark the section as worth revisiting, and continue. Do not let the interview spiral.
4. **Capture in the user's own words.** The authored regions should sound like the person who knows the system, not like generic PM-speak. Quote them; don't paraphrase the texture out.
5. **Keep answers tight.** One to three sentences per point. If the user writes a paragraph, ask which sentence is load-bearing.

## What to ask about

Work through the open "why" questions the draft raised first — these are the highest-value because the code surfaced them and couldn't answer them. Then, for the topic as a whole, probe the standing gaps that matter for understanding how the system works:

- **Rationale** — why is it built this way rather than the obvious alternative? What decision is encoded here that a newcomer would otherwise have to reverse-engineer or get wrong?
- **Business process** — what real-world process or domain rule does this implement? Who or what depends on it behaving exactly this way? (This is the half most likely to live only in someone's head.)
- **Constraints** — what can't change, and why? External contracts, regulatory or financial rules, ordering guarantees, things that look removable but aren't.
- **History** — only when it still governs the present: a past incident, migration, or decision that explains why the code is shaped the way it is. Skip nostalgia; capture only what a maintainer needs to not break it.

Not every prompt applies to every topic. Ask the ones the topic actually raises. A pure-mechanism subsystem may need only rationale; a billing or fulfillment flow may need all four.

## Pushback examples

Name the gap, then ask the sharper question. Do not lecture.

- **Restates the code as the reason** ("we call the fraud service because we need fraud checks") → "The draft already has that. *Why here* — why before payment capture instead of after? What goes wrong if it runs later?"
- **Asserts without the rule** ("orders can't be split") → "What's the rule behind that — a fulfillment constraint, a billing one, a promise to the customer? What breaks if an order is split?"
- **Vague value claim** ("this approach is cleaner") → "Cleaner in what way that a reader should know? What did the alternative cost that made you choose this?"
- **History with no live consequence** ("we rewrote this in 2024") → "Does that still constrain anything today? If a contributor doesn't know about the rewrite, what would they get wrong?"

## After the interview

Hand the captured answers to Phase 3 (`output-format.md`), which places them in the doc's `authored` regions — kept verbatim across future refreshes. If any section stayed thin after pushback, note it in the doc as an open question so the next person (or the next refresh) knows it's worth revisiting; do not invent a confident answer to fill the gap.
