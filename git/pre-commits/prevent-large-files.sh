#!/bin/bash

# Check for files larger than 5MB in the staged changes and aborts the commit if any are found.

MAX_SIZE=5000000 # 5MB
FILES=$(git diff --cached --name-only)

for FILE in $FILES; do
    if [ -f "$FILE" ] && [ $(stat -c%s "$FILE") -gt $MAX_SIZE ]; then
        echo "Aborting commit: File $FILE exceeds size limit of 5MB."
        exit 1
    fi
done

# OR

if git diff --cached --name-only | xargs du -b | awk '{if ($1 > 1048576) print $2}'; then
    echo "Aborting commit: Large files detected in staged changes."
    exit 1
fi
