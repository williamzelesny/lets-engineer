---
name: lets-model-domain
description: "Build and sharpen the project's shared domain language — capture terms in CONTEXT.md and consequential decisions as decision records under docs/decisions/. Use when a term is contested, overloaded, or fuzzy, when code and conversation disagree about a concept, when a hard-to-reverse decision gets made, or when asked to 'define our terms', 'write a glossary', 'name this properly', 'record this decision', or 'write an ADR'. Runs alongside brainstorming, planning, and design work rather than as a separate session."
argument-hint: "[optional: a term to resolve, a decision to record, or blank to work from the conversation]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Model the Domain

**Note: The current year is 2026.** Use this when dating decision records.

`lets-model-domain` builds the project's **shared language** and keeps it honest. It challenges contested terms as they come up, sharpens fuzzy ones into one canonical name, stress-tests concepts against concrete scenarios, and writes what settles into two artifacts: `CONTEXT.md` (the glossary) and `docs/decisions/` (the decisions a future reader will need explained). Precise shared vocabulary is compounding infrastructure — it makes every later prompt shorter, every plan less ambiguous, and every review sharper.

> **Model the language, not the implementation.** `CONTEXT.md` says what a term *means* to this project. How the concept is built, where its code lives, and how its flows run belong in `lets-document`. A glossary that drifts into implementation detail stops being loadable and becomes maintenance.

Two disciplines live here and fire at different moments:

- **Sharpen** — the live discipline, running *inside* a design conversation. This is where most of the value is.
- **Capture** — the write, at the instant a term or decision settles.

## When to Use

- A term is contested, overloaded, or means different things to different people (`account`, `user`, `cancellation`)
- Brainstorming or planning keeps circling a concept nobody has pinned down
- The conversation and the code disagree about how a concept behaves
- A hard-to-reverse decision just got made and a future reader will wonder why
- A repo has no glossary yet and the vocabulary lives only in people's heads
- The glossary has drifted — terms it defines no longer match the code that implements them

**Not for:** documenting how the system works (`lets-document`), writing up a solved problem (`lets-compound`), deciding what to build (`lets-brainstorm`), deciding how to build it (`lets-plan`), or critiquing code (`lets-review-code`).

## Interaction Method

Default to the platform's blocking question tool: `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_user` in Gemini, `ask_user` in Pi (requires the `pi-ask-user` extension). Fall back to numbered options in chat only when no blocking tool exists in the harness or the call errors (e.g., Codex edit modes) — not because a schema load is required. Never silently skip the question.

Ask one question at a time. Naming is the user's call; finding the facts that inform it is yours.

## Focus

<focus> #$ARGUMENTS </focus>

Interpret any argument as the thing to work on — a term to resolve (`cancellation`), a decision to record (`we're using event sourcing for orders`), or an area to audit (`billing`). With no argument, work from the current conversation.

## Core Principles

1. **The glossary is a glossary.** `CONTEXT.md` holds terms and what they mean. It is not a spec, a scratchpad, an architecture doc, or a home for decisions. Everything that is not "this word means this thing" belongs somewhere else.
2. **Capture at the moment of resolution.** Write the term down the turn it settles, mid-conversation. Batching them for the end loses the precision that made them worth recording.
3. **One name per concept, one concept per name.** Two words for one thing tax every reader. One word for two things produces bugs. When several words compete, pick one and list the rest as terms to avoid.
4. **Code is a witness, not the authority.** When the conversation and the code disagree about a concept, that contradiction is the finding — surface it and let the user settle which is right. Resolve it in the glossary; leave the code fix to `lets-work`.
5. **Hold decision records to the bar.** A decision earns a record only when it is hard to reverse, surprising without context, and the result of a real trade-off. Records that miss the bar dilute the ones that matter.
6. **Only this project's concepts.** General programming vocabulary (retries, timeouts, DTOs, feature flags) stays out, however heavily the project uses it. The test: would a competent engineer new to *this domain* need it explained?

## Execution Flow

### Phase 0: Locate the Model and Route

Find what already exists, using a file-search tool:

- `CONTEXT-MAP.md` at the repo root → multiple contexts; read it to find the one this work touches. Ask if it's unclear.
- `CONTEXT.md` at the repo root (or in the relevant subtree) → single context, already established.
- Neither → the model has not been started.

Then route, and announce the route in one line:

- **No `CONTEXT.md`, and `<focus>` is empty or an area** → **bootstrap** (Phase 1). "No glossary yet — let's build one from the codebase and your answers."
- **A live conversation, a contested term, or `<focus>` naming a term** → **sharpen** (Phase 2). This is the default whenever a glossary exists.
- **`<focus>` describes a decision already made** → skip to **capture** (Phase 3), decision-record half.
- **An explicit audit request, or a glossary you can see contradicts the code** → **audit** (Phase 4).

Create files lazily. A repo with nothing to say yet gets no empty `CONTEXT.md`.

### Phase 1: Bootstrap the Glossary

Read `references/bootstrap.md`. This load is non-optional — the term-mining strategy, the ranking rule that keeps the first glossary short, and the interview shape live there.

Mine the codebase for candidate terms, rank them by how much confusion each one is causing, interview the user on the contested ones only, and write the first `CONTEXT.md`. A first glossary of eight sharp terms beats forty vague ones. Then continue into Phase 2 for the rest of the session.

### Phase 2: Sharpen the Language

The live discipline. Four moves, applied whenever the conversation touches a domain concept:

- **Challenge against the glossary.** When a term the user just used conflicts with its `CONTEXT.md` definition, say so immediately and name both readings: "The glossary defines *cancellation* as voiding an unshipped order, but you're describing a refund after delivery. Which is it — or is one of these a new term?"
- **Sharpen fuzzy language.** When a term is vague or carries two concepts, propose a precise canonical name: "You're saying *account* — do you mean the **Customer** (who pays) or the **User** (who signs in)? Those have different lifecycles."
- **Stress-test with concrete scenarios.** When a relationship between concepts is being described, invent a specific case that probes its edge and forces precision: "A customer cancels one of three line items after the order ships. Is that a partial **Cancellation**, a **Return**, or something with no name yet?"
- **Cross-reference against the code.** When the user states how a concept behaves, check whether the code agrees, then surface any contradiction: "Your code cancels whole `Order` records with no line-item path, but you just described partial cancellation. Which one is the target?"

Search the code before asking. Finding facts is your job; deciding names is the user's.

### Phase 3: Capture

**Terms → `CONTEXT.md`, inline.** Read `references/context-format.md` — it holds the entry shape, the `_Avoid_` convention, the grouping rule, and the single-vs-multi-context layout. Write each term the turn it resolves, in the user's own chosen wording, and say in one line what you wrote.

**Decisions → `docs/decisions/`, at the bar.** Read `references/decision-records.md` — it holds the three-part bar, the template, sequential numbering, and what qualifies. Offer a record only when all three tests pass; when one fails, say which and move on rather than writing a record nobody will need. Keep records out of `CONTEXT.md`: the glossary defines words, records explain choices.

### Phase 4: Audit for Drift

Read `references/drift-audit.md`. This load is non-optional — the drift categories, the code-versus-glossary reconciliation procedure, and the rule for retiring dead terms live there.

Check every glossary term against the code that implements it, classify each mismatch (renamed, split, merged, dead, or never-implemented), and bring them to the user grouped by kind. Preserve the user's wording on every term that survives; delete only what they confirm is dead.

### Phase 5: Handoff

Report what changed in one or two lines — terms added or sharpened, records written. Then offer the natural next step:

- Terms settled and the work is ready to scope → `lets-brainstorm` or `lets-plan`, which inherit the vocabulary
- A contradiction surfaced between code and glossary that the code should lose → `lets-work`
- The concept is clear but its mechanics are not written down anywhere → `lets-document`

## How Other Skills Use This

`CONTEXT.md` is a shared asset, so name it when handing off. Any skill that names things — `lets-brainstorm`, `lets-plan`, `lets-work`, `lets-review-code` — should read it for vocabulary and match it in what they write. Reading the glossary is a one-line habit, not a reason to invoke this skill; invoke it when the model is *changing*.

## What This Skill Does Not Do

- Does not rename code. It resolves the language and hands contradictions to `lets-work`.
- Does not document architecture, flows, or business process (`lets-document`) — `CONTEXT.md` stays free of implementation.
- Does not record every decision made. The bar is deliberate and most decisions fail it.
- Does not maintain a decision index, status workflow, or supersession chain beyond a `superseded by` note.
- Does not define general programming vocabulary, however often the project uses it.

## Learn More

The reason a glossary pays for itself with agents is compression: once `Fulfillment` means exactly one thing across your prompts, your docs, and your code, a two-word phrase carries a paragraph of shared context — and a term used against its definition becomes a visible error instead of a silent misunderstanding. The three-part bar in `references/decision-records.md` protects the other half of that: a decisions directory stays worth reading only while every file in it earned its place.
