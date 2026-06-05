#!/bin/bash

# Check if any dependency files (like package-lock.json or requirements.txt) have been modified in the staged changes.

if git diff --cached --name-only | grep -qE '(package-lock.json|requirements.txt)'; then
    echo "Warning: Dependency files modified. Ensure dependencies are updated."
fi