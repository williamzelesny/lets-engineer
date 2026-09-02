# lets-engineer

A plugin of opinionated engineering workflows. This glossary fixes the words the project uses about itself, so that skills, agents, and documentation describe the same things the same way.

## Machinery

**Skill**
A named workflow this plugin ships, invoked by a user typing its name or fired automatically when a request matches what it is for. The unit a person reaches for.
_Avoid_: command, slash command

**Agent**
A definition this plugin ships for work that runs in its own context, and the process dispatched from it. Dispatched by a skill, never invoked directly by a user. Where the mechanism is the point rather than the definition, **subagent** is the same thing.
_Avoid_: sub-agent

**Persona**
The stance an agent takes while reviewing — the lens it applies and the class of problem it hunts for. A persona is a role; an agent is what runs it. One agent embodies exactly one persona, which is why the two words are easy to confuse and worth keeping apart: a persona can be described without an agent existing yet.
_Avoid_: reviewer type, review role

**Reference**
A document holding detail that only some runs of a skill need, loaded on demand rather than read every time. Keeps a skill's main body to what every run requires.
_Avoid_: reference doc, sub-doc, supporting doc

## Artifacts

**Artifact**
A durable document a skill writes into the repository for a later skill, or a later human, to consume. Durable is the distinction: an artifact outlives the session that produced it and is read by work that has not started yet. Unrelated to Claude Code's Artifacts feature, which publishes web pages.
_Avoid_: output, deliverable

**Requirements doc**
The artifact a brainstorm produces: what to build and why, at the scope the work actually warrants. Answers *what*, deliberately not *how*.

**Plan**
The artifact planning produces: how the requirements get built, broken into units a session can execute. A decision artifact rather than an execution script, and stale by design once the work ships.

**Learning**
The artifact compounding produces: a write-up of a problem this project already solved and how, written so the next person to meet it arrives prepared. Distinct from a Requirements doc or a Plan, which look forward; a Learning looks back.

**Decision record**
A short account of a choice that is hard to reverse, surprising without context, and the result of a real trade-off. Explains *why* a fork was taken, where a Learning explains *how* a problem was solved.

## Structure

**Route**
A branch taken near the start of a skill that decides which phases run. Selected from the state of the world — whether a file exists, what the user passed — not from a user's preference.

**Mode**
A whole-skill operating posture set at invocation, which changes what the skill does rather than which path it takes through the same work. Headless and description-only are modes.

**Phase**
A numbered stage of a skill's execution flow, ending in a stated result. Phases run in order unless a Route skips them.

**Step**
An ordered action inside a phase. Where a phase names a result, a step names a move.

**Tier**
A graded level inside a skill's own scheme, where the levels differ in depth rather than in kind — review tiers, capture tiers. Always scoped to one skill; there is no project-wide tier.
