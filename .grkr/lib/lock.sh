#!/bin/bash

# lib/lock.sh
# Provides locking functions using flock

with_lock() {
    local lock_name="$1"
    shift
    local lock_file=".grkr/locks/${lock_name}.lock"
    
    (
        flock -n 9 || { echo "Lock ${lock_name} busy, skipping."; exit 0; }
        "$@"
    ) 9>"$lock_file"
}

# Persistent lock for long running jobs
acquire_lock() {
    local lock_name="$1"
    local lock_file=".grkr/locks/${lock_name}.lock"
    
    # Open lock file on fd 9
    exec 9> "$lock_file"
    if ! flock -n 9; then
        return 1
    fi
    return 0
}

release_lock() {
    local lock_name="$1"
    # fd 9 is automatically closed when shell exits, but for manual release:
    exec 9>&-
}
