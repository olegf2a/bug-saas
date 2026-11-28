# AI Incident & Bug Triage

**Track:** 1. AI-First Web Service / SaaS Backend

## Purpose

A service that accepts bug reports and alerts from monitoring or a ticketing system, matches them
against logs, documentation, and the codebase, and suggests:

- a first-pass solution;
- tags;
- the responsible engineer.

## Architecture stack

| Component | Technology |
|---|---|
| Web API | FastAPI |
| Models and validation | Pydantic v2 |
| Database | PostgreSQL |
| ORM / database access | SQLAlchemy 2.0 + psycopg 3, migrations through Alembic |
| Storage for new bug reports | Redis |
| Queue processing | Dramatiq |
| ASGI server | Uvicorn |
| Settings / env config | pydantic-settings |
| App container | Docker (`Dockerfile`) |
| Local infrastructure | Docker Compose (PostgreSQL, Redis) |
| LLM provider | TBD (week 3)  |
| Vector search / embeddings | TBD (week 3)  |
| MCP server | TBD (week 4) |
| Evals / monitoring | TBD (week 5) |
| Dev tooling | pytest, ruff, mypy (strict), pre-commit |
| CI | GitHub Actions (`make check` on every pull request) |

## Project structure

```
src/app/
  main.py         FastAPI app: creates the app and includes the routers
  api/            HTTP layer: FastAPI routers, one module per domain
  services/       business logic, independent of HTTP and storage
  models/         Pydantic v2 schemas: API contracts and domain entities
tests/            pytest tests (FastAPI TestClient)
requirements.txt      runtime dependencies
requirements-dev.txt  dev dependencies (pytest, httpx2, pre-commit)
pyproject.toml        project metadata, pytest and mypy settings
.pre-commit-config.yaml  ruff, mypy and file checks from the official hook repos
Makefile              install / lint / typecheck / test / check commands
Dockerfile            container image for the app
docker-compose.yml    app + PostgreSQL + Redis for local development
.env.example          sample values for .env (Compose settings)
.github/workflows/ci.yml  CI: runs `make check` on every pull request
.github/workflows/docker.yml  manual run: validates Compose and builds the Docker image
```

## Running locally

Requirements: Python 3.12+ and `make`.

```bash
python3.12 -m venv .venv
source .venv/bin/activate
make install     # install runtime and dev dependencies
make hooks       # install git hooks (pre-commit, pre-push)
python -m uvicorn app.main:app --app-dir src --reload
```

The API runs at <http://localhost:8000>:

- health check: <http://localhost:8000/health> returns `{"status": "ok"}`;
- interactive API docs: <http://localhost:8000/docs>.

## Running with Docker Compose

`docker-compose.yml` runs the app together with PostgreSQL and Redis:

```bash
cp .env.example .env   # optional: change credentials or host ports
docker compose up --build
```

| Service | Address |
|---|---|
| app | <http://localhost:8000> (`APP_PORT`) |
| db (PostgreSQL 17) | `localhost:5432` (`POSTGRES_PORT`) |
| redis (Redis 7) | `localhost:6379` (`REDIS_PORT`) |

The app gets `DATABASE_URL` and `REDIS_URL` from Compose; it does not use them yet (week 2).
Stop with `docker compose down`; add `-v` to also delete the database and Redis data.

To run only the app container:

```bash
docker build -t bug-triage .
docker run --rm -p 8000:8000 bug-triage
```

## Development commands

| Command | What it does |
|---|---|
| `make install` | Install dependencies from `requirements-dev.txt` |
| `make hooks` | Install the git hooks |
| `make lint` | ruff check and ruff format (via pre-commit) |
| `make typecheck` | mypy in strict mode (via pre-commit) |
| `make test` | Run pytest |
| `make check` | Run all hooks including pytest; the same check CI runs |

The `Makefile` uses `.venv/bin/python` if it exists, otherwise `python3` from `PATH`. Override it
with `make test PYTHON=/path/to/python`.

## Roadmap (5 weeks)

1. **Week 1:** Skeleton, quality gates, agent instructions, and guardrails.
2. **Week 2:** MVP core — ingestion of bug reports/logs, basic validation, and storage.
3. **Week 3:** RAG / AI integration — stack trace summarization, auto-classification, and
   duplicate detection.
4. **Week 4:** Tool calling & MCP server — an agent tool for working with bugs from the IDE / chat.
5. **Week 5:** Evals, monitoring, accuracy metrics, and release.
