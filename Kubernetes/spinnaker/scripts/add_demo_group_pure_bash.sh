#!/bin/bash

# Script to append "demo" group to each permissions section in application.json
# Pure bash version without jq dependency - Not tested yet.
# Usage: ./add_demo_group_pure_bash.sh [path_to_application.json]

set -e  # Exit on any error

# Default file path
JSON_FILE="${1:-application.json}"

# Check if file exists
if [[ ! -f "$JSON_FILE" ]]; then
    echo "Error: File '$JSON_FILE' not found!"
    echo "Usage: $0 [path_to_application.json]"
    exit 1
fi

# Create backup of original file
BACKUP_FILE="${JSON_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$JSON_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Check if "demo" already exists in the file
if grep -q '"demo"' "$JSON_FILE"; then
    echo "Warning: 'demo' group already exists in the file."
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

echo "Adding 'demo' group to permissions..."

# Create temporary file
TEMP_FILE="${JSON_FILE}.tmp"

# Process the file line by line
while IFS= read -r line; do
    # Check if this line contains a permissions array that ends with ]
    if [[ $line =~ ^[[:space:]]*\"(EXECUTE|READ|WRITE)\":[[:space:]]*\[.*\][[:space:]]*,?[[:space:]]*$ ]]; then
        # Extract the permission type and the array content
        if [[ $line =~ \"(EXECUTE|READ|WRITE)\":[[:space:]]*\[(.*)\](.*)$ ]]; then
            perm_type="${BASH_REMATCH[1]}"
            array_content="${BASH_REMATCH[2]}"
            line_ending="${BASH_REMATCH[3]}"

            # Check if "demo" is already in this array
            if [[ ! $array_content =~ \"demo\" ]]; then
                # Add "demo" to the array
                if [[ -n $array_content && $array_content != *[[:space:]] ]]; then
                    # Array has content, add comma and demo
                    new_line="        \"$perm_type\": [${array_content}, \"demo\"]${line_ending}"
                else
                    # Empty array, just add demo
                    new_line="        \"$perm_type\": [\"demo\"]${line_ending}"
                fi
                echo "$new_line" >> "$TEMP_FILE"
            else
                # "demo" already exists, keep original line
                echo "$line" >> "$TEMP_FILE"
            fi
        else
            echo "$line" >> "$TEMP_FILE"
        fi
    else
        # Not a permissions array line, keep as is
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$JSON_FILE"

# Replace original file with updated content
mv "$TEMP_FILE" "$JSON_FILE"

echo "Successfully added 'demo' group to all permissions sections in $JSON_FILE"

# Display the updated permissions section
echo
echo "Updated permissions section:"
sed -n '/\"permissions\":/,/}/p' "$JSON_FILE"

echo
echo "Backup saved as: $BACKUP_FILE"
