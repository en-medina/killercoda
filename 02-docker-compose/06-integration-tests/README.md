## 🧪 Parte 6: Tests de Integración

### Paso 6.1: Entender los Tests de Integración

Los tests de integración verifican que:
- ✅ Todos los servicios se comunican correctamente
- ✅ Los endpoints responden como se espera
- ✅ Los datos persisten a través de la stack
- ✅ Los health checks funcionan
- ✅ La aplicación completa funciona end-to-end

### Paso 6.2: Crear Script de Tests Automatizados

Crea `~/code/scripts/test-stack.sh`:

```bash
cat > ~/code/scripts/test-stack.sh << 'SCRIPT_EOF'
#!/bin/bash

set -e

echo "🧪 Testing Link Shortener Stack..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check if all services are running
echo "1️⃣  Testing if all services are running..."
RUNNING=$(docker-compose -f ~/code/docker-compose.complete.yml ps --services --filter "status=running" | wc -l)
if [ "$RUNNING" -eq 3 ]; then
    echo -e "${GREEN}✅ All 3 services are running${NC}"
else
    echo -e "${RED}❌ Only $RUNNING/3 services are running${NC}"
    exit 1
fi

# Test 2: Health endpoints
echo ""
echo "2️⃣  Testing health endpoints..."

if curl -sf http://localhost:5000/health > /dev/null; then
    echo -e "${GREEN}✅ Backend health check passed${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
    exit 1
fi

# Test 3: Redis connectivity
echo ""
echo "3️⃣  Testing Redis connectivity..."
if docker-compose -f ~/code/docker-compose.complete.yml exec -T redis redis-cli ping | grep -q PONG; then
    echo -e "${GREEN}✅ Redis is responding${NC}"
else
    echo -e "${RED}❌ Redis is not responding${NC}"
    exit 1
fi

# Test 4: Create short URL
echo ""
echo "4️⃣  Testing URL shortening..."
RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://kubernetes.io/docs"}')

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}❌ No response from shorten endpoint${NC}"
    exit 1
fi

SHORT_CODE=$(echo "$RESPONSE" | jq -r '.short_code')
if [ "$SHORT_CODE" == "null" ] || [ -z "$SHORT_CODE" ]; then
    echo -e "${RED}❌ Short code not generated${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ URL shortened successfully${NC}"
echo -e "   Short code: ${YELLOW}$SHORT_CODE${NC}"

# Test 5: Test redirect
echo ""
echo "5️⃣  Testing redirect..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/$SHORT_CODE)

if [ "$HTTP_CODE" -eq 302 ] || [ "$HTTP_CODE" -eq 301 ]; then
    echo -e "${GREEN}✅ Redirect works (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Redirect failed (HTTP $HTTP_CODE, expected 302)${NC}"
    exit 1
fi

# Test 6: Test stats endpoint
echo ""
echo "6️⃣  Testing stats endpoint..."
STATS=$(curl -sf http://localhost:5000/stats/$SHORT_CODE)

if [ -z "$STATS" ]; then
    echo -e "${RED}❌ Stats endpoint failed${NC}"
    exit 1
fi

CLICKS=$(echo "$STATS" | jq -r '.clicks')
if [ "$CLICKS" -ge 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ Stats retrieved successfully${NC}"
    echo "   Clicks: $CLICKS"
else
    echo -e "${RED}❌ Invalid stats data${NC}"
    exit 1
fi

# Test 7: Test data persistence
echo ""
echo "7️⃣  Testing data persistence..."
NEW_RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://docker.com"}')
NEW_CODE=$(echo "$NEW_RESPONSE" | jq -r '.short_code')

# Verify we can retrieve it immediately
if curl -sf http://localhost:5000/stats/$NEW_CODE > /dev/null; then
    echo -e "${GREEN}✅ Data persists in Redis${NC}"
else
    echo -e "${RED}❌ Data persistence test failed${NC}"
    exit 1
fi

# Test 8: Test network isolation
echo ""
echo "8️⃣  Testing network isolation..."
if docker-compose -f ~/code/docker-compose.complete.yml exec -T frontend ping -c 1 redis 2>&1 | grep -q "bad address"; then
    echo -e "${GREEN}✅ Network isolation working (frontend cannot reach redis)${NC}"
else
    echo -e "${YELLOW}⚠️  Network isolation not properly configured${NC}"
fi

# Test 9: Test volume persistence
echo ""
echo "9️⃣  Testing volume existence..."
if docker volume ls | grep -q redis-data; then
    echo -e "${GREEN}✅ Redis data volume exists${NC}"
else
    echo -e "${RED}❌ Redis data volume not found${NC}"
    exit 1
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 All tests passed!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Stack is production-ready with:"
echo "  • All services healthy"
echo "  • Proper network isolation"
echo "  • Data persistence"
echo "  • Full end-to-end functionality"
SCRIPT_EOF

chmod +x ~/code/scripts/test-stack.sh
```{{exec}}

### Paso 6.3: Preparar la Stack para Testing

```bash
# Asegurar que la stack está corriendo
cd ~/code
docker-compose -f docker-compose.complete.yml up -d

# Esperar a que todos los health checks pasen
echo "Esperando a que todos los servicios estén saludables..."
sleep 20
```{{exec}}

### Paso 6.4: Ejecutar Suite de Tests

```bash
# Ejecutar todos los tests
~/code/scripts/test-stack.sh
```{{exec}}

### Paso 6.5: Crear Test de Smoke (Verificación Rápida)

```bash
cat > ~/code/scripts/smoke-test.sh << 'EOF'
#!/bin/bash

echo "🔥 Running smoke test..."

# Quick check: all services up and backend responding
if docker-compose -f ~/code/docker-compose.complete.yml ps | grep -q "Up" && \
   curl -sf http://localhost:5000/health > /dev/null; then
    echo "✅ Smoke test passed"
    exit 0
else
    echo "❌ Smoke test failed"
    exit 1
fi
EOF

chmod +x ~/code/scripts/smoke-test.sh
```{{exec}}

### Paso 6.6: Ejecutar Smoke Test

```bash
~/code/scripts/smoke-test.sh
```{{exec}}

### Paso 6.7: Crear Test de Carga Básico

```bash
cat > ~/code/scripts/load-test.sh << 'EOF'
#!/bin/bash

echo "⚡ Running basic load test..."
echo "Creating 50 short URLs..."

SUCCESS=0
FAIL=0

for i in $(seq 1 50); do
    RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
      -H "Content-Type: application/json" \
      -d "{\"url\": \"https://example.com/page${i}\"}")
    
    if echo "$RESPONSE" | jq -e '.short_code' > /dev/null 2>&1; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
    
    # Progress indicator
    if [ $((i % 10)) -eq 0 ]; then
        echo "  Progress: $i/50"
    fi
done

echo ""
echo "Results:"
echo "  ✅ Success: $SUCCESS"
echo "  ❌ Failed: $FAIL"
echo "  📊 Success rate: $(echo "scale=2; $SUCCESS * 100 / 50" | bc)%"

if [ $FAIL -eq 0 ]; then
    echo "🎉 Load test passed!"
    exit 0
else
    echo "⚠️  Some requests failed"
    exit 1
fi
EOF

chmod +x ~/code/scripts/load-test.sh
```{{exec}}

### Paso 6.8: Ejecutar Load Test

```bash
~/code/scripts/load-test.sh
```{{exec}}

### Paso 6.9: Verificar Performance

```bash
# Ver estadísticas de recursos después del load test
docker stats --no-stream

# Ver conteo de URLs en Redis
docker-compose -f docker-compose.complete.yml exec -T redis redis-cli DBSIZE
```{{exec}}

### Paso 6.10: Crear Script de Validación Completa

```bash
cat > ~/code/scripts/validate-all.sh << 'EOF'
#!/bin/bash

echo "🔍 Running complete validation suite..."
echo ""

# Run all tests
FAILED=0

echo "===== Smoke Test ====="
if ~/code/scripts/smoke-test.sh; then
    echo "✅ Smoke test passed"
else
    echo "❌ Smoke test failed"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "===== Integration Tests ====="
if ~/code/scripts/test-stack.sh; then
    echo "✅ Integration tests passed"
else
    echo "❌ Integration tests failed"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "===== Load Test ====="
if ~/code/scripts/load-test.sh; then
    echo "✅ Load test passed"
else
    echo "❌ Load test failed"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo "🎉 All validation suites passed!"
    exit 0
else
    echo "⚠️  $FAILED suite(s) failed"
    exit 1
fi
EOF

chmod +x ~/code/scripts/validate-all.sh
```{{exec}}

### Paso 6.11: Ejecutar Validación Completa

```bash
~/code/scripts/validate-all.sh
```{{exec}}

## ✅ Logros

- **Automated testing:** Scripts reutilizables para validación
- **Smoke tests:** Verificación rápida de funcionalidad básica
- **Integration tests:** Validación end-to-end de toda la stack
- **Load tests:** Verificación bajo carga
- **CI/CD ready:** Tests pueden ejecutarse en pipelines

## 📊 Comandos Útiles de Testing

```bash
# Ver todos los scripts de test
ls -lh ~/code/scripts/

# Ejecutar test específico
~/code/scripts/test-stack.sh

# Ver logs durante tests
docker-compose -f docker-compose.complete.yml logs -f backend

# Reiniciar stack para testing limpio
docker-compose -f docker-compose.complete.yml down -v
docker-compose -f docker-compose.complete.yml up -d
```

## 🎓 Mejores Prácticas Aprendidas

1. **Automatiza todo:** Tests manuales no escalan
2. **Test en diferentes niveles:** Smoke → Integration → Load
3. **Verifica health, no solo status:** Un contenedor "Up" puede estar roto
4. **Test network isolation:** Seguridad es parte de la funcionalidad
5. **Test data persistence:** Volúmenes deben funcionar como se espera

En el siguiente paso, crearemos configuraciones para múltiples entornos (desafío opcional).
