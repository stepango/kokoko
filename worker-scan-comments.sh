#!/bin/bash

# worker-scan-comments.sh
# Discovers new @:robot: comments

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"

PHASE="scan_comments"
PROCESSED_COMMENTS_FILE=".grkr/state/processed_comments.json"

if [ ! -f "$PROCESSED_COMMENTS_FILE" ]; then
    echo "[]" > "$PROCESSED_COMMENTS_FILE"
fi

scan_logic() {
    info "$PHASE" "" "" "Scanning for robot comments."
    
    COMMENTS=$(list_recent_comments)
    
    # Filter for robot comments
    NEW_COMMENTS=$(echo "$COMMENTS" | jq -c --arg prefix "$COMMENT_PREFIX" '
        .[] 
        | select(.body | startswith($prefix))
        | {id: .node_id, body: .body, updated_at: .updated_at, issue_url: .issue_url}
    ')
    
    while IFS= read -r comment; do
        [ -z "$comment" ] && continue
        
        COMMENT_ID=$(echo "$comment" | jq -r '.id')
        JOB_KEY="comment:$COMMENT_ID"
        
        if is_job_active "$JOB_KEY"; then
            continue
        fi
        
        # Check if already processed (simplified check by ID)
        if jq -e ".[] | select(.id == \"$COMMENT_ID\")" "$PROCESSED_COMMENTS_FILE" > /dev/null; then
            continue
        fi
        
        info "$PHASE" "$JOB_KEY" "" "Found new robot comment: $COMMENT_ID"
    done <<< "$NEW_COMMENTS"
}

with_lock "comments" scan_logic
