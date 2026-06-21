#!/bin/bash
set -e

echo "🔍 Verifying step 1..."
echo ""

# Check if namespace exists
if ! kubectl get namespace linkshortener &>/dev/null; then
    echo "❌ Namespace 'linkshortener' not found. Create it first."
    exit 1
fi

# Check if namespace file exists
if [ ! -f ~/code/manifests/01-namespace.yaml ]; then
    echo "❌ ~/code/manifests/01-namespace.yaml not found."
    exit 1
fi

# Check if images exist
if ! docker images | grep -q "link-backend.*v1"; then
    echo "❌ link-backend:v1 image not found. Build it first."
    exit 1
fi

if ! docker images | grep -q "link-frontend.*v1"; then
    echo "❌ link-frontend:v1 image not found. Build it first."
    exit 1
fi

echo "✅ Step 1 verification passed!"
echo "   - Namespace 'linkshortener' created"
echo "   - Backend and frontend images built"
