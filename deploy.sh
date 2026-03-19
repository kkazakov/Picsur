#!/bin/bash

set -e

echo "Rebuilding and redeploying Picsur..."

# Stop and remove containers
docker-compose down

# Rebuild and start containers
docker-compose up -d --build

echo "Done! Picsur is running at http://localhost:8080"
