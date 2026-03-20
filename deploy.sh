#!/bin/bash

set -e
echo "Rebuilding and redeploying Picsur..."
docker-compose build
docker-compose down
docker-compose up -d
echo "Done! Picsur is running at http://localhost:8080"
