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

echo "🔍 Verificando Parte 2: Multi-Stage Build Optimizado..."
echo ""

cd ~/code/apps/backend || { echo "❌ No se pudo acceder al directorio de la aplicación"; exit 1; }
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

# Verificar multi-stage build
if grep -q "FROM python:3.11-slim AS builder" Dockerfile.optimized; then
    check_pass "Stage 1 (builder) configurado correctamente"
else
    check_fail "Stage 1 (builder) no encontrado o incorrecto"
fi

if echo "$(grep "FROM python:3.11-slim" Dockerfile.optimized)" | grep -qv "AS builder" > /dev/null 2>&1; then
    check_pass "Stage 2 (runtime) configurado"
else
    check_fail "Stage 2 (runtime) no encontrado"
fi

# Verificar instalación de gcc en builder
if grep -q "gcc" Dockerfile.optimized; then
    check_pass "Dependencias de compilación (gcc) incluidas en builder"
else
    check_warning "gcc no encontrado en el builder stage"
fi

# Verificar virtualenv
if grep -q "python -m venv /opt/venv" Dockerfile.optimized; then
    check_pass "Virtualenv creado en /opt/venv"
else
    check_fail "Virtualenv no configurado correctamente"
fi

# Verificar COPY --from=builder
if grep -q "COPY --from=builder /opt/venv /opt/venv" Dockerfile.optimized; then
    check_pass "Virtualenv copiado desde builder"
else
    check_fail "COPY --from=builder no encontrado"
fi

# Verificar usuario no-root
if grep -q "groupadd.*appuser" Dockerfile.optimized && grep -q "useradd.*appuser" Dockerfile.optimized; then
    check_pass "Usuario appuser creado"
else
    check_fail "Usuario no-root no configurado"
fi

if grep -q "USER appuser" Dockerfile.optimized; then
    check_pass "USER appuser configurado"
else
    check_fail "No se cambió a usuario no-root"
fi

# Verificar HEALTHCHECK
if grep -q "HEALTHCHECK" Dockerfile.optimized; then
    check_pass "HEALTHCHECK configurado"
else
    check_warning "HEALTHCHECK no encontrado"
fi

# Verificar optimización de cache (COPY requirements antes de COPY app)
if grep -n "COPY requirements.txt" Dockerfile.optimized | head -1 | cut -d: -f1 > /tmp/req_line 2>/dev/null; then
    REQ_LINE=$(cat /tmp/req_line)
    if grep -n "COPY app/" Dockerfile.optimized | head -1 | cut -d: -f1 > /tmp/app_line 2>/dev/null; then
        APP_LINE=$(cat /tmp/app_line)
        if [ "$REQ_LINE" -lt "$APP_LINE" ]; then
            check_pass "Optimización de cache: requirements.txt antes de app/"
        else
            check_warning "requirements.txt debería copiarse antes que app/ para optimizar cache"
        fi
    fi
fi

# Verificar pip --no-cache-dir
if grep -q "pip install --no-cache-dir" Dockerfile.optimized; then
    check_pass "pip install --no-cache-dir configurado"
else
    check_warning "Se recomienda usar --no-cache-dir con pip"
fi

# Verificar limpieza de apt cache
if grep -q "rm -rf /var/lib/apt/lists/\*" Dockerfile.optimized; then
    check_pass "Limpieza de apt cache incluida"
else
    check_warning "Se recomienda limpiar /var/lib/apt/lists/* después de apt-get"
fi

echo ""

# ============================================
# Verificar contenido del .dockerignore
# ============================================
echo "🔍 Verificando .dockerignore..."

REQUIRED_PATTERNS=("__pycache__/" "*.pyc" ".git/" ".venv/" "venv/")
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
echo "🐳 Verificando imagen link-backend:optimized..."

if docker images link-backend:optimized --format "{{.Repository}}:{{.Tag}}" | grep -q "link-backend:optimized"; then
    check_pass "Imagen link-backend:optimized construida"

    # Verificar tamaño de la imagen
    IMAGE_SIZE=$(docker images link-backend:optimized --format "{{.Size}}" | head -1)
    IMAGE_SIZE_MB=$(docker images link-backend:optimized --format "{{.Size}}" | head -1 | sed 's/MB//' | sed 's/GB/*1024/' | bc 2>/dev/null || echo "0")

    echo "   Tamaño: $IMAGE_SIZE"

    # Verificar que sea menor a 300MB (debe ser ~180MB)
    if [ -n "$IMAGE_SIZE_MB" ] && [ $(echo "$IMAGE_SIZE_MB < 300" | bc -l 2>/dev/null || echo "0") -eq 1 ]; then
        check_pass "Tamaño optimizado (<300MB)"
    else
        check_warning "La imagen podría optimizarse más (esperado ~180MB)"
    fi

    # Verificar que tenga HEALTHCHECK
    if docker inspect link-backend:optimized | grep -q "Healthcheck"; then
        check_pass "Healthcheck configurado en la imagen"
    else
        check_warning "Healthcheck no detectado en la imagen"
    fi

    # Verificar usuario no-root
    IMAGE_USER=$(docker inspect link-backend:optimized --format='{{.Config.User}}' 2>/dev/null || echo "")
    if [ "$IMAGE_USER" = "appuser" ]; then
        check_pass "Usuario no-root configurado (appuser)"
    else
        check_warning "Usuario de la imagen: '$IMAGE_USER' (esperado: appuser)"
    fi

else
    check_fail "Imagen link-backend:optimized no construida"
    echo "   Ejecuta: docker build -f Dockerfile.optimized -t link-backend:optimized ."
fi

echo ""
echo "✅ Verificación completa. ¡Buen trabajo!"