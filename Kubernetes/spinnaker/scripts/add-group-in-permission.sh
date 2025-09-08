#!/bin/bash

# Usage: ./add-group-in-permission.sh [group_name] [path_to_json]
# Works for both a single application object or an array of applications.

set -e

FILE="$2"

if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found!"
    exit 1
fi

BACKUP_FILE="${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# jq filter: handle both array and single object
jq '
  (if type == "array" then . else [.] end)
  | map(
      .permissions.EXECUTE |= (if index("'$1'") then . else . + ["'$1'"] end)
    | .permissions.READ    |= (if index("'$1'") then . else . + ["'$1'"] end)
    | .permissions.WRITE?  |= (if index("'$1'") then . else . + ["'$1'"] end)
    | .email = "demo@test.com"
  )
  | (if length == 1 then .[0] else . end)
' "$FILE" > "${FILE}.tmp"

mv "${FILE}.tmp" "$FILE"

echo "Successfully added '$1' group to all permissions arrays."

# cat >> applications.json
# [
#   {
#     "accounts": "test-account",
#     "cloudProviders": "",
#     "createTs": "1571141367157",
#     "dataSources": {
#       "disabled": [],
#       "enabled": []
#     },
#     "description": "To deploy calico policy",
#     "email": "test@mail.com",
#     "instancePort": 80,
#     "lastModifiedBy": "test@mail.com",
#     "name": "calico",
#     "permissions": {
#       "EXECUTE": ["devops", "demo"],
#       "READ": ["devops", "demo"],
#       "WRITE": ["devops", "demo"]
#     },
#     "trafficGuards": [],
#     "updateTs": "1755838735593",
#     "user": "test@mail.com"
#   },
#   {
#     "accounts": "test-account",
#     "cloudProviders": "",
#     "createTs": "1571141367157",
#     "dataSources": {
#       "disabled": [],
#       "enabled": []
#     },
#     "description": "To deploy minio policy",
#     "email": "test@mail.com",
#     "instancePort": 80,
#     "lastModifiedBy": "test@mail.com",
#     "name": "calico",
#     "permissions": {
#       "EXECUTE": ["devops", "demo"],
#       "READ": ["devops", "demo"],
#       "WRITE": ["devops", "demo"]
#     },
#     "trafficGuards": [],
#     "updateTs": "1755838735593",
#     "user": "test@mail.com"
#   }
# ]
