#!/bin/bash

check_docker_installed() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed of version: $(docker --version)"
        exit 0
    else
        echo "Docker is not installed. Proceeding with installation..."
    fi
}

install_docker() {
    echo "Updating package lists..."
    sudo apt update -y

    echo "Installing essential dependencies..."
    sudo apt install -y ca-certificates curl gnupg

    echo "Adding Docker's official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "Setting up the Docker repo..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Updating package index again..."
    sudo apt update -y

    echo "Installing Docker..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Enabling and starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Verifying installation..."
    if docker --version; then
        echo "Docker installed successfully!"
    else
        echo "Docker installation failed!"
    fi
}

check_docker_installed
install_docker