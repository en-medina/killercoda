#!/bin/bash

set -e

echo "🚀 Preparando entorno Kubernetes..."

# Wait for Kubernetes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Create directory structure
mkdir -p ~/code/manifests
mkdir -p ~/code/apps

# Install jq if not present
if ! command -v jq &> /dev/null; then
    apt-get update && apt-get install -y jq
fi

touch /tmp/finished
