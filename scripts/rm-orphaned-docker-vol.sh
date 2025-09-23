#!/bin/bash

# Quickly find Docker volumes not tied to any container and optionally remove them.

# Pre-Configuration
DRY_RUN=true     # Set to false by using --delete
LOG_TO_FILE=false
LOG_FILE="/var/log/docker_volume_cleanup.log"
SCRIPT_NAME="rm-orphaned-docker-vol"

log() {
    local msg="$1"
    if $LOG_TO_FILE; then
        echo "$(date '+%F %T') $SCRIPT_NAME: $msg" >> "$LOG_FILE"
    else
        logger -t "$SCRIPT_NAME" "$msg"
    fi
}

# Handle command-line arguments
if [[ "$1" == "--delete" ]]; then
    DRY_RUN=false
    log "Running in DELETE mode. Orphaned volumes will be removed."
else
    log "Running in DRY-RUN mode. No volumes will be removed."
fi

# Check if Docker is running
if ! docker info &>/dev/null; then
    log "Docker is not running or not accessible. Exiting."
    exit 1
fi

# List and Handle Orphaned Volumes
ORPHANED_VOLUMES=$(docker volume ls -qf dangling=true)

if [[ -z "$ORPHANED_VOLUMES" ]]; then
    log "No orphaned volumes found."
    exit 0
fi

echo "Found orphaned Docker volumes:"
for vol in $ORPHANED_VOLUMES; do
    echo "  - $vol"
    log "Orphaned volume found: $vol"

    if ! $DRY_RUN; then
        if docker volume rm "$vol" &>/dev/null; then
            log "Removed volume: $vol"
        else
            log "ERROR: Failed to remove volume: $vol"
        fi
    fi
done

log "Docker volume cleanup completed."