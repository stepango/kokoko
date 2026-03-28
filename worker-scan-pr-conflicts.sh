#!/bin/bash

# worker-scan-pr-conflicts.sh
# Discovers PRs with conflicts

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"

PHASE="scan_prs"

scan_logic() {
    info "$PHASE" "" "" "Scanning for PR conflicts."
    
    PRS=$(list_open_pull_requests)
    
    # Filter for conflicting PRs
    # 1. mergeable == "CONFLICTING"
    # 2. baseRefName == MAIN_BRANCH
    
    CONFLICTING_PRS=$(echo "$PRS" | jq -c --arg base "$MAIN_BRANCH" '
        .[] 
        | select(.mergeable == "CONFLICTING" and .baseRefName == $base)
    ')
    
    while IFS= read -r pr; do
        [ -z "$pr" ] && continue
        
        PR_NUMBER=$(echo "$pr" | jq -r '.number')
        JOB_KEY="pr:$PR_NUMBER:conflict-resolution"
        
        if is_job_active "$JOB_KEY"; then
            continue
        fi
        
        info "$PHASE" "$JOB_KEY" "pr/$PR_NUMBER" "Found conflicting PR: $PR_NUMBER"
        
        # In a real system, we would spawn worker-resolve-pr.sh here
    done <<< "$CONFLICTING_PRS"
}

with_lock "prs" scan_logic
