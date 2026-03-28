#!/bin/bash

# lib/log.sh
# Provides logging functions

log() {
    local level="$1"
    local phase="$2"
    local job_key="$3"
    local entity="$4"
    local msg="$5"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local log_line="$timestamp $level phase=$phase job=$job_key entity=$entity msg=\"$msg\""
    
    echo "$log_line"
    echo "$log_line" >> .grkr/logs/main.log
    
    if [ "$phase" != "" ]; then
        echo "$log_line" >> .grkr/logs/loop.log
    fi
}

info() {
    log "INFO" "$1" "$2" "$3" "$4"
}

error() {
    log "ERROR" "$1" "$2" "$3" "$4"
}

warn() {
    log "WARN" "$1" "$2" "$3" "$4"
}
