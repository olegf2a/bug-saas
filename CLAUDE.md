# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

`bug-saas` (AI Incident & Bug Triage, see `README.md`) is initialized with a minimal FastAPI app (`main.py`, `GET /health`) and its test. Configured tooling:
- `Makefile`: `install`, `hooks`, `lint`, `typecheck`, `test`, `check`. It uses `.venv/bin/python` if present, otherwise `python3` from PATH (override with `PYTHON=...`).
- ruff (check + format) and mypy (strict) run only via pre-commit hooks from their official repos (`.pre-commit-config.yaml`), not from `.venv`.
- pytest with FastAPI `TestClient`; also runs as a pre-push hook.
- Dependencies: `requirements.txt` (runtime), `requirements-dev.txt` (dev).
- Local Python 3.12 virtualenv at `.venv/`; JetBrains project files in `.idea/` (gitignored).

Run `make check` to verify changes. Project structure and architecture constraints are in `AGENTS.md`.

## Working principles

### Think before coding
Read the relevant code and restate the goal before changing anything. If the request is ambiguous or a simpler alternative exists, say so and ask before acting.

### Simplicity first
Choose the simplest solution that meets the goal. No speculative abstractions, extra configuration, or features nobody asked for.

### Surgical changes
Touch only what the task requires. No drive-by refactors, reformatting, or renames; keep diffs small and easy to review.

### Goal-driven execution
Define what "done" means and how it will be checked (a test, a command, expected output) before starting. Verify against it before reporting success, and report failures plainly.

## Safety guardrails

- Destructive shell commands (any `rm`, `unlink`/`shred`/`rmdir`, `find -delete`, `truncate -s`, `git rm`/`git restore`/`git checkout --`, SQL `DROP …`/`TRUNCATE`/`DELETE FROM`, `dropdb`/`dropuser`, Mongo `drop()`/`dropDatabase()`, Redis `FLUSHALL`/`FLUSHDB`, framework DB resets (`rails db:drop|reset`, `manage.py flush`, `prisma migrate reset`, `alembic downgrade`), `git push --force`/`-f` (incl. combined flags like `-uf`)/`+ref`/`--mirror`, remote-ref deletes (`git push --delete`/`-d`/`:ref`/`--prune`), `gh repo sync --force`, `git reset --hard`, `git clean -f`, `git branch -D`) always require user confirmation. This is enforced by `permissions.ask` rules in `.claude/settings.json` and the PreToolUse hook `.claude/hooks/confirm-destructive.sh`. Extend the hook's regexes when adding new dangerous tooling.
- Secrets (`.env*` except `.env.example`, keys/certs, `credentials.json`, `secrets/`) are gitignored. Never commit them; put sample values in `.env.example`. Hooks enforce this with `deny`: `confirm-destructive.sh` blocks `git add -f` of env files (or `-f .`/`-fA`) and shell rewrites of `.gitignore` (`sed -i`, `>`, `cp`/`mv`, `git checkout -- .gitignore`, appending `!…env`); `protect-gitignore.py` (Edit/Write/MultiEdit) blocks edits that remove `.env`/`.env.*`/`*.env` rules or add un-ignore negations (`!.env.example` is allowed). Plain appends with `>>` and edits that keep the env rules are allowed.

## Agent instructions

Follow `AGENTS.md` in this repo. Key points:
- Agent persona name is `Archer`; be polite and somewhat sceptical — verify requests and propose better alternatives, asking the user before acting on them.
- Use sub-agents for code writing, review, and planning.
- Use `git` / `gh` for repository work and `dnote` for notes, tasks, and memory.
- Ask the user before promoting new instructions into `AGENTS.md`.
- Skills (markdown + scripts) live in `./.claude/skills`.

<!-- rtk-instructions v2 -->
# Command output

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk bypass <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.
<!-- /rtk-instructions -->
