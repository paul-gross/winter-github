# Issue Format

Every GitHub issue filed via `/wg-issue` uses this format. The format is opinionated on purpose — agents that pick up an issue later should be able to parse it without prompting.

## Title

- Imperative mood, one line, no period.
- Lead with the change, not the symptom: `Add winter ws checkout subcommand`, not `Worktrees can't adopt remote branches`.
- For bugs, prefix with `Bug:` — e.g. `Bug: ws connect silently fails on missing remote ref`.
- Under 70 characters when possible. Detail belongs in the body.

## Body

The body is markdown with a fenced YAML metadata block followed by fixed-name sections. Sections appear in this order. Omit a section only when its heading would have no content (e.g. no `Out of Scope` because everything in scope is stated positively).

### 1. Metadata block

A fenced `yaml` block at the very top. Keys:

| Key | Values | Notes |
|-----|--------|-------|
| `type` | `feature`, `bug`, `chore`, `refactor`, `spike` | One value. |
| `complexity` | `trivial`, `small`, `large` | Author's estimate. Not a contract. |
| `related` | list of issue URLs or `#NN` refs | Optional. Prior or blocking issues. |

Example:

```yaml
type: feature
complexity: small
related: []
```

### 2. Context

One short paragraph. Why does this issue exist? What's the current behavior or constraint that motivates the change? No solution yet.

Anchor to specifics — name the command, file, or concept — not vague phrases like "the system" or "users have problems."

### 3. Current Behavior

What happens today, stated concretely. Name the command, file, error, or step that exists now.

For a brand-new feature where nothing exists yet, write `N/A — new feature` and move on. For a bug, this is where reproduction steps and the actual observed result live.

### 4. Desired Behavior

What should happen instead. State the change directly — no hedging, no "we should consider."

When the behavior has multiple meaningful paths (happy path plus refusal paths plus edge cases), use **Given / When / Then** triples to enumerate them. Otherwise prose is fine.

Example of the optional triple form:

```
**Given** a worktree on its Greek-letter branch
**When** `winter ws checkout <wt> <feature>` is run
**Then** the worktree's branch reflects origin/<feature> in each repo
where that ref exists, with upstream tracking set.
```

Reach for triples only when the prose alternative would be a wall of "if / else if / else" — they're a tool, not a template.

### 5. Acceptance Criteria

A markdown checklist. Each item is testable in isolation — an agent should be able to read one item and know whether it's done. Avoid soft language ("works well", "is robust"). Prefer concrete observables.

```
- [ ] `winter ws checkout` subcommand registered and discoverable in `--help`
- [ ] Per-repo result line printed; non-zero exit if any repo fails
- [ ] Refuses on dirty or divergent worktree without `--force`
- [ ] `--json` mode mirrors existing commands
- [ ] Tests cover: happy path, missing remote, dirty worktree, divergent local
```

Three to seven items is the sweet spot. More than that usually means the issue should be split.

### 6. Out of Scope

A bulleted list of things this issue does **not** include — adjacent work, tempting expansions, the things a reviewer might ask about. This section is what keeps the issue from creeping.

```
- Creating new remote branches (use `git push -u` for that)
- Multi-branch operations per invocation
- Auto-stash of uncommitted changes
```

Skip this section when the scope is genuinely tight and unambiguous.

### 7. References

A bulleted list of pointers into the codebase or external sources. Use `file:line` format for code references — the same notation the agent uses to navigate.

```
- Existing impl: tools/winter-cli/src/winter_cli/modules/workspace/internal/write_repo_repository.py:61-78
- Related design note: winter-github:/ai/repo-selection.md
- GitHub CLI docs: https://cli.github.com/manual/
```

## Labels

Apply labels that correspond to the metadata block when filing. Standard label set:

- **Type:** `type:feature`, `type:bug`, `type:chore`, `type:refactor`, `type:spike`
- **Complexity:** `complexity:trivial`, `complexity:small`, `complexity:large`

Don't fabricate labels that don't exist on the target repo. If a label is missing, file the issue without it and let the user create the label after — or bootstrap the canonical set per [`gh-cli.md`](./gh-cli.md#bootstrapping-the-canonical-label-set).

## Writing rules

- **Specific over general.** Name files, commands, error messages. "The fetch step" beats "the network operation."
- **No filler.** Skip "We should consider…", "It would be nice to…". State the change directly.
- **No retrospectives.** Don't recap the conversation that led to the issue. The issue stands on its own.
- **Code references over screenshots.** If a screenshot is essential, attach it; otherwise prefer `file:line` pointers.
- **No emoji.** Not in titles, not in bodies. (Project-wide convention.)

## Anti-patterns

- Acceptance criteria that restate the title ("The feature is implemented")
- A Behavior section that's just a wish list instead of Given/When/Then
- Open-ended Out of Scope items ("We won't do anything fancy")
- A Context section that explains how the system works generally rather than what specifically motivates this change
