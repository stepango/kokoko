# Task: Implement implement-or-refuse decision gate

## Goal
Implement a decision gate after research and planning to decide whether to proceed with implementation or refuse the issue.

## Requirements
- Use a separate Gemini invocation with a tightly-scoped prompt.
- Consider issue description, comments, `research.md`, `plan.md`, repository context, and project policy.
- Possible decisions: `proceed` or `refuse`.
- Refuse by default if underspecified, too large, missing dependencies, etc.

## Outcome
Gemini correctly decides based on research and plan. For Issue #1, it decided "proceed".

## Status
- [x] Update `worker-exec-issue.sh` to include the decision stage
- [x] Create a decision prompt in `tasks/<slug>/gemini/decision.prompt.md`
- [x] Invoke Gemini to get the decision
- [x] Record the decision in `progress.json`
