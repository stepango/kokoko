# Task: Decision for Issue #1
Title: Implement doctor.sh

## Research
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

## Plan
<!-- grkr:checkpoint stage=plan task=issue-1-implement-doctor-sh version=1 -->
# Implementation Plan: Issue #1 - Implement `doctor.sh`

The goal is to enhance `doctor.sh` to be a robust pre-flight check for the autonomous agent, ensuring all tools, tokens, and configurations are correctly in place.

## Proposed Changes

### 1. Refactor `doctor.sh` to use `lib/log.sh`
- Source `.grkr/config.sh` and `.grkr/lib/log.sh`.
- Update all status reporting to use the `info`, `warn`, and `error` functions from `lib/log.sh`.
- Set the logging phase to `doctor`.

### 2. Enhanced Tool Verification
- Verify the presence of `jq`, `timeout`, `flock`, `git`, `gh`, and `gemini` in the `PATH`.
- Attempt a basic execution test for each (e.g., `gemini --help`).

### 3. Comprehensive GitHub Token Scope Validation
- Parse the output of `gh auth status` to ensure the token has at least the following scopes:
    - `repo`
    - `project`
    - `read:org`
- Fail if any required scope is missing.

### 4. Git Remote and Configuration Validation
- Verify that `git remote get-url origin` matches the `REPO` specified in `.grkr/config.sh`.
- Check that `MAIN_BRANCH` is correctly configured and exists.

### 5. Detailed GitHub Project V2 Validation
- Verify the existence of the coI have completed the planning phase for Issue #1: Implement `doctor.sh`. The proposed plan includes:

1.  **Logging Integration**: Refactoring `doctor.sh` to use the project's internal logging library (`lib/log.sh`) for consistent status and error reporting.
2.  **Robust Verification**:
    *   **Tools**: Confirming the presence and basic functionality of `jq`, `timeout`, `flock`, `git`, `gh`, and `gemini`.
    *   **Authentication**: Parsing `gh auth status` to ensure the GitHub token has the required `repo`, `project`, and `read:org` scopes.
    *   **Project V2**: Validating the existence of the GitHub Project and ensuring required field options (e.g., `Backlog`, `Ready`, `P0`) are configured.
    *   **Environment**: Verifying repository remotes, directory permissions for `.grkr/`, and the existence of build/test scripts.
3.  **Error Handling**: Ensuring clear exit codes and informative failure messages.

The implementation plan has been saved to `.grkr/tasks/issue-1-implement-doctor-sh/plan.md`. I am ready to proceed with the implementation once directed.
ly a validation script.

## Test Strategy
- **Unit Testing**: Manually run `doctor.sh` with various (mis)configurations to ensure it detects and reports errors correctly.
- **Scenario Testing**: 
    - Test with missing tools.
    - Test with insufficient GitHub token scopes.
    - Test with incorrect repository URL.
    - Test with missing project field options.
    - Test with read-only filesystem.

## Rollback Strategy
- Revert the changes to `doctor.sh` using `git checkout doctor.sh`.

## Out-of-Scope Items
- Automatically fixing GitHub token scopes or Project V2 field options.
- Installing missing tools.
- Fixing git remote URLs automatically.

## Refusal Assessment
This task is fully implementable. All required tools (`gh`, `jq`, `git`) are available in the environment, and the configuration file provides sufficient context for the necessary checks.

## Goal
Decide whether to proceed with the implementation or refuse it.
You MUST output ONLY one word: "proceed" or "refuse".

Refuse if:
- underspecified
- too large or high complexity
- missing dependencies
- blocked by product or design decision
- unsafe or inappropriate for autonomous implementation
- repository state not suitable

Otherwise, proceed.
