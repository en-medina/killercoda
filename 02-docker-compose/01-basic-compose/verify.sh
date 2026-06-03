#!/bin/bash
set -e

echo "🔍 Verifying step 1..."
echo ""

# Check if docker-compose.starter.yml exists
if [ ! -f ~/code/docker-compose.starter.yml ]; then
    echo "❌ docker-compose.starter.yml not found. Create it first."
    exit 1
fi

# Check if file contains required services
if ! grep -q "redis:" ~/code/docker-compose.starter.yml || \
   ! grep -q "backend:" ~/code/docker-compose.starter.yml || \
   ! grep -q "frontend:" ~/code/docker-compose.starter.yml; then
    echo "❌ docker-compose.starter.yml must contain redis, backend, and frontend services."
    exit 1
fi

echo "✅ Step 1 verification passed!"
echo "   - docker-compose.starter.yml created with all required services"
