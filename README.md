# ❄️ winter-github

A [winter](https://github.com/paul-gross/winter) extension that adds GitHub issue management to a winter workspace: a precise, AI-native issue format, an `issue` skill that drafts and files an issue against the right repo, and a `refine` skill that updates an existing issue interactively or by processing inline comment requests.

📚 **Documentation:** <https://paul-gross.github.io/winter-docs/>

## ✨ Features

- **AI-native issue format** — YAML metadata block + Context + Current/Desired Behavior + checklist Acceptance Criteria + explicit Out of Scope + code References. Structured enough for an agent to parse; readable enough for humans.
- **Smart repo selection** — infers the target GitHub repo from conversation context (files discussed, commands referenced, recently-edited worktrees) and resolves to a real GitHub URL via the workspace's `.winter/config.toml`. Never falls back to a workspace-level repo — anything that looks workspace-level is re-routed to winter or a winter extension.
- **Two skills, no ceremony** — `/wg-issue <freeform description>` drafts a complete issue from the current conversation, confirms the target repo and content with you, and files via `gh`. `/wg-refine <issue-number-or-url> [--comments]` refines an existing issue: interactively (fetch, converse, apply edits after confirmation) or in comment-processing mode (enumerate comments, skip already-`:eyes:`-reacted ones by the running identity, process the rest, mark each with `:eyes:` for idempotent re-runs). (The `wg` prefix is workspace-configurable; the canonical skill names are `issue` and `refine`.)

## 🚀 Installation

Add to the workspace's `.winter/config.toml`:

```toml
[[standalone_repository]]
name = "winter-github"
url = "git@github.com:paul-gross/winter-github.git"
```

Then run `winter ws init`. The skill becomes available as `/wg-issue` (the `wg` prefix is set by `prefix = "wg"` in `winter-ext.toml` and is workspace-configurable).

## ✅ Prerequisites

- [`gh`](https://cli.github.com/) installed and authenticated against `github.com`:
  ```
  gh auth login --hostname github.com
  ```

Run `winter doctor` to verify your `gh` prerequisites for the `issue` and `refine` skills — this extension contributes the probes that check them (see [`ai/gh-cli.md`](./ai/gh-cli.md#one-time-setup)).

## 🧩 How it works

`issue` drafts a complete, format-conforming issue from the current conversation and files it against the repo you confirm, returning the issue URL. The authoritative procedure lives in [`skills/issue/SKILL.md`](./skills/issue/SKILL.md).

`refine` targets an existing issue by number or URL. In interactive mode (Mode 1) it fetches the issue, opens a conversation to identify what needs updating, and applies a format-conforming body edit via `gh issue edit` after explicit confirmation. In comment-processing mode (Mode 2, `--comments` flag) it enumerates the issue's comments, skips any already marked `:eyes:` by the running identity, processes the rest as inline requests, and adds an `:eyes:` reaction to each processed comment — making re-runs idempotent. The authoritative procedure lives in [`skills/refine/SKILL.md`](./skills/refine/SKILL.md).

See [`index.md`](./index.md) for the full layout and [`ai/issue-format.md`](./ai/issue-format.md) for the format spec — both auto-loaded into every Claude session that runs in a winter workspace with this extension installed.

## License

MIT.
