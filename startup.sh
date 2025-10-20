#!/bin/bash
# Update system
apt update -y && apt upgrade -y

# Install Git
apt install -y git

# Clone or update the repository
APP_DIR="/opt/app"

if [ ! -d "$APP_DIR" ]; then
  git clone https://github.com/takiuddinahmed/n8n-self-host "$APP_DIR"
else
  cd "$APP_DIR"
  git pull origin main
fi

# Go to the app directory
cd "$APP_DIR"

# Make sure command.sh is executable
chmod +x command.sh

# Run the command script
./command.sh
