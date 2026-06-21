# GitHub issues

Raise and refine GitHub issues from a winter workspace using a precise, AI-native format. The `issue` skill drafts an issue from your current conversation and files it against the appropriate GitHub repository via the [`gh`](https://cli.github.com/) CLI. The `refine` skill updates an existing issue interactively or by processing inline comment requests.

## Path notation

Files in this extension are addressed with the `winter-github:` prefix — for example, `winter-github:/ai/issue-format.md`. Resolve to the on-disk path via the `# Winter Extensions` block in workspace `CLAUDE.md`; the local directory name varies (`./.winter/ext/github/`, `./winter-github/`, etc.).

## What this extension provides

- **`issue` skill** at [`skills/issue/SKILL.md`](./skills/issue/SKILL.md) — drafts an issue from `$ARGUMENTS` plus conversation context, picks the target GitHub repo (see [`ai/repo-selection.md`](./ai/repo-selection.md)), confirms with the user, and files via [`gh`](https://cli.github.com/) (the `gh` convention is established by [winter-harness](https://github.com/paul-gross/winter-harness)).
- **`refine` skill** at [`skills/refine/SKILL.md`](./skills/refine/SKILL.md) — refines an existing issue: interactive editing (fetch, converse, apply a format-conforming body after confirmation) or comment processing (enumerate comments, skip those already `:eyes:`-reacted by the running identity, process the rest, mark each with `:eyes:` for idempotency).
- **AI-native issue format** — YAML metadata + Context + Current/Desired Behavior + checklist Acceptance Criteria + Out of Scope + References. Full spec at [`ai/issue-format.md`](./ai/issue-format.md).

Full conventions in [ai/index.md](./ai/index.md).
