# Epics

An **epic** is a large body of work that decomposes into several child issues delivered independently. The epic is a parent tracking issue; the children are the units of work. This convention keeps a decomposed epic legible in a flat issue list — without it, the epic and its children scatter and read as unrelated issues.

Three mechanisms tie an epic together, and all three are required:

1. A **`[EPIC]` title prefix** on the parent and a **`[<TAG>]` title prefix** on every child.
2. The **`type:epic` label** on the parent.
3. A **GitHub sub-issue link** from the parent to each child (the parent becomes the child's parent issue).

## Title prefixes

The epic's title is prefixed with a literal `[EPIC]`:

```
[EPIC] Build a mono/polyrepo Winter autonomy benchmark
```

Every child's title is prefixed with the epic's **tag** — a short, all-caps, single-token keyword that names the epic's subject, in square brackets:

```
[BENCHMARK] Mechanically derive the polyrepo fixture from winter-test-service
[BENCHMARK] Author the four-task prompt suite plus the compound task
```

The tag rule:

- All caps, a single token (no spaces), kept short — aim for ≤ 12 characters.
- Names the epic's subject, not the word "epic" — `BENCHMARK`, not `EPIC1`.
- Declared once in the epic's `epic_tag` metadata field (below) and reused **verbatim** on every child.

The bracket prefix is in addition to the normal title — the descriptive remainder still follows the [issue-format](./issue-format.md) title rules (imperative mood, lead with the change).

## Metadata block

Epics and children both use the standard [issue-format](./issue-format.md) metadata block, with epic-specific keys.

**Epic** metadata uses `type: epic`, declares the child `epic_tag`, and omits `complexity` (an epic's size is the sum of its children, sized individually):

```yaml
type: epic
epic_tag: BENCHMARK
related: []
```

**Child** metadata is an ordinary issue's metadata plus an `epic` key naming the parent. The child keeps its own real `type` and `complexity`:

```yaml
type: feature
complexity: large
epic: "#118"
related: []
```

| Key | Where | Values |
|-----|-------|--------|
| `type: epic` | epic only | Marks the parent. Mutually exclusive with the other `type:` values. |
| `epic_tag` | epic only | The all-caps child-title tag. Required on epics. |
| `epic` | child only | The parent epic, as a bare `#N` (always same-repo — see the sub-issue link section). |

## The `type:epic` label

The parent carries the `type:epic` label and **no other `type:` label** — `epic` replaces the type slot rather than stacking on it. Children carry their own `type:` label as normal; they do **not** carry `type:epic`.

`type:epic` is part of the canonical label set. Color and description live in `workspace:/context/github.md` (the single source of truth).

## Parent / child sub-issue link

The epic is the **parent issue** of each child via GitHub's sub-issues feature. The `[<TAG>]` prefix and `epic:` metadata are human/agent-readable signals; the sub-issue link is the machine-readable one that drives GitHub's tracking UI. Create all three.

**An epic and all of its children live in one repository.** A GitHub sub-issue link cannot cross repositories, so the parent link only resolves when the child is filed in the same repo as the epic — which is why the `epic` metadata names the parent by a bare `#N`, never a cross-repo URL. When an epic's work naturally spans several repos, pick the single repo where it is **most applicable** as the epic's home and file every child there.

The `gh` invocations to link, list, and unlink sub-issues are at [`gh-cli.md#sub-issues-epic-parentchild-links`](./gh-cli.md#sub-issues-epic-parentchild-links).

## What is and is not an epic

Use an epic when a single goal genuinely fans out into several independently deliverable issues that benefit from being tracked together. Signs you have an epic:

- The work spans multiple repositories, milestones, or weeks.
- You are about to file 3+ issues that all serve one named outcome.
- A reader scanning the backlog would otherwise not see that the children belong together.

Do **not** mint an epic for a single issue with a checklist of acceptance criteria — that is just an issue. The epic earns its overhead only once there are real child issues to parent.
