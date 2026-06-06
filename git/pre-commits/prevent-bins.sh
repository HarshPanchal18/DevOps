#!/bin/bash

# Check for binary files

if git diff --cached --name-only | grep -E '\.(exe|dll|bin)$'; then
    echo "Aborting commit: Binary files detected in staged changes."
    exit 1
fi
