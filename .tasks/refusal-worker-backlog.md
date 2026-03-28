# Task: Implement refusal worker and Backlog transition

## Goal
Implement the refusal flow that posts a reasoned comment and moves the project item to Backlog when an issue is refused.

## Requirements
- Generate `refusal.md` with detailed reasoning.
- Post `refusal.md` as an issue comment with a checkpoint marker.
- Move the project item from `Ready` to `Backlog`.
- Record the refusal class and reasoning.
- Treat refusal as a valid terminal state.

## Outcome
Refusal flow implemented. Tested with an underspecified issue, Gemini refused it, posted reasoning, and moved the item to Backlog.

## Status
- [x] Create `worker-refuse-issue.sh`
- [x] Implement `refusal.md` generation using Gemini
- [x] Post the refusal comment
- [x] Update the GitHub Project status to `Backlog`
- [x] Integrate `worker-refuse-issue.sh` into `worker-exec-issue.sh`
