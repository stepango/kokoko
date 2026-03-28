#!/bin/bash

# worker-exec-issue.sh
# Orchestrates issue workflow

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"
source "$(dirname "$0")/.grkr/lib/worktree.sh"
source "$(dirname "$0")/.grkr/lib/gemini.sh"

ISSUE_NUMBER="$1"
PHASE="issue_execute"

if [ -z "$ISSUE_NUMBER" ]; then
    error "$PHASE" "" "" "No issue number provided."
    exit 1
fi

# Load issue context
CONTEXT=$(get_issue_context "$ISSUE_NUMBER")
TITLE=$(echo "$CONTEXT" | jq -r '.title')
SLUG="issue-$ISSUE_NUMBER-$(echo \"$TITLE\" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')"
TASK_DIR=".grkr/tasks/$SLUG"
JOB_KEY="issue:$ISSUE_NUMBER:execution"

mkdir -p "$TASK_DIR/gemini"

info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting workflow for $SLUG"

# Progress state
PROGRESS_FILE="$TASK_DIR/progress.json"
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "{\"issue_number\": $ISSUE_NUMBER, \"task_slug\": \"$SLUG\", \"status\": \"started\", \"stages\": {}}" > "$PROGRESS_FILE"
fi

# Helper to update progress
update_progress() {
    local stage="$1"
    local stage_status="$2"
    local comment_id="$3"
    
    local tmp_file=$(mktemp)
    jq --arg stage "$stage" --arg status "$stage_status" --arg cid "$comment_id" '
        .stages[$stage] = {status: $status, comment_id: $cid}
        | .updated_at = "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"
    ' "$PROGRESS_FILE" > "$tmp_file"
    mv "$tmp_file" "$PROGRESS_FILE"
}

# 1. Research Stage
RESEARCH_FILE="$TASK_DIR/research.md"
COMMENT_ID=$(find_checkpoint_comment "$ISSUE_NUMBER" "research" "$SLUG")

if [ -n "$COMMENT_ID" ] && [ -f "$RESEARCH_FILE" ]; then
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Research checkpoint exists, skipping."
else
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting Research stage."
    
    PROMPT_FILE="$TASK_DIR/gemini/research.prompt.md"
    cat <<EOF > "$PROMPT_FILE"
# Task: Research for Issue #$ISSUE_NUMBER
Title: $TITLE
Body:
$(echo "$CONTEXT" | jq -r '.body')

## Goal
Generate a research document following the spec:
- problem statement
- current system behavior
- relevant files/modules
- assumptions
- unknowns
- risks
- inferred acceptance criteria

Please provide the output in Markdown format.
EOF
    
    invoke_gemini "$PROMPT_FILE" "$RESEARCH_FILE"
    
    if [ ! -f "$RESEARCH_FILE" ]; then
        error "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Research stage failed to produce output."
        exit 1
    fi
    
    # Prepend checkpoint marker
    CHECKPOINT_HEADER="<!-- grkr:checkpoint stage=research task=$SLUG version=1 -->"
    sed -i '' "1i\\
$CHECKPOINT_HEADER
" "$RESEARCH_FILE"
    
    post_comment "$ISSUE_NUMBER" "$RESEARCH_FILE"
    NEW_COMMENT_ID=$(find_checkpoint_comment "$ISSUE_NUMBER" "research" "$SLUG")
    update_progress "research" "done" "$NEW_COMMENT_ID"
fi

# 2. Plan Stage
PLAN_FILE="$TASK_DIR/plan.md"
COMMENT_ID=$(find_checkpoint_comment "$ISSUE_NUMBER" "plan" "$SLUG")

if [ -n "$COMMENT_ID" ] && [ -f "$PLAN_FILE" ]; then
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Plan checkpoint exists, skipping."
else
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting Plan stage."
    
    PROMPT_FILE="$TASK_DIR/gemini/plan.prompt.md"
    cat <<EOF > "$PROMPT_FILE"
# Task: Plan for Issue #$ISSUE_NUMBER
Title: $TITLE

## Research Context
$(cat "$RESEARCH_FILE")

## Goal
Generate a plan document following the spec:
- implementation plan
- files likely to change
- migration or data concerns
- test strategy
- rollback strategy
- out-of-scope items
- refusal assessment section (explicitly answering implementability)

Please provide the output in Markdown format.
EOF
    
    invoke_gemini "$PROMPT_FILE" "$PLAN_FILE"
    
    if [ ! -f "$PLAN_FILE" ]; then
        error "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Plan stage failed to produce output."
        exit 1
    fi
    
    # Prepend checkpoint marker
    CHECKPOINT_HEADER="<!-- grkr:checkpoint stage=plan task=$SLUG version=1 -->"
    sed -i '' "1i\\
$CHECKPOINT_HEADER
" "$PLAN_FILE"
    
    post_comment "$ISSUE_NUMBER" "$PLAN_FILE"
    NEW_COMMENT_ID=$(find_checkpoint_comment "$ISSUE_NUMBER" "plan" "$SLUG")
    update_progress "plan" "done" "$NEW_COMMENT_ID"
fi

# 3. Decision Stage
DECISION_FILE="$TASK_DIR/decision.txt"
if [ -f "$DECISION_FILE" ]; then
    DECISION=$(cat "$DECISION_FILE")
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Decision already made: $DECISION"
else
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting Decision stage."
    
    PROMPT_FILE="$TASK_DIR/gemini/decision.prompt.md"
    cat <<EOF > "$PROMPT_FILE"
# Task: Decision for Issue #$ISSUE_NUMBER
Title: $TITLE

## Research
$(cat "$RESEARCH_FILE")

## Plan
$(cat "$PLAN_FILE")

## Goal
Decide whether to proceed with the implementation or refuse it.
You MUST output ONLY one word: "proceed" or "refuse".

Refuse if:
- underspecified
- too large or high complexity
- missing dependencies
- blocked by product or design decision
- unsafe or inappropriate for autonomous implementation
- repository state not suitable

Otherwise, proceed.
EOF
    
    invoke_gemini "$PROMPT_FILE" "$DECISION_FILE"
    
    DECISION=$(cat "$DECISION_FILE" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    echo "$DECISION" > "$DECISION_FILE"
    
    update_progress "decision" "$DECISION" ""
fi

if [ "$DECISION" = "refuse" ]; then
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Issue refused. Triggering refusal flow."
    bash "$(dirname "$0")/worker-refuse-issue.sh" "$ISSUE_NUMBER" "$SLUG"
    exit 0
fi

# 4. Implementation Stage
if [ "$DECISION" = "proceed" ]; then
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting Implementation stage."
    
    # Create worktree
    create_worktree "$SLUG" "origin/$MAIN_BRANCH"
    WT_PATH=".grkr/worktrees/$SLUG"
    
    PROMPT_FILE="$TASK_DIR/gemini/implement.prompt.md"
    IMPLEMENT_LOG="$TASK_DIR/implementation.log"
    
    cat <<EOF > "$PROMPT_FILE"
# Task: Implementation for Issue #$ISSUE_NUMBER
Title: $TITLE

## Research
$(cat "$RESEARCH_FILE")

## Plan
$(cat "$PLAN_FILE")

## Goal
Apply the changes described in the plan.
Follow the plan strictly.
Minimize unrelated edits.
EOF
    
    invoke_gemini_with_worktree "$PROMPT_FILE" "$IMPLEMENT_LOG" "$WT_PATH"
    
    # Commit and push
    (
        cd "$WT_PATH"
        git add .
        git commit -m "feat(robot): implement #$ISSUE_NUMBER $TITLE"
        git push origin "robot/$SLUG"
    )
    
    create_pull_request "$ISSUE_NUMBER" "Implement #$ISSUE_NUMBER $TITLE" "robot/$SLUG"
    
    update_progress "implementation" "done" ""
    
    # 5. Test Stage
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Starting Test stage."
    
    TEST_OUTPUT_FILE="$TASK_DIR/test.log"
    (
        cd "$WT_PATH"
        # For testing, we'll run doctor.sh as the test command if configured
        bash doctor.sh > "../../$TEST_OUTPUT_FILE" 2>&1
    )
    
    PROMPT_FILE="$TASK_DIR/gemini/test.prompt.md"
    TEST_REPORT="$TASK_DIR/test.md"
    
    cat <<EOF > "$PROMPT_FILE"
# Task: Test Report for Issue #$ISSUE_NUMBER
Title: $TITLE

## Test Output
$(cat "$TEST_OUTPUT_FILE")

## Goal
Generate a test report following the spec:
- commands run
- pass/fail summary
- output excerpts
- remaining risks
- recommendation: ready or needs follow-up

Please provide the output in Markdown format.
EOF
    
    invoke_gemini "$PROMPT_FILE" "$TEST_REPORT"
    
    # Prepend checkpoint marker
    CHECKPOINT_HEADER="<!-- grkr:checkpoint stage=test task=$SLUG version=1 -->"
    sed -i '' "1i\\
$CHECKPOINT_HEADER
" "$TEST_REPORT"
    
    post_comment "$ISSUE_NUMBER" "$TEST_REPORT"
    
    update_progress "test" "done" ""
    update_progress "status" "complete" ""
    
    # Move project item to Done
    ITEM_ID=$(find_project_item_id "$ISSUE_NUMBER")
    if [ -n "$ITEM_ID" ]; then
        update_project_item_status "$ITEM_ID" "$DONE_VALUE"
    fi
fi
