#!/bin/bash
set -e

echo "🔍 Verifying step 3..."
echo ""

# Check if redis.conf exists
if [ ! -f ~/code/configs/redis.conf ]; then
    echo "❌ configs/redis.conf not found. Create it first."
    exit 1
fi

# Check if docker-compose.volumes.yml exists
if [ ! -f ~/code/docker-compose.volumes.yml ]; then
    echo "❌ docker-compose.volumes.yml not found. Create it first."
    exit 1
fi

# Check if file contains required services
if ! grep -q "redis:" ~/code/docker-compose.volumes.yml || \
   ! grep -q "backend:" ~/code/docker-compose.volumes.yml || \
   ! grep -q "frontend:" ~/code/docker-compose.volumes.yml; then
    echo "❌ docker-compose.volumes.yml must contain redis, backend, and frontend services."
    exit 1
fi

# Check if file contains backend-network and frontend-network
if ! grep -q "backend-network" ~/code/docker-compose.volumes.yml || \
   ! grep -q "frontend-network" ~/code/docker-compose.volumes.yml; then
    echo "❌ docker-compose.volumes.yml must define backend-network and frontend-network."
    exit 1
fi

# Check if file contains volumes section
if ! grep -q "volumes:" ~/code/docker-compose.volumes.yml; then
    echo "❌ docker-compose.volumes.yml must contain volumes section."
    exit 1
fi

# Check if file contains redis-data volume
if ! grep -q "redis-data" ~/code/docker-compose.volumes.yml; then
    echo "❌ docker-compose.volumes.yml must define redis-data volume."
    exit 1
fi

# Check if file contains depends_on
if ! grep -q "depends_on:" ~/code/docker-compose.volumes.yml; then
    echo "❌ docker-compose.volumes.yml must use depends_on for service dependencies."
    exit 1
fi

echo "✅ Step 3 verification passed!"
echo "   - Redis configuration created"
echo "   - docker-compose.volumes.yml created with persistent volumes"
