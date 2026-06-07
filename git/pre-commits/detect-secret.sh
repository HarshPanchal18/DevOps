#!/bin/bash

# Check for sensitive information in staged changes.

if git diff --cached | grep -E '(AWS_SECRET|API_KEY|PASSWORD|TOKEN)'; then
    echo "Aborting commit: Sensitive information detected in staged changes."
    exit 1
fi
