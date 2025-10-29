#!/bin/bash

# Usage: ./append-configmap.sh <configmap-name> <namespace> key1:value1 [key2:value2 ...]

set -e

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <configmap-name> <namespace> key1:value1 [key2:value2 ...]"
    exit 1
fi

CM_NAME=$1
NAMESPACE=$2
KEY=$3
VALUE=$4

shift 2

TMP_FILE=$(mktemp -p .)

# Export current ConfigMap to temp file
kubectl get configmap "$CM_NAME" -n "$NAMESPACE" -o yaml > "$TMP_FILE"

# If 'data:' does not exist, add it
if ! grep -q "^data:" "$TMP_FILE"; then
    echo "data:" >> "$TMP_FILE"
fi

# Check if yq is installed
# Uncomment the following lines if you want to ensure yq is installed before proceeding
# Note: This part is commented out to avoid requiring yq installation for the script to run
# if ! command -v yq &> /dev/null; then
#     echo "yq is not installed. Please install yq to manipulate YAML files."
#     echo "Do you want to install yq now? (y/n)"
#     read -r INSTALL_YQ
#     if [ "$INSTALL_YQ" != "y" ]; then
#         echo "Exiting without installing yq."
#         exit 1
#     fi

#     sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
#     sudo chmod +x /usr/local/bin/yq
#     echo "yq installed successfully."
# fi

# Loop over each key:value argument
for pair in "$@"; do

    if [[ ! "$pair" =~ ^[^:]+:[^:]+$ ]]; then
        echo "Invalid pair '$pair'. Must be in format key:value"
        exit 1
    fi

    KEY="${pair%%:*}"   # part before the first colon
    VALUE="${pair#*:}"  # part after the first colon

    # AWK block to append or update the key-value pair in the data section of the ConfigMap
    # The following awk script does the following:
    # -v k="$KEY" -v v="$VALUE"     : Passes your shell variables $KEY and $VALUE into the awk script.
    # BEGIN { ... }                 : Create a regular expression to find the key, ensuring it's indented.
    # in_data = 1                   : A flag is set when the script enters the data: block.
    # in_data && /^\S/              : Detect the end of the data block by finding the next un-indented line. If the key wasn't found (!key_found), it inserts the new key-value pair.
    # in_data && $0 ~ key_regex     : If inside the data block and the line contains the key, it replaces the line with the new value, preserving the original indentation.
    # END { ... }                   : Handle the special case where data: is the very last section in the file.
    # > "$TMP_FILE.tmp" && mv ...   : Safely performs the in-place edit, which is the standard way to modify a file with awk.

    awk -v key="$KEY" -v val="$VALUE" '
    BEGIN { key_regex = "^[[:space:]]+" key ":" }
    /^data:/ { in_data = 1 }
    in_data && /^\S/ && !/^data:/ {
        if (!key_found) { print "  " key ": \"" val "\"" }
        key_found = 1; in_data = 0;
    }
    in_data && $0 ~ key_regex {
        match($0, /^[[:space:]]+/);
        print substr($0, RSTART, RLENGTH) key ": \"" val "\"";
        key_found = 1; next;
    }
    { print }
    END {
        if (in_data && !key_found) { print "  " key ": \"" val "\"" }
    }
    ' "$TMP_FILE" > "$TMP_FILE.tmp" && mv "$TMP_FILE.tmp" "$TMP_FILE"

    # Alternatively, using yq to append or update the key-value pair
    # yq e ".data.\"$KEY\" = \"$VALUE\"" -i "$TMP_FILE"

done

# Apply back to cluster
kubectl apply -f "$TMP_FILE" 2>/dev/null
rm "$TMP_FILE"
