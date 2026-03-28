# Task: Implement project issue picker

## Goal
Query the configured GitHub Project and select the highest-priority `Todo` issue assigned to the bot.

## Requirements
- Item type: Issue.
- Assigned to the bot/authenticated user.
- Status: Todo.
- Issue is open.
- Issue belongs to the configured repo.
- Not already active.
- Priority ordering:
  1. Highest priority.
  2. Oldest update time.
  3. Lowest issue number.

## Outcome
`worker-pick-issue.sh` implemented and tested with actual GitHub Project items.

## Status
- [x] Create `worker-pick-issue.sh`
- [x] Implement project querying using `gh api` (or `gh project item-list`)
- [x] Filter and sort issues according to requirements
- [x] Select the top candidate and log its details
- [x] Create a basic implementation of `active_jobs.json` to track if an issue is already being processed
