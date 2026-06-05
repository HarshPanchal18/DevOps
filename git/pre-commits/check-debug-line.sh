#!/bin/bash

# Check for debugging code.

if git diff --cached | grep -E '(console\.log|debugger)'; then
    echo "Aborting commit: Debugging code detected in staged changes."
    exit 1
fi
