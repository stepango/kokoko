# Task: Implement Stage 5: Test

## Goal
Implement the final test stage where Gemini runs configured test commands and generates a test report.

## Requirements
- Run configured `TEST_COMMAND` and `BUILD_COMMAND`.
- Write `test.md` with commands run, pass/fail summary, and output excerpts.
- Post `test.md` as an issue comment.
- Mark progress as complete on success.

## Outcome
Test stage implemented. Gemini runs `doctor.sh` in the worktree and generates a detailed test report. Tested with Issue #1.

## Status
- [x] Update `worker-exec-issue.sh` to include the test stage
- [x] Execute tests in the worktree
- [x] Build the test report using Gemini based on the test output
- [x] Post the test checkpoint comment
- [x] Move the project item to `Done` on success
