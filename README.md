# Kokoko AI Agent

A long-running shell-based AI agent that uses Codex CLI and GitHub CLI (`gh`) to continuously triage repository work.

## Task Tracking Format

The project uses a structured task tracking system located in the `.tasks/` directory:

- `.tasks/manifest.json`: A central registry of all tasks, their statuses, and associated GitHub Issue IDs.
- `.tasks/<task-slug>.md`: Detailed information for each task, following the lifecycle defined in `spec.md`:
  - Research
  - Plan
  - Implementation Decision (Proceed/Refuse)
  - Implementation Log
  - Test Results

Status codes:
- `todo`: Task is in the backlog.
- `in-progress`: Task is currently being worked on.
- `done`: Task is completed and verified.
- `refused`: Task was intentionally not implemented.
- `failed`: Task implementation failed.

## Implementation Order

Following the `spec.md` recommendation:

1. `doctor.sh`
2. supervisor loop + logging + locks
3. sync-main worker
4. project issue picker
5. issue workflow with research and plan checkpoints
6. implement-or-refuse decision gate
7. refusal worker and Backlog transition
8. implement stage
9. test stage
10. comment scanning + reactions
11. PR conflict resolution
12. cleanup and retry polish
