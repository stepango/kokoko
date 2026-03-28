# Task: Implement comment scanning + reactions

## Goal
Implement the logic to discover `@:robot:` comments and process them with Gemini, including adding and removing reactions.

## Requirements
- Scan for comments starting with `@:robot:`.
- Add `eyes` reaction at the start.
- Remove `eyes` and add `rocket` on success.
- Support issue and PR comments.
- Isolate comment jobs in worktrees if needed.

## Outcome
Comment scanning and handling implemented. The bot correctly identifies `@:robot:` comments, reacts with `eyes`, processes them with Gemini, posts a response, and then replaces `eyes` with `rocket`.

## Status
- [x] Create `worker-scan-comments.sh`
- [x] Create `worker-handle-comment.sh`
- [x] Implement reaction helpers in `lib/github.sh`
- [x] Implement comment discovery using `gh api`
- [x] Implement comment processing logic with Gemini
