#!/bin/bash
# One-time droplet setup script
# Run this on your droplet after first SSH login

set -e

# Set non-interactive mode for apt
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Setting up DigitalOcean Droplet for LLM Chat App"
echo "=================================================="

# Update system
echo "📦 Updating system packages..."
sudo -E apt-get update
sudo -E apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

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
    sudo -E apt-get install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "✅ Nginx installed"
else
    echo "✅ Nginx already installed"
fi

# Install curl (usually pre-installed but ensure it exists)
echo "📦 Ensuring curl is installed..."
sudo -E apt-get install -y curl
echo "✅ curl ready"

# Create app directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/llm-chat-app/scripts
sudo chown $USER:$USER /opt/llm-chat-app
echo "✅ Directory created"

# GitHub Container Registry Login
echo ""
echo "🔑 GitHub Container Registry Login"

# Check if credentials are provided via environment variables
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_USER or GITHUB_TOKEN not set as environment variables"
    echo ""
    echo "You need a GitHub Personal Access Token with 'read:packages' scope"
    echo "Create one at: https://github.com/settings/tokens"
    echo ""
    echo "To login later, run:"
    echo "  echo \$GITHUB_TOKEN | docker login ghcr.io -u \$GITHUB_USER --password-stdin"
    echo ""
    echo "⏭️  Skipping GHCR login for now..."
else
    # Login to GitHub Container Registry
    echo "Logging in to GHCR as $GITHUB_USER..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
    
    if [ $? -eq 0 ]; then
        echo "✅ Logged in to GitHub Container Registry"
    else
        echo "❌ Failed to login to GHCR. Please check your credentials."
        echo "You can login manually later with:"
        echo "  echo \$GITHUB_TOKEN | docker login ghcr.io -u \$GITHUB_USER --password-stdin"
    fi
fi

echo ""
echo "=================================================="
echo "✅ Droplet setup complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Login to GitHub Container Registry (if not done above):"
echo "   export GITHUB_USER='your-github-username'"
echo "   export GITHUB_TOKEN='your-github-token'"
echo "   echo \$GITHUB_TOKEN | docker login ghcr.io -u \$GITHUB_USER --password-stdin"
echo ""
echo "2. Copy deploy.sh script to /opt/llm-chat-app/scripts/"
echo "   (This will be done automatically by GitHub Actions)"
echo ""
echo "3. Configure Nginx for your app"
echo "4. Add GitHub secrets to your repository"
echo "5. Push to main branch to trigger deployment"
echo ""
echo "⚠️  IMPORTANT: You may need to log out and back in for docker group to take effect"
echo "=================================================="
