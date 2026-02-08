Contributing
============

Thanks for helping improve this project. This document explains the recommended developer workflow, how to run checks locally, and PR/branching guidelines.

Quick start
-----------

1. Install a supported Python (3.10+ recommended).
2. Install the small set of developer tools:

```bash
python -m pip install --upgrade pip
pip install uv
```

3. Install project dependencies and pre-commit hooks:

```bash
make install        # installs deps and pre-commit hooks via Makefile targets
pre-commit install  # registers git hooks in this clone
```

Running checks locally
----------------------

- Run all pre-commit hooks over the repo once:

```bash
pre-commit run --all-files
```

- Run the full validation pipeline (format, lint, type-check, tests):

```bash
make check PYTHON_VERSION=3.10
```

Tests
-----

- Tests live in the `tests/` directory. Run them with `pytest`:

```bash
pytest -q
```

Code style and static analysis
------------------------------

- We use `ruff` for formatting and linting (configured in `pyproject.toml`). The repo uses a 120-character line length.
- To auto-fix issues where possible:

```bash
uv run ruff format src tests
```

Pre-commit and gitleaks
-----------------------

- This repo's `.pre-commit-config.yaml` includes standard housekeeping hooks and a `gitleaks` hook configured as a `language: system` hook.
- `gitleaks` is intended to run on developers' machines (detect accidental secrets before push). It is not run in CI by default. If you want CI to run secret scans, update CI to install the `gitleaks` binary or use a containerized/mirrored hook.

Branching and Pull Requests
---------------------------

- Branch naming: use short feature/task branches (e.g., `feature/add-thing`, `bugfix/fix-typo`, or `task/NN/short-desc`).
- Open a PR against the default branch and include a short description of the change, motivation, and any testing performed.
- The repository's CI runs `make check` on pull requests. Ensure your branch passes CI before requesting review.

Commits and reviews
-------------------

- Keep commits small and focused. Use a short subject line (<=72 chars) and an optional body.
- Squash or rebase before merging if your team prefers a linear history.

CI notes
--------

- GitHub Actions runs the `ci.yml` workflow on pull requests; it checks out the code, sets up Python 3.10, installs `uv`, runs `make install-ci` and `make check`.
- The CI does not run the `gitleaks` system hook by default.

Troubleshooting
---------------

- If `pre-commit` complains about YAML or parsing errors, check `.pre-commit-config.yaml` for valid YAML and ensure hooks are pinned to a `rev`.
- If a `language: system` hook fails (e.g., gitleaks), install the required binary on your machine (brew/apt or download the release) or change the hook to a CI-compatible execution method.

Questions
---------

If anything is unclear or you need help getting set up, open an issue or mention the repository owner in a PR for guidance.
