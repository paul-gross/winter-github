# GitHub issues

Raise and refine GitHub issues from a winter workspace using a precise, AI-native format. Uses the [`gh`](https://cli.github.com/) CLI to file issues against the appropriate repository.

## Path notation

Files in this extension are addressed with the `winter-github:` prefix — for example, `winter-github:/context/issue-format.md`. Resolve to the on-disk path via the `# Winter Extensions` block in workspace `CLAUDE.md`; the local directory name varies (`./.winter/ext/github/`, `./winter-github/`, etc.).

## Skills and conventions

| Topic | Read when… |
|-------|------------|
| [`issue` skill](./skills/issue/SKILL.md) | …you need to draft and file a new issue |
| [`refine` skill](./skills/refine/SKILL.md) | …you need to update or process comments on an existing issue |
| [Issue conventions hub](./context/index.md) | …you need the issue-writing conventions — format, repo selection, epics, gh-cli, injection tests |
