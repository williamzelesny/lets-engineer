# Bootstrap: Mining a First Glossary

Loaded by `SKILL.md` at the start of Phase 1, on repos with no `CONTEXT.md` yet. Defines where candidate terms come from, how to rank them so the first glossary stays short, and the interview that resolves the contested ones.

**Aim for eight to fifteen terms.** A short glossary of sharp, contested terms gets read and gets used. A forty-term dump of every noun in the codebase gets skimmed once and rots. Rank hard, cut deep, and let the glossary grow later through Phase 2 as real arguments arise.

## Where candidate terms come from

Search the codebase before asking the user anything. Richest sources first:

- **Persistence and models.** Table names, model and entity classes, foreign keys. The schema is the project's most committed statement about its nouns.
- **States and lifecycles.** Enum values, status columns, state-machine transitions. A domain's joints are where its vocabulary is most precise and most contested.
- **Events and messages.** Published event names, queue and topic names, webhook payload types.
- **Module and directory names.** The top two levels of the source tree usually name the areas.
- **Test descriptions.** `it("user can checkout with valid cart")` states behaviour in domain language deliberately.
- **Human-written prose in the repo.** README, `docs/`, and — in a repo using this plugin — `docs/brainstorms/`, `docs/plans/`, `docs/solutions/`, and `docs/how-it-works/`. These carry the terms people actually say.
- **Recent history.** `git log` over the last few months surfaces the vocabulary currently in flux, which is where confusion concentrates.

## Ranking: confusion first

Score each candidate by how much trouble it is causing right now. Take the top of the list, not the whole list.

1. **One concept, several names.** `Customer` in the schema, `client` in the service layer, `account` in the UI copy. Highest value — the entry ends the argument and the `_Avoid_` line prevents its return.
2. **One name, several concepts.** `Account` meaning both the billing entity and the login. These cause real bugs, not just friction.
3. **Contested boundaries.** Two neighbouring concepts where nobody can state the line between them (`Order` vs `Quote`, `Cancellation` vs `Return`).
4. **Non-standard usage.** A word this project uses against its industry default, where an experienced newcomer would confidently assume wrong.
5. **Lifecycle states.** The values a core entity moves through, when their names are doing real work.

Drop everything else, and drop these outright: general programming vocabulary (retry, timeout, DTO, feature flag), framework nouns (controller, migration, middleware), and any term with one obvious meaning nobody has ever gotten wrong.

## The interview

**Triage first, in one pass.** Present the ranked candidates as a single short list with your read on each ("`Customer` / `client` / `account` all appear to mean the same party — worth pinning down?") and let the user strike the ones that do not matter. One round, not one question per term.

**Then resolve, one term at a time.** For each survivor:

- **Bring a draft, not a blank.** Propose a definition derived from the code, with the evidence: "The schema says a `Customer` owns orders and carries the billing address, while `users` holds credentials. Is Customer the billed party and User the authenticated one?" Editing a wrong draft is faster and more precise than composing from nothing.
- **Name the competitors.** List the synonyms in live use so the user can pick the winner explicitly. That choice becomes the `_Avoid_` line.
- **Probe the boundary with a scenario** when two terms sit close together. A concrete edge case forces a precision that an abstract question never will.
- **Keep their words.** Write the definition in the user's phrasing.

Write each term into `CONTEXT.md` as it resolves, following `context-format.md`. Do not hold them all to the end.

## Finishing the bootstrap

Write the file, report the term count and where it lives in one line, then continue into Phase 2 — the same conversation will keep producing terms, and they get captured the same way. Offer a decision record only if the bootstrap surfaced a choice meeting the bar in `decision-records.md`; a first glossary usually surfaces none.
