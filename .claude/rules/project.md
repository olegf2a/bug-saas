# Project rules

Basic rules for the AI Incident & Bug Triage service (see `README.md` and `AGENTS.md`).

## Code

- Python >= 3.12. Every function has type hints; code must pass `mypy --strict` and ruff.
- Request and response bodies are Pydantic v2 models, not raw dicts.
- Group endpoints with FastAPI `APIRouter`s, one router per domain (e.g. bug reports, alerts).
- Keep request handlers thin: validate, store, enqueue. Do slow or AI work in Dramatiq workers.
- Dramatiq tasks must be idempotent and safe to retry.
- Read configuration (database URL, Redis URL, API keys) from environment variables. Never
  hardcode secrets; put sample values in `.env.example`.

## Data

- PostgreSQL is the system of record; Redis holds new, unprocessed bug reports and the queue.
- Access PostgreSQL through SQLAlchemy 2.0 + psycopg 3; change the schema only through Alembic
  migrations.
- Do not send secrets or personal data from bug reports or logs to an LLM.

## Tests

- Every endpoint and task gets a pytest test; use FastAPI `TestClient` for endpoints.
- Unit tests must not need a real network, LLM, PostgreSQL or Redis: mock or fake them.
- Fix a bug by first adding a test that reproduces it.

## Workflow

- New runtime dependencies go into `requirements.txt` and into `additional_dependencies` of the
  `mypy` and `pytest` hooks in `.pre-commit-config.yaml`.
- Run `make check` before reporting a task as done.
- Work on a feature branch; keep commits small and focused.
