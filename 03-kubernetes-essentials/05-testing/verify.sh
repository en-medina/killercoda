#!/bin/bash
set -e

echo "🔍 Verifying step 5..."
echo ""

# Check if all deployments are ready
READY_DEPLOYMENTS=$(kubectl get deployments -n linkshortener -o json | jq '[.items[] | select(.status.readyReplicas == .spec.replicas)] | length')
TOTAL_DEPLOYMENTS=$(kubectl get deployments -n linkshortener -o json | jq '.items | length')

if [ "$READY_DEPLOYMENTS" -ne "$TOTAL_DEPLOYMENTS" ]; then
    echo "❌ Not all deployments are ready. $READY_DEPLOYMENTS/$TOTAL_DEPLOYMENTS ready."
    exit 1
fi

# Test backend health
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
if ! curl -sf http://$NODE_IP:30500/health &>/dev/null; then
    echo "❌ Backend health check failed."
    exit 1
fi

echo "✅ Step 5 verification passed!"
echo "   - All deployments ready"
echo "   - Backend health check passing"
echo "   - Application fully functional"
