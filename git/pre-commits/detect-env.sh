#!/bin/bash

# pre-commit hook.
# Check for .env files in the staged changes and aborts the commit if any are found.
# It should be placed in the .git/hooks directory and made executable as chmod +x .git/hooks/pre-commit.

if git diff --cached --name-only | grep -q '\.env'; then
    echo "Aborting commit: .env file(s) detected in staged changes."
    exit 1
fi
