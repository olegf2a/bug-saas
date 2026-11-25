BIN := .venv/bin

.PHONY: install lint typecheck test check hooks

install:
	$(BIN)/pip install -r requirements-dev.txt

lint:
	$(BIN)/ruff check .
	$(BIN)/ruff format --check .

typecheck:
	$(BIN)/mypy main.py tests

test:
	$(BIN)/pytest -q

check: lint typecheck test

hooks:
	$(BIN)/pre-commit install
