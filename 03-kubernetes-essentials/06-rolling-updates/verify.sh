#!/bin/bash
set -e

echo "🔍 Verifying step 6..."
echo ""

# Check if there's rollout history
REVISIONS=$(kubectl rollout history deployment/backend -n linkshortener 2>/dev/null | grep -c "^[0-9]" || echo "0")

if [ "$REVISIONS" -lt 2 ]; then
    echo "❌ Not enough rollout history. Perform at least one update."
    exit 1
fi

echo "✅ Step 6 verification passed!"
echo "   - Rolling update performed"
echo "   - Rollout history available ($REVISIONS revisions)"
