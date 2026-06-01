#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS=0
FAILED=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

check_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "🔍 Verificando Parte 3: Optimización Frontend (React/Nginx)..."
echo ""

cd ~/code/apps/frontend || { echo "❌ No se pudo acceder al directorio de la aplicación"; exit 1; }

# ============================================
# Verificar archivos requeridos
# ============================================
echo "📁 Verificando archivos..."

if [ -f "Dockerfile.optimized" ]; then
    check_pass "Dockerfile.optimized existe"
else
    check_fail "Dockerfile.optimized no existe"
fi

if [ -f ".dockerignore" ]; then
    check_pass ".dockerignore existe"
else
    check_fail ".dockerignore no existe"
fi

echo ""

# ============================================
# Verificar contenido del Dockerfile.optimized
# ============================================
echo "🔍 Verificando Dockerfile.optimized..."

# Verificar Stage 1: Builder (Node)
if grep -q "FROM node:.*-alpine AS builder" Dockerfile.optimized; then
    check_pass "Stage 1 (builder) configurado correctamente con Node Alpine"
else
    check_fail "Stage 1 (builder) no encontrado o incorrecto"
fi

# Verificar Stage 2: Runtime (Nginx)
if grep -q "FROM nginx:alpine" Dockerfile.optimized; then
    check_pass "Stage 2 (runtime) configurado con Nginx Alpine"
else
    check_fail "Stage 2 (runtime) no encontrado"
fi

# Verificar npm ci
if grep -q "npm ci" Dockerfile.optimized; then
    check_pass "npm ci configurado (mejor que npm install)"
else
    check_warning "Se recomienda usar 'npm ci' en lugar de 'npm install'"
fi

# Verificar npm run build
if grep -q "npm run build" Dockerfile.optimized; then
    check_pass "npm run build encontrado"
else
    check_fail "npm run build no configurado"
fi

# Verificar COPY --from=builder
if grep -q "COPY --from=builder /app/dist /usr/share/nginx/html" Dockerfile.optimized; then
    check_pass "Assets copiados desde builder a Nginx"
else
    check_fail "COPY --from=builder no encontrado o incorrecto"
fi

# Verificar configuración de Nginx para SPA
if grep -q "try_files.*\$uri.*\$uri/.*index.html" Dockerfile.optimized; then
    check_pass "Configuración de Nginx para SPA (try_files)"
else
    check_warning "Configuración de Nginx para SPA no detectada"
fi

# Verificar health endpoint
if grep -q "/health" Dockerfile.optimized; then
    check_pass "Endpoint /health configurado"
else
    check_warning "Endpoint /health no encontrado"
fi

# Verificar HEALTHCHECK
if grep -q "HEALTHCHECK" Dockerfile.optimized; then
    check_pass "HEALTHCHECK configurado"
else
    check_warning "HEALTHCHECK no encontrado"
fi

# Verificar optimización de cache (COPY package.json antes de COPY .)
if grep -n "COPY package.json" Dockerfile.optimized | head -1 | cut -d: -f1 > /tmp/pkg_line 2>/dev/null; then
    PKG_LINE=$(cat /tmp/pkg_line)
    if grep -n "COPY \. \." Dockerfile.optimized | head -1 | cut -d: -f1 > /tmp/dot_line 2>/dev/null; then
        DOT_LINE=$(cat /tmp/dot_line)
        if [ "$PKG_LINE" -lt "$DOT_LINE" ]; then
            check_pass "Optimización de cache: package.json antes de COPY . ."
        else
            check_warning "package.json debería copiarse antes que COPY . . para optimizar cache"
        fi
    fi
fi

# Verificar npm ci --silent
if grep -q "npm ci --silent" Dockerfile.optimized; then
    check_pass "npm ci --silent configurado (reduce ruido en logs)"
else
    check_warning "Se recomienda usar --silent con npm ci"
fi

echo ""

# ============================================
# Verificar contenido del .dockerignore
# ============================================
echo "🔍 Verificando .dockerignore..."

REQUIRED_PATTERNS=("node_modules/" "dist/" ".git/" ".env.local")
for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if grep -q "$pattern" .dockerignore; then
        check_pass "Patrón '$pattern' en .dockerignore"
    else
        check_warning "Patrón '$pattern' no encontrado en .dockerignore"
    fi
done

echo ""

# ============================================
# Verificar imagen construida
# ============================================
echo "🐳 Verificando imagen link-frontend:optimized..."

if docker images link-frontend:optimized --format "{{.Repository}}:{{.Tag}}" | grep -q "link-frontend:optimized"; then
    check_pass "Imagen link-frontend:optimized construida"

    # Verificar tamaño de la imagen
    IMAGE_SIZE=$(docker images link-frontend:optimized --format "{{.Size}}" | head -1)
    IMAGE_SIZE_MB=$(docker images link-frontend:optimized --format "{{.Size}}" | head -1 | sed 's/MB//' | sed 's/GB/*1024/' | bc 2>/dev/null || echo "0")

    echo "   Tamaño: $IMAGE_SIZE"

    # Verificar que sea menor a 100MB (debe ser ~50MB)
    if [ -n "$IMAGE_SIZE_MB" ] && [ $(echo "$IMAGE_SIZE_MB < 100" | bc -l 2>/dev/null || echo "0") -eq 1 ]; then
        check_pass "Tamaño optimizado (<100MB)"
    else
        check_warning "La imagen podría optimizarse más (esperado ~50MB)"
    fi

    # Verificar que tenga HEALTHCHECK
    if docker inspect link-frontend:optimized | grep -q "Healthcheck"; then
        check_pass "Healthcheck configurado en la imagen"
    else
        check_warning "Healthcheck no detectado en la imagen"
    fi

else
    check_fail "Imagen link-frontend:optimized no construida"
    echo "   Ejecuta: docker build -f Dockerfile.optimized -t link-frontend:optimized ."
fi

echo ""
echo "✅ Verificación completa. ¡Buen trabajo!"
