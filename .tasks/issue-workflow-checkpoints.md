# Task: Implement issue workflow with research and plan checkpoints

## Goal
Implement the first two stages of the issue pipeline: research and plan.

## Requirements
- Create per-issue task folder under `.grkr/tasks/<slug>/`.
- Write `research.md`, `plan.md`, and `progress.json`.
- Include required content in each checkpoint file.
- Post both checkpoint files as issue comments.
- Support resuming when matching checkpoint comments already exist.

## Outcome
`worker-exec-issue.sh` implements research and plan stages using Gemini CLI. It correctly handles checkpoints and resumes from existing comments.

## Status
- [x] Create per-issue task folder
- [x] Implement Research stage with Gemini prompt
- [x] Implement Plan stage with Gemini prompt
- [x] Post checkpoints as issue comments
- [x] Support resuming from checkpoints
