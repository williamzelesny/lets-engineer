# Output Format: Doc Template, Markers, and Index

Loaded by `SKILL.md` at the start of Phase 3. Defines the per-topic doc shape, the **provenance markers** that make refresh safe, the maintained index, and the path/naming rules. The marker convention here is what `refresh.md` relies on — keep them in sync.

## Where docs live

- Home: `docs/how-it-works/` (create on demand with `mkdir -p`).
- Per-topic doc: `docs/how-it-works/<topic-kebab>.md` — kebab-case the topic (`order fulfillment` → `order-fulfillment.md`).
- Index: `docs/how-it-works/index.md` — the maintained overview that links every per-topic doc.
- All file references **inside** a generated doc are repo-relative (`app/services/billing.rb`), never absolute.

## Provenance markers — the core convention

Each section is individually wrapped in a paired HTML-comment marker declaring who owns it:

- **`generated`** — code-derived content (architecture, flows). A refresh may regenerate this region from current source.
- **`authored`** — human-captured content (the "why", business process, constraints). A refresh **never** touches this region; it is preserved verbatim.

```
<!-- lets-document:generated -->
... code-derived section(s) ...
<!-- /lets-document:generated -->

<!-- lets-document:authored -->
... human-authored section(s) ...
<!-- /lets-document:authored -->
```

Rules that make this work:

- **Per-section, not two big blocks.** Wrap each section (or small run of same-kind sections) in its own marker pair so `generated` and `authored` can **alternate** through the doc — architecture, then its "why", then the next flow, then its rules. Teaching depth wants the "why" next to what it explains; do not segregate all authored content to the bottom.
- **Every marker is paired.** An open `<!-- lets-document:generated -->` always has a matching `<!-- /lets-document:generated -->`. Refresh keys off intact pairs; an unmatched marker is treated as a marker-integrity failure (see `refresh.md`).
- **Markers wrap headings and their content**, so a whole section moves as a unit.
- **Visible boundary cue on generated sections.** Immediately under each generated section's heading, add a one-line italic caption so someone editing the rendered doc knows not to write there:

  `_Code-derived — regenerated on refresh. Add your own notes in an authored section so they're preserved._`

  Authored sections need no caption (preserved is the safe default), but you may add `_Authored — preserved across refreshes._` when a doc mixes many sections and the distinction helps.

## Frontmatter

```yaml
---
topic: order-fulfillment
date: 2026-06-09          # first authored
last_updated: 2026-06-09  # bumped by refresh when it writes
sources:                  # repo-relative paths the generated regions were drafted from
  - app/services/fulfillment
  - app/models/order.rb
---
```

- `sources` tells a refresh what to re-read; keep it accurate when the documented code moves.
- YAML safety: quote any array item that begins with a reserved indicator (`` ` [ * & ! | > % @ ? ``) or contains `": "`. Plain paths don't need quoting; unusual ones do.

## Per-topic doc template

The block below is the shape to write. Replace placeholders; alternate `generated` and `authored` sections as the topic needs. Drop sections that don't apply.

~~~markdown
---
topic: {{topic-kebab}}
date: {{YYYY-MM-DD}}
last_updated: {{YYYY-MM-DD}}
sources:
  - {{repo-relative path}}
---

# {{Topic Title}}

<!-- lets-document:authored -->
## What this is

_Authored — preserved across refreshes._

{{One or two sentences: what this subsystem/process is and the job it does. From the interview, in the user's words.}}
<!-- /lets-document:authored -->

<!-- lets-document:generated -->
## Architecture

_Code-derived — regenerated on refresh. Add your own notes in an authored section so they're preserved._

{{Components, responsibilities, boundaries — grounded in source. Mermaid diagram if it aids understanding.}}
<!-- /lets-document:generated -->

<!-- lets-document:authored -->
## Why it's built this way

{{Rationale and constraints from the interview — the decisions a newcomer would otherwise get wrong.}}
<!-- /lets-document:authored -->

<!-- lets-document:generated -->
## How it works

_Code-derived — regenerated on refresh. Add your own notes in an authored section so they're preserved._

{{The key flow(s): trigger → steps → outcome, teaching depth. Diagram if it helps.}}
<!-- /lets-document:generated -->

<!-- lets-document:authored -->
## Business process

{{The real-world process / domain rules this implements, and who depends on it behaving this way. From the interview.}}

## Open questions

{{Anything the interview left thin — so the next refresh knows to revisit it. Delete if none.}}
<!-- /lets-document:authored -->
~~~

In **survey mode** there is no per-topic file — the overview goes straight into `index.md` (below).

## Index template

`docs/how-it-works/index.md` is the navigable map. It carries a short, code-derived architecture overview (survey mode writes this) plus a linked entry per topic doc.

~~~markdown
---
topic: index
date: {{YYYY-MM-DD}}
last_updated: {{YYYY-MM-DD}}
---

# How {{Project}} Works

<!-- lets-document:generated -->
## Overview

_Code-derived — regenerated on refresh._

{{Architecture overview: top-level components and the request/data lifecycle. Written by survey mode; refreshed from source.}}
<!-- /lets-document:generated -->

## Topics

- [{{Topic Title}}](./{{topic-kebab}}.md) — {{one-line summary}}
<!-- Add one line per topic doc. Keep summaries to a single line. -->
~~~

When a per-topic doc is written or refreshed, add or update its line in the `## Topics` list. Update its one-line summary only when the topic's summary actually changed (avoid churn).

## Post-write checklist

Before confirming the write:

- [ ] Every marker is paired — no orphan `generated`/`authored` open or close.
- [ ] `generated` and `authored` sections are split by ownership (no human prose inside a `generated` region, no code-derived claims inside an `authored` region).
- [ ] Every generated section carries the visible boundary cue.
- [ ] Every structural claim in a `generated` section is grounded in a `sources` path (verify-before-claiming).
- [ ] All in-doc file references are repo-relative, not absolute.
- [ ] Frontmatter present with `topic`, `date`, `last_updated`, `sources`; `last_updated` is today's ISO date.
- [ ] The index `## Topics` list links this doc.
- [ ] No placeholders (`{{...}}`) remain.
