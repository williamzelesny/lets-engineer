# Walkthrough Template

The shape of the explanatory walkthrough Stage 2 produces: one document, two layers, visually separated.

> Render this in chat. It is a reader's orientation + teaching aid, not a review. Never include findings, severity ratings, or fix recommendations — `lets-code-review` owns critique.

## Skeleton

```
## Orientation

**What & why:** <1-2 sentences: what the change does and the intent behind it>

**Map:** <the areas/files touched and how they connect — group related files, name the seams>

**Read first:** <suggested reading order — where a reader should start, and why>

**Where to focus:** <load-bearing changes, the riskiest or most non-obvious parts, edge cases worth attention>

---

## How it works

<the teaching layer — prose, sub-headed by area when the change is large>
- Patterns used, and why they fit here
- The reasoning and trade-offs behind key decisions
- How the new code connects to existing structure (callers, callees, conventions it follows)

<optional: a small ASCII or mermaid diagram of control/data flow — only when it makes the change materially easier to grasp>
```

## Layering

Orientation comes first and stands alone — a reviewer who only needs to get oriented can stop after it. The teaching layer goes deeper for a reader who wants to understand how and why. There is no mode flag; the reader self-selects depth by how far they read.

## Depth scaling

Match length to the change:

- **Small** (a few files): a tight Orientation and a short How-it-works; usually no diagram.
- **Large** (many files / cross-cutting): keep Orientation concise by prioritizing reading order and the highest-attention areas; sub-head the teaching layer by area; add a diagram when the flow is hard to follow in prose.

Do not pad a small change to fill the skeleton, and do not let a large change bury the Orientation.

## Explain, don't critique

If the diff contains something that looks like a bug, explain what the code does and let the reader draw their own conclusions. Do not label defects, assign severity, or recommend fixes. If the reader wants critique, offer the `lets-code-review` handoff in Stage 3.
