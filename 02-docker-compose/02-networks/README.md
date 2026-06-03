## 🔧 Parte 2: Redes Personalizadas

### Paso 2.1: Entender el Aislamiento de Redes

En producción, queremos aislar servicios por capas:
- **backend-network:** Solo Redis y Backend
- **frontend-network:** Solo Backend y Frontend

**Beneficio de seguridad:** El Frontend nunca puede acceder directamente a Redis, solo a través de la API del Backend.

### Paso 2.2: Crear Compose con Redes

Crea `docker-compose.networks.yml`:

```yaml
services:
  redis:
    image: redis:7-alpine
    networks:
      - backend-network
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    networks:
      - backend-network
      - frontend-network
    ports:
      - "5000:5000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - FLASK_ENV=production

  frontend:
    build:
      context: ./apps/frontend
      dockerfile: Dockerfile
    networks:
      - frontend-network
    ports:
      - "5173:80"
    environment:
      - VITE_BACKEND_URL=http://localhost:5000

networks:
  backend-network:
    driver: bridge
  frontend-network:
    driver: bridge
```{{copy}}

**Nota:** El Backend está conectado a AMBAS redes, actuando como puente entre Frontend y Redis.

### Paso 2.3: Levantar Stack con Redes

```bash
cd ~/code
docker-compose -f docker-compose.networks.yml up --build -d
```{{exec}}

### Paso 2.4: Verificar Redes Creadas

```bash
# Listar redes de Docker
docker network ls | grep code

# Inspeccionar la red backend
docker network inspect code_backend-network
```{{exec}}

### Paso 2.5: Probar Aislamiento de Red

```bash
# Intentar conectar desde frontend a redis (debe fallar)
docker-compose -f docker-compose.networks.yml exec frontend ping -c 2 redis || echo "✅ Correctamente aislado: frontend no puede alcanzar redis"

# Intentar conectar desde backend a redis (debe funcionar)
docker-compose -f docker-compose.networks.yml exec backend ping -c 2 redis && echo "✅ Backend puede alcanzar redis"
```{{exec}}

### Paso 2.6: Verificar que la Aplicación Funciona

```bash
# Crear URL corta
RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}')

echo $RESPONSE

# Extraer short_code
SHORT_CODE=$(echo $RESPONSE | jq -r '.short_code')
echo "Short code: $SHORT_CODE"

# Verificar redirección
curl -I http://localhost:5000/$SHORT_CODE
```{{exec}}

## ✅ Logros

- **Aislamiento por capas:** Frontend → Backend → Redis (nunca Frontend → Redis)
- **Seguridad mejorada:** Minimiza superficie de ataque
- **Networking automático:** DNS service discovery entre contenedores

## 🧹 Limpieza

```bash
docker-compose -f docker-compose.networks.yml down
```{{exec}}

En el siguiente paso, agregaremos volúmenes persistentes para no perder datos.
