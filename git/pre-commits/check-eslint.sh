#!/bin/bash

# Run linter on staged files

FILES=$(git diff --cached --name-only -- '*.js' '*.py')
if [ -n "$FILES" ]; then
    eslint $FILES
    if [ $? -ne 0 ]; then
        echo "Aborting commit: Linting errors detected."
        exit 1
    fi
fi
