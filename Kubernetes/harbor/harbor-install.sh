#!/bin/bash

function check_helm_installed() {
    if command -v helm &> /dev/null; then
        echo "Helm is already installed of version: $(helm --version)"
        exit 0
    else
        echo "Helm is not installed. Proceeding with installation..."
        snap install helm --classic
    fi
}

function fetch_harbor() {
    if [ -d "harbor" ]; then
        echo "Harbor helm chart already fetched."
        exit 0
    else
        echo "Fetching Harbor helm chart..."
        # Add Harbor helm repo
        helm repo add harbor https://helm.goharbor.io
        helm repo update

        # Fetch Harbor helm chart
        helm fetch harbor/harbor --untar

    fi
}

check_helm_installed
fetch_harbor

cd harbor