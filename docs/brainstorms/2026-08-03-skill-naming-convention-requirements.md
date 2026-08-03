---
date: 2026-08-03
topic: skill-naming-convention
---

# Skill Naming Convention: `lets-<action>`

## Summary

Establish a naming rule for the plugin's command surface — every skill a user invokes is named so it completes the sentence *"let's ___"* — and rename the ten workflow skills that currently fail it. Style guides and agent personas keep noun-shaped names, because neither is a command anyone types. Old names are retired outright, with no compatibility stubs.

---

## Problem Frame

All 27 skills already share the `lets-` prefix, but the half that follows it is inconsistent. Fifteen are verb-shaped and read as commands: `lets-plan`, `lets-debug`, `lets-commit`. Twelve are noun-shaped and don't: `lets-code-review`, `lets-doc-review`, `lets-frontend-design`.

The friction is in reading, not recall. `lets-code-review` expands to *"let's code review"* — grammatically wrong in a way that catches the eye every time it appears in the README table or a skill cross-reference. The prefix sets up a sentence that the rest of the name then fails to finish.

Because the prefix implies a sentence, the inconsistency isn't cosmetic drift — it's a broken promise repeated 12 times across a surface whose whole point is to be typed quickly and read at a glance. The plugin is effectively single-user, so the cost is borne entirely by the person who reads these names most.

---

## Requirements

**The convention**

- R1. A skill a user invokes as a workflow is named `lets-<verb>` or `lets-<verb>-<object>`, such that the full name reads as a natural completion of *"let's ___"*.
- R2. A skill that describes a style, posture, or reference mode rather than a bounded action is exempt and keeps a noun-shaped name. Two skills qualify: `lets-dhh-rails-style` and `lets-agent-native-architecture`.
- R3. Agent personas under `plugins/lets-engineer/agents/` are exempt. They are noun-shaped by design, are never user-invoked, and are not part of the command surface.
- R4. The convention and its two exemption classes are documented in the README so the rule is inferable by a reader, not just by the author.

**The renames**

- R5. Ten workflow skills are renamed:

| Current | New | Reads as |
|---|---|---|
| `lets-code-review` | `lets-review-code` | let's review code |
| `lets-doc-review` | `lets-review-docs` | let's review docs |
| `lets-frontend-design` | `lets-design-frontend` | let's design frontend |
| `lets-product-pulse` | `lets-take-pulse` | let's take pulse |
| `lets-demo-reel` | `lets-record-demo` | let's record demo |
| `lets-sessions` | `lets-search-sessions` | let's search sessions |
| `lets-strategy` | `lets-strategize` | let's strategize |
| `lets-worktree` | `lets-branch-off` | let's branch off |
| `lets-gemini-imagegen` | `lets-generate-images` | let's generate images |
| `lets-compound-refresh` | `lets-refresh-learnings` | let's refresh learnings |

- R6. For each rename, the skill directory name and the `name:` field in its `SKILL.md` frontmatter both change and stay identical to each other.
- R7. Every in-repo textual reference to a renamed skill is updated — across skill bodies, `references/*.md` files, the three agent files that name skills, and the README.

**Linkage integrity**

- R8. No renamed skill may be referenced by directory path from outside itself. Cross-skill references use the bare name or slash-command form only.
- R9. Script and reference paths inside a skill stay relative to the skill directory (`scripts/foo.py`, `${CLAUDE_SKILL_DIR:-.}/scripts/foo.sh`) so they continue resolving after the directory moves.
- R10. After the rename, no reference to any old name remains anywhere in the repo outside `docs/brainstorms/` and `docs/plans/`.

**Discoverability**

- R11. Where a new name drops a term the old name carried — `worktree`, `gemini`, `product` — the skill's `description` field must contain that term, so description-matched auto-activation still fires for users who phrase requests using it.
- R12. README updates cover the pipeline diagram node labels, all skill tables, and the artifact-directory list.

**Release**

- R13. No compatibility stubs, alias directories, or deprecation shims are created. Old slash commands stop resolving.
- R14. The version in `plugins/lets-engineer/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` is bumped, per the repo convention that every content merge to main bumps both.
- R15. Dated artifacts under `docs/brainstorms/` and `docs/plans/` keep their original skill names as historical record and are not rewritten.

---

## Acceptance Examples

- AE1. **Covers R11.** Given `lets-worktree` has been renamed to `lets-branch-off`, when a user asks "set up a worktree for this," the skill still activates — because its description names *worktree* even though the skill name no longer does.
- AE2. **Covers R9.** Given `lets-demo-reel` has been renamed to `lets-record-demo`, when the skill invokes `python3 scripts/capture-demo.py`, the relative path resolves inside the renamed directory with no edit to the invocation.
- AE3. **Covers R7, R10.** Given the rename is complete, when the repo is searched for any of the ten old names excluding `docs/`, the search returns zero results.
- AE4. **Covers R13.** Given a user types `/lets-code-review` after updating, the command does not resolve and no stub intercepts it.

---

## Success Criteria

- Reading the README skill tables top to bottom, every command name completes *"let's ___"* — and the two noun-shaped exemptions are visibly a category, not an oversight.
- A reader who has never seen the repo can infer the rule and its exemptions from the README alone, and would name a new skill correctly without asking.
- A downstream implementer can execute the rename from this document with no naming decisions left to make and no ambiguity about which files to touch.
- Every skill that worked before the rename works after it, invoked under its new name.

---

## Scope Boundaries

- The 46 agent personas are not renamed.
- `lets-dhh-rails-style` and `lets-agent-native-architecture` are not renamed.
- The 15 skills that already pass the sentence test are not touched, including `lets-setup` and `lets-update`.
- The plugin name, marketplace name, and repository name are unchanged.
- No compatibility layer, alias mechanism, or migration tooling is built.
- Skill *content* is not revised — this is a naming change, except for description edits required by R11.

---

## Key Decisions

- **Sentence test over mechanical verb-first**: the rule is "does it complete *let's ___*," not "does it start with a verb." The sentence framing is what makes the two exemptions principled rather than arbitrary — `lets-dhh-rails-style` describes how you write, not a task with a beginning and an end, so forcing `lets-write-rails` onto it would satisfy a rule while making the name less true.
- **Workflows renamed, style guides exempt**: the repo ends with two visible conventions — verbs for things you run, nouns for things you write in — each internally consistent and each explainable in one line.
- **Clean break over deprecation stubs**: stub directories would add clutter to the exact surface being cleaned. Justified by the plugin being effectively single-user; verified that no references exist outside the repo.
- **Accepting the loss of the `compound` / `compound-refresh` pairing**: `lets-refresh-learnings` no longer visibly pairs with `lets-compound`. The pairing was carried by a name that failed the sentence test, and `docs/solutions/` is the real link between the two skills.
- **Grouping shifts from domain to action**: `lets-review-code` and `lets-review-docs` now sort together, while `lets-code-review` and `lets-commit` no longer do. Accepted — action-grouping matches how the skills are reached for.

---

## Dependencies / Assumptions

- **Verified — no path-based linkages exist.** Every script invocation in the affected skills is relative (`scripts/capture-demo.py`, `${CLAUDE_SKILL_DIR:-.}/scripts/worktree-manager.sh`); none embeds its own directory name. `CLAUDE_PLUGIN_ROOT` appears only in `lets-update` and `lets-setup`, neither of which is renamed nor hardcodes a renamed directory. The only `skills/lets-<name>/` path references in the repo are inside the two historical plan documents.
- **Verified — no references outside the repo.** `~/.claude/settings.json`, the project memory directory, and project-level `.claude/` contain no references to any of the ten names.
- **Verified — reference surface is 44 files.** Concentrated in `lets-code-review` (96 references), `lets-doc-review` (38), `lets-sessions` (28), and `lets-compound-refresh` (28); the remaining six have fewer than 10 each.
- The `"code-review"` entry in `plugin.json` keywords is a marketplace topic tag, not a skill reference, and needs no change.
- Assumes skill auto-activation matches on the `description` field, which is why R11 is sufficient to preserve discoverability for dropped keywords.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R13][Technical] When Claude Code updates a cached plugin, is the version directory replaced wholesale or merged? If merged, stale directories under the old names could linger in the local cache and keep resolving old slash commands after the update — which would quietly violate the clean-break intent.
- [Affects R7][Technical] Whether a scripted find-and-replace is safe given `lets-code-review` is a substring-adjacent prefix of nothing else, versus reviewing the 44 files individually. Ordering matters if any replacement could produce a string another replacement then matches.
