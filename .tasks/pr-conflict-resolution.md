# Task: Implement PR conflict resolution

## Goal
Detect open PRs with merge conflicts against `main` and resolve them using Gemini in isolated worktrees.

## Requirements
- List open PRs and check mergeability.
- Use a dedicated worktree for resolution.
- Attempt rebase (default) or merge.
- Use Gemini to resolve conflicts in specific files.
- Run validation commands.
- Push the resolved branch.

## Outcome
PR conflict discovery and resolution scripts implemented. `worker-resolve-pr.sh` correctly uses Gemini to resolve conflicts during a rebase in a dedicated worktree.

## Status
- [x] Create `worker-scan-pr-conflicts.sh`
- [x] Create `worker-resolve-pr.sh`
- [x] Implement PR discovery logic
- [x] Implement conflict resolution logic with Gemini
- [x] Integrate with worktree and git helpers
