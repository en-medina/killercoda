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

echo "🔍 Verificando Parte 5: Despliegue de Aplicación..."
echo ""

# ============================================
# Verificar imágenes existen
# ============================================
echo "🐳 Verificando imágenes disponibles..."

BACKEND_EXISTS=false
FRONTEND_EXISTS=false

if docker images link-backend:optimized --format "{{.Repository}}:{{.Tag}}" | grep -q "link-backend:optimized"; then
    check_pass "Imagen link-backend:optimized disponible"
    BACKEND_EXISTS=true
else
    check_fail "Imagen link-backend:optimized no encontrada (debe completarse Parte 2)"
fi

if docker images link-frontend:optimized --format "{{.Repository}}:{{.Tag}}" | grep -q "link-frontend:optimized"; then
    check_pass "Imagen link-frontend:optimized disponible"
    FRONTEND_EXISTS=true
else
    check_fail "Imagen link-frontend:optimized no encontrada (debe completarse Parte 3)"
fi

echo ""

# ============================================
# Verificar contenedores en ejecución
# ============================================
echo "🔄 Verificando contenedores en ejecución..."

# Verificar Redis
if docker ps --format "{{.Names}}" | grep -q "redis-test"; then
    check_pass "Contenedor redis-test en ejecución"

    # Verificar puerto Redis
    if docker ps --filter "name=redis-test" --format "{{.Ports}}" | grep -q "6379"; then
        check_pass "Redis puerto 6379 expuesto"
    else
        check_warning "Puerto 6379 de Redis no expuesto correctamente"
    fi
else
    check_warning "Contenedor redis-test no está en ejecución"
    echo "   Inicia con: docker run -d --name redis-test -p 6379:6379 redis:7-alpine"
fi

# Verificar Backend
if docker ps --format "{{.Names}}" | grep -q "backend-test"; then
    check_pass "Contenedor backend-test en ejecución"

    # Verificar puerto Backend
    if docker ps --filter "name=backend-test" --format "{{.Ports}}" | grep -q "5000"; then
        check_pass "Backend puerto 5000 expuesto"
    else
        check_warning "Puerto 5000 de Backend no expuesto correctamente"
    fi

    # Verificar variables de entorno
    REDIS_HOST=$(docker inspect backend-test --format '{{range .Config.Env}}{{println .}}{{end}}' | grep REDIS_HOST | cut -d'=' -f2)
    REDIS_PORT=$(docker inspect backend-test --format '{{range .Config.Env}}{{println .}}{{end}}' | grep REDIS_PORT | cut -d'=' -f2)

    if [ -n "$REDIS_HOST" ]; then
        check_pass "Variable REDIS_HOST configurada: $REDIS_HOST"
    else
        check_warning "Variable REDIS_HOST no configurada"
    fi

    if [ "$REDIS_PORT" = "6379" ]; then
        check_pass "Variable REDIS_PORT configurada: $REDIS_PORT"
    else
        check_warning "Variable REDIS_PORT no configurada o incorrecta"
    fi

else
    check_warning "Contenedor backend-test no está en ejecución"
    echo "   Inicia con: docker run -d --name backend-test -p 5000:5000 -e REDIS_HOST=host.docker.internal -e REDIS_PORT=6379 link-backend:optimized"
fi

# Verificar Frontend
if docker ps --format "{{.Names}}" | grep -q "frontend-test"; then
    check_pass "Contenedor frontend-test en ejecución"

    # Verificar puerto Frontend
    if docker ps --filter "name=frontend-test" --format "{{.Ports}}" | grep -q "8080"; then
        check_pass "Frontend puerto 8080 expuesto"
    else
        check_warning "Puerto 8080 de Frontend no expuesto correctamente"
    fi
else
    check_warning "Contenedor frontend-test no está en ejecución"
    echo "   Inicia con: docker run -d --name frontend-test -p 8080:80 link-frontend:optimized"
fi

echo ""

# ============================================
# Verificar conectividad y salud
# ============================================
echo "🏥 Verificando endpoints de salud..."

# Verificar Backend health
if docker ps --format "{{.Names}}" | grep -q "backend-test"; then
    echo ""
    echo "📡 Probando Backend (http://localhost:5000/health)..."

    # Esperar un momento para que el servicio esté listo
    sleep 2

    if curl -s -f http://localhost:5000/health > /tmp/backend-health.json 2>&1; then
        check_pass "Endpoint /health del backend responde"

        # Verificar JSON válido
        if jq empty /tmp/backend-health.json 2>/dev/null; then
            check_pass "Respuesta del backend es JSON válido"

            # Verificar status
            STATUS=$(jq -r '.status' /tmp/backend-health.json 2>/dev/null || echo "")
            if [ "$STATUS" = "healthy" ]; then
                check_pass "Backend status: healthy"
            else
                check_warning "Backend status: $STATUS (esperado: healthy)"
            fi

            # Verificar conexión Redis
            REDIS_STATUS=$(jq -r '.redis' /tmp/backend-health.json 2>/dev/null || echo "")
            if [ "$REDIS_STATUS" = "connected" ]; then
                check_pass "Backend conectado a Redis"
            else
                check_warning "Backend no conectado a Redis: $REDIS_STATUS"
            fi
        else
            check_warning "Respuesta del backend no es JSON válido"
            cat /tmp/backend-health.json
        fi
    else
        check_warning "Endpoint /health del backend no responde"
        echo "   Verifica logs: docker logs backend-test"
    fi
fi

# Verificar Frontend health
if docker ps --format "{{.Names}}" | grep -q "frontend-test"; then
    echo ""
    echo "📡 Probando Frontend (http://localhost:8080/health)..."

    if curl -s -f http://localhost:8080/health > /tmp/frontend-health.txt 2>&1; then
        check_pass "Endpoint /health del frontend responde"

        if grep -q "healthy" /tmp/frontend-health.txt; then
            check_pass "Frontend status: healthy"
        fi
    else
        check_warning "Endpoint /health del frontend no responde"
        echo "   Verifica logs: docker logs frontend-test"
    fi

    # Verificar página principal
    if curl -s -f http://localhost:8080/ > /dev/null 2>&1; then
        check_pass "Página principal del frontend responde (http://localhost:8080)"
    else
        check_warning "Página principal del frontend no responde"
    fi
fi

echo ""

# ============================================
# Verificar logs de contenedores
# ============================================
echo "📋 Verificando logs de contenedores..."

if docker ps --format "{{.Names}}" | grep -q "backend-test"; then
    BACKEND_LOGS=$(docker logs backend-test 2>&1 | tail -5)
    if echo "$BACKEND_LOGS" | grep -qi "error"; then
        check_warning "Se detectaron errores en logs del backend"
        echo "   Revisa con: docker logs backend-test"
    else
        check_pass "Logs del backend sin errores aparentes"
    fi
fi

if docker ps --format "{{.Names}}" | grep -q "frontend-test"; then
    FRONTEND_LOGS=$(docker logs frontend-test 2>&1 | tail -5)
    if echo "$FRONTEND_LOGS" | grep -qi "error"; then
        check_warning "Se detectaron errores en logs del frontend"
        echo "   Revisa con: docker logs frontend-test"
    else
        check_pass "Logs del frontend sin errores aparentes"
    fi
fi

echo ""

# ============================================
# Resumen de puertos
# ============================================
echo "🌐 Resumen de servicios disponibles:"
echo ""

if docker ps --format "{{.Names}}" | grep -q "redis-test"; then
    echo "  🔴 Redis:    localhost:6379"
fi

if docker ps --format "{{.Names}}" | grep -q "backend-test"; then
    echo "  🐍 Backend:  http://localhost:5000"
    echo "             http://localhost:5000/health"
fi

if docker ps --format "{{.Names}}" | grep -q "frontend-test"; then
    echo "  ⚛️  Frontend: http://localhost:8080"
    echo "             http://localhost:8080/health"
fi

echo ""
echo "✅ Verificación completa. ¡Buen trabajo!"
echo ""
echo "💡 Comandos útiles:"
echo "   docker logs backend-test   # Ver logs del backend"
echo "   docker logs frontend-test  # Ver logs del frontend"
echo "   docker ps                  # Ver todos los contenedores"
echo ""
echo "🧹 Para limpiar los contenedores:"
echo "   docker stop backend-test frontend-test redis-test"
echo "   docker rm backend-test frontend-test redis-test"
