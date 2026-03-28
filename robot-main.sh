#!/bin/bash

# robot-main.sh - Supervisor

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"

# Initial validation
if ! bash doctor.sh; then
    error "startup" "" "" "Doctor check failed. Exiting."
    exit 1
fi

info "startup" "" "" "Supervisor started."

run_phase() {
    local phase="$1"
    local script="$2"
    
    info "$phase" "" "" "Starting phase."
    
    if [ -f "$script" ]; then
        if ! bash "$script"; then
            error "$phase" "" "" "Phase failed with exit code $?."
        else
            info "$phase" "" "" "Phase completed."
        fi
    else
        warn "$phase" "" "" "Worker script $script not found. Skipping."
    fi
}

reap_jobs() {
    info "reap" "" "" "Reaping finished jobs."
    # Check active_jobs.json and remove PIDs that are no longer running
    local active_jobs=$(cat .grkr/state/active_jobs.json)
    local job_keys=$(echo "$active_jobs" | jq -r 'keys[]')
    
    for key in $job_keys; do
        local pid=$(echo "$active_jobs" | jq -r ".\"$key\".pid")
        if ! ps -p "$pid" > /dev/null 2>&1; then
            info "reap" "$key" "" "Job process $pid no longer exists. Removing from active jobs."
            remove_job "$key"
        fi
    done
}

cleanup_stale() {
    info "cleanup" "" "" "Cleaning up stale worktrees and locks."
    # Prune worktrees older than 1 hour (simplified)
    git worktree prune
}

ITERATION=0
while true; do
    tick_started_at=$(date +%s)
    ITERATION=$((ITERATION + 1))
    
    run_phase "sync_main" "worker-sync-main.sh"
    run_phase "scan_prs" "worker-scan-pr-conflicts.sh"
    run_phase "scan_comments" "worker-scan-comments.sh"
    run_phase "pick_issue" "worker-pick-issue.sh"
    
    reap_jobs
    
    if [ $((ITERATION % 10)) -eq 0 ]; then
        cleanup_stale
    fi
    
    tick_ended_at=$(date +%s)
    elapsed=$((tick_ended_at - tick_started_at))
    remaining=$((LOOP_INTERVAL_SECS - elapsed))
    
    if [ $remaining -gt 0 ]; then
        info "sleep" "" "" "Sleeping for $remaining seconds."
        sleep $remaining
    else
        warn "loop" "" "" "Loop took $elapsed seconds, longer than $LOOP_INTERVAL_SECS interval."
    fi
done
