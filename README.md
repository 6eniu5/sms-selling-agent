# SMS Selling Agent

A text-based agent that sells items over SMS: buyers text in with questions and
offers, the agent classifies each message, negotiates within the seller's rules,
and tracks offers per buyer until the auction closes.

- **Backend:** Python 3.12 · FastAPI · SQLModel · PostgreSQL/SQLite · Redis · OpenAI
- **Frontend:** React · TypeScript · Vite · Tailwind · TanStack Query
- **Infra:** Docker Compose · GitHub Actions CI

This repo is a thin top level (scripts + docs) wrapping two **git submodules**:
[`backend`](https://github.com/6eniu5/sms-selling-agent-backend) and
[`frontend`](https://github.com/6eniu5/sms-selling-agent-frontend).

```bash
# Clone WITH submodules:
git clone --recursive git@github.com:6eniu5/sms-selling-agent.git
# Already cloned without --recursive?
git submodule update --init --recursive
```

## Run it locally (handover quickstart)

The SMS selling-agent backend runs with **one command — no Docker, Postgres, or
Redis needed** (it uses a local SQLite file and seeds the demo auction on start):

```bash
cd backend
./scripts/run_local.sh      # creates venv, installs deps, serves on :8000
```

> Requires **Python 3.11–3.13** (the `psycopg2-binary` pin has no 3.14 wheel yet)
> and Node 18+ for the frontend. `run_local.sh` auto-picks a suitable Python.

- API + interactive docs → http://localhost:8000/docs
- Health → http://localhost:8000/health
- A live "iPhone 15 Pro" auction (min $500) is seeded automatically.

### 1. Add the OpenAI key (optional but recommended)

The agent classifies messages and writes replies with OpenAI. Put your key in
`backend/.env` (copy from `backend/.env.example`):

```bash
# backend/.env
KEY="sk-proj-...your key..."
```

Verify the key actually works before running:

```bash
cd backend && ./scripts/check_openai_key.sh   # expects HTTP 200 + "pong"
```

**Without a valid key the system still runs** — it falls back to a deterministic
rule-based agent, so nothing breaks; you just don't get LLM-quality replies.

### 2. Try it

```bash
# send an incoming SMS (the agent replies asynchronously)
curl -X POST http://localhost:8000/api/sms/inbound \
  -H 'Content-Type: application/json' \
  -d '{"buyer_username":"alice","text":"I will pay $700 for the iPhone"}'

# then read the thread + offers
curl "http://localhost:8000/api/convos?buyer_username=alice"
curl "http://localhost:8000/api/convos/1/messages"
curl "http://localhost:8000/api/listings/1/offers"
```

### Frontend (the SMS simulator UI)

In a second terminal, with the backend running on :8000:

```bash
cd frontend
npm install
npm run dev          # opens http://localhost:5173
```

Open http://localhost:5173: text the agent as different buyers (each is a tab),
watch its replies arrive, and see offers update live on the right. The backend URL
defaults to `http://localhost:8000` (override with `VITE_API_URL`).

### Full stack with Docker (Postgres + Redis)

```bash
docker compose up --build      # web :5173, API :8000, with Postgres + Redis
```

## What's inside

```
backend/                FastAPI + SQLModel + Postgres + Redis
  app/
    main.py             app factory, CORS, error envelope, lifespan
    config.py           env-driven settings (pydantic-settings)
    db.py               engine + session dependency
    redis_client.py     Redis client (wired, available for caching/locks/queues)
    models.py           SQLModel tables  (Note — the reference entity)
    schemas.py          request/response models (API contract)
    crud.py             data-access layer
    routers/            health.py, notes.py
  tests/                pytest (in-memory SQLite — fast, no Docker)
  Dockerfile            multi-stage: dev (reload) / prod (workers)
frontend/               React + TS + Vite + Tailwind + TanStack Query
  src/
    lib/api.ts          typed fetch client + error handling
    lib/queryClient.ts  TanStack Query setup
    components/NotesPanel.tsx   reference list + create form
    App.tsx             app shell + live API status
  Dockerfile            multi-stage: dev (Vite) / prod (nginx)
docker-compose.yml      db + redis + api + web, with healthchecks
.github/workflows/ci.yml  lint + test backend, typecheck + build frontend
CLAUDE.md / AGENTS.md   how to work here + Definition of Done
Makefile                up / down / test / fmt / seed
```

## Test & lint

```bash
cd backend && pytest          # 5 tests, sub-second
cd backend && ruff check .
cd frontend && npm run typecheck && npm run build
```

## Adding a feature

Copy the `Note` vertical slice — full recipe in **CLAUDE.md → "Adding a feature."**
Order per slice: model → schema → crud → router → test → frontend, then demo and
commit. With `AUTO_CREATE_TABLES=true`, new tables appear on API restart.

## Build it out with Claude Code

This repo is the foundation; the working agreement in `CLAUDE.md` keeps an agent
on rails. High-level flow:

1. Point Claude Code at the repo and have it read `CLAUDE.md` + `AGENTS.md`; confirm the baseline is green.
2. Give it the problem; ask for a **plan + slice order**, not code.
3. Build slice by slice — failing test first, then implement, show the output, commit.
4. Add infra (workers, caching, external APIs) only as the task needs it.
5. Finish with a Definition-of-Done pass and a demo.

## Decisions (fill in as you build)

- _Data model:_ …
- _Key tradeoffs / cuts:_ …

## With more time

Alembic migrations · authn/z · rate limiting + idempotency · caching · async workers ·
JSON logs + OpenTelemetry · cursor-based pagination · load testing.
