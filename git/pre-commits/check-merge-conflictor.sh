#!/bin/bash

# Check for merge conflict markers
if git diff --cached | grep -E '<<<<<<<|=======|>>>>>>>'; then
    echo "Aborting commit: Merge conflict markers detected in staged changes."
    exit 1
fi

# Check for merge conflict markers in all files
if git diff --cached --name-only | xargs grep -E '<<<<<<<|=======|>>>>>>>'; then
    echo "Aborting commit: Merge conflict markers detected in staged changes."
    exit 1
fi
