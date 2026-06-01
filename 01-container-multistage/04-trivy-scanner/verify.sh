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

echo "🔍 Verificando Parte 4: Escaneo de Vulnerabilidades con Trivy..."
echo ""

# ============================================
# Verificar Trivy instalado
# ============================================
echo "🔧 Verificando instalación de Trivy..."

if command -v trivy &> /dev/null; then
    check_pass "Trivy está instalado"
    TRIVY_VERSION=$(trivy --version | head -1)
    echo "   Versión: $TRIVY_VERSION"
else
    check_fail "Trivy no está instalado"
fi

echo ""

# ============================================
# Verificar escaneos realizados
# ============================================
echo "🔍 Verificando escaneos realizados..."

# Verificar si se han ejecutado los comandos de escaneo
# (comprobando el historial de bash)
HISTORY_FILE="$HOME/.bash_history"

if [ "$BACKEND_EXISTS" = true ]; then
    echo ""
    echo "📊 Escaneando backend..."

    # Ejecutar escaneo silencioso para verificar
    if trivy image --quiet --severity HIGH,CRITICAL link-backend:optimized > /tmp/backend-scan.txt 2>&1; then
        check_pass "Escaneo de backend ejecutado correctamente"

        # Contar vulnerabilidades HIGH y CRITICAL
        HIGH_CRITICAL=$(grep -E "(HIGH|CRITICAL)" /tmp/backend-scan.txt | wc -l || echo "0")

        if [ "$HIGH_CRITICAL" -gt 0 ]; then
            check_warning "Se encontraron $HIGH_CRITICAL vulnerabilidades HIGH/CRITICAL en backend"
            echo "   Revisa con: trivy image --severity HIGH,CRITICAL link-backend:optimized"
        else
            check_pass "No se encontraron vulnerabilidades HIGH/CRITICAL en backend"
        fi
    else
        check_warning "Error al escanear backend"
    fi
fi

if [ "$FRONTEND_EXISTS" = true ]; then
    echo ""
    echo "📊 Escaneando frontend..."

    # Ejecutar escaneo silencioso para verificar
    if trivy image --quiet --severity HIGH,CRITICAL link-frontend:optimized > /tmp/frontend-scan.txt 2>&1; then
        check_pass "Escaneo de frontend ejecutado correctamente"

        # Contar vulnerabilidades HIGH y CRITICAL
        HIGH_CRITICAL=$(grep -E "(HIGH|CRITICAL)" /tmp/frontend-scan.txt | wc -l || echo "0")

        if [ "$HIGH_CRITICAL" -gt 0 ]; then
            check_warning "Se encontraron $HIGH_CRITICAL vulnerabilidades HIGH/CRITICAL en frontend"
            echo "   Revisa con: trivy image --severity HIGH,CRITICAL link-frontend:optimized"
        else
            check_pass "No se encontraron vulnerabilidades HIGH/CRITICAL en frontend"
        fi
    else
        check_warning "Error al escanear frontend"
    fi
fi

echo ""

# ============================================
# Verificar reportes JSON
# ============================================
echo "📄 Verificando reportes JSON..."

if [ -f "/opt/backend-scan.json" ]; then
    check_pass "Reporte backend-scan.json existe"

    # Verificar que sea JSON válido
    if jq empty /opt/backend-scan.json 2>/dev/null; then
        check_pass "backend-scan.json es JSON válido"

        # Contar vulnerabilidades
        VULN_COUNT=$(jq '[.Results[]?.Vulnerabilities[]?] | length' /opt/backend-scan.json 2>/dev/null || echo "0")
        echo "   Vulnerabilidades totales en backend: $VULN_COUNT"
    else
        check_warning "backend-scan.json no es JSON válido"
    fi
else
    check_fail "backend-scan.json no existe. Ejecuta:"
    echo "   trivy image --format json --output /opt/backend-scan.json link-backend:optimized"
fi

if [ -f "/opt/frontend-scan.json" ]; then
    check_pass "Reporte frontend-scan.json existe"

    # Verificar que sea JSON válido
    if jq empty /opt/frontend-scan.json 2>/dev/null; then
        check_pass "frontend-scan.json es JSON válido"

        # Contar vulnerabilidades
        VULN_COUNT=$(jq '[.Results[]?.Vulnerabilities[]?] | length' /opt/frontend-scan.json 2>/dev/null || echo "0")
        echo "   Vulnerabilidades totales en frontend: $VULN_COUNT"
    else
        check_warning "frontend-scan.json no es JSON válido"
    fi
else
    check_fail "frontend-scan.json no existe. Ejecuta:"
    echo "   trivy image --format json --output /opt/frontend-scan.json link-frontend:optimized"
fi

echo ""

# ============================================
# Verificar comprensión de severidades
# ============================================
echo "📚 Verificación de conocimiento..."

echo ""
echo "Recuerda los niveles de severidad:"
echo "  • CRITICAL: Requiere acción inmediata"
echo "  • HIGH: Parchear pronto"
echo "  • MEDIUM: Revisar en próximas actualizaciones"
echo "  • LOW: Informativas, baja prioridad"

echo ""
echo "✅ Verificación completa. ¡Buen trabajo!"
echo ""
echo "💡 Próximos pasos:"
echo "   - Revisa las vulnerabilidades encontradas"
echo "   - Considera actualizar imágenes base para reducir vulnerabilidades"
echo "   - Documenta las vulnerabilidades críticas que requieren atención"
