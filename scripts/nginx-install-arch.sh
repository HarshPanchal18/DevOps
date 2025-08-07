#!/bin/bash

# Update package index and install nginx using yum (for Amazon Linux, RHEL, CentOS)
sudo yum update -y
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Firewall configuration for firewalld (common on RHEL/CentOS/Amazon Linux 2)
if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --zone=public --add-service=http
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload
fi

# Check if Nginx is enabled to start on boot
if systemctl is-enabled --quiet nginx; then
    echo "Nginx is enabled to start on boot."
else
    echo "Nginx is not enabled to start on boot."
fi

# Check if Nginx is listening on port 80
if sudo netstat -tuln | grep ':80'; then
    echo "Nginx is listening on port 80."
else
    echo "Nginx is not listening on port 80."
fi

# echo "Hello World!" | sudo tee /usr/share/nginx/html/index.html

echo "Nginx installation and configuration completed successfully."