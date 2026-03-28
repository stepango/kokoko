#!/bin/bash

# lib/state.sh
# Manages internal state

STATE_DIR=".grkr/state"
ACTIVE_JOBS_FILE="$STATE_DIR/active_jobs.json"

if [ ! -f "$ACTIVE_JOBS_FILE" ]; then
    echo "{}" > "$ACTIVE_JOBS_FILE"
fi

is_job_active() {
    local job_key="$1"
    jq -e ".\"$job_key\" != null" "$ACTIVE_JOBS_FILE" > /dev/null
}

register_job() {
    local job_key="$1"
    local pid="$2"
    local metadata="$3"
    
    local tmp_file=$(mktemp)
    jq ".\"$job_key\" = {pid: \"$pid\", started_at: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", metadata: $metadata}" "$ACTIVE_JOBS_FILE" > "$tmp_file"
    mv "$tmp_file" "$ACTIVE_JOBS_FILE"
}

remove_job() {
    local job_key="$1"
    local tmp_file=$(mktemp)
    jq "del(.\"$job_key\")" "$ACTIVE_JOBS_FILE" > "$tmp_file"
    mv "$tmp_file" "$ACTIVE_JOBS_FILE"
}
