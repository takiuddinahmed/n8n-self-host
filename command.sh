#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting n8n self-hosting setup..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root"
    exit 1
fi

# Remove incompatible or out of date Docker implementations if they exist
echo "🧹 Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg 2>/dev/null || true
done

# Install prereq packages
echo "📦 Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
# Download the repo signing key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Configure the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker and Docker Compose
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



# Add user to docker group
echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Start and enable Docker
echo "🐳 Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Create local-files directory
echo "📁 Creating local-files directory..."
mkdir -p local-files

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "📄 Creating from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file successfully!"
fi

# Start services
echo "🚀 Starting n8n services..."
sudo docker compose up -d

echo "✅ Setup complete!"
echo "📝 Next steps:"
echo "1. Configure your DNS to point to this server"
echo "2. Access n8n at: https://$(grep SUBDOMAIN .env | cut -d'=' -f2).$(grep DOMAIN_NAME .env | cut -d'=' -f2)"
echo "3. Check logs with: docker compose logs -f"