#!/bin/bash
set -e

echo "🔍 Verifying step 4..."
echo ""

# Check if docker-compose.complete.yml exists
if [ ! -f ~/code/docker-compose.complete.yml ]; then
    echo "❌ docker-compose.complete.yml not found. Create it first."
    exit 1
fi

# Check if file contains healthcheck sections
healthcheck_count=$(grep -c "healthcheck:" ~/code/docker-compose.complete.yml || echo "0")
if [ "$healthcheck_count" -lt 3 ]; then
    echo "❌ docker-compose.complete.yml must contain healthcheck for all three services."
    exit 1
fi

# Check if file contains restart policy
if ! grep -q "restart:" ~/code/docker-compose.complete.yml; then
    echo "❌ docker-compose.complete.yml must contain restart policies."
    exit 1
fi

# Check if file contains resource limits
if ! grep -q "deploy:" ~/code/docker-compose.complete.yml || \
   ! grep -q "resources:" ~/code/docker-compose.complete.yml; then
    echo "❌ docker-compose.complete.yml must contain resource limits."
    exit 1
fi

# Check if file contains conditional depends_on
if ! grep -q "condition: service_healthy" ~/code/docker-compose.complete.yml; then
    echo "❌ docker-compose.complete.yml must use conditional depends_on with service_healthy."
    exit 1
fi

# Check if docker-compose services are running
if ! docker-compose -f ~/code/docker-compose.complete.yml ps | grep -q "Up"; then
    echo "❌ docker-compose services are not running. Start them with: docker-compose -f ~/code/docker-compose.complete.yml up"
    exit 1
fi

echo "✅ Step 4 verification passed!"
echo "   - docker-compose.complete.yml created with health checks"
echo "   - Restart policies configured"
echo "   - Resource limits defined"
echo "   - Conditional dependencies configured"
