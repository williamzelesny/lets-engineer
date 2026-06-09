# Refresh In Place

Loaded by `SKILL.md` at the start of Phase 4, when a doc already exists for the topic. Refresh keeps the code-derived content current **without ever losing what a human wrote**. The marker convention from `output-format.md` is what makes this possible — read that first if the markers aren't fresh in mind.

The governing rule: **match the doc to reality, and avoid low-value churn.** A refresh that rewrites prose nothing in the code changed is a regression, not an update.

## Step 1: Marker integrity first

Before touching anything, check that the existing doc's provenance markers are intact — every `generated` and `authored` region is a matched, well-formed pair.

- **Markers intact** → continue to Step 2.
- **Markers missing or malformed** (hand-stripped, mangled by a merge, or removed by a comment-stripping formatter) → **do not regenerate in place.** You can no longer tell which content is safe to overwrite. Treat the whole file as authored, surface the situation to the user via the blocking question tool, and let them decide (re-mark by hand, or have you re-document from scratch). Never re-derive markers over content you can't attribute — that is exactly how human-authored text gets silently clobbered.

## Step 2: Re-read sources and detect drift

For each `generated` region, re-read the doc's `sources` and re-derive what that region should say, with the same verify-before-claiming discipline as the first draft (`codebase-research.md`).

**Drift means a change in code facts, not a change in wording.** Regeneration is non-deterministic — re-drafting unchanged code produces differently-worded but equivalent prose. Compare the **structural facts** (components, flows, boundaries, source paths), not the sentences:

- **No fact changed** → no-write for that region. Leave it exactly as it is. This is what makes no-churn real; do not rewrite a region just because you'd phrase it differently today.
- **Facts changed** → that region is a regeneration candidate; continue to Step 3 before writing it.

`authored` regions are never re-derived and never drift-checked — they are preserved verbatim, full stop.

## Step 3: Detect conflicts before overwriting

A regenerated `generated` region can carry a new fact that contradicts a claim a human wrote in an adjacent `authored` region — e.g., the code now splits orders, but the authored "Business process" says orders are never split.

For each region you're about to regenerate, check whether any new code fact contradicts an adjacent authored claim. If it does:

- **Do not silently overwrite.** Name the specific authored sentence and the contradicting code fact, and surface the conflict to the user via the blocking question tool (e.g., "Code now does X; your note says Y — update the note, keep it, or flag it?").
- Apply the regeneration only after the user resolves it. The authored text is theirs to change; you flag, you don't decide.

## Step 4: Human-edit safeguard

If a `generated` region contains prose the code draft would not produce — a "why" paragraph a contributor added inside it, not seeing the boundary — **surface it, don't discard it.** Offer to move it into an adjacent `authored` region. Regenerating over it would destroy exactly the human content this skill exists to protect.

## Step 5: Write and update the index

When regenerations are resolved:

- Write only the regions whose facts changed; preserve everything else (all authored regions, all unchanged generated regions) byte-for-byte.
- Bump `last_updated` to today's ISO date **only if you wrote something.** A pure no-op refresh leaves the file untouched, including `last_updated`.
- If the topic's one-line summary changed, update its entry in `docs/how-it-works/index.md`; otherwise leave the index alone.

## After refresh

Report what changed in one or two lines — which regions were updated, any conflict surfaced, or "no code-fact changes — doc already current." Don't narrate the unchanged regions.
