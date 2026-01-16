# DigitalOcean Droplet Setup Guide

This guide helps you set up your DigitalOcean droplet for automated deployments.

## 🚀 Quick Setup (One Command)

Run this on your **fresh DigitalOcean droplet**:

```bash
curl -fsSL https://raw.githubusercontent.com/namanvats/llm-chat-demo/main/scripts/setup_droplet.sh | bash
```

This will:
- ✅ Update system packages (non-interactive)
- ✅ Install Docker
- ✅ Install Nginx
- ✅ Install curl
- ✅ Create application directory at `/opt/llm-chat-app`
- ℹ️  Skip GitHub login (do it manually after)

## 🔑 Login to GitHub Container Registry

After the setup completes, login to GitHub Container Registry:

```bash
# Set your credentials
export GITHUB_USER='your-github-username'
export GITHUB_TOKEN='ghp_your_personal_access_token'

# Login
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
```

**Note:** Create a Personal Access Token at: https://github.com/settings/tokens  
Required scope: `read:packages`

## 🌐 Configure Nginx

Create Nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/llm-chat-demo
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-droplet-ip;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        proxy_pass http://localhost:8000/health;
        access_log off;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/llm-chat-demo /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔐 Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DROPLET_IP` | Your droplet's IP address | `164.92.123.45` |
| `DROPLET_USER` | SSH username | `root` or your user |
| `DROPLET_SSH_KEY` | Private SSH key | Contents of `~/.ssh/id_rsa` |
| `OPENAI_API_KEY` | OpenAI API key | `sk-...` |
| `LLM_MODEL` | Model to use | `gpt-4` or `gpt-3.5-turbo` |

## 🚢 Deploy

Once everything is configured, push to main branch:

```bash
git push origin main
```

GitHub Actions will automatically:
1. ✅ Run tests
2. ✅ Build Docker image
3. ✅ Push to GitHub Container Registry
4. ✅ Deploy to your droplet using blue-green deployment

## 🔧 Troubleshooting

### Script hangs during apt upgrade

If you see package configuration prompts, the script is not running in non-interactive mode. Make sure you're using the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/namanvats/llm-chat-demo/main/scripts/setup_droplet.sh | bash
```

### Docker permission denied

Log out and back in for docker group to take effect:

```bash
exit
# SSH back in
```

Or run:

```bash
newgrp docker
```

### Cannot pull Docker image

Make sure you logged into GHCR:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
```

### Deployment fails

Check logs on droplet:

```bash
docker ps -a
docker logs llm-chat-demo-blue
docker logs llm-chat-demo-green
```

Check Nginx:

```bash
sudo nginx -t
sudo systemctl status nginx
```

## 📝 Manual Deployment

To manually deploy on the droplet:

```bash
cd /opt/llm-chat-app
export OPENAI_API_KEY="sk-..."
export LLM_MODEL="gpt-4"
export GITHUB_REPOSITORY="namanvats/llm-chat-demo"
bash scripts/deploy.sh abc123  # Use commit SHA or tag
```

## 🔄 Re-running Setup

If you need to re-run setup on a fresh droplet:

```bash
# With GitHub credentials
export GITHUB_USER='your-username'
export GITHUB_TOKEN='your-token'
curl -fsSL https://raw.githubusercontent.com/namanvats/llm-chat-demo/main/scripts/setup_droplet.sh | bash
```

This will install everything fresh and login to GHCR automatically.
