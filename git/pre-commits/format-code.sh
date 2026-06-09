#!/bin/bash

# Check for code formatting issues using Prettier in the staged changes and aborts the commit if any are found.

if ! prettier --check $(git diff --cached --name-only); then
    echo "Aborting commit: Code formatting issues detected."
    exit 1
fi

# If you want to automatically fix formatting issues, uncomment the following line:
# prettier --write $(git diff --cached --name-only)
# git add $(git diff --cached --name-only)
# This will automatically stage the changes made by Prettier.
# Note: Make sure to have Prettier installed and configured in your project.

# You can install Prettier globally using npm:
# npm install -g prettier
# Or you can add it as a dev dependency in your project:
# npm install --save-dev prettier
# You can also create a Prettier configuration file (e.g., .prettierrc) in your project root to customize the formatting rules.
