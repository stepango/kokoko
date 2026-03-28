#!/bin/bash

# lib/worktree.sh
# Git worktree helpers

create_worktree() {
    local slug="$1"
    local base_ref="$2"
    local wt_path=".grkr/worktrees/$slug"
    local branch="robot/$slug"
    
    if [ -d "$wt_path" ]; then
        info "worktree" "" "" "Worktree $wt_path already exists."
        return 0
    fi
    
    git worktree add -b "$branch" "$wt_path" "$base_ref"
}

remove_worktree() {
    local slug="$1"
    local wt_path=".grkr/worktrees/$slug"
    local branch="robot/$slug"
    
    if [ -d "$wt_path" ]; then
        git worktree remove "$wt_path"
        git branch -D "$branch" || true
    fi
}
