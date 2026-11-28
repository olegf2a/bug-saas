# Use the project virtualenv if it exists, otherwise python3 from PATH.
# Override with: make test PYTHON=/path/to/python
VENV ?= .venv
PYTHON ?= $(if $(wildcard $(VENV)/bin/python),$(VENV)/bin/python,python3)

.PHONY: install lint typecheck test check hooks

install:
	$(PYTHON) -m pip install -r requirements-dev.txt

lint:
	$(PYTHON) -m pre_commit run ruff-check --all-files
	$(PYTHON) -m pre_commit run ruff-format --all-files

typecheck:
	$(PYTHON) -m pre_commit run mypy --all-files

test:
	$(PYTHON) -m pytest -q

check:
	$(PYTHON) -m pre_commit run --all-files --hook-stage pre-push

hooks:
	$(PYTHON) -m pre_commit install
