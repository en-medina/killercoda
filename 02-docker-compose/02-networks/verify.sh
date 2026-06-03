#!/bin/bash
set -e

echo "🔍 Verifying step 2..."
echo ""

# Check if docker-compose.networks.yml exists
if [ ! -f ~/code/docker-compose.networks.yml ]; then
    echo "❌ docker-compose.networks.yml not found. Create it first."
    exit 1
fi

# Check if file contains networks section
if ! grep -q "networks:" ~/code/docker-compose.networks.yml; then
    echo "❌ docker-compose.networks.yml must contain networks section."
    exit 1
fi

# Check if file contains required services
if ! grep -q "redis:" ~/code/docker-compose.networks.yml || \
   ! grep -q "backend:" ~/code/docker-compose.networks.yml || \
   ! grep -q "frontend:" ~/code/docker-compose.networks.yml; then
    echo "❌ docker-compose.networks.yml must contain redis, backend, and frontend services."
    exit 1
fi

# Check if file contains backend-network and frontend-network
if ! grep -q "backend-network" ~/code/docker-compose.networks.yml || \
   ! grep -q "frontend-network" ~/code/docker-compose.networks.yml; then
    echo "❌ docker-compose.networks.yml must define backend-network and frontend-network."
    exit 1
fi

# Expectation: user saved `docker network inspect code_backend-network | jq '.[].Containers'`
# to /opt/networks.json and it contains the redis and backend container entries.
if [ -f /opt/networks.json ]; then
    if ! grep -q "code_redis_1" /opt/networks.json || ! grep -q "code_backend_1" /opt/networks.json; then
        echo "❌ /opt/networks.json found but does not contain expected container entries (code_redis_1, code_backend_1)."
        exit 1
    fi
        echo "✅ /opt/networks.json contains expected container entries"
else
    echo "❌ /opt/networks.json not found. To verify network containers, run:"
    echo "   docker network inspect code_backend-network | jq '.[].Containers' > /opt/networks.json"
    exit 1
fi


echo "✅ Step 2 verification passed!"
echo "   - docker-compose.networks.yml created with custom networks"
