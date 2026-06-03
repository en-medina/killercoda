## 💾 Parte 3: Volúmenes Persistentes

### Paso 3.1: Entender el Problema de Persistencia

Sin volúmenes, cuando Redis se reinicia:
- ❌ Todos los datos se pierden
- ❌ URLs cortas creadas desaparecen
- ❌ No es aceptable para producción

### Paso 3.2: Crear Configuración de Redis

Primero, crea un archivo de configuración para Redis con persistencia habilitada:

```bash
cat > ~/code/configs/redis.conf << 'EOF'
# Redis configuration for production

# Enable AOF persistence
appendonly yes
appendfsync everysec

# Save snapshots
save 900 1
save 300 10
save 60 10000

# Set directory for data
dir /data
EOF
```{{exec}}

### Paso 3.3: Crear Compose con Volúmenes

Crea `docker-compose.volumes.yml`:

```yaml
services:
  redis:
    image: redis:7-alpine
    networks:
      - backend-network
    volumes:
      - redis-data:/data
      - ./configs/redis.conf:/usr/local/etc/redis/redis.conf:ro
    command: redis-server /usr/local/etc/redis/redis.conf
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
    depends_on:
      - redis

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
    depends_on:
      - backend

networks:
  backend-network:
    driver: bridge
  frontend-network:
    driver: bridge

volumes:
  redis-data:
    driver: local
```{{copy}}

**Novedades:**
- `redis-data:/data` - Volumen named para persistencia
- `depends_on` - Control de orden de inicio
- Configuración de Redis montada como read-only (`:ro`)

### Paso 3.4: Levantar Stack con Volúmenes

```bash
cd ~/code
docker-compose -f docker-compose.volumes.yml up --build -d

# Esperar a que los servicios estén listos
sleep 10
```{{exec}}

### Paso 3.5: Probar Persistencia de Datos

```bash
# Crear una URL corta
RESPONSE=$(curl -s -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://kubernetes.io"}')

echo "Respuesta: $RESPONSE"

# Guardar el código corto
SHORT_CODE=$(echo $RESPONSE | jq -r '.short_code')
echo "Short code creado: $SHORT_CODE"

# Verificar que funciona
curl -I http://localhost:5000/$SHORT_CODE | head -n 5
```{{exec}}

### Paso 3.6: Simular Reinicio (Sin Perder Datos)

```bash
# Detener servicios (SIN eliminar volúmenes)
docker-compose -f docker-compose.volumes.yml down

# Verificar que el volumen persiste
docker volume ls | grep redis-data

# Levantar de nuevo
docker-compose -f docker-compose.volumes.yml up -d

# Esperar a que Redis inicie
sleep 10
```{{exec}}

### Paso 3.7: Verificar que los Datos Persisten

```bash
# Usar el SHORT_CODE guardado anteriormente
# (si no lo guardaste, usa uno que hayas creado)

# Verificar que el dato persiste después del reinicio
curl -I http://localhost:5000/$SHORT_CODE | head -n 5

echo ""
echo "✅ Los datos persistieron después del reinicio!"
```{{exec}}

### Paso 3.8: Inspeccionar el Volumen

```bash
# Ver detalles del volumen
docker volume inspect code_redis-data

# Ver cuánto espacio usa
docker system df -v | grep redis-data
```{{exec}}

## ✅ Logros

- **Persistencia de datos:** Redis sobrevive reinicios
- **Configuración personalizada:** Redis usa nuestro archivo de configuración
- **Control de dependencias:** Services inician en orden lógico
- **Volúmenes named:** Fáciles de gestionar y respaldar

## 🧹 Limpieza

```bash
# Detener y eliminar contenedores (pero preservar volúmenes)
docker-compose -f docker-compose.volumes.yml down

# Para eliminar TAMBIÉN los volúmenes (perderás los datos)
# docker-compose -f docker-compose.volumes.yml down -v
```{{exec}}

En el siguiente paso, agregaremos health checks para monitoreo robusto.
