#!/bin/bash

# Configuration
USER="user"
HOST="host"
SSH_DIR="$HOME/.ssh"
OLD_KEY="$SSH_DIR/id_rsa"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NEW_KEY="$SSH_DIR/id_rsa_$TIMESTAMP"
BACKUP_SUFFIX=".bak_$TIMESTAMP"
KEY_TYPE="rsa"
KEY_BITS=4096
QUIET=true

# Logging Function
log() {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

# Pre-checks
if ! command -v ssh-keygen >/dev/null || ! command -v ssh-copy-id >/dev/null; then
    log "ERROR: Required commands (ssh-keygen, ssh-copy-id) not found."
    exit 1
fi

if ! ping -c 1 -W 2 "$HOST" &>/dev/null; then
    log "ERROR: Host $HOST unreachable. Aborting."
    exit 1
fi

log "Generating new SSH key at $NEW_KEY..."
ssh-keygen -t "$KEY_TYPE" -b "$KEY_BITS" -f "$NEW_KEY" ${QUIET:+-q} -N ""

if [[ ! -f "${NEW_KEY}.pub" ]]; then
    log "ERROR: Public key generation failed."
    exit 1
fi

log "Copying new public key to $USER@$HOST..."
if ! ssh-copy-id -i "${NEW_KEY}.pub" "$USER@$HOST"; then
    log "ERROR: Failed to copy new key to remote server."
    rm -f "$NEW_KEY" "${NEW_KEY}.pub"
    exit 1
fi

# Backup existing key
if [[ -f "$OLD_KEY" && -f "$OLD_KEY.pub" ]]; then
    log "Backing up old keys..."
    cp "$OLD_KEY" "$OLD_KEY$BACKUP_SUFFIX"
    cp "$OLD_KEY.pub" "$OLD_KEY.pub$BACKUP_SUFFIX"
else
    log "WARNING: No existing SSH key pair to back up."
fi

# Replace key
log "Replacing old key with new key..."
mv "$NEW_KEY" "$OLD_KEY"
mv "${NEW_KEY}.pub" "$OLD_KEY.pub"
chmod 600 "$OLD_KEY"
chmod 644 "$OLD_KEY.pub"

log "Testing new SSH key connection to $USER@$HOST..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$USER@$HOST" true; then
    log "SSH key rotation successful. You can connect with the new key."
else
    log "WARNING: New key setup failed. Reverting..."
    mv "$OLD_KEY" "$NEW_KEY"
    mv "$OLD_KEY.pub" "${NEW_KEY}.pub"
    mv "$OLD_KEY$BACKUP_SUFFIX" "$OLD_KEY"
    mv "$OLD_KEY.pub$BACKUP_SUFFIX" "$OLD_KEY.pub"
    exit 2
fi

log "SSH key rotation completed successfully."
exit 0
