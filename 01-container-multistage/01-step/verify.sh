#!/bin/bash
set -e

echo "🔍 Verifying step 1..."
echo ""

# Check if images exist
if ! docker images | grep -q "link-backend:basic"; then
    echo "❌ link-backend:basic not found. Build it first."
    exit 1
fi

# Check if size is greater than 1GB
size=$(docker images --format "{{.Size}}" "link-backend:basic" | sed 's/GB/*1024/;s/MB//;s/KB/\/1024/' | bc 2>/dev/null || echo "0")
if (( size < 1024 )); then
    echo "❌ link-backend:basic size is less than 1GB. Build it first."
    exit 1
fi 