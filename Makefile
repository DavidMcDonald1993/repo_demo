SHELL := /usr/bin/env bash

-include .env
export

# Extract Python version from pythonLocation if set, otherwise use default
PYTHON_VERSION  ?= $(shell if [ -n "$$pythonLocation" ]; then $$pythonLocation/bin/python --version 2>&1 | cut -d' ' -f2; else echo "3.10.0"; fi)
SRC_DIR		   	:= src
TEST_DIR	   	:= tests
CHECK_DIRS	 	:= $(SRC_DIR) $(TEST_DIR)
PYTEST_FLAGS 	:= --no-header


.PHONY: all
all: help

.PHONY: help
help: ## Show the available commands
	@echo "Available commands:"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Builds the package
	uv build

.PHONY: install-dependencies
install-dependencies: ## Install dependencies from the lock file
	uv sync --python $(PYTHON_VERSION)

.PHONY: install-pre-commit
install-pre-commit: ## Install pre-commit hooks
	uv run pre-commit autoupdate
	uv run pre-commit install

.PHONY: install
install: install-dependencies install-pre-commit ## Install local environment

.PHONY: install-ci
install-ci: install-dependencies ## Install ci environment

.PHONY: update
update: ## Update python dependencies
	uv lock --upgrade

.PHONY: format
format: ## Format repository code
	uv run ruff format $(CHECK_DIRS)

.PHONY: format-check
format-check: ## Check the code format
	uv run ruff format --check $(CHECK_DIRS)

.PHONY: lint
lint: ## Lint repository code
	uv run ruff check --fix $(CHECK_DIRS)

.PHONY: lint-check
lint-check: ## Check the code lint
	uv run ruff check $(CHECK_DIRS)

.PHONY: type-check
type-check: ## Launch the type checking tool
	uv run mypy --ignore-missing-imports $(CHECK_DIRS)

.PHONY: test
test: ## Launch basic (fast) tests
	uv run pytest $(PYTEST_FLAGS) $(TEST_DIR)

.PHONY: check
check: format-check lint-check type-check test ## Launch all checks to approve the code

.PHONY: clean
clean: ## Clean the repository
	rm -rf dist
	rm -rf *.egg-info

.PHONY: publish
publish: clean build ## Publishes the package to Artifactory
	UV_PUBLISH_USERNAME=$(ARTIFACTORY_USER) \
	UV_PUBLISH_PASSWORD=$(ARTIFACTORY_APIKEY) \
	uv publish --index artifactory

.PHONY: release
release: ## Releases a new version of the package
	@current_branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$current_branch" != "master" ]; then \
		echo "Error: You must be on the master branch to create a release. Current branch: $$current_branch"; \
		exit 1; \
	fi; \
	git fetch origin master; \
	local_commit=$$(git rev-parse HEAD); \
	remote_commit=$$(git rev-parse origin/master); \
	if [ "$$local_commit" != "$$remote_commit" ]; then \
		echo "Error: Your local master branch is not up to date with origin/master."; \
		echo "Please run 'git pull origin master' first."; \
		exit 1; \
	fi; \
	current_version=$$(uv version --short); \
	latest_version=$$(gh release view --json tagName --jq .tagName); \
	echo "Current version: $$current_version"; \
	echo "Latest version: $$latest_version"; \
	if [ "$$latest_version" != "$$current_version" ]; then \
		echo "Creating GitHub release from master for version $$current_version"; \
		gh release create $$current_version \
			--title "Release $$current_version" \
			--target master \
			--generate-notes; \
	else \
		echo "No version change detected. Skipping release."; \
	fi

.PHONY: docs
docs: install ## Builds the static documentation site with Mockumentary
	uv run mockumentary build

.PHONY: docs-serve
docs-serve: ## Serves the documentation locally with hot-reloading
	uv run mockumentary serve

.PHONY: bump-patch
bump-patch:
	uv version --bump patch

.PHONY: bump-minor
bump-minor:
	uv version --bump minor

.PHONY: bump-major
bump-major:
	uv version --bump major
