#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================="
echo "  Link Shortener Tests"
echo "=================================="
echo ""

# Check if services are running
echo "Checking if services are running..."
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}Error: Services are not running. Please run 'docker-compose up' first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Services are running${NC}"
echo ""

# Test 1: Health Check
echo "Test 1: Backend Health Check"
HEALTH_RESPONSE=$(curl -s http://localhost:5000/health)
if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo -e "${GREEN}✓ Backend health check passed${NC}"
else
    echo -e "${RED}✗ Backend health check failed${NC}"
    echo "Response: $HEALTH_RESPONSE"
fi
echo ""

# Test 2: Shorten URL
echo "Test 2: Shorten a URL"
TEST_URL="https://github.com/anthropics/claude-code"
SHORTEN_RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$TEST_URL\"}")

if echo "$SHORTEN_RESPONSE" | grep -q "short_code"; then
    echo -e "${GREEN}✓ URL shortening successful${NC}"
    SHORT_CODE=$(echo "$SHORTEN_RESPONSE" | grep -o '"short_code":"[^"]*"' | cut -d'"' -f4)
    SHORT_URL=$(echo "$SHORTEN_RESPONSE" | grep -o '"short_url":"[^"]*"' | cut -d'"' -f4)
    echo "Short Code: $SHORT_CODE"
    echo "Short URL: $SHORT_URL"
else
    echo -e "${RED}✗ URL shortening failed${NC}"
    echo "Response: $SHORTEN_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Get Stats
echo "Test 3: Get URL Statistics"
STATS_RESPONSE=$(curl -s http://localhost:5000/stats/$SHORT_CODE)
if echo "$STATS_RESPONSE" | grep -q "original_url"; then
    echo -e "${GREEN}✓ Stats retrieval successful${NC}"
    echo "Stats: $STATS_RESPONSE"
else
    echo -e "${RED}✗ Stats retrieval failed${NC}"
    echo "Response: $STATS_RESPONSE"
fi
echo ""

# Test 4: Redirect (follow redirects and check final URL)
echo "Test 4: Test Redirection"
REDIRECT_URL=$(curl -s -L -w "%{url_effective}" -o /dev/null http://localhost:5000/$SHORT_CODE)
if [ "$REDIRECT_URL" == "$TEST_URL" ]; then
    echo -e "${GREEN}✓ Redirection successful${NC}"
    echo "Redirected to: $REDIRECT_URL"
else
    echo -e "${YELLOW}⚠ Redirection might be incorrect${NC}"
    echo "Expected: $TEST_URL"
    echo "Got: $REDIRECT_URL"
fi
echo ""

# Test 5: Invalid URL
echo "Test 5: Test with Invalid URL"
INVALID_RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
    -H "Content-Type: application/json" \
    -d '{"url": "not-a-valid-url"}')

if echo "$INVALID_RESPONSE" | grep -q "error"; then
    echo -e "${GREEN}✓ Invalid URL properly rejected${NC}"
else
    echo -e "${RED}✗ Invalid URL should have been rejected${NC}"
    echo "Response: $INVALID_RESPONSE"
fi
echo ""

# Test 6: Missing URL
echo "Test 6: Test with Missing URL"
MISSING_RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
    -H "Content-Type: application/json" \
    -d '{}')

if echo "$MISSING_RESPONSE" | grep -q "error"; then
    echo -e "${GREEN}✓ Missing URL properly rejected${NC}"
else
    echo -e "${RED}✗ Missing URL should have been rejected${NC}"
    echo "Response: $MISSING_RESPONSE"
fi
echo ""

# Test 7: Nonexistent Short Code
echo "Test 7: Test with Nonexistent Short Code"
NOTFOUND_RESPONSE=$(curl -s http://localhost:5000/XXXXXX)
if echo "$NOTFOUND_RESPONSE" | grep -q "not found"; then
    echo -e "${GREEN}✓ Nonexistent code properly handled${NC}"
else
    echo -e "${YELLOW}⚠ Nonexistent code handling might be incorrect${NC}"
    echo "Response: $NOTFOUND_RESPONSE"
fi
echo ""

# Test 8: Frontend Health
echo "Test 8: Frontend Health Check"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/)
if [ "$FRONTEND_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✓ Frontend is accessible${NC}"
else
    echo -e "${RED}✗ Frontend is not accessible (HTTP $FRONTEND_STATUS)${NC}"
fi
echo ""

# Test 9: Redis Connection
echo "Test 9: Redis Connection Test"
REDIS_PING=$(docker-compose exec -T redis redis-cli ping 2>/dev/null)
if [ "$REDIS_PING" == "PONG" ]; then
    echo -e "${GREEN}✓ Redis connection successful${NC}"
else
    echo -e "${RED}✗ Redis connection failed${NC}"
fi
echo ""

echo "=================================="
echo "  Test Summary"
echo "=================================="
echo ""
echo -e "${GREEN}All critical tests completed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open http://localhost:5173 in your browser"
echo "  2. Try shortening a URL manually"
echo "  3. Check the logs with: docker-compose logs -f"
echo ""
