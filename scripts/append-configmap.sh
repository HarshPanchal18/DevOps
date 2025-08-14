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

if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Please install yq to manipulate YAML files."

    echo "Do you want to install yq now? (y/n)"
    read -r INSTALL_YQ
    if [ "$INSTALL_YQ" != "y" ]; then
        echo "Exiting without installing yq."
        exit 1
    fi

    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
    echo "yq installed successfully."
fi

# Loop over each key:value argument
for pair in "$@"; do

    if [[ ! "$pair" =~ ^[^:]+:[^:]+$ ]]; then
        echo "Invalid pair '$pair'. Must be in format key:value"
        exit 1
    fi

    KEY="${pair%%:*}"   # part before the first colon
    VALUE="${pair#*:}"  # part after the first colon

    # Use 'yq' type inference: no quotes, so numbers/bools remain native types
    yq e ".data.\"$KEY\" = \"$VALUE\"" -i "$TMP_FILE"
done

# Apply back to cluster
kubectl apply -f "$TMP_FILE" &>/dev/null

echo "✅ ConfigMap '$CM_NAME' in namespace '$NAMESPACE' updated with provided key-value pairs."
rm "$TMP_FILE"
