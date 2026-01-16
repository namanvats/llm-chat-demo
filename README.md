# LLM Chat API Demo

A FastAPI-powered LLM Chat API with automated CI/CD deployment to DigitalOcean.

## 🚀 Quick Start (Local Development)

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variable
export OPENAI_API_KEY="sk-your-api-key"

# Run server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Visit: http://localhost:8000

## 🐳 Docker

```bash
docker build -t llm-chat-app .
docker run -p 8000:8000 -e OPENAI_API_KEY="sk-..." llm-chat-app
```

## 🌐 Deployment

### Automated Deployment to DigitalOcean

This project uses GitHub Actions for automated blue-green deployments.

**Quick setup:** See [DROPLET_SETUP.md](./DROPLET_SETUP.md) for detailed instructions.

**One-line setup on your droplet:**
```bash
curl -fsSL https://raw.githubusercontent.com/namanvats/llm-chat-demo/main/scripts/setup_droplet.sh | bash
```

Every push to `main` automatically:
- ✅ Runs tests and linting
- ✅ Builds and pushes Docker image to GHCR
- ✅ Deploys to DigitalOcean with zero downtime

## 📚 API Endpoints

- `GET /` - Welcome message
- `POST /chat` - Send chat message
- `GET /health` - Health check

## 📖 Documentation

- [Droplet Setup Guide](./DROPLET_SETUP.md) - Complete deployment setup
- API Docs: http://your-server:8000/docs