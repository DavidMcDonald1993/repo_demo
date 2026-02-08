# Repo Demo

This repository is a small Python project scaffold with developer convenience targets and CI hooks.

Repository layout
-----------------

- `Makefile` - Top-level developer Makefile. Provides targets for building, installing dependencies, formatting, linting, type checking, running tests, and a `check` target that runs the full validation pipeline.
- `pyproject.toml` - Project metadata and dependency groups. Dev dependencies (pytest, pre-commit, ruff, mypy, etc.) are declared here.
- `uv.lock` - Lockfile used by `uv` (the dependency/tool manager used by the Makefile).
- `LICENSE` - Repository license.
- `README.md` - This file.

Directories
-----------

- `src/` - The package source directory. Contains the Python package `repo_demo`.
- `tests/` - Test suite. Contains `test_dummy.py` as a placeholder and any other unit tests.

Tooling and important files
---------------------------

- `.pre-commit-config.yaml` - Defines pre-commit hooks that run locally before commits. This repo includes standard housekeeping hooks (end-of-file fixer, trailing-whitespace, YAML checks, large-file checks, merge conflict checks) and a local `gitleaks` hook configured to run as a system hook (so it runs on developer machines but is not required in CI unless explicitly installed).

- `.github/workflows/ci.yml` - GitHub Actions workflow that runs on pull requests. It checks out the code, sets up Python 3.10, installs `uv`, runs `make install-ci` and `make check` (which runs formatting checks, lint, mypy, and pytest via the Makefile).

- `Makefile` targets of note:
	- `make install-dependencies` - Install dependencies from the `uv.lock` lockfile.
	- `make install-pre-commit` - Install pre-commit hooks locally.
	- `make install-ci` - Install CI environment dependencies (used by `ci.yml`).
	- `make format` / `make format-check` - Format code with `ruff` and check formatting.
	- `make lint` / `make lint-check` - Lint with `ruff`.
	- `make type-check` - Run `mypy`.
	- `make test` - Run `pytest`.
	- `make check` - Runs `format-check`, `lint-check`, `type-check`, and `test`.

Developer workflow
------------------

1. Set up your environment (recommended Python 3.10+):

```bash
python -m pip install --upgrade pip
pip install uv pre-commit
```

2. Install project dependencies (local dev environment):

```bash
make install
```

3. Install pre-commit hooks in your clone:

```bash
pre-commit install
pre-commit run --all-files   # to run hooks over the full repo once
```

3.5 Local pre-push hook sample
------------------------------

This repository includes a sample local pre-push hook at `hooks/pre-push.sample`. It prevents accidental direct pushes to protected branches (by default `master`). This is a local safety net only — it must be copied into `.git/hooks/pre-push` and made executable in each clone.

To enable the sample hook in your local clone:

```bash
cp hooks/pre-push.sample .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

You can edit `hooks/pre-push.sample` to add other protected branches.

4. Run the full checks locally:

```bash
make check PYTHON_VERSION=3.10
```

CI notes
--------

- The GitHub Actions workflow runs `make check` on pull requests. It does not run the `gitleaks` hook by default (gitleaks is intentionally configured as a developer-only, `language: system` pre-commit hook).
- If you'd like pre-commit hooks to run in CI (excluding `gitleaks`), consider adding a CI step that installs `pre-commit` and runs a subset of hooks, for example:

```yaml
- name: Install pre-commit
	run: pip install pre-commit

- name: Run pre-commit (selected hooks)
	run: pre-commit run --all-files ruff mypy end-of-file-fixer
```

License
-------

See `LICENSE` for license terms.
