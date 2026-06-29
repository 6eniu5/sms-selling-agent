# CLAUDE.md — working agreement for this repo

> Read this first, every session. It defines how we work, our conventions, and
> the bar for "done." It's the convention source of truth for Claude Code,
> Cursor, and Codex (see AGENTS.md).

## What this is

A clean, Dockerized full-stack foundation — no domain logic baked in. It boots
green and ships one throwaway reference entity (`Note`) that proves the stack is
wired end-to-end. Build the real feature set on top of it.

- **Backend:** Python 3.12, FastAPI, SQLModel (SQLAlchemy + Pydantic), PostgreSQL, Redis.
- **Frontend:** React + TypeScript, Vite, Tailwind, TanStack Query.
- **Infra:** Docker Compose (Postgres, Redis, API, web), GitHub Actions CI.

## Run / test

- Whole stack: `docker compose up --build` → web on :5173, API + docs on :8000/docs.
- Backend tests (fast, SQLite, no Docker): `cd backend && pytest`.
- Lint: `cd backend && ruff check .` · Frontend: `cd frontend && npm run typecheck`.

## How we work (the loop)

Agentic engineering, not vibe coding: **research → plan → execute → review → ship**,
with the human as oversight at each gate.

1. **Plan before code.** When asked for a feature, restate it, list the data
   model + endpoints + UI you'll touch, name what you're NOT doing, and wait for
   a go-ahead. Don't jump straight to code.
2. **Vertical slices, one at a time.** Schema → migration/seed → one endpoint →
   its test → wire to UI → demo it works → commit. Then the next slice.
3. **Test-first on logic.** For anything with branching or rules, write a failing
   `pytest` first, then make it pass.
4. **Show evidence, not claims.** After a change, run the tests / curl the
   endpoint and show the output. Never say "done" without proof.
5. **Small diffs, scoped edits.** Touch only the files the slice needs. Don't
   refactor or rename unrelated code without asking.
6. **Context is infrastructure.** This file, the models, and the README are the
   shared context. Keep them current as the design moves.
7. **Commit per green slice** with a clear message so we can revert cleanly.

## Conventions

- **Layering:** routers (HTTP only) → `crud.py` (persistence) → `models.py`
  (tables). Request/response shapes live in `schemas.py`, decoupled from tables.
- **Validation at the boundary** with Pydantic; reject bad input with 422.
- **Errors** use one envelope: `{"error": {"code", "message", "details?"}}`
  (see `app/main.py`).
- **Lists are paginated** (`limit`/`offset` now; keyset/cursor when it matters).
- **Types everywhere** — Python type hints and strict TS. No `any`.
- **State as data.** If you add status fields, store them as plain strings and
  keep an Enum of valid values + a transitions map in code.

## Definition of Done

A slice is done when:
- [ ] The happy path works end-to-end and I've demoed it (UI or curl).
- [ ] Input is validated and there's at least one sad-path test (bad input / not found).
- [ ] Tests pass (`pytest`) and lint is clean (`ruff`, `tsc`).
- [ ] Data is seedable so the feature is runnable from scratch.
- [ ] Types are clean; the error envelope is used; no secrets in code.
- [ ] README notes the decision + what I'd do with more time.

> Production-ready (beyond an MVP) would also need, as applicable: Alembic
> migrations, authn/z, rate limiting + idempotency, caching, async workers,
> structured/JSON logs + OpenTelemetry, and load testing. Name these; build
> only what the task needs.

## Adding a feature (the recipe — copy `Note`)

To add an entity, e.g. `Thing`, touch these in order, one slice each:
1. `backend/app/models.py` — the SQLModel table (fields, indexes, relationships).
2. `backend/app/schemas.py` — `ThingCreate` / `ThingRead` (+ a page model).
3. `backend/app/crud.py` — create/get/list functions.
4. `backend/app/routers/things.py` — the endpoints; include it in `app/main.py`.
5. `backend/tests/test_things.py` — happy path + a sad path.
6. `frontend/src/types.ts` + a component modeled on `NotesPanel.tsx` (if it needs a UI).

With `AUTO_CREATE_TABLES=true` (dev), restarting the API creates new tables
automatically. For real migrations, switch it off and use Alembic.

## Extending the stack on demand

The foundation is deliberately minimal. Add infrastructure only when the task
calls for it, and keep it clean:
- **Background work / queues:** add a worker process; Redis is already available
  for a simple queue, locks, or pub/sub.
- **Caching / rate limiting / idempotency:** Redis is wired (`app/redis_client.py`).
- **External APIs or an LLM:** put each behind a small interface module so it's
  swappable and testable; validate any external/model output against a schema
  before you trust it. Keep money/state/decision logic deterministic.
