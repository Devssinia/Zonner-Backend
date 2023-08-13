#!/bin/bash

# Update package lists and install Nginx, Git, and Docker
sudo apt update
sudo apt install nginx git
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo usermod -aG docker ${USER}

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Node.js and NVM
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install lts/hydrogen

# Install PostgreSQL and PostgreSQL-contrib
sudo apt update
sudo apt install postgresql postgresql-contrib


# Configure UFW Firewall
sudo ufw allow 'Nginx HTTP'
sudo ufw enable
sudo ufw allow 443
sudo ufw allow 80
sudo ufw allow 22
sudo ufw allow 2000
sudo ufw reload

# Install PM2
sudo npm install pm2 -g


