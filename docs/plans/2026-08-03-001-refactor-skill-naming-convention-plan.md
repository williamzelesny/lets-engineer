---
title: "refactor: Rename workflow skills to lets-<action> convention"
type: refactor
status: completed
date: 2026-08-03
origin: docs/brainstorms/2026-08-03-skill-naming-convention-requirements.md
---

# refactor: Rename workflow skills to `lets-<action>` convention

## Summary

Rename ten workflow skill directories and their frontmatter names, then update every textual reference to them across the plugin and README. The work lands in four dependency-ordered units: directory renames first, then in-plugin cross-references, then user-facing docs, then version bump and a verification sweep that proves no stale reference survives.

---

## Problem Frame

Twelve of the plugin's 27 skills are noun-shaped and don't complete the sentence the `lets-` prefix sets up — `lets-code-review` expands to *"let's code review."* The origin document establishes which ten get renamed and why two are exempt (see `docs/brainstorms/2026-08-03-skill-naming-convention-requirements.md`).

The plan-specific problem is different from the naming problem: skill names are plain text scattered across 39 files with no compiler, no test suite, and no reference-resolution mechanism to catch a miss. A missed reference doesn't fail loudly — it produces a skill instructing the agent to invoke a command that no longer exists. Verification therefore has to be exhaustive rather than spot-checked.

---

## Requirements

- R1. Skills a user invokes are named `lets-<verb>` or `lets-<verb>-<object>`, completing *"let's ___"*.
- R2. Style/reference skills (`lets-dhh-rails-style`, `lets-agent-native-architecture`) stay noun-shaped.
- R3. Agent personas under `plugins/lets-engineer/agents/` are exempt.
- R4. The convention and its exemption classes are documented in the README.
- R5. Ten workflow skills are renamed per the mapping table below.
- R6. Directory name and `SKILL.md` frontmatter `name:` change together and stay identical.
- R7. Every in-repo textual reference is updated.
- R8. No renamed skill is referenced by directory path from outside itself.
- R9. Intra-skill script and reference paths stay relative.
- R10. No old-name reference remains outside `docs/brainstorms/` and `docs/plans/`.
- R11. Terms dropped from names (`worktree`, `gemini`, `product`) remain present in the skill's `description`.
- R12. README pipeline diagram, skill tables, and artifact list are updated.
- R13. No compatibility stubs or alias directories.
- R14. Version bumped in both `plugins/lets-engineer/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
- R15. Dated artifacts under `docs/brainstorms/` and `docs/plans/` are not rewritten.

**Origin acceptance examples:** AE1 (covers R11), AE2 (covers R9), AE3 (covers R7, R10), AE4 (covers R13)

### Rename mapping

| Current | New |
|---|---|
| `lets-code-review` | `lets-review-code` |
| `lets-doc-review` | `lets-review-docs` |
| `lets-frontend-design` | `lets-design-frontend` |
| `lets-product-pulse` | `lets-take-pulse` |
| `lets-demo-reel` | `lets-record-demo` |
| `lets-sessions` | `lets-search-sessions` |
| `lets-strategy` | `lets-strategize` |
| `lets-worktree` | `lets-branch-off` |
| `lets-gemini-imagegen` | `lets-generate-images` |
| `lets-compound-refresh` | `lets-refresh-learnings` |

---

## Scope Boundaries

- The 46 agent personas are not renamed — only the three agent files that *reference* renamed skills are edited.
- `lets-dhh-rails-style` and `lets-agent-native-architecture` are not renamed.
- The 15 skills already passing the sentence test are not renamed, including `lets-setup` and `lets-update`.
- Plugin name, marketplace name, and repository name are unchanged.
- No compatibility layer, alias mechanism, or migration tooling.
- Skill *content* is not revised — this is a naming change only.
- Script *filenames* inside renamed skills (e.g. `worktree-manager.sh`, `capture-demo.py`) are not renamed; they are internal and unreferenced from outside their skill.

---

## Context & Research

### Relevant Code and Patterns

- `plugins/lets-engineer/skills/*/SKILL.md` — frontmatter carries `name:`, `description:`, optional `argument-hint:`. The `name:` must match the directory name.
- `plugins/lets-engineer/skills/lets-worktree/SKILL.md` — invokes its script as `"${CLAUDE_SKILL_DIR:-.}/scripts/worktree-manager.sh"`. This is the most path-sensitive skill in the set and it is still directory-relative, confirming R9 holds by construction.
- `plugins/lets-engineer/skills/lets-demo-reel/`, `lets-sessions/`, `lets-compound-refresh/` — invoke scripts as bare `scripts/<name>.py`, also directory-relative.
- `README.md` lines 16 and 20 — mermaid node *labels* carry skill names; node *IDs* (`strategy`, `review`) are internal and need not change, though aligning them reads better.
- `.claude-plugin/marketplace.json` and `plugins/lets-engineer/.claude-plugin/plugin.json` — both carry a `version` field, currently `0.3.0`. The `"code-review"` entry in plugin.json `keywords` is a marketplace topic tag, not a skill reference.

### Institutional Learnings

- `docs/solutions/` does not exist in this repo — no prior learnings to draw on.
- Repo convention (carried from prior work): every content merge to main bumps the version in *both* manifests, or `/lets-update` reports "up to date" and never fetches the change.

### Verified Findings

- **Plugin cache is version-scoped.** `~/.claude/plugins/cache/lets-engineer/lets-engineer/` contains a single `0.3.0/` directory despite two prior version bumps, indicating the cache replaces rather than accumulates. Old skill directories therefore disappear on update, and the clean break needs no cleanup step.
- **No substring collisions.** No new name contains an old name; no old name nests inside another old name. Near-misses that would break a careless prefix match — `lets-code-simplicity-reviewer`, `lets-document`, `lets-session-historian`, `lets-product-lens-reviewer`, and `lets-compound` inside `lets-compound-refresh` — are all safe under full-name matching.
- **One non-reference occurrence.** `lets-sessions` appears three times in `plugins/lets-engineer/skills/lets-sessions/SKILL.md` as a `mktemp -d -t lets-sessions-XXXXXX` prefix and in illustrative temp paths. This is not a skill reference and carries no linkage risk.
- **R11 is verify-only.** All three descriptions already contain their dropped term: `lets-worktree` ("isolated git worktree"), `lets-gemini-imagegen` ("the Gemini API"), `lets-product-pulse` ("how the product performed"). No description edits are needed to satisfy R11.
- **Reference surface is 39 files** outside `docs/`, concentrated in `lets-code-review` (96 references) and `lets-doc-review` (38).

---

## Key Technical Decisions

- **`git mv` for directory renames, not delete-and-recreate**: preserves rename detection in history, so `git log --follow` still works on skill files and the diff reads as 10 renames rather than 27 deletions and 27 additions.
- **Full-name anchored replacement, longest-name-first**: the only nesting in the set is `lets-compound` inside `lets-compound-refresh`, and `lets-compound` is not being renamed — so ordering is not load-bearing here. Anchoring on the full name is what makes it safe, and longest-first is cheap insurance if the rename set is ever extended.
- **Rename the temp-dir prefix too**: `mktemp -d -t lets-sessions-XXXXXX` becomes `lets-search-sessions-XXXXXX` for consistency. Cosmetic and internal; no linkage depends on it.
- **Version bump to 0.4.0, not a patch**: retiring slash commands is a breaking change to the command surface. Pre-1.0, so a minor bump is the right size.
- **Directory renames precede reference updates**: after U1 the plugin is internally inconsistent (correct directories, stale references), which is a legible intermediate state. The reverse order produces references pointing at directories that don't exist yet, which reads as a broken repo if the work is interrupted.
- **Mermaid node IDs realigned alongside labels**: purely cosmetic, but leaving `review["lets-review-code"]` with a node ID of `review` while `strategy` becomes `strategize` would be inconsistent in a diagram whose whole purpose is legibility.

---

## Open Questions

### Resolved During Planning

- *Does a plugin update leave stale skill directories that keep old commands alive?* No — the cache is version-scoped and holds one version directory. The clean break holds with no cleanup step.
- *Is a scripted find-and-replace safe across 39 files, or does ordering matter?* Safe under full-name anchored matching; verified no collisions among old names, new names, and adjacent agent/skill names.
- *Do the three keyword-dropping skills need description edits?* No — all three descriptions already carry the dropped term.

### Deferred to Implementation

- Whether to align README mermaid node IDs with the new labels or leave them: trivial either way, decided at edit time by whichever reads better in context.
- Exact wording of the README convention section (R4): drafted during U3 rather than pre-specified here.

---

## Implementation Units

### U1. Rename skill directories and frontmatter names

**Goal:** The ten skill directories carry their new names and each `SKILL.md` frontmatter `name:` matches its directory.

**Requirements:** R1, R2, R3, R5, R6, R11, R13

**Dependencies:** None

**Files:**
- Rename: the ten directories under `plugins/lets-engineer/skills/` per the mapping table
- Modify: the `name:` field in each renamed skill's `SKILL.md` (10 files)

**Approach:**
- Use `git mv` per directory so rename detection is preserved.
- Edit only the `name:` line in each frontmatter. Leave `description:` and `argument-hint:` alone — research confirmed the three keyword-carrying descriptions already satisfy R11.
- Do not create stub or alias directories (R13).
- Cross-references inside these files are intentionally left stale until U2; U1 is complete when directories and frontmatter agree.

**Patterns to follow:**
- Existing frontmatter shape in `plugins/lets-engineer/skills/lets-code-review/SKILL.md` — `name`, `description`, optional `argument-hint`, in that order.

**Test scenarios:**
*(No test harness exists in this repo — verification is assertion-by-inspection.)*
- Happy path: for each of the ten skills, the directory basename and the frontmatter `name:` value are identical strings.
- Happy path: `git status` reports ten renames, not ten deletions plus ten additions.
- Edge case: `lets-dhh-rails-style`, `lets-agent-native-architecture`, and the other 15 skills are untouched — 27 skill directories still exist.
- Covers AE1. Integration: `lets-branch-off`, `lets-generate-images`, and `lets-take-pulse` descriptions still contain `worktree`, `Gemini`, and `product` respectively.
- Covers AE4. Edge case: no directory named `lets-code-review` (or any other old name) remains under `skills/`.

**Verification:**
- Ten directories renamed, ten frontmatter names updated, 27 skills total.
- No old-named directory or stub remains.

---

### U2. Update cross-references across skills and agents

**Goal:** Every reference to a renamed skill inside the plugin points at its new name.

**Requirements:** R7, R8, R9, R10

**Dependencies:** U1

**Files:**
- Modify: 38 files under `plugins/lets-engineer/` — 3 agent files (`lets-best-practices-researcher.md`, `lets-learnings-researcher.md`, `lets-session-historian.md`) and 35 skill `SKILL.md` / `references/*.md` files
- Notable concentrations: `lets-review-code/` (4 files), `lets-review-docs/` (4 files), `lets-plan/` (5 files), `lets-work/` (3 files), `lets-explain/` (3 files)

**Approach:**
- Replace full skill names only, anchored so partial matches cannot fire. Both bare (`lets-code-review`) and slash-command (`/lets-code-review`) forms are covered by matching the bare name.
- Handle the three `mktemp`/temp-path occurrences in `lets-search-sessions/SKILL.md` as a deliberate rename to `lets-search-sessions-XXXXXX`, not as an accidental byproduct.
- Do not introduce any directory-path reference to a skill (R8) — cross-references stay bare-name or slash-command form.
- Do not touch relative script or reference paths (R9); they resolve inside the renamed directory unchanged.
- Leave `docs/brainstorms/` and `docs/plans/` untouched (R15) — including the origin document and this plan, both of which intentionally contain old names.

**Patterns to follow:**
- Existing cross-reference style, e.g. `plugins/lets-engineer/skills/lets-brainstorm/references/handoff.md` refers to sibling skills as `lets-doc-review` / `/lets-plan`, never by path.

**Test scenarios:**
- Happy path: searching the plugin directory for any of the ten old names returns zero results.
- Happy path: each new name appears at least once outside its own skill directory, confirming references were rewritten rather than deleted.
- Edge case: `lets-code-simplicity-reviewer`, `lets-session-historian`, `lets-product-lens-reviewer`, `lets-document`, and `lets-compound` are unchanged — none was caught by a partial match.
- Covers AE2. Integration: `lets-record-demo/SKILL.md` still invokes `python3 scripts/capture-demo.py` and `lets-branch-off/SKILL.md` still invokes `"${CLAUDE_SKILL_DIR:-.}/scripts/worktree-manager.sh"` — both unedited and both resolving inside the renamed directory.
- Edge case: the three `lets-search-sessions-XXXXXX` temp-path occurrences read consistently and no longer mix old and new naming.

**Verification:**
- Zero old-name references anywhere under `plugins/`.
- No skill references another by directory path.
- All relative script invocations unchanged.

---

### U3. Update README and document the convention

**Goal:** The README reflects the new names and states the naming rule so a reader can infer it without asking.

**Requirements:** R4, R12

**Dependencies:** U1, U2

**Files:**
- Modify: `README.md`

**Approach:**
- Update the mermaid pipeline diagram (node labels at lines 16 and 20; realign node IDs if it reads better).
- Update the prose handoff paragraph that names `lets-code-review`.
- Update the skill tables across all six category groups.
- Update the artifact-directory list that credits `lets-strategy` for `STRATEGY.md`.
- Add a short convention statement covering the sentence test and both exemption classes — workflows are verbs, style guides and agent personas are nouns. Keep it to a few lines; this is a README, not a style guide.

**Patterns to follow:**
- Existing README table and section shape — six grouped skill tables with `| Skill | What it does |` headers.

**Test scenarios:**
- Happy path: every skill name in the README resolves to a directory that exists under `plugins/lets-engineer/skills/`.
- Happy path: the mermaid block parses and every node label matches a real skill.
- Edge case: the two exempt style guides still appear in the README under their unchanged names.
- Covers AE3. Integration: searching the whole repo for old names returns hits only under `docs/brainstorms/` and `docs/plans/`.

**Verification:**
- README names match the filesystem exactly.
- The convention and its exemptions are stated and would let a reader name a new skill correctly.

---

### U4. Version bump and verification sweep

**Goal:** The release is publishable and provably free of stale references.

**Requirements:** R10, R14, R15

**Dependencies:** U1, U2, U3

**Files:**
- Modify: `plugins/lets-engineer/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

**Approach:**
- Bump both manifests from `0.3.0` to `0.4.0`. Both must change or `/lets-update` reports "up to date" and the rename never reaches an installed copy.
- Leave the `"code-review"` keyword in `plugin.json` — it is a marketplace topic tag, not a skill reference.
- Run the final sweep: repo-wide search for all ten old names, expecting hits only in `docs/brainstorms/` and `docs/plans/`.
- Confirm the skill count is still 27 and the agent count still 46.

**Patterns to follow:**
- Existing version field placement in both manifests; the two values are kept in lockstep.

**Test scenarios:**
- Happy path: both manifests read `0.4.0`.
- Happy path: repo-wide search for the ten old names returns matches only under `docs/`.
- Edge case: `plugins/lets-engineer/skills/` contains exactly 27 directories and `plugins/lets-engineer/agents/` exactly 46 files.
- Integration: loading the plugin locally surfaces all ten new slash commands and none of the old ones.

**Verification:**
- Both manifests bumped in lockstep.
- Only historical documents retain old names.
- All 27 skills load and the ten renamed commands resolve.

---

## System-Wide Impact

- **Interaction graph:** Skills reference each other for handoff (`lets-brainstorm` → `lets-plan` → `lets-work` → `lets-review-code`) and three agent files name skills in their guidance. Every such edge is plain text; all are covered by U2.
- **Error propagation:** A missed reference fails silently — the agent reads an instruction to invoke a command that no longer resolves. This is the reason U4's sweep is exhaustive rather than sampled.
- **State lifecycle risks:** None. No persistent state, no migrations, no runtime data.
- **API surface parity:** Slash commands are the plugin's public contract. The break is deliberate (R13) and scoped by the origin document's finding that no references exist outside this repo.
- **Integration coverage:** The relative-path invocations in `lets-branch-off` and `lets-record-demo` are the cases where a directory rename could plausibly break execution. Both were verified directory-relative before planning; U2 asserts they remain unedited.
- **Unchanged invariants:** Agent names, script filenames, script contents, skill descriptions, all reference-file names, the plugin name, and the marketplace name are all unchanged. The 15 already-conforming skills and the 2 exempt style guides are untouched.

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| A reference is missed and fails silently at runtime | U4's sweep searches the whole repo for all ten old names and expects hits only under `docs/` |
| A partial-match replacement corrupts an adjacent name (`lets-code-simplicity-reviewer`, `lets-document`, `lets-compound`) | Full-name anchored matching; U2 asserts each near-miss name is unchanged |
| Only one manifest is bumped, so `/lets-update` never fetches the rename | U4 treats the two version fields as a single lockstep edit and verifies both |
| History is lost by recreating directories instead of moving them | U1 uses `git mv` and asserts `git status` shows renames |
| The user's own installed copy still exposes old commands until updated | Expected and accepted — the cache is version-scoped, so the bump in U4 is what propagates the change |

---

## Documentation / Operational Notes

- README is the only user-facing doc affected; it is handled in U3 rather than deferred.
- After merge, `/lets-update` in an installed session is what pulls the renamed commands; until then the local install keeps resolving old names from its cached `0.3.0` directory.
- Old commands stop working with no deprecation warning. This is the intended behavior per R13, justified by the origin document's verification that no references exist outside this repo.

---

## Sources & References

- **Origin document:** `docs/brainstorms/2026-08-03-skill-naming-convention-requirements.md`
- Related code: `plugins/lets-engineer/skills/`, `plugins/lets-engineer/agents/`, `README.md`
- Manifests: `plugins/lets-engineer/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
