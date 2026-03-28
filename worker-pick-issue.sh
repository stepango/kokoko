#!/bin/bash

# worker-pick-issue.sh

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"

PHASE="pick_issue"

# Get current user
CURRENT_USER=$(gh auth status 2>&1 | grep "Logged in to github.com account" | awk '{print $7}')
if [ -z "$CURRENT_USER" ]; then
    error "$PHASE" "" "" "Could not determine current user."
    exit 1
fi

pick_logic() {
    info "$PHASE" "" "" "Scanning for issues in project $PROJECT_NUMBER."
    
    ITEMS=$(gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json)
    
    # Filter for candidates
    # jq will handle the logic
    CANDIDATE=$(echo "$ITEMS" | jq -c --arg user "$CURRENT_USER" --arg todo "$TODO_VALUE" '
        .items[] 
        | select(.content.type == "Issue")
        | select((.assignees // []) | contains([$user]))
        | select(.status == $todo or ((.labels // []) | contains(["status:todo"])))
        | .priority_val = (if .priority == "P0" or ((.labels // []) | contains(["priority:P0"])) then 0 
                            elif .priority == "P1" or ((.labels // []) | contains(["priority:P1"])) then 1 
                            elif .priority == "P2" or ((.labels // []) | contains(["priority:P2"])) then 2 
                            else 999 end)
        | .issue_num = .content.number
    ' | jq -s -c 'sort_by(.priority_val, .issue_num) | .[0]')
    
    if [ "$CANDIDATE" == "null" ] || [ -z "$CANDIDATE" ]; then
        info "$PHASE" "" "" "No eligible issues found."
        return 0
    fi
    
    ISSUE_NUMBER=$(echo "$CANDIDATE" | jq -r '.content.number')
    ISSUE_TITLE=$(echo "$CANDIDATE" | jq -r '.title')
    JOB_KEY="issue:$ISSUE_NUMBER:execution"
    
    if is_job_active "$JOB_KEY"; then
        info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Issue already active, skipping."
        return 0
    fi
    
    info "$PHASE" "$JOB_KEY" "issue/$ISSUE_NUMBER" "Selected issue: $ISSUE_TITLE"
}

with_lock "issues" pick_logic
