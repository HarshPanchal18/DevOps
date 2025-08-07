#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
sudo ufw delete allow 'Nginx HTTPS'

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

# echo "Hello World!" | sudo tee /var/www/html/index.html

echo "Nginx installation and configuration completed successfully."