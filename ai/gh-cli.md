# GH CLI Notes

Just the things specific to filing issues against GitHub via `/issue`. The agent already knows `gh`'s general surface.

## One-time setup

Interactive (the standard path):

```
gh auth login --hostname github.com
```

Pick `HTTPS` as the protocol if you don't want to manage SSH keys, and let `gh` upload an OAuth token to the keyring. The flow opens a browser for OAuth.

Non-interactive (CI, scripts, machine accounts):

```
echo "<personal-access-token>" | gh auth login --hostname github.com --with-token
```

Generate the token at https://github.com/settings/tokens with the `repo` and `read:org` scopes at minimum. Verify with `gh auth status`.

**Verify with `winter doctor`.** This extension contributes probes that check the `gh` prerequisites for `/issue` — the canonical "is my setup correct?" check before filing. The probes live at `scripts/doctor.sh` (registered via `doctor = "scripts/doctor.sh"` in `winter-ext.toml`), which is their single source of truth; reachability is a `warn`-level probe, so a transient network blip won't block `/issue`.

## Filing an issue

The recommended invocation — `--body-file` reads from a file to keep multi-line markdown intact without shell-quoting hell:

```
gh issue create \
  --repo <owner>/<name> \
  --title "<title>" \
  --body-file /tmp/issue-body.md \
  --label "type:feature,complexity:small"
```

Labels must already exist on the target repo. `gh issue create --label` rejects any label that isn't defined. **Prefer bootstrapping** the canonical workspace label set when a label is missing rather than silently dropping it (see *Bootstrapping the canonical label set* below). Fall back to dropping the label only if the user declines.

`gh issue create` returns the issue URL on stdout — capture it for the Step 6 report.

## Viewing an existing issue

`gh` has a first-class `view` subcommand. Default output is a colored terminal renderer; pass `--json` to get a parseable shape with the body intact:

```
# get one issue's body + metadata
gh issue view <N> --repo <owner>/<name> --json title,body,labels,state

# or list with bodies
gh issue list --repo <owner>/<name> --json number,title,body --state open
```

Use `--json` for any multi-line body — the default human renderer wraps and reflows.

## Bootstrapping the canonical label set

`workspace:/ai/github.md` is the **single source of truth** for both label names and hex colors. The block below is a mirror — when it drifts from the workspace table, the workspace wins. Do not fork colors here or in any other extension doc.

When `gh issue create` rejects a label as undefined, **offer to create the full canonical set** rather than silently dropping. All eight labels in one block so a fresh repo lands on the canonical set in one shot:

```
gh label create "type:feature"       --repo <owner>/<name> --color "0e8a16" --description "New capability"
gh label create "type:bug"           --repo <owner>/<name> --color "d73a4a" --description "Something is broken"
gh label create "type:chore"         --repo <owner>/<name> --color "cccccc" --description "Maintenance, housekeeping"
gh label create "type:refactor"      --repo <owner>/<name> --color "1d76db" --description "Internal restructuring, no behavior change"
gh label create "type:spike"         --repo <owner>/<name> --color "5319e7" --description "Time-boxed investigation"
gh label create "complexity:trivial" --repo <owner>/<name> --color "ededed" --description "Author estimate: trivial"
gh label create "complexity:small"   --repo <owner>/<name> --color "fbca04" --description "Author estimate: small"
gh label create "complexity:large"   --repo <owner>/<name> --color "e99695" --description "Author estimate: large"
```

`gh label create` is idempotent only when `--force` is passed — without it, a second run fails with `label already exists`. When bootstrapping into a repo that already has *some* of the canonical labels, prefer creating the missing ones one-by-one rather than blasting the full block with `--force` (which would overwrite colors and descriptions on labels the user may have customized).

## Re-labeling or editing an existing issue

`gh` exposes this natively — no API fallback needed:

```
# add labels (comma-separated, repeatable)
gh issue edit <N> --repo <owner>/<name> --add-label "type:bug,complexity:small"

# remove a label
gh issue edit <N> --repo <owner>/<name> --remove-label "complexity:large"

# change title
gh issue edit <N> --repo <owner>/<name> --title "New title"

# replace body from a file
gh issue edit <N> --repo <owner>/<name> --body-file /tmp/new-body.md
```

Confirm with the user before mutating an existing issue.

## GitHub-API fallback

For anything `gh` doesn't expose directly — bulk operations, advanced project-board queries, repo settings the CLI hasn't caught up to — use `gh api` with the same auth context. No separate token plumbing required.

```
# raw GET — list issues with custom field projection the CLI doesn't offer
gh api repos/<owner>/<name>/issues?state=open&per_page=100 \
  --jq '.[] | {number, title, labels: [.labels[].name]}'

# POST / PATCH — body via --input or --field
gh api repos/<owner>/<name>/issues/<N> -X PATCH \
  --input - <<<'{"state":"closed","state_reason":"completed"}'

# paginated GET — let `gh api` follow Link headers
gh api repos/<owner>/<name>/issues --paginate \
  --jq '.[] | .number'
```

Common cases that *do* warrant the API fallback today:

- Bulk relabeling across many issues — loop over `gh api repos/.../issues?labels=old-label --paginate` and `PATCH` each.
- Listing or mutating issue *comments* by ID — `gh issue comment` only appends; comment edits/deletes go through `repos/<owner>/<name>/issues/comments/<comment-id>`.
- Repo-level settings (default branch, label color migrations across many repos) — `gh api repos/<owner>/<name> -X PATCH`.

Confirm with the user before any mutation through the API fallback.

## GitHub-specific failure modes

If `/issue` fails, run `winter doctor` first — the `gh github.com auth` and `api.github.com reachable` probes catch standing prerequisite breakage. The table below covers failures that only surface at file-time (token expired mid-session, secondary rate limits, label-set drift, repo doesn't exist).

| Error | Cause | Recovery |
|-------|-------|----------|
| `Could not resolve to a Repository` / `HTTP 404` on issue create | Repo doesn't exist or you lack access | Ask user to create it or correct the target. |
| `'<x>' is not a valid label` | Label not yet defined on the repo | Drop the label and file without it; tell user to add the label after. Prefer bootstrapping the canonical set. |
| `HTTP 401: Bad credentials` | Token expired or `gh auth login` not set up for `github.com` | Point user at the setup section above. |
| `HTTP 403: API rate limit exceeded` / `secondary rate limit triggered` | Burst of API calls within a short window | Wait the duration `gh` reports (`Retry-After` header for primary limits; ~60s for secondary). Don't retry blindly. |
| `HTTP 422: Validation Failed` on label create | Label already exists | Skip it; the canonical set is convergent, not exhaustive. |
| `HTTP 5xx` from `api.github.com` | GitHub under load or incident | Check `gh issue list --repo <target> --limit 5` to see whether the issue was actually created before retrying. |
