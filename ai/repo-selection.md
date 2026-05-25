# Repo Selection

How `/wg-issue` decides which GitHub repository to file against.

The skill almost always runs from the workspace root, so the working directory's git remote is uninformative (it points at the workspace itself). The real signal is **what the conversation has been about** — which project, command, file, or worktree.

## Migration note

Repos under the `paul-gross/` org on GitHub are being stood up incrementally as part of the move off Codeberg. Not every winter-ecosystem repo has a GitHub counterpart yet — until a repo is migrated, `/wg-issue` will fail at the `gh issue list` access check (Step 2 of the skill). When that happens, surface the missing target to the user and offer to either (a) wait until migration, or (b) fall back to `/wc-issue` against the Codeberg copy.

## The rule

> **Never file against the workspace repo.** A workspace-named repo (e.g. `paul-gross/winter-workspace`) is a thin configuration layer over winter and is not a valid issue target. Anything that looks workspace-level is really a winter issue or a winter-extension issue — re-route it (see [Re-routing apparent workspace-level issues](#re-routing-apparent-workspace-level-issues) below).

1. **Infer the project from the conversation.**
   - Identify the project the user is filing an issue *about*: the repo whose code, commands, behavior, or files the conversation has been discussing.
   - Resolve the project's short name to a GitHub `<owner>/<name>` by reading `workspace:/.winter/config.toml`. Match against `[[project_repository]].name`; the matching repo's GitHub slug under `paul-gross/<name>` is authoritative once the repo is migrated. If the config still records the Codeberg URL, the GitHub mirror is `paul-gross/<name>` (one-to-one with the Codeberg repo name).
   - If nothing in the conversation points to a single project, re-route per [Re-routing apparent workspace-level issues](#re-routing-apparent-workspace-level-issues) — do **not** fall back to the workspace repo.
2. **Check the inferred repo's `CONTRIBUTING.md` for explicit routing.**
   - Open `CONTRIBUTING.md` at the root of the inferred repo (in whichever worktree has it checked out). If it routes issues elsewhere — "file bugs at `<owner>/<name>`", "use the tracker at <URL>", a `## Issues` section — surface that to the user at confirmation alongside the inferred target.
   - If `CONTRIBUTING.md` is silent on issue routing, ignore it.
3. **Confirm with the user before filing.**
   - Always show the inferred target (and the `CONTRIBUTING.md`-routed target if different) and offer to override. Never file silently.

## Signals for inferring the project

In rough order of strength:

- **File paths in the conversation** — edits or reads in `alpha/winter-github/`, `beta/winter-product/`, or `.winter/ext/<name>/` map directly to the corresponding project.
- **Repo names mentioned by name** — "the winter-github extension", "winter-cli's connect command".
- **Components or commands discussed** — map mention → target repo:
  - `winter` CLI commands (`winter ws *`, `winter repo *`, `winter dashboard`) → `paul-gross/winter`
  - `/wg-issue`, GitHub conventions, issue format → `paul-gross/winter-github`
  - `/wc-issue`, Codeberg conventions, `tea` cheatsheet → `paul-gross/winter-codeberg` (parallel coexistence during the migration)
  - `/wf-blizzard`, `/wf-thaw`, `/wf-cold-review`, `/wf-harness-review`, `/wf-commit`, blizzard team agents (architect, developer, …) → `paul-gross/winter-workflow`
  - `/wp-refine`, `/wp-todo`, backlog / work-item model → `paul-gross/winter-product`
  - `./up` / `./down` / `./status`, tmux service orchestration, `workflow.sh` → `paul-gross/winter-service-tmux`
  - Python conventions (DI, repository pattern, error handling), exemplars → `paul-gross/winter-harness`
- **Workflow position** — if the user just finished work in a worktree, that worktree's project is the most likely target.

If multiple signals point to different repos, surface the candidates at confirmation rather than picking blindly.

## Re-routing apparent workspace-level issues

The workspace is never the target. Anything that looks "workspace-level" belongs in winter or in a winter extension. Pick by what the issue is actually about:

- **About how the workspace consumes winter** — CLI behavior, framework convention, `winter ws *` lifecycle, hook contract, `.winter/config.toml` schema → `paul-gross/winter`
- **About a specific extension's surface** — a skill, agent, convention file, or hook owned by one extension → that extension's repo (`paul-gross/winter-github`, `paul-gross/winter-codeberg`, `paul-gross/winter-workflow`, `paul-gross/winter-product`, `paul-gross/winter-service-tmux`, `paul-gross/winter-harness`)
- **Spans multiple winter components without a single owner** — ecosystem-wide docs, cross-extension conventions, framework-level policy → default to `paul-gross/winter`, because winter is the framework that ties the pieces together

### Examples

- "The workspace-level `CLAUDE.md` should describe X" → re-routes to `paul-gross/winter` (the framework owns the workspace `CLAUDE.md` template and conventions, not a separate workspace project).
- "Our Python conventions need a new section on Y" → re-routes to `paul-gross/winter-harness` (the conventions repo owns Python guidance).
- "The `/wg-issue` skill should also do Z" → re-routes to `paul-gross/winter-github` (the extension owning the skill).
- "We need a routing rule for cross-cutting documentation spikes" → re-routes to `paul-gross/winter` (cross-cutting framework rule with no single extension owner).

## Override

The user can always answer the confirmation prompt with a different `<owner>/<name>` pair. Use the override verbatim; don't re-apply the rule to it.
