#!/bin/bash

# Install Terraform on a Debian-based system.

# Get the latest version of Terraform. Add the HashiCorp GPG key and repository.
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the HashiCorp repository to the sources list and ensure it uses the correct architecture.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update the package list and install Terraform.
sudo apt update && sudo apt install terraform

# Verify the installation.
terraform -version
