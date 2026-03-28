# Task: Implement doctor.sh

## Goal
Validate tools, auth, repo, and config to ensure the agent can run successfully.

## Requirements
At startup the supervisor must verify:
1. `gh auth status` succeeds.
2. GitHub token has the required scopes.
3. `git remote get-url origin` matches configured repo.
4. `gemini` is installed and runnable.
5. Required tools exist: `jq`, `timeout`, `flock`, `git`, `gh`.
6. Local `.grkr` directory can be created and written.
7. The configured project contains the required fields and values (Status, Todo, Backlog, Priority).

## Research
- `gh auth status` output format.
- `gh api` for checking scopes and project fields.
- `gemini` availability.

## Outcome
Task completed successfully. `doctor.sh` implements all required checks.

## Status
- [x] Create `doctor.sh`
- [x] Implement checks for each requirement
- [x] Return non-zero exit code if critical checks fail
- [x] Log errors clearly
