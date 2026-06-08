#!/bin/bash

# Checks if the commit message follows the Conventional Commits format.

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat $COMMIT_MSG_FILE)

if ! echo "$COMMIT_MSG" | grep -Eq '^(feat|fix|docs|style|refactor|test|chore): .+'; then
    echo "Aborting commit: Commit message does not follow the Conventional Commits format."
    exit 1
fi

# Check if the commit message contains a JIRA ticket number
if ! echo "$COMMIT_MSG" | grep -Eq '^[A-Z]+-[0-9]+'; then
    echo "Aborting commit: Commit message does not contain a JIRA ticket number."
    exit 1
fi

# Check if the commit message is too long
if [ ${#COMMIT_MSG} -gt 72 ]; then
    echo "Aborting commit: Commit message is too long."
    exit 1
fi

# Check if the commit message is too short
if [ ${#COMMIT_MSG} -lt 10 ]; then
    echo "Aborting commit: Commit message is too short."
    exit 1
fi

# Check if the commit message contains a body
if ! echo "$COMMIT_MSG" | grep -Eq '\n\n'; then
    echo "Aborting commit: Commit message does not contain a body."
    exit 1
fi

# Check if the commit message contains a footer
if ! echo "$COMMIT_MSG" | grep -Eq '\n\n\n'; then
    echo "Aborting commit: Commit message does not contain a footer."
    exit 1
fi

# Check if the commit message contains a breaking change
if ! echo "$COMMIT_MSG" | grep -Eq 'BREAKING CHANGE:'; then
    echo "Aborting commit: Commit message does not contain a breaking change."
    exit 1
fi

# Check if the commit message contains a footer with a breaking change
if ! echo "$COMMIT_MSG" | grep -Eq 'BREAKING CHANGE: .+'; then
    echo "Aborting commit: Commit message does not contain a footer with a breaking change."
    exit 1
fi
