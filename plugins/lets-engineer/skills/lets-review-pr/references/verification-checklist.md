# Verification Checklist

Checks by kind of change. Run the ones the diff calls for; most PRs need two or three sections.

## Any PR

- Read every bot and author comment. A posted plan, a local test run, or "state already pushed" changes what needs checking.
- Compare the changed-file list to the description. A lock file, a generated file, or an unrelated edit should be explained or expected.
- Find sibling PRs: search the same repo and neighbouring repos for the ticket key or branch name, and check whether each is merged.

## CI failures

- Open the failing job's log and find the first real error, not the trailing `exit code 1`.
- Check the timeline. A ref that "did not match any" often means the tag was cut after the run started — compare the run time to the tag's commit time, and recommend a re-run.
- Check the credentials. A permission error from a provider usually means the CI identity lacks a scope the author's local credentials have.
- Check whether other PRs touching the same area fail the same way. A recurring failure belongs in its own ticket, not in this PR's review.
- When CI cannot pass for environmental reasons, say what the team does instead (a local plan posted as a comment, a manual apply) and what risk that adds.

## Infrastructure as code (Terraform, OpenTofu, Terragrunt, Pulumi)

- Read the plan output and count adds, changes, and destroys against the description. Any destroy or replace needs a reason.
- Module or provider version bumps: confirm the tag exists, and that the plan shows no drift beyond the intended change.
- Resources the diff references by ARN, ID, or name: confirm they exist. For something a sibling PR created, find that PR's apply run and confirm it applied, not just merged.
- State moves or imports done outside CI: state is now ahead of the default branch, so any plan from the default branch would destroy those resources until this merges.
- New dependencies between units: confirm the dependent unit will plan once the dependency is gone or renamed.

## Module and library interfaces

- When a variable, argument, export, or schema is removed or renamed, search the module repo and every consuming repo for callers.
- Run the repo's validator (`validate`, typecheck, build) in a temporary worktree on the PR's head for the changed module and its in-repo callers. Format checks passing in CI does not mean it validates.
- Changed `for_each` keys or resource addresses: existing instances will be destroyed and recreated unless state is moved. Check the provider's delete behaviour to say how disruptive that is.
- Inputs that combine badly (an option that only works with another) should fail at plan or compile time, not at apply or runtime.

## IAM, trust, and access

- Cross-account access needs both sides: the caller's identity policy allows the action, and the target's trust policy names the caller.
- Confirm OIDC provider IDs, account IDs, and role names against other places the repo already uses them.
- Confirm the subject and audience claims match the actual namespace and service account the workload runs as.
- A read-only role gaining the ability to assume a write-capable role is a privilege change; say so, and note precedent if the repo already does it elsewhere.

## GitOps manifests (Argo CD, Flux, Helm values)

- Every source path, chart path, and values file the manifest resolves to must exist on the target revision — expand template variables to the real filename.
- Check which controller picks up the new file: a root app's path and `recurse` setting decide whether the old instance or the new one owns it, and whether names collide.
- Unpinned (`master`, `main`) versus pinned (tag) targets: when siblings are pinned, a new unpinned entry should be deliberate.
- Notification triggers, templates, and secrets the annotations reference must exist on that controller.
- Manual-sync apps need someone to sync after merge; say so.

## Live state

- Use read-only calls, and use the profile or context the repo's CI uses for that account where you can.
- When access fails, name what could not be checked and give the login command, prefixed so it runs in the session (in Claude Code, `! <command>`).
