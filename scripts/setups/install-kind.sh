#!/bin/bash

# This script installs Kind (Kubernetes IN Docker) on a Linux system.
# For AMD64 / x86_640
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64

if [ $? -ne 0 ]; then
    echo "Failed to download Kind binary."
    exit 1
fi

# Make the binary executable and move it to /usr/local/bin
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

if [ $? -ne 0 ]; then
    echo "Failed to make Kind binary executable."
    exit 1
fi

# Verify the installation
echo "Verifying Kind installation..."
kind version

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Kind installation failed."
    exit 1
else
    echo "Kind installed successfully."
fi
