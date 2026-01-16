#!/bin/bash
# One-time droplet setup script
# Run this on your droplet after first SSH login

set -e

echo "🚀 Setting up DigitalOcean Droplet for LLM Chat App"
echo "=================================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Nginx
echo "🌐 Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    sudo apt install nginx -y
    sudo systemctl enable nginx
    echo "✅ Nginx installed"
else
    echo "✅ Nginx already installed"
fi

# Install curl
sudo apt install curl -y

# Create app directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/llm-chat-app/scripts
sudo chown $USER:$USER /opt/llm-chat-app
echo "✅ Directory created"

# Prompt for GitHub details
echo ""
echo "🔑 GitHub Container Registry Login"
echo "You need a GitHub Personal Access Token with 'read:packages' scope"
echo "Create one at: https://github.com/settings/tokens"
echo ""
read -p "Enter your GitHub username: " GITHUB_USER
read -sp "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo ""

# Login to GitHub Container Registry
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin

if [ $? -eq 0 ]; then
    echo "✅ Logged in to GitHub Container Registry"
else
    echo "❌ Failed to login to GHCR. Please check your credentials."
    exit 1
fi

# Reload docker group
echo "🔄 Activating docker group..."
newgrp docker <<EOF
echo "✅ Docker group activated"
EOF

echo ""
echo "=================================================="
echo "✅ Droplet setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure Nginx (see DEPLOYMENT_GUIDE.md)"
echo "2. Add GitHub secrets to your repository"
echo "3. Push to main branch to trigger deployment"
echo ""
echo "To configure Nginx, run:"
echo "  sudo nano /etc/nginx/sites-available/llm-chat-app"
echo ""
echo "Then copy the nginx configuration from config/nginx-llm-chat-app"
echo "=================================================="
