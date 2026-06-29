# AGENTS.md

Conventions and the full working agreement live in **CLAUDE.md** — read it first.

Quick version for any coding agent (Claude Code, Cursor, Codex):

- **Plan before coding.** Restate the task, list the data model + endpoints + UI,
  say what's out of scope, then wait for go-ahead.
- **Work in vertical slices:** schema → endpoint → test → UI → demo → commit.
- **Test-first** on anything with logic; **show the test/curl output** — never
  claim "done" without evidence.
- **Small, scoped diffs.** Don't touch unrelated code or rename without asking.
- **Honor the Definition of Done** in CLAUDE.md (validation, a sad-path test,
  passing `pytest` + `ruff` + `tsc`, seedable data, error envelope, no secrets).

Run: `docker compose up --build` · Test: `cd backend && pytest`.
