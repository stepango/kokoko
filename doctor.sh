#!/bin/bash

# doctor.sh - Pre-flight check for the autonomous shell-based agent.
# Verifies tools, auth tokens, repository config, and GitHub Project settings.

# Load configuration and logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.grkr/config.sh"
LOG_LIB="$SCRIPT_DIR/.grkr/lib/log.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

if [ -f "$LOG_LIB" ]; then
    source "$LOG_LIB"
else
    echo "Error: $LOG_LIB not found."
    exit 1
fi

PHASE="doctor"

log_info() { info "$PHASE" "" "" "$1"; }
log_warn() { warn "$PHASE" "" "" "$1"; }
log_error() { error "$PHASE" "" "" "$1"; }

fail() {
    log_error "$1"
    exit 1
}

log_info "Starting pre-flight checks..."

# 1. Verify required tools are in PATH and functional
REQUIRED_TOOLS=("jq" "timeout" "flock" "git" "gh" "gemini")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" > /dev/null 2>&1; then
        fail "Required tool '$tool' not found in PATH."
    fi
    
    # Basic execution test
    if [ "$tool" == "gemini" ]; then
        if ! gemini --help > /dev/null 2>&1; then
            fail "Tool '$tool' is installed but failed to execute (--help)."
        fi
    elif [ "$tool" == "gh" ]; then
        if ! gh --version > /dev/null 2>&1; then
            fail "Tool '$tool' is installed but failed to execute (--version)."
        fi
    fi
done
log_info "✓ Required tools (${REQUIRED_TOOLS[*]}) are available."

# 2. Comprehensive GitHub Token Scope Validation
log_info "Verifying GitHub authentication and token scopes..."
if ! gh auth status > /dev/null 2>&1; then
    fail "gh auth status failed. Please run 'gh auth login'."
fi

# Parsing scopes from gh auth status output
# Output format example: - Token scopes: 'gist', 'project', 'read:org', 'repo', 'workflow'
SCOPES=$(gh auth status 2>&1 | grep "Token scopes:" | sed "s/.*Token scopes: //" | tr -d "'")
REQUIRED_SCOPES=("repo" "project" "read:org")

for scope in "${REQUIRED_SCOPES[@]}"; do
    if [[ ! ",$SCOPES," =~ ", $scope," ]] && [[ ! ",$SCOPES," =~ ",$scope," ]]; then
        # Handle cases with and without leading spaces
        if [[ "$SCOPES" != *"$scope"* ]]; then
             fail "GitHub token is missing required scope: '$scope'. Current scopes: $SCOPES"
        fi
    fi
done
log_info "✓ GitHub token has required scopes (${REQUIRED_SCOPES[*]})."

# 3. Git Remote and Configuration Validation
log_info "Validating git repository configuration..."
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$REMOTE_URL" != *"$REPO"* ]]; then
    fail "Git remote origin ($REMOTE_URL) does not match configured REPO ($REPO)."
fi

if ! git rev-parse --verify "$MAIN_BRANCH" > /dev/null 2>&1; then
    # Check if it exists on remote if not local
    if ! git rev-parse --verify "origin/$MAIN_BRANCH" > /dev/null 2>&1; then
        fail "Configured MAIN_BRANCH '$MAIN_BRANCH' not found locally or on origin."
    fi
fi
log_info "✓ Git remote and MAIN_BRANCH are correctly configured."

# 4. Detailed GitHub Project V2 Validation
log_info "Verifying GitHub Project V2 ($PROJECT_NUMBER) for owner $PROJECT_OWNER..."
PROJECT_DATA=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json 2>/dev/null)
if [ $? -ne 0 ]; then
    fail "GitHub Project $PROJECT_NUMBER not found for owner $PROJECT_OWNER."
fi

PROJECT_FIELDS=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json 2>/dev/null)
if [ $? -ne 0 ]; then
    fail "Failed to fetch field list for project $PROJECT_NUMBER."
fi

# Verify Status field and options
STATUS_FIELD=$(echo "$PROJECT_FIELDS" | jq -e ".fields[] | select(.name == \"$STATUS_FIELD_NAME\")")
if [ $? -ne 0 ]; then
    fail "Project field '$STATUS_FIELD_NAME' not found."
fi

for val in "$TODO_VALUE" "$BACKLOG_VALUE"; do
    if ! echo "$STATUS_FIELD" | jq -e ".options[] | select(.name == \"$val\")" > /dev/null; then
        fail "Project field '$STATUS_FIELD_NAME' is missing required option: '$val'."
    fi
done

# Verify Priority field
PRIORITY_FIELD=$(echo "$PROJECT_FIELDS" | jq -e ".fields[] | select(.name == \"$PRIORITY_FIELD_NAME\")")
if [ $? -ne 0 ]; then
    fail "Project field '$PRIORITY_FIELD_NAME' not found."
fi

if [[ "$PRIORITY_MODE" == "single_select" ]]; then
    if ! echo "$PRIORITY_FIELD" | jq -e ".options | length > 0" > /dev/null; then
        fail "Project field '$PRIORITY_FIELD_NAME' is configured as single_select but has no options."
    fi
fi

# 5. Directory permission checks
log_info "Checking directory permissions..."
REQUIRED_DIRS=(".grkr" ".grkr/logs" ".grkr/locks" ".grkr/state" ".grkr/worktrees")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        # Try to create it if it doesn't exist
        mkdir -p "$dir" || fail "Failed to create directory '$dir'."
    fi
    if [ ! -w "$dir" ]; then
        fail "Directory '$dir' is not writable."
    fi
done
log_info "✓ .grkr and subdirectories are writable."

# 6. Build and Test command existence (Warnings)
if [ ! -f "$BUILD_COMMAND" ]; then
    log_warn "BUILD_COMMAND '$BUILD_COMMAND' not found. Build steps will fail."
fi

if [ ! -f "$TEST_COMMAND" ]; then
    log_warn "TEST_COMMAND '$TEST_COMMAND' not found. Test steps will fail."
fi

log_info "Doctor check passed successfully!"
echo "Doctor check passed!"
exit 0
