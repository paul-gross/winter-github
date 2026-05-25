# winter-github

A [winter](https://github.com/paul-gross/winter) extension that adds GitHub issue-raising to a winter workspace: a precise, AI-native issue format and a single skill, `/wg-issue`, that drafts and files an issue against the right repo.

## Features

- **AI-native issue format** — YAML metadata block + Context + Current/Desired Behavior + checklist Acceptance Criteria + explicit Out of Scope + code References. Structured enough for an agent to parse; readable enough for humans.
- **Smart repo selection** — infers the target GitHub repo from conversation context (files discussed, commands referenced, recently-edited worktrees) and resolves to a real GitHub URL via the workspace's `.winter/config.toml`. Never falls back to a workspace-level repo — anything that looks workspace-level is re-routed to winter or a winter extension.
- **One skill, no ceremony** — `/wg-issue <freeform description>` drafts a complete issue from the current conversation, confirms the target repo and content with you, and files via `gh`.

## Installation

Add to the workspace's `.winter/config.toml`:

```toml
[[standalone_repository]]
name = "winter-github"
url = "git@github.com:paul-gross/winter-github.git"
```

Then run `winter ws init`. The skill becomes available as `/wg-issue`.

## Prerequisites

- [`gh`](https://cli.github.com/) installed and authenticated against `github.com`:
  ```
  gh auth login --hostname github.com
  ```

Run `winter doctor` to verify — this extension contributes probes for the `gh` binary, the `github.com` auth entry, and `api.github.com` reachability. It's the canonical "is my setup correct?" check before `/wg-issue`.

## How it works

When you run `/wg-issue <description>`:

1. **Target repo** — picked per [`ai/repo-selection.md`](./ai/repo-selection.md). You confirm before filing.
2. **Draft body** — generate title and body in the AI-native format using `$ARGUMENTS`, conversation context, and codebase knowledge (file paths, components).
3. **Confirm** — show the draft, let you tweak title/labels.
4. **File** — `gh issue create` against the confirmed repo, return the URL.

See [`index.md`](./index.md) for the full layout and [`ai/issue-format.md`](./ai/issue-format.md) for the format spec — both auto-loaded into every Claude session that runs in a winter workspace with this extension installed.
