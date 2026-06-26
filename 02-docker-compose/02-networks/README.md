## 🔧 Parte 2: Redes Personalizadas

### Paso 2.1: Entender el Aislamiento de Redes

En producción, queremos aislar servicios por capas:
- **backend-network:** Solo Redis y Backend
- **frontend-network:** Solo Backend y Frontend

**Beneficio de seguridad:** El Frontend nunca puede acceder directamente a Redis, solo a través de la API del Backend.

### Paso 2.2: Crear Compose con Redes

Dentro del directorio ~/code. Crea `docker-compose.networks.yml`:

```bash
cat << 'EOF' > ~/code/docker-compose.networks.yml
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
    env_file:
      - ./apps/frontend/.env

networks:
  backend-network:
    driver: bridge
  frontend-network:
    driver: bridge
EOF
```{{exec}}

**Nota:** El Backend está conectado a AMBAS redes, actuando como puente entre Frontend y Redis.

### Paso 2.3: Levantar Stack con Redes

```bash
docker-compose -f docker-compose.networks.yml up --build -d
```{{exec}}

### Paso 2.4: Verificar Redes Creadas

```bash
# Listar redes de Docker
docker network ls | grep code

# Inspeccionar la red backend
docker network inspect code_backend-network

# Revisa los containers que estan conectados a estas redes
docker network inspect code_backend-network | jq '.[].Containers'

# Guarda la salida de este comando en /opt/networks.json
```

### Paso 2.5: Probar Aislamiento de Red

```bash
# Intentar verificar desde frontend la IP redis (no devolvera nada)
docker-compose -f docker-compose.networks.yml exec frontend getent hosts redis 

# Intentar verificar desde backend  la IP redis (si la conoce)
docker-compose -f docker-compose.networks.yml exec backend getent hosts redis
```

**Nota**: La IP de redis que conoce el backend coincide con la IP asignada a redis en la red **code_backend-network**.

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

# Verificar redirección en el Header `Location`
# te debe redirigir a la URL original
curl -sI http://localhost:5000/$SHORT_CODE | grep Location

```

## ✅ Logros

- **Aislamiento por capas:** Frontend → Backend → Redis (nunca Frontend → Redis)
- **Seguridad mejorada:** Minimiza superficie de ataque
- **Networking automático:** DNS service discovery entre contenedores

## 🧹 Limpieza

```bash
docker-compose -f docker-compose.networks.yml down
```{{exec}}

En el siguiente paso, agregaremos volúmenes persistentes para no perder datos.
