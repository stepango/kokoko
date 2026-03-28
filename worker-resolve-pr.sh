#!/bin/bash

# worker-resolve-pr.sh
# Resolves conflicts in a PR

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"
source "$(dirname "$0")/.grkr/lib/state.sh"
source "$(dirname "$0")/.grkr/lib/github.sh"
source "$(dirname "$0")/.grkr/lib/worktree.sh"
source "$(dirname "$0")/.grkr/lib/gemini.sh"

PR_NUMBER="$1"
PHASE="resolve_pr"

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <pr_number>"
    exit 1
fi

info "$PHASE" "pr:$PR_NUMBER:conflict-resolution" "pr/$PR_NUMBER" "Starting conflict resolution."

# 1. Fetch PR details
PR_DATA=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefName,baseRefName)
HEAD_BRANCH=$(echo "$PR_DATA" | jq -r '.headRefName')
SLUG="pr-$PR_NUMBER-conflict"
WT_PATH=".grkr/worktrees/$SLUG"

# 2. Create worktree
create_worktree "$SLUG" "$HEAD_BRANCH"

# 3. Attempt rebase
(
    cd "$WT_PATH"
    git fetch origin "$MAIN_BRANCH"
    if ! git rebase "origin/$MAIN_BRANCH"; then
        info "$PHASE" "" "" "Conflicts detected. Invoking Gemini."
        
        # 4. Resolve conflicts with Gemini
        CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
        
        for file in $CONFLICT_FILES; do
            PROMPT_FILE=$(mktemp)
            cat <<EOF > "$PROMPT_FILE"
# Task: Resolve Merge Conflict
File: $file

## Content with Markers
\$(cat "$file")

## Goal
Resolve the merge conflicts in this file. 
Preserve the intent of both branches.
Output the entire resolved file.
EOF
            
            invoke_gemini "$PROMPT_FILE" "$file"
            git add "$file"
        done
        
        if ! git rebase --continue --no-edit; then
            error "$PHASE" "" "" "Gemini failed to resolve all conflicts."
            exit 1
        fi
    fi
    
    # 5. Push resolved branch
    git push origin "$HEAD_BRANCH" --force-with-lease
)

info "$PHASE" "pr:$PR_NUMBER:conflict-resolution" "pr/$PR_NUMBER" "Conflict resolution completed."
