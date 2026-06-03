## 🚀 Parte 1: Compose Básico
## 🎯 Objetivos

- Orquestar 3 servicios (Frontend + Backend + Redis) con Docker Compose
- Configurar redes personalizadas y volúmenes persistentes
- Implementar health checks y dependencias entre servicios
- Simular escenarios de fallo y recuperación

## 📚 Conceptos Clave

**Docker Compose:** Herramienta para definir y ejecutar aplicaciones multi-contenedor usando un archivo YAML.

**Beneficios:**
- Un solo comando para levantar toda la stack
- Networking automático entre servicios
- Gestión de volúmenes y variables de entorno
- Reproducible en cualquier máquina

### Paso 1.1: Examinar la Estructura del Proyecto

```bash
cd ~/code
ls -la
# Verás: apps/ (con backend, frontend)
```{{exec}}

### Paso 1.2: Crear Docker Compose Starter

En este directorio, vamos a crear un archivo Docker Compose básico que orqueste tres servicios: Redis, Backend y Frontend.

Crea `docker-compose.starter.yml`:

```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - FLASK_ENV=production

  frontend:
    build:
      context: ./code/apps/frontend
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    environment:
      - VITE_BACKEND_URL=http://localhost:5000
```{{copy}}

**Nota:** Los servicios se descubren por nombre DNS. El backend puede conectarse a Redis usando `redis` como hostname.

### Paso 1.3: Construir y Levantar la Stack

```bash
# Construir imágenes y levantar servicios
docker-compose -f docker-compose.starter.yml up --build -d

# Verificar estado de servicios
docker-compose -f docker-compose.starter.yml ps
```{{copy}}

### Paso 1.4: Probar la Aplicación

Esperar unos segundos para que los servicios inicien y luego chequea su estado:

```bash
# Probar el backend directamente
curl http://localhost:5000/health

# Probar creación de URL corta
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://kubernetes.io"}'

# Chequea el estado de cada contenedor
docker ps 
```{{copy}}

### Paso 1.5: Ver Logs

```bash
# Ver logs de todos los servicios
docker-compose -f docker-compose.starter.yml logs --tail=20

# Ver logs solo del backend
docker-compose -f docker-compose.starter.yml logs backend --tail=10
```{{copy}}

## ❌ Problemas de este Enfoque Básico

1. **Sin redes aisladas:** El frontend podría acceder directamente a Redis (violación de seguridad)
2. **Sin persistencia:** Si Redis se reinicia, perdemos todos los datos
3. **Sin health checks:** No sabemos si los servicios están realmente funcionando
4. **Sin control de orden:** Los servicios inician en paralelo sin esperar dependencias

## 🧹 Limpieza

```bash
# Detener y eliminar contenedores
docker-compose -f docker-compose.starter.yml down
```{{exec}}

En el siguiente paso, agregaremos redes personalizadas para mejorar la seguridad.
