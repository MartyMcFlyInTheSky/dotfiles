# Agent Instructions

## Reporting style

- When reporting information to me, be extremely concise and sacrifice grammar for the sake of concision.
- If I use a technical term incorrectly, gently point it out and give the precise term; distinguish genuine errors from acceptable informal wording.

## Coding

- Document critical code sections or sections that incurr significant cognitive or temporal overhead to parse.

## Python guidelines

- **Use `Self` for self-referencing annotations.** Methods and classmethods returning their own class (alternate constructors, copy-like methods, `model_validator(mode="after")`, parameters of the same type) are annotated `-> Self` (`from typing import Self`), not with a quoted class name, so renames and subclasses stay correct. A quoted name stays only for a *different* class defined later in the module.
- **Declare custom exceptions at the top of each module and raise them; do not return errors as values.** Each module defines the exceptions it raises right after its imports and constants, one class per distinct failure (a subclass per kind, not an error-kind enum plus a message). Callers use `try/except`, with the narrowest type, instead of checking an `error` field or a `T | Error` return. Group related failures under a shared base so callers catch one type, and derive from a built-in (`ValueError`) only where a framework requires it (pydantic validators).

## Formatting

- Avoid unrelated formatting or style changes. Intentional formatter-only changes require a separate `style(...): ...` commit after verifying formatter scope.
- For commands requiring credentials from `.env`, explicitly load/export the variables in the command environment; never assume shell processes inherit `.env`.
- Run `ruff check --no-fix` for validation; run formatting separately when changes are intended.

## Commit Strategy

### Workflow

1. Inspect `git status`, `git diff`, and recent commits. Identify pre-existing changes; never include or alter unrelated work.
2. Gather the user request, implementation plan, existing commit plan, current diff, and relevant TODO comments within the requested code scope; ignore scratchpad files such as `TODO.md`.
3. Before coding, stop and critically re-derive the commit plan rather than trusting existing boundaries. Split, merge, or reorder slices until each has one reason to change, explicit scope and exclusions, its own verification, and a valid resulting repo state.
4. When dependency order permits, place mechanical refactors before semantic changes if they remain independently valid.
5. Implement only first slice against current committed state.
6. Verify slice, review its diff, and commit it when commits are requested or explicitly authorized; then reassess remaining boundaries before starting next slice. Repeat until complete.
7. Update `todowrite` after each commit when task tracking is warranted.

### Staged Scope Gate

- Before every commit inspect `git status --short`, `git diff --cached --name-only`, and `git diff --cached --stat`.
- Compare `git diff --cached --name-only` against current slice allowlist.
- If scope mismatches, stop, do not commit, and re-plan.
- Stage explicit paths only; the Git index is shared state, not scratch space.
- After commits inspect `git show --stat --name-only HEAD`.
- Commit namespace must match paths: `ai(graph): ...` allows only `graphify-out/**`; use `ai(...)` for agent/skill workflows and agent-only `AGENTS.md` changes.

Never implement whole code change first, then extract planned commits from aggregate diff through partial staging or cherry-picking. Sequential atomic commits may intentionally touch same lines; final state loses intermediate states, making post-hoc partitioning unreliable or impossible.

### Commit Plan Gate

Treat every existing plan as a hypothesis: before editing, ensure each proposed commit is coherent, reviewable, verifiable, and safe to apply at its planned position without a later commit. If implementation exposes a weak boundary or scope drift, stop immediately and re-plan the remaining commits instead of absorbing adjacent work.

## Guardrails

- Never change Git branch destinations or upstream tracking configuration. If a push destination mismatch occurs, stop and notify me; do not repoint the branch.
- **Separate mechanical and semantic changes.** Keep equivalent refactors apart from behavior changes whenever both can remain independently valid.
- **Protect existing work.** Never revert, overwrite, stage, or commit unrelated changes.
- **Explain durable decisions.** Comment non-obvious code constraints backed by explicit user decisions.
- **Use conventional commits, including approved custom types such as `remove` and `ai`.** Subject completes: "If applied, this commit will <subject>." Body explains why without merely restating changed files or behavior.
- **Mark breaking changes.** Use `!` when applicable.
- **Use `remove` for feature removal.** Do not label removal as `refactor`.
- **Use `ai` for AI-only infrastructure,** including graphify output, agent/skill workflows, and agent-only `AGENTS.md` instructions; exclude production rules and code conventions.
- **Keep subjects concise.** Imperative, no period, at most 72 characters; avoid vague wording, issue refs, and unrelated clauses joined by "and".
- **Use non-interactive git.** Avoid editor-dependent commands.
- **Exclude working drafts.** Never commit ignored specfiles or handoff documents.
- **Ask when commit ownership or boundaries remain ambiguous.**
- **Preserve code comments**: When changing or rewriting files, never drop existing comments, only update if stale.

## Examples

Usage of breaking change (!) marker:

```text
refactor(opmet_fetcher)!: enable sadis as source for pireps
```

Approved custom conventional-commit types (`remove` and `ai`):

```text
remove(opmet_fetcher): remove stale EventCollector class
```

Non interactive editor commands:

```sh
GIT_EDITOR=true git rebase --continue
```
