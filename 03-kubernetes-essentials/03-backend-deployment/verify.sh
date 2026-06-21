#!/bin/bash
set -e

echo "🔍 Verifying step 3..."
echo ""

# Check ConfigMap
if ! kubectl get configmap backend-config -n linkshortener &>/dev/null; then
    echo "❌ ConfigMap 'backend-config' not found."
    exit 1
fi

# Check Secret
if ! kubectl get secret backend-secret -n linkshortener &>/dev/null; then
    echo "❌ Secret 'backend-secret' not found."
    exit 1
fi

# Check Backend deployment
if ! kubectl get deployment backend -n linkshortener &>/dev/null; then
    echo "❌ Backend deployment not found."
    exit 1
fi

# Check if backend has 3 replicas
REPLICAS=$(kubectl get deployment backend -n linkshortener -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" -ne 3 ]; then
    echo "❌ Backend should have 3 replicas, found $REPLICAS."
    exit 1
fi

# Check Backend service
if ! kubectl get service backend -n linkshortener &>/dev/null; then
    echo "❌ Backend service not found."
    exit 1
fi

echo "✅ Step 3 verification passed!"
echo "   - ConfigMap and Secret created"
echo "   - Backend deployment with 3 replicas running"
echo "   - Backend service configured"
