#!/bin/bash

# lib/gemini.sh
# Gemini CLI helpers

invoke_gemini() {
    local prompt_file="$1"
    local output_file="$2"
    
    gemini --yolo --sandbox $GEMINI_ARGS --prompt "-" < "$prompt_file" > "$output_file"
}

invoke_gemini_with_worktree() {
    local prompt_file="$1"
    local output_file="$2"
    local wt_path="$3"
    
    # Get absolute paths
    local abs_prompt=$(realpath "$prompt_file")
    local abs_output=$(realpath "$output_file")
    
    # Using gemini for non-interactive run in a specific directory
    (
        cd "$wt_path"
        gemini --yolo --sandbox $GEMINI_ARGS --prompt "-" < "$abs_prompt" > "$abs_output"
    )
}
