#!/bin/bash

set -e

echo "🚀 Preparando entorno Kubernetes..."

# Wait for Kubernetes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Create directory structure
mkdir -p ~/code/manifests
mkdir -p ~/code/apps

# Install metric server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server \
-n kube-system \
--set args[0]=--kubelet-insecure-tls \
--set args[1]=--kubelet-preferred-address-types=InternalIP

# Install jq if not present
if ! command -v jq &> /dev/null; then
    apt-get update && apt-get install -y jq
fi

touch /tmp/finished
