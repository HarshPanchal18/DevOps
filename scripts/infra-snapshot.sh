#!/bin/bash

# Quickly take a snapshot of the current infrastructure state.

# Configuration
SNAPSHOT_DIR="/var/log/snapshots"
DATE=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$SNAPSHOT_DIR/snapshot_$DATE.log"

# Functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# To be sure snapshot directory exists
if ! mkdir -p "$SNAPSHOT_DIR"; then
    echo "ERROR: Failed to create directory $SNAPSHOT_DIR"
    exit 1
fi

log "Starting infrastructure snapshot..."

# Capture processes
if ps aux >> "$LOGFILE" 2>/dev/null; then
    log "Captured process list."
else
    log "ERROR: Failed to capture process list."
fi

# Capture listening ports and sockets
if ss -tulnp >> "$LOGFILE" 2>/dev/null; then
    log "Captured network sockets."
else
    log "ERROR: Failed to capture network sockets."
fi

# Capture installed packages (Debian/Ubuntu)
if command -v dpkg &>/dev/null; then
    if dpkg -l >> "$LOGFILE" 2>/dev/null; then
        log "Captured installed packages (dpkg)."
    else
        log "ERROR: Failed to capture dpkg package list."
    fi
elif command -v rpm &>/dev/null; then
    if rpm -qa >> "$LOGFILE" 2>/dev/null; then
        log "Captured installed packages (rpm)."
    else
        log "ERROR: Failed to capture rpm package list."
    fi
else
    log "WARNING: Package manager not detected; skipping package snapshot."
fi

log "Infrastructure snapshot taken on $DATE."
exit 0