#!/bin/bash

update_pkgs() {
    sudo apt-get update
    sudo apt install apt-transport-https curl -y # Install essential dependencies
}

install_containerd() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg # Add Docker's official GPG key
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null # Add Docker repo
    sudo apt-get update
    sudo apt-get install containerd.io -y # Install containerd
}

containerd_config() {
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml # Generate default config
    sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml # Enable Systemd cgroup driver
    sudo systemctl restart containerd # Restart containerd
}

install_k8s() {
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg # Add Kubernetes' official GPG key
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list # Add Kubernetes repo
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl # Install Kubernetes
    sudo apt-mark hold kubelet kubeadm kubectl # Hold the installed packages
    sudo systemctl enable --now kubelet # Enable and start kubelet service
}

disable_swaps() {
    sudo swapoff -a # Turn off swap
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab # Comment out swap partitions in /etc/fstab
}

enable_kernel_module() {
    sudo modprobe br_netfilter # Enable bridge netfilter module
    sudo sysctl -w net.ipv4.ip_forward=1 # Enable IP forwarding
}

setup_k8s() {
    # Master only
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 # --ignore-preflight-errors=all
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config # Copy kubeconfig to user's home directory
    sudo chown $(id -u):$(id -g) $HOME/.kube/config # Change ownership of kubeconfig
}

install_calico() {
    # Master only
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml # Install Calico CNI
}

echo "Updating package lists..."
update_pkgs

echo "Installing containerd..."
install_containerd

echo "Configuring containerd..."
containerd_config

echo "Installing Kubernetes..."
install_k8s

echo "Disabling swap..."
disable_swaps

echo "Enabling kernel modules..."
enable_kernel_module

echo "Setting up Kubernetes..."
setup_k8s

echo "Installing Calico..."
install_calico

echo "Kubernetes cluster setup completed successfully!"
sudo kubectl get nodes