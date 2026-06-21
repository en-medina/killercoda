## 🎓 Parte 6: Reto Final - Múltiples Entornos (Opcional)

**Nota:** Antes de iniciar este reto, asegura haber detenido la aplicación anterior con el siguiente commando
```
docker-compose -f docker-compose.complete.yml down
```{{exec}}

### Desafío 1: Separar Configuración por Entornos

En producción, normalmente necesitas diferentes configuraciones para desarrollo, staging y producción.

#### Paso 6.1: Crear Archivo Base

Crea `docker-compose.yml` (configuración base):

```yaml
services:
  redis:
    image: redis:7-alpine
    networks:
      - backend-network
    volumes:
      - redis-data:/data

  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    networks:
      - backend-network
      - frontend-network
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379

  frontend:
    build:
      context: ./apps/frontend
      dockerfile: Dockerfile
    networks:
      - frontend-network
    depends_on:
      - backend

networks:
  backend-network:
  frontend-network:

volumes:
  redis-data:
```{{copy}}

#### Paso 6.2: Crear Override para Desarrollo

Crea `docker-compose.dev.yml` (overrides para desarrollo):

```yaml
services:
  redis:
    ports:
      - "6379:6379"  # Exponer para debugging
    command: redis-server --loglevel debug

  backend:
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    volumes:
      - ./apps/backend:/app  # Hot reload
    command: flask run --host=0.0.0.0 --reload

  frontend:
    ports:
      - "5173:5173"
    env_file:
      - ./apps/frontend/.env
    volumes:
      - ./apps/frontend/src:/app/src  # Hot reload
```{{copy}}

#### Paso 6.3: Crear Override para Producción

Crea `docker-compose.prod.yml` (overrides para producción):

```yaml
services:
  redis:
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
    volumes:
      - ./configs/redis.conf:/usr/local/etc/redis/redis.conf:ro
    command: redis-server /usr/local/etc/redis/redis.conf
    # No exponer puertos (solo red interna)

  backend:
    restart: always
    environment:
      - FLASK_ENV=production
    depends_on:
      redis:
        condition: service_healthy
    healthcheck:
      test: [
        "CMD",
        "python",
        "-c",
        "\"import urllib.request; urllib.request.urlopen('http://localhost:5000/health').read()\""
      ]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    ports:
      - "5000:5000"

  frontend:
    restart: always
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
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M
    ports:
      - "80:80"
```{{copy}}

#### Paso 6.4: Probar Configuración de Desarrollo

```bash
cd ~/code

# Levantar con configuración de desarrollo
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Verificar
docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps

# Probar
curl -s http://localhost:5000/health | jq .
```{{exec}}

#### Paso 6.5: Cambiar a Configuración de Producción

```bash
# Detener desarrollo
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down

# Levantar producción
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Verificar health checks (toma más tiempo)
sleep 20
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

# Probar
curl -s http://localhost:5000/health | jq .
```{{exec}}

### Desafío 2: Variables de Entorno con .env
Antes de iniciar remueve todos los contenedores del paso anterior con el siguiente comando:
```
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```{{exec}}

#### Paso 6.6: Crear Archivo .env

```bash
cat > ~/code/.env << 'EOF'
# Project configuration
COMPOSE_PROJECT_NAME=linkshortener

# Service ports
BACKEND_PORT=5000
FRONTEND_PORT=5173
REDIS_PORT=6379

# Environment
ENVIRONMENT=production

# Resource limits
BACKEND_MEMORY_LIMIT=512M
BACKEND_CPU_LIMIT=0.5
FRONTEND_MEMORY_LIMIT=128M
FRONTEND_CPU_LIMIT=0.25
EOF
```{{exec}}

#### Paso 6.7: Crear Compose con Variables

Crea `docker-compose.env.yml`:

```yaml
services:
  redis:
    image: redis:7-alpine
    networks:
      - backend-network
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - redis-data:/data

  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    networks:
      - backend-network
      - frontend-network
    ports:
      - "${BACKEND_PORT}:5000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - FLASK_ENV=${ENVIRONMENT}
    deploy:
      resources:
        limits:
          cpus: '${BACKEND_CPU_LIMIT}'
          memory: ${BACKEND_MEMORY_LIMIT}

  frontend:
    build:
      context: ./apps/frontend
      dockerfile: Dockerfile
    networks:
      - frontend-network
    ports:
      - "${FRONTEND_PORT}:80"
    env_file:
      - ./apps/frontend/.env
    depends_on:
      - backend
    deploy:
      resources:
        limits:
          cpus: '${FRONTEND_CPU_LIMIT}'
          memory: ${FRONTEND_MEMORY_LIMIT}

networks:
  backend-network:
  frontend-network:

volumes:
  redis-data:
```{{copy}}

#### Paso 6.8: Probar con Variables de Entorno

```bash
# Docker Compose carga .env automáticamente
docker-compose -f docker-compose.env.yml up -d

# Verificar que los puertos son los correctos
docker-compose -f docker-compose.env.yml ps
```{{exec}}

## 🏆 Desafíos Completados

Si completaste todos los desafíos, ahora sabes:

- ✅ **Múltiples entornos:** Separar configuración por ambiente
- ✅ **Variables de entorno:** Parametrizar configuración
- ✅ **Profiles:** Servicios opcionales bajo demanda
- ✅ **Automatización:** Makefile para comandos comunes
- ✅ **Best practices:** Configuración production-ready

## 📚 Comandos Avanzados de Compose

```bash
# Override específico
docker-compose -f docker-compose.yml -f custom.yml up

# Usar .env alternativo
docker-compose --env-file .env.staging up

# Escalar servicios (sin container_name)
docker-compose up -d --scale backend=3

# Recrear solo un servicio
docker-compose up -d --force-recreate backend

# Ver configuración resultante
docker-compose config

# Validar sintaxis
docker-compose config --quiet
```

## 🎓 Conceptos Avanzados Aprendidos

1. **Compose file merging:** Combinar múltiples archivos para diferentes entornos
2. **Variable substitution:** Usar variables de entorno en YAML
3. **Profiles:** Activar servicios condicionalmente
4. **Config validation:** Verificar sintaxis antes de deploy
5. **Infrastructure as Code:** Toda la configuración en archivos versionados

## 🎉 ¡Laboratorio Completado!

Has dominado Docker Compose desde lo básico hasta configuraciones production-ready con múltiples entornos.

### Próximos Pasos Recomendados

1. **Docker Swarm:** Orquestación multi-nodo
2. **Kubernetes:** Orquestación enterprise-grade
3. **CI/CD Integration:** Integrar estos compose files en pipelines
4. **Secrets Management:** Usar Docker secrets o herramientas externas
5. **Monitoring Stack:** Prometheus + Grafana completo
