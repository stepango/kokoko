#!/bin/bash

# worker-handle-comment.sh
# Processes one @:robot: comment

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"
source "$(dirname "$0")/.grkr/lib/gemini.sh"

COMMENT_ID="$1"
PHASE="handle_comment"
PROCESSED_COMMENTS_FILE=".grkr/state/processed_comments.json"

if [ -z "$COMMENT_ID" ]; then
    echo "Usage: $0 <comment_id>"
    exit 1
fi

info "$PHASE" "comment:$COMMENT_ID" "" "Handling comment $COMMENT_ID"

# 1. Add eyes reaction
add_reaction "$COMMENT_ID" "EYES"

# 2. Fetch comment details
COMMENT_DATA=$(gh api "repos/$REPO/issues/comments" --jq ".[] | select(.node_id == \"$COMMENT_ID\")" | head -n 1)
# Wait, gh api above is not efficient if we have many comments. 
# Better use a direct query if possible, but for now:
if [ -z "$COMMENT_DATA" ]; then
    # Maybe it's a pull request comment?
    COMMENT_DATA=$(gh api "repos/$REPO/pulls/comments" --jq ".[] | select(.node_id == \"$COMMENT_ID\")" | head -n 1)
fi

ISSUE_URL=$(echo "$COMMENT_DATA" | jq -r '.issue_url // .pull_request_url')
ISSUE_NUM=$(basename "$ISSUE_URL")
BODY=$(echo "$COMMENT_DATA" | jq -r '.body')
COMMAND=${BODY#$COMMENT_PREFIX}

# 3. Build prompt
PROMPT_FILE=$(mktemp)
cat <<EOF > "$PROMPT_FILE"
# Task: Respond to Robot Command
Issue: $ISSUE_NUM
Command: $COMMAND

## Context
$(gh issue view "$ISSUE_NUM" --repo "$REPO" --json title,body,comments)

## Goal
Respond to the command. 
If it's a question, answer it.
If it's a request for action, explain what you would do (implementation is not yet automated for comments).
EOF

RESPONSE_FILE=$(mktemp)
invoke_gemini "$PROMPT_FILE" "$RESPONSE_FILE"

# 4. Post response
post_comment "$ISSUE_NUM" "$RESPONSE_FILE"

# 5. Update reactions
remove_reaction "$COMMENT_ID" "EYES"
add_reaction "$COMMENT_ID" "ROCKET"

# 6. Mark as processed
jq ". += [{\"id\": \"$COMMENT_ID\", \"updated_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}]" "$PROCESSED_COMMENTS_FILE" > "$PROCESSED_COMMENTS_FILE.tmp" && mv "$PROCESSED_COMMENTS_FILE.tmp" "$PROCESSED_COMMENTS_FILE"

info "$PHASE" "comment:$COMMENT_ID" "" "Comment handled successfully."
