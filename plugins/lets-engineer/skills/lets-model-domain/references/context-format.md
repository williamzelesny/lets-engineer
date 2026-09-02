# CONTEXT.md Format: Entries, Layout, and Scope

Loaded by `SKILL.md` at the start of Phase 3. Defines the glossary's entry shape, the conventions that keep it opinionated, and how the file is laid out in single- and multi-context repos. `drift-audit.md` reconciles against this shape — keep them in sync.

## Where the glossary lives

- **Single context (most repos):** one `CONTEXT.md` at the repo root.
- **Multiple contexts:** a `CONTEXT-MAP.md` at the repo root naming each context, where its own `CONTEXT.md` lives, and how the contexts relate.
- Create either one lazily — on the first term that resolves, never in advance.

## Entry shape

~~~markdown
# {Project or Context Name}

{One or two sentences: what this context covers and where its boundary sits.}

## Language

**Order**
A customer's committed request for goods at agreed prices. Exists from checkout until every line item is fulfilled or cancelled.
_Avoid_: purchase, transaction, cart

**Cancellation**
The voiding of one or more unshipped line items on an Order. Distinct from a Return, which applies after delivery.
_Avoid_: void, refund

**Customer**
The party that owns an Order and is billed for it. Distinct from a User, who authenticates.
_Avoid_: client, buyer, account
~~~

## Rules for entries

- **Define what it *is*, not what it does.** "A committed request for goods" is a definition; "handles checkout and validates stock" is a job description that will go stale.
- **One or two sentences.** A definition that needs a paragraph is usually two concepts wearing one name — split it.
- **Be opinionated with `_Avoid_`.** When several words compete for a concept, name the winner and list the losers. This is the line that stops the drift, so include it whenever a rejected synonym is in live use.
- **Draw the distinction that was contested.** When a term earned its entry by being confused with a neighbour, say so in the definition ("Distinct from a Return, which applies after delivery"). The contrast is usually the whole reason the entry exists.
- **Keep implementation out.** No file paths, class names, table names, endpoints, library choices, or flow descriptions. Those live in `lets-document` output. A glossary entry survives a rewrite of the code it describes.
- **Group under subheadings** once natural clusters appear (`## Ordering`, `## Billing`). A flat `## Language` list is right until roughly a dozen terms.
- **Use the user's chosen wording.** When they pick a name or phrase a definition, keep their words rather than polishing them into your own.

## What earns an entry

A term belongs when a competent engineer new to *this domain* would need it explained, and when getting it wrong would cost something. That means:

- Concepts with contested or overloaded names — the ones that started an argument
- Concepts whose boundary against a neighbour is subtle (`Order` vs `Quote`, `Cancellation` vs `Return`)
- Domain nouns the code already uses inconsistently
- Terms this project uses in a non-standard sense, where the industry default would mislead

It does not belong when it is general programming vocabulary (retry, timeout, DTO, feature flag, idempotency), an implementation artifact (a service name, a queue name), or a term with exactly one obvious meaning nobody has ever gotten wrong.

## CONTEXT-MAP.md

~~~markdown
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md): receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md): generates invoices and takes payment
- [Fulfillment](./src/fulfillment/CONTEXT.md): warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced`; Fulfillment consumes it to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched`; Billing invoices against it
- **Ordering ↔ Billing**: share `CustomerId` and `Money`
~~~

Reach for a map only once a second context genuinely exists — a distinct area with its own vocabulary, where the same word means different things on either side. A single team's repo almost always stays single-context. When a term means one thing in Ordering and another in Billing, that is the signal to split, and both definitions then say which context they belong to.
