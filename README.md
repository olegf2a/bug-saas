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
| Local infrastructure | Docker Compose (PostgreSQL, Redis) |
| LLM provider | TBD (week 3)  |
| Vector search / embeddings | TBD (week 3)  |
| MCP server | TBD (week 4) |
| Evals / monitoring | TBD (week 5) |
| Dev tooling | pytest, ruff, mypy (strict), pre-commit |

## Roadmap (5 weeks)

1. **Week 1:** Skeleton, quality gates, agent instructions, and guardrails.
2. **Week 2:** MVP core — ingestion of bug reports/logs, basic validation, and storage.
3. **Week 3:** RAG / AI integration — stack trace summarization, auto-classification, and
   duplicate detection.
4. **Week 4:** Tool calling & MCP server — an agent tool for working with bugs from the IDE / chat.
5. **Week 5:** Evals, monitoring, accuracy metrics, and release.
