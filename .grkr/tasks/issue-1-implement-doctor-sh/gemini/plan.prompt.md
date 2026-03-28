# Task: Plan for Issue #1
Title: Implement doctor.sh

## Research Context
<!-- grkr:checkpoint stage=research task=issue-1-implement-doctor-sh version=1 -->
# Research: Implement doctor.sh

## Problem Statement
The autonomous shell-based agent requires a robust pre-flight check (`doctor.sh`) to verify that all necessary tools, authentication tokens, repository configurations, and GitHub Project settings are correctly in place. Without this, the agent might fail later in its execution loop with hard-to-diagnose errors. The current implementation of `doctor.sh` is incomplete and lacks verification of specific project field values and detailed token scope validation.

## Current System Behavior
- `doctor.sh` exists but is a partial implementation.
- It checks for the existence of tools (`jq`, `timeout`, `flock`, `git`, `gh`, `gemini`).
- It verifies `gh auth status` but does not parse token scopes.
- It checks if the git remote origin matches the `REPO` in `.grkr/config.sh`.
- It checks if the `.grkr` directory is writable.
- It verifies the existence of the configured GitHub Project and its fields (`Status`, `Priority`), but does not validate that the required options (like `Ready`, `Backlog`, `P0`, etc.) exist within those fields.
- It does not use the project's logging library (`lib/log.sh`).
- It does not check if `BUILD_COMMAND` and `TEST_COMMAND` scripts are present.

## Relevant Files/Modules
- `doctor.sh`: Primary script to be implemented.
- `.grkr/config.sh`: Configuration source.
- `.grkr/lib/log.sh`: Logging utility for status and error reporting.
- `spec.md`: Source of requirements for startup validation.

## Assumptions
- The user has already run `gh auth login`.
- `.grkr/config.sh` is correctly populated with `REPO`, `PROJECT_OWNER`, and `PROJECT_NUMBER`.
- GitHub Project V2 is used.
- The environment has GNU coreutils (for `timeout` and `flock`).

## Unknowns
- Whether `doctor.sh` should attempt to fix minor issues (like missing directories) or just report them.
- How to handle potential variations in `gh auth status` output across different `gh` CLI versions.

## Risks
- Token scopes might be insufficient for project mutations even if `gh auth status` reports success.
- `doctor.sh` might report success even if some subtle environmental issue exists (e.g. `gemini` API quota exceeded).
- Missing `BUILD_COMMAND` or `TEST_COMMAND` might be acceptable if the projI have completed the research for Issue #1: Implement `doctor.sh`. Below is the research document summarizing the findings and proposed implementation criteria.

# Research: Implement doctor.sh

## Problem Statement
The autonomous shell-based agent requires a robust pre-flight check (`doctor.sh`) to verify that all necessary tools, authentication tokens, repository configurations, and GitHub Project settings are correctly in place. Without this, the agent might fail later in its execution loop with hard-to-diagnose errors. The current implementation of `doctor.sh` is incomplete and lacks verification of specific project field values and detailed token scope validation.

## Current System Behavior
- `doctor.sh` exists but is a partial implementation.
- It checks for the existence of tools (`jq`, `timeout`, `flock`, `git`, `gh`, `gemini`).
- It verifies `gh auth status` but does not parse token scopes.
- It checks if the git remote origin matches the `REPO` in `.grkr/config.sh`.
- It checks if the `.grkr` directory is writable.
- It verifies the existence of the configured GitHub Project and its fields (`Status`, `Priority`), but does not validate that the required options (like `Ready`, `Backlog`, `P0`, etc.) exist within those fields.
- It does not use the project's logging library (`lib/log.sh`).
- It does not check if `BUILD_COMMAND` and `TEST_COMMAND` scripts are present.

## Relevant Files/Modules
- `doctor.sh`: Primary script to be implemented.
- `.grkr/config.sh`: Configuration source.
- `.grkr/lib/log.sh`: Logging utility for status and error reporting.
- `spec.md`: Source of requirements for startup validation.

## Assumptions
- The user has already run `gh auth login`.
- `.grkr/config.sh` is correctly populated with `REPO`, `PROJECT_OWNER`, and `PROJECT_NUMBER`.
- GitHub Project V2 is used.
- The environment has GNU coreutils (for `timeout` and `flock`).

## Unknowns
- Whether `doctor.sh` should attempt to fix minor issues (like missing directories) or just report them.
- How to handle potential variations in `gh auth status` output across different `gh` CLI versions.

## Risks
- Token scopes might be insufficient for project mutations even if `gh auth status` reports success.
- `doctor.sh` might report success even if some subtle environmental issue exists (e.g. `gemini` API quota exceeded).
- Missing `BUILD_COMMAND` or `TEST_COMMAND` might be acceptable if the project doesn't have them yet, but should be warned about.

## Inferred Acceptance Criteria
1. `doctor.sh` returns 0 on success and non-zero on any failure.
2. Verified tools: `jq`, `timeout`, `flock`, `git`, `gh`, `gemini`.
3. Token scopes: Must explicitly verify `repo`, `project`, and `read:org`.
4. Git Remote: `git remote get-url origin` must match the configured `REPO`.
5. Project Fields: Must verify `Status` field contains `TODO_VALUE` and `BACKLOG_VALUE`.
6. Project Fields: Must verify `Priority` field exists and has options.
7. Logs: Use `info` and `error` from `lib/log.sh` to report progress and failures.
8. Directory: Verify `.grkr` and subdirectories (`logs`, `locks`, `state`, `worktrees`) are writable.
9. Build/Test: Warn if `BUILD_COMMAND` or `TEST_COMMAND` files are missing.

## Goal
Generate a plan document following the spec:
- implementation plan
- files likely to change
- migration or data concerns
- test strategy
- rollback strategy
- out-of-scope items
- refusal assessment section (explicitly answering implementability)

Please provide the output in Markdown format.
