# Read-Only Input Resolution

How `lets-explain` resolves the change to explain. Adapted from `lets-review-code`'s scope detection (`skills/lets-review-code/SKILL.md` Stage 1 and `references/diff-scope.md`), but **read-only**: never switch or mutate the working tree.

## Output

Every path below produces the same handoff for Stage 2:

- `BASE:` — the resolved base SHA (the merge-base, or the range start)
- `FILES:` — changed file paths
- `DIFF:` — the unified diff. For local scope (blank/branch/range) request generous context (e.g. `-U10`) so the teaching layer has surrounding code. `gh pr diff` has no context flag and emits the default 3 lines; for PR scope, lean on the "Reading full-file context" section below when the teaching layer needs more than the diff shows.
- For PR targets: title, body, and URL for intent

## Input forms

### Blank or branch name

Diff against the merge base — **never** `git checkout`.

- Detect the default branch, in order:
  1. `git symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed 's#^origin/##'`
  2. fallback: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
  3. fallback: the first of `main` / `master` / `develop` / `trunk` that exists as `origin/<name>` or bare `<name>`
- `BASE=$(git merge-base HEAD <base-ref>)` — use `<branch>` in place of `HEAD` when a branch name was given. `<base-ref>` is `origin/<default>` when available, else the bare local `<default>` (covers single-branch clones and missing remotes).
- If `BASE` is empty and the clone is shallow (`git rev-parse --is-shallow-repository`), run `git fetch --unshallow origin` and retry.
- If no base resolves, **stop** with a clear message. Do **not** fall back to `git diff HEAD` — that shows only uncommitted changes and silently misses committed work.

Then produce the diff (diffs the merge base against the working tree, so committed, staged, and unstaged changes are all in scope):

```
echo "BASE:$BASE" && echo "FILES:" && git diff --name-only $BASE && echo "DIFF:" && git diff -U10 $BASE
```

### Commit range

A range (`A..B`) names both endpoints, so diff them directly — do **not** route through the merge-base command above (`git diff $BASE` would diff `A` against the working tree, not `A..B`):

```
echo "BASE:A" && echo "FILES:" && git diff --name-only A..B && echo "DIFF:" && git diff -U10 A..B
```

### PR number or GitHub URL

Use `gh` — **never** `gh pr checkout`.

- Metadata: `gh pr view <number-or-url> --json title,body,url,baseRefName`
- Diff: `gh pr diff <number-or-url>`

**Do not** reuse `lets-review-code`'s local merge-base path for PRs. That path computes `git merge-base HEAD <base>`, where `HEAD` is the PR head *only after* `gh pr checkout`. With no checkout, `HEAD` is the user's current branch and the scope would be wrong. `gh pr diff` reflects the remote PR state, which is correct here — `lets-explain` explains the PR as proposed, not unpushed local fix commits.

## Untracked files

For blank/branch scope, untracked files are outside the diff. If `git ls-files --others --exclude-standard` is non-empty and any look relevant to the change, note them in the walkthrough's Orientation rather than silently ignoring them. Never stage them.

## Reading full-file context

When the teaching layer needs surrounding code the diff does not show:

- **Local scope:** `Read` the file directly.
- **PR scope:** read the file at the PR ref without switching the tree — e.g. `git show <ref>:<path>` after a non-mutating `git fetch` of the ref, or via `gh api`. Never `git checkout` / `gh pr checkout`.
