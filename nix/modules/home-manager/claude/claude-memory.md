# Operating Guidelines

I work across many tools and systems (infra/GitOps, Go, YAML, TypeScript,
Python, Java, docs). Project-specific rules live in each repo's CLAUDE.md —
read it first and let it override anything here. This file is about *how* to
work, not project facts.

Treat work as ticket-driven: diagnose, implement, validate, and commit as a
complete loop. Hard prohibitions are enforced by my permission settings; you
don't need to ask about things that are already blocked.

## Autonomy contract

Work autonomously and finish the loop. Don't narrate permission requests for
routine, reversible work.

**Proceed without asking (green):** reading/searching/navigating; running
tests, linters, builds, golden-file regen, and read-only/`--dry-run`
commands; targeted in-scope edits; staging and committing to a feature
branch.

**Confirm first (yellow):** irreversible/destructive actions not already
blocked; changes well beyond stated scope or touching many unrequested
files; adding/removing/upgrading dependencies; anything still genuinely
uncertain *after* a reasonable attempt to resolve it yourself.

**Never (red — also enforced by settings):** force-push, commits to
protected branches, secret exfiltration, editing `.git` internals or system
config, printing secret-bearing env vars.

When uncertain, prefer one focused attempt over stopping to ask. Save
questions for genuine forks in the plan, not routine steps.

## Commit discipline

Checkpoint completed units of work with descriptive commits on a feature
branch — don't let hours of edits sit uncommitted. Commit at natural
stopping points and reference the ticket ID. Show changed files before
committing.

## Verify, don't speculate

For factual claims about how a tool, config, or policy behaves, check the
actual file/docs before asserting it. Cite the specific file/line or doc you
verified against, and label anything inferred as a hypothesis. Don't lecture
from memory.

## Research scope

When gathering external info, state the goal and stay within a tight budget
(e.g. a handful of lookups), then report a hypothesis and recommended action
rather than open-ended exploration. Tie findings back to a concrete change.

## Searching and navigating code

- Use LSP first for code symbols: go-to-definition, find references,
  hover/type info, and diagnostics — instead of text-searching for symbols.
- After edits, check LSP diagnostics rather than assuming correctness.
- For text/content search use `rg` and `fd`. Never `find ... -exec grep`,
  `find | xargs grep`, or `grep -r/-R` (blocked anyway).

## Tools over scripts

For file/text/data work, reach for purpose-built CLI tools (`rg`, `fd`,
`jq`, `yq`, `awk`, targeted `sed`, `sort`, `comm`) rather than throwaway
Python scripts *or* long chains of one-off Bash. Write a script only when the
task genuinely needs logic these tools can't express cleanly.

## Editing conventions

- Keep changes small and in-scope; don't refactor or delete dead/commented
  code unless asked.
  - Bulk whitespace changes (like the outcome of `yq eval`) is allowed and
    should not be a justification for avoiding a particular tool.
- After edits, run the repo's tests/lint/golden-file regen before calling
  the task done.
