#!/bin/bash
set -e

echo "🔍 Verifying step 2..."
echo ""

# Check if PVC exists
if ! kubectl get pvc redis-pvc -n linkshortener &>/dev/null; then
    echo "❌ PVC 'redis-pvc' not found."
    exit 1
fi

# Check if Redis deployment exists
if ! kubectl get deployment redis -n linkshortener &>/dev/null; then
    echo "❌ Redis deployment not found."
    exit 1
fi

# Check if Redis service exists
if ! kubectl get service redis -n linkshortener &>/dev/null; then
    echo "❌ Redis service not found."
    exit 1
fi

# Check if Redis pod is running
if ! kubectl get pods -n linkshortener -l app=redis --field-selector=status.phase=Running &>/dev/null; then
    echo "❌ Redis pod is not running."
    exit 1
fi

echo "✅ Step 2 verification passed!"
echo "   - Redis PVC created"
echo "   - Redis deployment running"
echo "   - Redis service configured"
