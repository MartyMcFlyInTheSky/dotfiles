---
description: Agentically rebase current branch onto a target branch
agent: build
subtask: false
---

# Rebase Workflow

Rebase the current branch onto the specified target branch (`$1`), one commit at a time, preserving every commit and never squashing.

If `$1` is empty, default to `origin/master`.

Proceed automatically between conflicts, but stop for every merge conflict. Present resolution choices side by side with concise snippets, consequences, and your recommendation. Wait for my explicit approval before continuing.

## Guardrails

- Fetch first: Never assume the target branch is up to date. Always run `git fetch origin` first. If the command fails, abort and surface the error.
- Fix fallout: After the rebase, run the full test suite to surface potential bugs. Fix only bugs provably caused by the rebase itself.
- Never reset, abort, continue, or force-push without approval.
- Keep prose terse. Present critical choices side by side with concise snippets, consequences, and recommendation.

## Command Semantics

- `$1` is the branch to rebase onto.
- Preserve branch names exactly as supplied.
- Do not interpret additional user text as a different target branch.
- Before starting, report the current branch and resolved target branch.
- If the target cannot be resolved unambiguously, stop and ask.
