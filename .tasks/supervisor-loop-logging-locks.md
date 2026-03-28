# Task: Implement supervisor loop + logging + locks

## Goal
Implement the main loop that orchestrates worker execution, manages logging, and ensures proper locking.

## Requirements
- Loop every **20 seconds**.
- Maintain `robot-main.sh` as the supervisor.
- Use `flock` for locking (main.lock, prs.lock, issues.lock, comments.lock).
- Implement structured logging to `.grkr/logs/main.log` and `.grkr/logs/loop.log`.
- Phases in order: sync_main, scan_prs, scan_comments, pick_issue, reap, cleanup.
- Resilience: main loop must survive worker failures.

## Outcome
Supervisor loop and libraries for logging and locking implemented.

## Status
- [x] Create `robot-main.sh`
- [x] Implement logging library in `lib/log.sh`
- [x] Implement locking library in `lib/lock.sh`
- [x] Implement basic loop structure
- [x] Add phase execution with error boundaries
- [x] Integrate with `doctor.sh` for startup validation
