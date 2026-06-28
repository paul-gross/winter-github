# GitHub Issue Conventions

Conventions for raising GitHub issues from a winter workspace. See [`../index.md`](../index.md) at the extension root for the overall layout and what this extension provides.

## Documents

| Document | When to read |
|----------|--------------|
| [Issue Format](./issue-format.md) | Drafting an issue body; reviewing an issue someone else wrote |
| [Epics](./epics.md) | Filing a large body of work that decomposes into child issues, or attaching issues to a parent epic |
| [Repo Selection](./repo-selection.md) | Deciding which GitHub repository an issue belongs to |
| [GH CLI Cheatsheet](./gh-cli.md) | Filing, listing, or viewing issues from the command line |
| [Injection Tests](./injection-tests.md) | Manually exercising the Safety guards after touching `skills/issue/SKILL.md` or `skills/refine/SKILL.md` |

## Principle

Issues are written so a future agent (human or AI) can pick one up cold and start work without re-asking the author for context. Every issue states **what** behavior changes, **how you'd know** it changed (acceptance criteria), and **where** in the codebase to look. Anything missing from those three slots is a defect in the issue.
