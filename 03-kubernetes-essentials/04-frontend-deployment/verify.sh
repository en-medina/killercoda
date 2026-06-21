#!/bin/bash
set -e

echo "🔍 Verifying step 4..."
echo ""

if ! kubectl get deployment frontend -n linkshortener &>/dev/null; then
    echo "❌ Frontend deployment not found."
    exit 1
fi

REPLICAS=$(kubectl get deployment frontend -n linkshortener -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" -ne 2 ]; then
    echo "❌ Frontend should have 2 replicas, found $REPLICAS."
    exit 1
fi

if ! kubectl get service frontend -n linkshortener &>/dev/null; then
    echo "❌ Frontend service not found."
    exit 1
fi

echo "✅ Step 4 verification passed!"
echo "   - Frontend deployment with 2 replicas running"
echo "   - Frontend service configured"
