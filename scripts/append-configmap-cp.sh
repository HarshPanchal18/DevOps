#!/bin/bash
# Usage:
# ./append-configmap.sh <configmap-name> <namespace> [kubectl create configmap args...]
#
# Example:
# ./append-configmap.sh my-config my-namespace --from-literal=foo=bar
# ./append-configmap.sh my-config my-namespace --from-env-file=my.env
# ./append-configmap.sh my-config my-namespace --from-file=app.conf

set -e

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <configmap-name> <namespace> [kubectl create configmap args...]"
    exit 1
fi

CM_NAME=$1
NAMESPACE=$2
shift 2

# 1. Get existing configmap
EXISTS=$(kubectl get configmap "$CM_NAME" -n "$NAMESPACE" --ignore-not-found)

# 2. Create a "new" configmap YAML from provided args, but don't apply
NEW_CM=$(kubectl create configmap "$CM_NAME" "$@" -o yaml --dry-run=client)

if [ -z "$EXISTS" ]; then
    echo "ConfigMap '$CM_NAME' does not exist, creating new one..."
    echo "$NEW_CM" | kubectl apply -n "$NAMESPACE" -f -
    exit 0
fi

# 3. Merge data sections
MERGED_CM=$(kubectl get configmap "$CM_NAME" -n "$NAMESPACE" -o yaml \
    | kubectl create configmap "$CM_NAME" "$@" -o yaml --dry-run=client \
    | kubectl patch -n "$NAMESPACE" configmap "$CM_NAME" --type merge -p "$(kubectl create configmap "$CM_NAME" "$@" -o json --dry-run=client \
    | jq '{data: .data}')")

echo "ConfigMap '$CM_NAME' updated in namespace '$NAMESPACE'."
