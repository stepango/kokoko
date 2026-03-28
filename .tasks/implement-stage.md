# Task: Implement Stage 4: Implement

## Goal
Implement the actual code change stage where Gemini modifies the repository files based on the research and plan.

## Requirements
- Use a dedicated `git worktree` for each issue.
- Build a prompt from `research.md`, `plan.md`, issue context, and repository context.
- instruct Gemini to follow the plan and minimize unrelated edits.
- run build and test commands if configured.
- push the branch and create a PR.

## Outcome
Implementation stage implemented and tested. Gemini correctly applies changes in a worktree, commits, pushes, and creates a PR.

## Status
- [x] Update `worker-exec-issue.sh` to include the implementation stage
- [x] Implement worktree creation and cleanup
- [x] Build the implementation prompt in `tasks/<slug>/gemini/implement.prompt.md`
- [x] Invoke Gemini with workspace write access
- [x] Commit and push the changes
- [x] Create a PR linked to the issue
