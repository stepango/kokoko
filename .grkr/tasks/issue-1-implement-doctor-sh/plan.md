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
