export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)
SHELL := /bin/bash
MAKE_FILES = ${MAKE_PATH}/Makefile

github_tag = $(shell git describe)

## Format Terraform code
fmt:
	terraform fmt --recursive

## Upgrade examples/complete test workspace
upgrade:
	cd examples/complete && \
		terraform init -upgrade=true

## Run a test plan
plan:
	cd examples/complete && \
		terraform init && \
		aws-vault exec $(profile) -- terraform plan

## Install pre-commit hooks
pre-commit/install:
	pre-commit install --install-hooks --allow-missing-config -t pre-commit

## Create github release
release:
	gh release create v$(github_tag) -n $(notes)

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"
	@printf "\n"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKE_FILES) | sort -u
