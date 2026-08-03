---
name: lets-document
description: "Document how an application works — its architecture, functionality, and business processes — as durable in-repo reference for teammates and contributors. Use when asked to 'document the architecture', 'write docs for this subsystem', 'explain how X works for the team', 'document our order/billing/auth process', or to produce onboarding docs people can read to understand the codebase. Name a topic for one focused doc, or omit one for a whole-app survey. Documents the system as it currently stands — not a change (lets-explain) or a solved problem (lets-compound)."
argument-hint: "[topic to document, e.g. 'billing' or 'order fulfillment'; blank for a full-app survey]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Document How It Works

**Note: The current year is 2026.** Use this when dating generated docs.

`lets-document` produces and maintains durable markdown that explains **how an application works** — its architecture, what it does, and the business processes behind it — for teammates and contributors learning the system. It reads the codebase to draft what code can show, interviews you for the intent and "why" that code cannot show, and writes per-topic docs plus a maintained index under `docs/how-it-works/`. Re-running refreshes a doc in place.

> **Document the system as it stands — not the change, not the fix.** A doc here answers "how does this work, and why is it built this way?" for someone new to it. It is not a walkthrough of a diff or PR (that is `lets-explain`), and it is not a write-up of a problem you just solved (that is `lets-compound`).

## When to Use

- Documenting the architecture of a system, or a specific subsystem, for the team
- Capturing a business process — the domain rules and the "why" — that lives in people's heads
- Producing onboarding reference a new contributor can read to understand how the app functions
- Keeping an existing how-it-works doc current as the code evolves (re-run to refresh)

**Not for:** explaining a change you didn't write (`lets-explain`), capturing a recently solved problem (`lets-compound`), critiquing code (`lets-review-code`), or product requirements and plans (`lets-brainstorm`, `lets-plan`).

## Interaction Method

Default to the platform's blocking question tool: `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_user` in Gemini, `ask_user` in Pi (requires the `pi-ask-user` extension). Fall back to numbered options in chat only when no blocking tool exists in the harness or the call errors (e.g., Codex edit modes) — not because a schema load is required. Never silently skip the question.

Ask one question at a time. The interview is targeted: ask only about what the code could not reveal, never re-asking what the draft already established.

## Topic

<topic> #$ARGUMENTS </topic>

Interpret any argument as the topic to document — a subsystem (`billing`), a feature (`checkout`), or a business process (`order fulfillment`). With no argument, produce a whole-application survey.

## Core Principles

1. **Code is the source of truth for structure; you are the source of truth for "why".** Architecture and functionality are drafted from the code and verified against it. Rationale, process context, and constraints come from the interview. Keep the two clearly separated in the doc.
2. **Verify before claiming.** Every structural claim — a component, a flow, a boundary — must be grounded in actual source, not guessed. If you cannot ground it, leave it out or mark it open. Hallucinated architecture is worse than a gap.
3. **Teaching depth, not a terse reference.** Write for a contributor learning the system: explain how it works and why, in plain language. A reader should come away able to explain the topic, not just look up a name.
4. **Refresh, don't churn.** On a re-run, update only what the code's facts changed. Preserve every word the human wrote. Never silently overwrite an authored section — surface a conflict instead.
5. **Repo-relative paths only.** Every path in a generated doc is relative to the repo root (e.g., `app/services/billing.rb`), never absolute. Absolute paths break portability across machines and teammates.

## Execution Flow

### Phase 0: Route by Scope and File State

Parse `<topic>`, then route:

- **No topic** → **survey mode.** Document the whole application: an architecture overview plus the major subsystems and flows. Go to Phase 1, then write the overview into the index (Phase 3). Survey writes the overview + index only — it does not seed per-subsystem stubs.
- **Topic given, no existing doc** at `docs/how-it-works/<topic-kebab>.md` → **new doc.** Go to Phase 1.
- **Topic given, doc already exists** → **refresh.** Go to Phase 4.

Use a file-search tool (Glob) to check for the existing doc. Announce the path in one line: e.g., "No doc for `billing` yet — drafting a new one." / "Found `docs/how-it-works/billing.md` — refreshing it." / "No topic given — surveying the whole app."

### Phase 1: Draft from the Codebase

Read `references/codebase-research.md`. This load is non-optional — the scoping rules (topic vs survey), the verify-before-claiming discipline, and the mermaid guidance live there.

Read the relevant source and draft the **code-derived** content: architecture (components, boundaries), functionality (key flows), with diagrams where they aid understanding. This becomes the `generated` regions of the doc.

### Phase 2: Targeted Interview

Read `references/interview.md`. This load is non-optional — the one-question-at-a-time discipline, the pushback rule, and the "don't re-ask what the code showed" rule live there.

Interview the user for what code could not reveal — business rationale, process context, constraints, the reasons behind decisions. Capture answers in the user's own language. This becomes the `authored` regions of the doc.

### Phase 3: Write the Doc and Update the Index

Read `references/output-format.md`. This load is non-optional — the per-topic doc template, the provenance-marker convention, the index template, and the path/naming/frontmatter rules live there.

Write the per-topic doc to `docs/how-it-works/<topic-kebab>.md` (create the directory on demand) with code-derived and authored sections each wrapped in their provenance markers, and update `docs/how-it-works/index.md` so the new doc is linked. In survey mode, write the overview into `index.md`. Present what was written in one or two lines.

### Phase 4: Refresh an Existing Doc

Read `references/refresh.md`. This load is non-optional — the marker-integrity check, the drift-is-a-code-fact-change rule, the conflict-detection-and-surfacing contract, and the human-edit safeguard live there.

Check marker integrity, re-read the current source, regenerate only the `generated` regions whose code facts changed, preserve every `authored` region verbatim, surface any conflict or marker-integrity failure to the user, bump `last_updated` if anything was rewritten, and update the index entry if the summary changed.

### Phase 5: Handoff

Note where the doc lives in one line. Offer the natural next step: document another topic, run a survey if none exists yet, or — if the reader now wants to understand a recent *change* rather than the system as a whole — point to `lets-explain`.

## What This Skill Does Not Do

- Does not track staleness or auto-refresh. Refresh is user-initiated; there is no manifest or drift watcher (that overlaps `lets-refresh-learnings`).
- Does not publish to an external doc site, wiki, or hosted portal. Output is in-repo markdown only.
- Does not generate API reference from code annotations or docstrings.
- Does not document changes/diffs (`lets-explain`) or solved problems (`lets-compound`).
- Does not author the target app's README or changelog, and does not run on commit or in CI.

## Learn More

The split between code-derived structure and human-authored "why" is the core idea: architecture and flows are recoverable from source and kept honest by verification, while the rationale and business process behind them are not in the code at all and must be captured from the people who hold them. The provenance markers in `references/output-format.md` are what let a refresh keep both halves trustworthy over time.
