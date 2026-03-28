#!/bin/bash

# lib/github.sh
# GitHub API helpers

post_comment() {
    local issue_num="$1"
    local body_file="$2"
    gh issue comment "$issue_num" --body-file "$body_file" --repo "$REPO"
}

get_comments() {
    local issue_num="$1"
    gh issue view "$issue_num" --repo "$REPO" --json comments --jq '.comments[]'
}

get_issue_context() {
    local issue_num="$1"
    gh issue view "$issue_num" --repo "$REPO" --json title,body,author,createdAt,updatedAt
}

find_checkpoint_comment() {
    local issue_num="$1"
    local stage="$2"
    local slug="$3"
    
    # Search for the checkpoint marker in comments
    get_comments "$issue_num" | jq -r --arg stage "$stage" --arg slug "$slug" '
        select(.body | contains("grkr:checkpoint stage=" + $stage + " task=" + $slug))
        | .id
    ' | head -n 1
}

find_project_item_id() {
    local issue_num="$1"
    gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json | jq -r --arg num "$issue_num" '
        .items[] | select(.content.number == ($num | tonumber)) | .id
    '
}

update_project_item_status() {
    local item_id="$1"
    local status_name="$2"
    
    # We need the option ID for the status name
    local option_id=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json | jq -r --arg status "$status_name" '
        .fields[] | select(.name == "Status") | .options[] | select(.name == $status) | .id
    ')
    
    if [ -n "$option_id" ]; then
        gh project item-edit --id "$item_id" --project-id "PVT_kwHOABOmdc4BTCfi" --field-id "PVTSSF_lAHOABOmdc4BTCfizhAZd9I" --single-select-option-id "$option_id"
    else
        echo "Error: Could not find option ID for status $status_name"
        return 1
    fi
}

create_pull_request() {
    local issue_num="$1"
    local title="$2"
    local head_branch="$3"
    
    gh pr create --repo "$REPO" --base "$MAIN_BRANCH" --head "$head_branch" --title "$title" --body "Fixes #$issue_num"
}

add_reaction() {
    local comment_id="$1"
    local reaction="$2" # eyes, rocket, etc.
    gh api graphql -f query='mutation($id:ID!, $reaction:ReactionContent!) { addReaction(input: {subjectId: $id, content: $reaction}) { reaction { content } } }' -f id="$comment_id" -f reaction="$reaction"
}

list_recent_comments() {
    # This is a bit broad, but we can search for comments in the repo
    # Or just list recent issue comments
    gh api "repos/$REPO/issues/comments?sort=created&direction=desc&per_page=50"
}

list_open_pull_requests() {
    gh pr list --repo "$REPO" --state open --json number,headRefName,baseRefName,mergeable
}

remove_reaction() {
    local comment_id="$1"
    local reaction="$2"
    gh api graphql -f query='mutation($id:ID!, $reaction:ReactionContent!) { removeReaction(input: {subjectId: $id, content: $reaction}) { reaction { content } } }' -f id="$comment_id" -f reaction="$reaction"
}
