---
name: lets-review-pr
description: "Review someone else's pull request as its reviewer — check the description's claims against the diff, CI output, related PRs, and live state, then give a verdict and a short comment drafted in the user's voice. Use when asked to 'review this PR', 'can we review <PR link>', 'is this good to approve', 'why did this PR's CI fail', or 'draft a comment for this PR'. Verifies and drafts a reply; for a multi-persona critique of code you wrote, use lets-review-code."
argument-hint: "[PR link or number]"
---

# Review a Pull Request

Review a teammate's PR the way a careful reviewer does: confirm the change does what its description claims, check it against the systems it touches, and hand the user a verdict plus a comment they can paste. The output is for the user, who decides what to post.

**Boundary:** `lets-review-code` critiques code you wrote, before it becomes a PR, with parallel reviewer personas. `lets-review-pr` reviews someone else's open PR and verifies it against the outside world — CI runs, plans, sibling PRs, tags, and live infrastructure. Use `lets-explain` first when the user wants to understand the change rather than judge it.

## Read-Only Contract

- Read the PR with `gh pr view` and `gh pr diff`, and read other refs with `git show <ref>:<path>`. Leave the user's working tree on its current branch.
- When a check needs the PR's files on disk (a validate, a lint, a build), add a temporary worktree from `mktemp -d` and remove it when done.
- Live systems are read-only: describe, list, and get calls only.
- Post nothing to the PR unless the user asks in this conversation.

## Phase 1: Gather

Fetch in one pass: title, author, body, head branch, changed files, check results, reviews, and comments. Then the full diff.

Read the PR body as it stands now. If a claim matters and seems to be missing, check the body's edit history before citing it — authors revise descriptions.

## Phase 2: Verify

Turn the description into claims and check each against evidence. Work through `references/verification-checklist.md`, which lists the checks by kind of change (infrastructure as code, GitOps manifests, IAM and trust, module or library interfaces, CI failures) and how to run each.

The checks that catch the most:

- **Plan or test output matches the description.** When the description says "the plan only adds X", read the plan and confirm nothing else changes.
- **References resolve.** Tags, module refs, paths, values files, ARNs, IDs, and policies the diff points at must exist — and for infrastructure, merged is not applied, so check the apply run.
- **Callers still work.** When the diff changes an interface (a variable, an export, a schema), search for its consumers and run the repo's validator against them.
- **CI failures are diagnosed, not reported.** Read the failing job's log and decide whether the PR caused it, the timing did (a tag cut after the run), or the environment did (a credential lacking a permission). Check whether the same failure appears on other PRs before blaming this one.
- **Order across PRs.** Find sibling PRs in the same change and state the merge or apply order they need.

Use the repo's actual toolchain — read the CI workflow to see which binary it runs rather than assuming one.

When live access fails (an expired session, a missing profile), say what could not be verified and give the user the command to restore access, then continue with what the repo shows.

## Phase 3: Report

Lead with the verdict in one line: approve, approve with a heads-up, needs a re-run, or request changes, and the reason.

Then three short groups, omitting any that are empty:

- **Blocking** — what must change before merge, with the evidence (file and line, error text, command output).
- **Worth raising** — real risks or questions that do not block.
- **Checked** — what was verified, in a line each, so the user knows the approval is earned.

Mark anything inferred rather than verified as inferred.

## Phase 4: Draft the comment

Write a PR comment as the user would post it, following `references/comment-voice.md`, which covers voice, length, and what to leave out.

When the user asks to reword it, rewrite it whole rather than patching phrases.

If the user asks to post it, use the platform's blocking question tool to confirm the exact text and whether it is a plain comment, an approval, or a change request: `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_user` in Gemini, `ask_user` in Pi. Fall back to a numbered choice in chat only when no blocking tool exists or the call errors. Never post without that confirmation.

## Success Criteria

- The verdict comes first and follows from the evidence shown.
- Every claim in the PR description that affects safety was checked, or is listed as unverified with the reason.
- CI failures are attributed to their actual cause.
- Related PRs and the order they need are named.
- The drafted comment is short enough to paste unedited and sounds like the user.
