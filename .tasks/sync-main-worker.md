# Task: Implement sync-main worker

## Goal
Synchronize the supervisor checkout to the latest remote `main` branch.

## Requirements
- Fetch remote changes.
- Reset local `main` to `origin/main`.
- Use `main.lock` to ensure only one sync happens at a time.

## Outcome
`worker-sync-main.sh` implemented and tested.

## Status
- [x] Create `worker-sync-main.sh`
- [x] Implement fetch and reset logic
- [x] Wrap execution in `with_lock "main"`
- [x] Log progress
