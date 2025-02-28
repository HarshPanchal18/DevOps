#!/bin/bash

update_pkgs() {
    sudo apt-get update
    sudo apt install apt-transport-https curl -y
}

install_containerd() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install containerd.io -y
}

containerd_config() {
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    sudo systemctl restart containerd
}

install_k8s() {
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
}

disable_swaps() {
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

enable_kernel_module() {
    sudo modprobe br_netfilter
    sudo sysctl -w net.ipv4.ip_forward=1
}

setup_k8s() {
    # Master only
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

install_calico() {
    # Master only
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
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