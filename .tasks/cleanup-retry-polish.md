# Task: Implement cleanup and retry polish

## Goal
Implement background cleanup of worktrees and locks, and handle stale jobs.

## Requirements
- Detect and recover stale jobs from `active_jobs.json`.
- Periodically prune stale worktrees and locks.
- Implement retry/backoff logic for transient failures (optional but recommended).

## Outcome
Reaping and cleanup logic implemented in the main supervisor loop. Stale jobs are detected by checking PIDs, and worktrees are pruned periodically.

## Status
- [x] Implement stale job recovery in `robot-main.sh`
- [x] Implement worktree and lock cleanup in `robot-main.sh`
- [x] Add loop iteration count to trigger periodic cleanup
