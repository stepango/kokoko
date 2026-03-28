#!/bin/bash

# worker-sync-main.sh

source "$(dirname "$0")/.grkr/config.sh"
source "$(dirname "$0")/.grkr/lib/log.sh"
source "$(dirname "$0")/.grkr/lib/lock.sh"

PHASE="sync_main"

sync_logic() {
    info "$PHASE" "" "" "Syncing main branch."
    git fetch origin "$MAIN_BRANCH" --prune
    git checkout "$MAIN_BRANCH"
    git reset --hard "origin/$MAIN_BRANCH"
}

with_lock "main" sync_logic
