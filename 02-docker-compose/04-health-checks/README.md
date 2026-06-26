## 🏥 Parte 4: Health Checks y Production-Ready

### Paso 4.1: Entender Health Checks

Los health checks permiten:
- ✅ Detectar servicios que están "up" pero no funcionan
- ✅ Retrasar el inicio de servicios dependientes hasta que estén realmente listos
- ✅ Reiniciar automáticamente servicios no saludables
- ✅ Integración con orquestadores (Kubernetes, Docker Swarm)

### Paso 4.2: Crear Compose Production-Ready

En el directorio `~/code`. Crea `docker-compose.complete.yml`:

```yaml
services:
  redis:
    image: redis:7-alpine
    container_name: link-redis
    networks:
      - backend-network
    volumes:
      - redis-data:/data
      - ./configs/redis.conf:/usr/local/etc/redis/redis.conf:ro
    command: redis-server /usr/local/etc/redis/redis.conf
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
    restart: unless-stopped
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    container_name: link-backend
    networks:
      - backend-network
      - frontend-network
    ports:
      - "5000:5000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - FLASK_ENV=production
    depends_on:
      redis:
        condition: service_healthy
    healthcheck:
      test: [
        "CMD",
        "python",
        "-c",
        "import urllib.request; urllib.request.urlopen('http://localhost:5000/health').read()"
      ]
      interval: 5s
      timeout: 3s
      retries: 2
      start_period: 10s
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  frontend:
    build:
      context: ./apps/frontend
      dockerfile: Dockerfile
    container_name: link-frontend
    networks:
      - frontend-network
    ports:
      - "5173:80"
    env_file:
      - ./apps/frontend/.env
    depends_on:
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:80/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M

networks:
  backend-network:
    driver: bridge
  frontend-network:
    driver: bridge

volumes:
  redis-data:
    driver: local
```{{copy}}

**Características Production-Ready:**
- **Health checks:** Cada servicio tiene verificación de salud
- **Restart policies:** Auto-recuperación ante fallos
- **Resource limits:** Previene que un servicio consuma todos los recursos
- **Conditional dependencies:** Servicios esperan hasta que dependencias estén "healthy"

### Paso 4.3: Levantar Stack Production-Ready

```bash
docker-compose -f docker-compose.complete.yml up --build -d
```

### Paso 4.4: Monitorear Health Status

```bash
# Ver estado con health checks
docker-compose -f docker-compose.complete.yml ps

# Esperar unos segundos para ver los health checks

# Ver de nuevo (los estados deberían ser "healthy")
docker-compose -f docker-compose.complete.yml ps
```

### Paso 4.5: Inspeccionar Health Checks

```bash
# Inspeccionar health del backend
docker inspect link-backend --format='{{json .State.Health}}' | jq

```{{exec}}

### Paso 4.6: Monitorear Recursos

```bash
# Ver uso de CPU y memoria
docker stats --no-stream

# Ver límites configurados
docker inspect link-backend --format='Memory Limit: {{.HostConfig.Memory}}'
docker inspect link-backend --format='CPU Limit: {{.HostConfig.NanoCpus}}'
```{{exec}}

### Paso 4.7: Ver Logs en Tiempo Real

```bash
docker-compose -f docker-compose.complete.yml logs --tail=20 # Ver logs de todos los servicios
```{{exec}}

### Paso 4.8: Probar la Aplicación Completa

```bash
# Test 1: Health endpoints
echo "Testing health endpoints..."
curl -f http://localhost:5000/health && echo "✅ Backend healthy"

# Test 2: Crear URL
echo ""
echo "Creating short URL..."
RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://docker.com"}')
echo $RESPONSE

# Test 3: Verificar redirect
SHORT_CODE=$(echo $RESPONSE | jq -r '.short_code')
echo ""
echo "Testing redirect for: $SHORT_CODE"
curl -sI http://localhost:5000/$SHORT_CODE  | grep Location
```{{exec}}

## ✅ Logros

- **Health monitoring:** Detección automática de servicios no saludables
- **Conditional startup:** Servicios esperan a que dependencias estén realmente listas
- **Resource management:** Límites de CPU y memoria previenen resource starvation
- **Auto-recovery:** Restart policies permiten recuperación automática
- **Production-ready:** Stack lista para ambientes de producción

## 🧹 Preparación para Siguiente Paso

```bash
# Dejar la stack corriendo para el siguiente paso
# (en el siguiente paso simularemos fallos)
```

En el siguiente paso, simularemos escenarios de fallo para probar la resiliencia.
