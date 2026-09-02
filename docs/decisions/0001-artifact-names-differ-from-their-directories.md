# Artifact names differ from the directories that hold them

A Learning lives in `docs/solutions/` and a Requirements doc lives in `docs/brainstorms/`, so in both cases the artifact's name and its home disagree. We are keeping the directories as they are: they already exist in the repositories of everyone using this plugin, and renaming them would strand existing files, require migration handling in `lets-compound` and `lets-refresh-learnings`, and force a version bump users have no reason to want. The glossary in `CONTEXT.md` is the authority on what each artifact is called; the directory name is a historical path, not a claim about the artifact.

## Considered options

Renaming `docs/solutions/` to `docs/learnings/` was the obvious consistency fix and was rejected on compatibility alone — the mismatch costs a moment of confusion once, where the rename costs every existing user a migration.

Renaming the artifact instead, retiring "learning" in favour of "solution", was rejected because "learning" is the better description of what the document is: it records what the project now knows, not merely that something got fixed.

## Consequences

A contributor reading `docs/solutions/` will reasonably assume the artifact is called a solution. That assumption is wrong, and this record exists so the correction is one file away rather than a rediscovered argument. The same applies to `docs/brainstorms/`, where the directory names the activity and the file names the output.
