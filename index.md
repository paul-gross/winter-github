# GitHub issues

Raise and refine GitHub issues from a winter workspace using a precise, AI-native format. Uses the [`gh`](https://cli.github.com/) CLI to file issues against the appropriate repository.

## Path notation

Files in this extension are addressed with the `winter-github:` prefix — for example, `winter-github:/context/issue-format.md`. Resolve to the on-disk path via the `# Winter Extensions` block in workspace `CLAUDE.md`; the local directory name varies (`./.winter/ext/github/`, `./winter-github/`, etc.).

## Skills and conventions

| Topic | Where to read |
|-------|---------------|
| `issue` skill — draft and file a new issue | [`skills/issue/SKILL.md`](./skills/issue/SKILL.md) |
| `refine` skill — update or process comments on an existing issue | [`skills/refine/SKILL.md`](./skills/refine/SKILL.md) |
| Issue format, repo selection, gh-cli cheatsheet | [context/index.md](./context/index.md) |
