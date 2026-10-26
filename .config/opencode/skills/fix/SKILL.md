---
name: fix
description: Drive a Jira-tracked bug fix from ticket context through implementation and verification. Use ONLY when the user explicitly invokes `/fix` or explicitly asks to use the fix skill; never select it for ordinary bug reports or general debugging.
---

# workflow

Treat this as an explicit Jira bug-fix session. Resolve the ticket key from the `/fix` argument or current branch; otherwise ask for it as the very first action, then fetch the Jira issue before changing code.

Check whether its corresponding branch is checked out; if not, identify it from refs, conventions, or Jira context and make a mental note to check it out later. Do not silently switch branches or discard changes; verify, diagnose, fix, and regression-test the bug.

# guidelines

- Trigger only from explicit `/fix` invocation or explicit request to use this skill; example: `/fix CPP-24162`.
- Resolve keys from argument, current branch, then ask before investigation.
- Use Jira tools; do not guess ticket criteria or status.
- Treat unchecked-out branches as follow-ups; never switch branches or discard unrelated changes silently.
- Prefer the smallest fix with regression coverage; run focused checks first.
