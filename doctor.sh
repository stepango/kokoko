#!/bin/bash

# Load configuration
CONFIG_FILE="$(dirname "$0")/.grkr/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

set -e

echo "Running doctor check..."

# 1. Check if gh auth status succeeds
if ! gh auth status > /dev/null 2>&1; then
    echo "Error: gh auth status failed. Please run 'gh auth login'."
    exit 1
fi
echo "✓ gh auth status"

# 2. Check GitHub token scopes (requires 'repo', 'read:org', 'read:project')
# This is a bit tricky to check exactly via CLI without parsing, 
# but we can try to access the project as a proxy.
# Or just assume for now if gh auth status is OK.

# 3. Check git remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$REMOTE_URL" != *"$REPO"* ]]; then
    echo "Error: git remote origin ($REMOTE_URL) does not match configured REPO ($REPO)."
    exit 1
fi
echo "✓ git remote"

# 4. Check gemini
if ! command -v gemini > /dev/null 2>&1; then
    echo "Error: gemini CLI not found."
    exit 1
fi
# Check if it runs
if ! gemini --help > /dev/null 2>&1; then
    echo "Error: gemini CLI is installed but failed to run."
    exit 1
fi
echo "✓ gemini"

# 5. Check other tools
for tool in jq timeout flock git gh; do
    if ! command -v "$tool" > /dev/null 2>&1; then
        echo "Error: $tool not found."
        exit 1
    fi
done
echo "✓ Required tools (jq, timeout, flock, git, gh)"

# 6. Check .grkr directory
if [ ! -d ".grkr" ] || [ ! -w ".grkr" ]; then
    echo "Error: .grkr directory is missing or not writable."
    exit 1
fi
echo "✓ .grkr directory"

# 7. Check project configuration
# We need to verify that the PROJECT_NUMBER exists and has required fields.
# For now, let's just check if we can fetch it.
if ! gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" > /dev/null 2>&1; then
    echo "Error: GitHub Project $PROJECT_NUMBER not found for owner $PROJECT_OWNER."
    # We might need to create it if it doesn't exist, but doctor should just report.
    exit 1
fi
echo "✓ GitHub Project $PROJECT_NUMBER"

# Check fields (Status, Priority)
PROJECT_FIELDS=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json)

check_field() {
    local field_name="$1"
    if ! echo "$PROJECT_FIELDS" | jq -e ".fields[] | select(.name == \"$field_name\")" > /dev/null; then
        echo "Error: Project field '$field_name' not found."
        exit 1
    fi
}

check_field "$STATUS_FIELD_NAME"
check_field "$PRIORITY_FIELD_NAME"
echo "✓ Project fields ($STATUS_FIELD_NAME, $PRIORITY_FIELD_NAME)"

echo "Doctor check passed!"
exit 0
