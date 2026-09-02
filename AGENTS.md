# AGENTS.md

Standards for contributing to `lets-engineer`. These are the rules this repo actually holds itself to — they are the criteria `lets-review-code`'s `lets-project-standards-reviewer` cites, so a rule here should be checkable against a diff.

Rules are marked **MUST** (universal, a violation is a finding) or **SHOULD** (the house default, deviate with a reason). Patterns followed by only a handful of files are recorded under [Not yet conventions](#not-yet-conventions) rather than enforced.

## Repository shape

```
.claude-plugin/marketplace.json     marketplace manifest
plugins/lets-engineer/
├── .claude-plugin/plugin.json      plugin manifest
├── skills/<skill-name>/
│   ├── SKILL.md                    the workflow
│   ├── references/*.md             progressively disclosed detail
│   └── scripts/*                   executables the skill invokes
└── agents/<agent-name>.md          subagents skills dispatch
docs/brainstorms/  docs/plans/      artifacts from dogfooding the pipeline
docs/decisions/                     decision records
CONTEXT.md                          the project's own glossary
```

- A skill directory name **MUST** equal its frontmatter `name`, and an agent filename **MUST** equal its frontmatter `name`.
- Skills and agents are discovered by directory scan. Neither manifest lists them, so adding one requires no manifest edit beyond the version bump.

## Naming

- A skill **MUST** be named `lets-<action>`, a verb phrase completing the sentence its prefix starts: `lets-review-code` is *"let's review code."*
- Two exemptions, both noun-shaped on purpose: **stack styles** (`lets-dhh-rails-style`) and **architecture references** (`lets-agent-native-architecture`) describe how to write rather than a task to run.
- An agent **MUST** be named `lets-<role>` and is noun-shaped, because agents are dispatched by skills and never typed by a user: `lets-security-reviewer`, `lets-web-researcher`.
- Review personas dispatched by `lets-review-code` end in `-reviewer`.

## Skill authoring

### Frontmatter

- `name` and `description` are **MUST**. Everything else is optional.
- `description` **MUST** state what the skill does *and* when to use it, in third person, including the trigger phrasings a user would actually type. It is the context pointer that decides whether the skill fires at all, so it earns more care than any line in the body.
- `argument-hint` **SHOULD** be present when the skill accepts arguments, written as a bracketed hint: `"[PR number, or blank for current branch]"`.
- `allowed-tools` **SHOULD** be set only to *narrow* a skill's surface. Omit it when the skill needs the full toolset.
- `disable-model-invocation: true` **MUST** be reserved for skills that would misfire if a model chose them on its own — environment setup, version checks, and anything with a side effect the user has not asked for. Skills whose value depends on firing mid-conversation **MUST NOT** set it.

### Reference documents

- Detail that only some runs need **SHOULD** be pushed into `references/` and reached by a pointer, keeping `SKILL.md` to what every run reads.
- A pointer to a reference file **MUST** be a backticked repo-relative path — `` `references/output-format.md` `` — and **MUST NOT** be a markdown link like `[output-format.md](./references/output-format.md)`. A backticked path reads as an instruction to open the file; a markdown link reads as optional navigation, and harnesses differ on whether they follow it.
- A pointer **SHOULD** say what the reference contains, so the reader knows what they are loading and why.

### Body

- A skill **SHOULD** open with an H1 title and a paragraph stating what the skill produces and for whom.
- A skill that asks the user anything **MUST**, at the point of asking, name the platform's blocking-question tool (`AskUserQuestion`, `request_user_input`, `ask_user`), state the condition for falling back to chat, and state that the question is never silently skipped. The standard Interaction Method paragraph is the usual form; a condensed inline sentence carrying the same three facts satisfies the rule, and the rule may be met in the reference that owns the question rather than in `SKILL.md`.
- A skill whose output is dated **MUST** state the current year in its body. Model priors run behind the calendar and produce documents dated to a past year otherwise.
- A skill that overlaps a neighbour **SHOULD** name the boundary explicitly, both in the `description` and in the body. `lets-explain` explains a change and `lets-review-code` critiques one; saying so in both is how each one stays in its lane.

## Agent authoring

- Frontmatter **MUST** carry `name`, `description`, and `model`. `tools` **SHOULD** be set to the narrowest sufficient list; omit it only when the agent genuinely needs everything.
- `model` **MUST** be `inherit` unless the agent has a stated reason to pin one. Pinning costs the user their model choice.
- A `description` **MUST** state the dispatch condition — what has to be true for a skill to spawn this agent — because that is what the dispatching skill matches on.
- A review persona **MUST** declare whether it is always-on or conditional, and a conditional one **MUST** state the diff signal that selects it.
- An agent that reports findings **MUST** define its confidence calibration and **MUST** list what it does not flag. An agent that flags everything is noise.

## Portability

Skills run on macOS and Linux, under Claude Code and other harnesses.

- Paths written into generated documents **MUST** be repo-relative. Absolute paths break the moment the doc is read on another machine.
- Temporary files **MUST** go through `mktemp`, honouring `${TMPDIR:-/tmp}` or using a `-t` template. A hardcoded `/tmp` path is a finding.
- Shell in skills and scripts **SHOULD** stay POSIX-portable. Where a GNU-only invocation is unavoidable, guard it or state the requirement.
- A skill **SHOULD** degrade rather than fail when a platform lacks a tool it prefers, and **SHOULD** say what it fell back to.

## Versioning and release

- A new skill or agent is a **minor** bump; a fix to existing wording is a **patch**.
- `.claude-plugin/marketplace.json` and `plugins/lets-engineer/.claude-plugin/plugin.json` **MUST** move in lockstep. When they diverge, `/lets-update` reports "up to date" and never fetches the release.
- `README.md` **MUST** stay accurate on the skill count and the skills table when either changes.

## Prose style

- Em dashes are the house default in skill and reference prose. Agent files predate this and are inconsistent; the rule applies to new and modified content, not to untouched agent text.
- Steer by stating the target behaviour rather than banning its opposite. A prohibition makes the forbidden behaviour more available, not less, so reserve it for hard guardrails that resist positive phrasing.
- Prune on every edit. A line that does not change behaviour against the model's default is spending context to say nothing.

## Not yet conventions

Patterns present in only a few files. Follow them if you like the shape, but they are not enforced and **MUST NOT** be cited as findings until they are promoted here.

- Opening a reference file with a `Loaded by SKILL.md at ...` line stating its role (8 of 91 reference files).
- Marking a pointer `This load is non-optional` (5 skills).
- Closing a skill with a `What This Skill Does Not Do` section (3 skills).
- The `lets_platforms` frontmatter key (1 skill, `lets-update`).
