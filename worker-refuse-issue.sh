#!/bin/bash

# worker-refuse-issue.sh
# Handles issue refusal

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"
source "$(dirname "$0")/.grkr/lib/gemini.sh"

ISSUE_NUMBER="$1"
SLUG="$2"
TASK_DIR=".grkr/tasks/$SLUG"
PHASE="issue_refuse"

if [ -z "$ISSUE_NUMBER" ] || [ -z "$SLUG" ]; then
    echo "Usage: $0 <issue_number> <slug>"
    exit 1
fi

info "$PHASE" "" "issue/$ISSUE_NUMBER" "Starting refusal flow for $SLUG"

RESEARCH_FILE="$TASK_DIR/research.md"
PLAN_FILE="$TASK_DIR/plan.md"
REFUSAL_FILE="$TASK_DIR/refusal.md"

PROMPT_FILE="$TASK_DIR/gemini/refuse.prompt.md"
cat <<EOF > "$PROMPT_FILE"
# Task: Refusal Reasoning for Issue #$ISSUE_NUMBER
Title: $(gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json title -q .title)

## Research
$(cat "$RESEARCH_FILE")

## Plan
$(cat "$PLAN_FILE")

## Goal
Generate a refusal document following the spec:
- refusal summary
- refusal class (underspecified, too_large, missing_dependency, needs_design_decision, unsafe_autonomous_change, repo_not_ready, other)
- detailed reasoning
- what information or prerequisite is missing
- explicit next step recommendations

Please provide the output in Markdown format.
EOF

invoke_gemini "$PROMPT_FILE" "$REFUSAL_FILE"

# Prepend checkpoint marker
CHECKPOINT_HEADER="<!-- grkr:checkpoint stage=refusal task=$SLUG version=1 -->"
sed -i '' "1i\\
$CHECKPOINT_HEADER
" "$REFUSAL_FILE"

# Post comment
post_comment "$ISSUE_NUMBER" "$REFUSAL_FILE"

# Move project item to Backlog
ITEM_ID=$(find_project_item_id "$ISSUE_NUMBER")
if [ -n "$ITEM_ID" ]; then
    update_project_item_status "$ITEM_ID" "$BACKLOG_VALUE"
    info "$PHASE" "" "issue/$ISSUE_NUMBER" "Moved project item $ITEM_ID to $BACKLOG_VALUE"
else
    warn "$PHASE" "" "issue/$ISSUE_NUMBER" "Could not find project item for issue $ISSUE_NUMBER"
fi

info "$PHASE" "" "issue/$ISSUE_NUMBER" "Refusal flow completed."
