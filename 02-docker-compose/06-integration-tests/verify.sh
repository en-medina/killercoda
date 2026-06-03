#!/bin/bash
set -e

echo "🔍 Verifying step 6..."
echo ""

# Check if test scripts exist
if [ ! -f ~/code/scripts/test-stack.sh ]; then
    echo "❌ test-stack.sh not found. Create it first."
    exit 1
fi

if [ ! -f ~/code/scripts/smoke-test.sh ]; then
    echo "❌ smoke-test.sh not found. Create it first."
    exit 1
fi

if [ ! -f ~/code/scripts/load-test.sh ]; then
    echo "❌ load-test.sh not found. Create it first."
    exit 1
fi

# Check if scripts are executable
if [ ! -x ~/code/scripts/test-stack.sh ]; then
    echo "❌ test-stack.sh is not executable."
    exit 1
fi

# Verify stack is running
cd ~/code
if ! docker-compose -f docker-compose.complete.yml ps | grep -q "Up"; then
    echo "⚠️  Stack is not running. Tests created but not executed."
    echo "✅ Step 6 verification passed (scripts created)."
    exit 0
fi

echo "✅ Step 6 verification passed!"
echo "   - Integration test scripts created"
echo "   - Scripts are executable"
echo "   - Test suite ready to run"
