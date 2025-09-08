#!/bin/bash

# Script to append "demo" group to each permissions section in application.json
# Usage: ./add_demo_group.sh [path_to_application.json]

set -e  # Exit on any error

# Default file path
JSON_FILE="${1:-application.json}"

# Check if file exists
if [[ ! -f "$JSON_FILE" ]]; then
    echo "Error: File '$JSON_FILE' not found!"
    echo "Usage: $0 [path_to_application.json]"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: sudo apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

# Create backup of original file
BACKUP_FILE="${JSON_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$JSON_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Check if "demo" already exists in any permissions array
DEMO_EXISTS=$(jq -r '.permissions | to_entries[] | select(.value[] == "demo") | .key' "$JSON_FILE" 2>/dev/null || true)

if [[ -n "$DEMO_EXISTS" ]]; then
    echo "Warning: 'demo' group already exists in the following permissions: $DEMO_EXISTS"
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Add "demo" to each permissions array if it doesn't already exist
echo "Adding 'demo' group to permissions..."

# Process the JSON file
jq '
.permissions.EXECUTE |= if index("demo") then . else . + ["demo"] end |
.permissions.READ |= if index("demo") then . else . + ["demo"] end |
.permissions.WRITE |= if index("demo") then . else . + ["demo"] end
' "$JSON_FILE" > "${JSON_FILE}.tmp"

# Replace original file with updated content
mv "${JSON_FILE}.tmp" "$JSON_FILE"

echo "Successfully added 'demo' group to all permissions sections in $JSON_FILE"

# Display the updated permissions section
echo
echo "Updated permissions section:"
jq '.permissions' "$JSON_FILE"

echo
echo "Backup saved as: $BACKUP_FILE"
