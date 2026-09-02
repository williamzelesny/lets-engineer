# Decision Records: The Bar, the Template, and What Qualifies

Loaded by `SKILL.md` in Phase 3 before offering a record. Defines when a decision earns a file, what goes in it, and how records are numbered. The bar is the point of this reference — a decisions directory is worth reading only while every file in it earned its place.

Records live in `docs/decisions/`, created lazily on the first one. They are architecture decision records (ADRs) in the usual sense; this repo calls the directory `docs/decisions/` to match its other plain-named doc homes.

## The bar

Offer a record only when **all three** are true:

1. **Hard to reverse.** Changing your mind later costs real time or migration risk. An easily reversed decision needs no record — you will simply reverse it.
2. **Surprising without context.** A future reader looking at the code will ask "why on earth was it done this way?" If the choice is the obvious one, nobody will wonder.
3. **The result of a real trade-off.** Genuine alternatives existed and you picked one for stated reasons. Without an alternative there is nothing to record beyond "we did the obvious thing."

When a decision misses the bar, name the test it failed in one line and move on. Do not write the record anyway.

## Template

~~~markdown
# {Short title naming the decision}

{One to three sentences: the context, what was decided, and why.}
~~~

That is the whole requirement. A record can be a single paragraph. The value is in preserving *that* a choice was made and *why*, not in filling out sections.

Add these only when they carry weight the paragraph cannot:

- **`status` frontmatter** (`proposed` / `accepted` / `deprecated` / `superseded by NNNN`) — when a decision is likely to be revisited
- **Considered options** — when the rejected alternatives are the part worth remembering
- **Consequences** — when a downstream effect is non-obvious and someone will trip on it

## Numbering and naming

- Scan `docs/decisions/` for the highest existing number and increment: `0001-slug.md`, `0002-slug.md`.
- Slug the title in kebab-case: `0003-event-sourced-order-write-model.md`.
- Date the record in its body or frontmatter using the current year noted in `SKILL.md`.
- Never renumber existing records. A superseded decision keeps its number and gains a `superseded by` note; the record that replaces it takes the next number and links back.

## What qualifies

- **Architectural shape.** "The write model is event-sourced; reads are projected into Postgres."
- **Integration patterns between areas.** "Ordering and Billing communicate by domain events, never synchronous HTTP."
- **Technology choices carrying lock-in.** Database, message bus, auth provider, deployment target — the ones that would take a quarter to swap, not every library.
- **Boundary and ownership decisions.** "Customer data is owned by the Customer context; everything else references it by ID." The explicit *no* is as valuable as the yes.
- **Deliberate deviations from the obvious path.** "Hand-written SQL instead of the ORM, because of the reporting query shapes." These stop the next engineer from "fixing" something intentional.
- **Constraints invisible in the code.** Compliance rules, partner SLAs, contractual response-time limits.
- **Non-obvious rejections.** If GraphQL was considered and REST won for subtle reasons, record it — otherwise GraphQL gets proposed again in six months.

## Boundaries against neighbouring artifacts

- A **decision record** captures a choice and its trade-off. A **`CONTEXT.md` entry** captures what a word means. When a decision also settles a term, write both — the record explains the choice, the glossary carries the name.
- A **learning** (`lets-compound`) captures a problem you solved and how. A record captures a fork you chose between. When a debugging session ends in an architectural commitment, both are appropriate.
- A **plan** (`lets-plan`) captures what will be built next and goes stale by design once built. A record outlives the work. When a plan contains a decision that meets the bar, lift it into a record so it survives the plan's archive.
