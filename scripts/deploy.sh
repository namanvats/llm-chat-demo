#!/bin/bash

set -e

#Configuration
APP_NAME="llm-chat-demo"
DOCKER_IMAGE="$1"
BLUE_PORT=8000
GREEN_PORT=8001
NGINX_CONFIG="/etc/nginx/sites-available/${APP_NAME}"

echo "Starting Blue Green Deployment for $DOCKER_IMAGE"

CURRENT_ENV=$(docker ps --filter "name=${APP_NAME}-" --format "{{.Names}}" | grep -o 'blue\|green' | head -1)

if [ -z "$CURRENT_ENV" ]; then
    echo "No existing environment found. Creating new one."
    NEW_ENV="blue"
    NEW_PORT=$BLUE_PORT
    CURRENT_PORT=""
elif [ "$CURRENT_ENV" == "blue" ]; then
    NEW_ENV="green"
    NEW_PORT=$GREEN_PORT
    CURRENT_PORT=$BLUE_PORT
else
    echo "Current environment is : GREEN, Deploying to BLUE"
    NEW_ENV="blue"
    NEW_PORT=$BLUE_PORT
    CURRENT_PORT=$GREEN_PORT
fi

echo "Deploying to $NEW_ENV environment on port $NEW_PORT"

docker stop ${APP_NAME}-${NEW_ENV} 2>/dev/null || true
docker rm ${APP_NAME}-${NEW_ENV} 2>/dev/null || true

docker run -d \
    --name ${APP_NAME}-${NEW_ENV} \
    --restart unless-stopped \
    -p ${NEW_PORT}:8000 \
    -e OPENAI_API_KEY=${OPENAI_API_KEY} \
    -e LLM_MODEL=${LLM_MODEL} \
    ghcr.io/${GITHUB_REPOSITORY}:${DOCKER_IMAGE}

# Wait for health check to pass
echo "Waiting for health check to pass"
sleep 10
MAX_TRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_TRIES ]; do
    if curl -s http://localhost:${NEW_PORT}/health &>/dev/null; then
        echo "Health check passed"
        break
    fi
    echo "Health check failed. Retrying..."
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_TRIES ]; then
    echo "Health check failed after $MAX_TRIES attempts"
    docker stop ${APP_NAME}-${NEW_ENV}
    docker rm ${APP_NAME}-${NEW_ENV}
    exit 1
fi

# Switch Nginx config
# Switch Nginx config (only if there's a current environment)
if [ -n "$CURRENT_PORT" ]; then
    echo "Switching Nginx config from port $CURRENT_PORT to $NEW_PORT"
    sudo sed -i "s/proxy_pass http:\/\/localhost:${CURRENT_PORT};/proxy_pass http:\/\/localhost:${NEW_PORT};/" ${NGINX_CONFIG}
    sudo nginx -t && sudo systemctl reload nginx
    
    # Waiting for connections to switch
    echo "Waiting for connections to switch"
    sleep 5
else
    echo "First deployment - Nginx config should already point to blue environment"
fi

#Stop old environments
if [ -n "$CURRENT_ENV" ]; then
    echo "Stopping old environment"
    docker stop ${APP_NAME}-${CURRENT_ENV} 2>/dev/null || true
    docker rm ${APP_NAME}-${CURRENT_ENV} 2>/dev/null || true
fi

# Cleanup old images
echo "Cleaning up old images"
docker image prune -f --filter "until=24h"

echo "Deployment completed successfully, environment $NEW_ENV is now live"