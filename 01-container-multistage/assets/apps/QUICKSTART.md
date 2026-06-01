# Quick Start Guide

## Inicio Rápido (5 minutos)

### Opción 1: Script de inicio automático

**En Windows:**
```bash
start.bat
```

**En Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

### Opción 2: Comandos manuales

```bash
# 1. Iniciar todos los servicios
docker-compose up --build -d

# 2. Verificar que estén corriendo
docker-compose ps

# 3. Ver logs (opcional)
docker-compose logs -f
```

### Acceso a la aplicación

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:5000/health
- **Redis:** localhost:6379

## Prueba Rápida

### 1. Desde el navegador

1. Abre http://localhost:5173
2. Pega esta URL de prueba:
   ```
   https://github.com/anthropics/claude-code
   ```
3. Haz clic en "Shorten URL"
4. Copia el enlace corto generado
5. Abre el enlace corto en una nueva pestaña (debería redirigir)

### 2. Desde la terminal (curl)

```bash
# Acortar una URL
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"}'

# Respuesta esperada:
# {
#   "short_url": "http://localhost:5000/Abc123",
#   "short_code": "Abc123",
#   "original_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
# }

# Probar la redirección (opcional)
curl -L http://localhost:5000/Abc123
```

## Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs solo del backend
docker-compose logs -f backend

# Reiniciar un servicio específico
docker-compose restart backend

# Detener todos los servicios
docker-compose down

# Detener y limpiar volúmenes (reset completo)
docker-compose down -v

# Ver estado de los contenedores
docker-compose ps

# Ejecutar comandos dentro del contenedor backend
docker-compose exec backend bash

# Ejecutar comandos en Redis
docker-compose exec redis redis-cli
```

## Solución Rápida de Problemas

### El frontend muestra error de conexión

```bash
# Verificar que el backend esté corriendo
docker-compose ps backend

# Ver logs del backend
docker-compose logs backend

# Reiniciar el backend
docker-compose restart backend
```

### Redis no se conecta

```bash
# Verificar que Redis esté healthy
docker-compose ps redis

# Probar conexión manual
docker-compose exec redis redis-cli ping
# Debería devolver: PONG
```

### Puerto ocupado

Si un puerto ya está en uso, edita `docker-compose.yml`:

```yaml
# Cambiar el mapeo de puertos
ports:
  - "8080:80"    # En lugar de 5173:80 para frontend
  - "8000:5000"  # En lugar de 5000:5000 para backend
```

### Limpiar todo y empezar de cero

```bash
# Detener y eliminar todo (contenedores, volúmenes, redes)
docker-compose down -v

# Eliminar imágenes construidas
docker rmi link-shortener-backend link-shortener-frontend

# Reconstruir todo
docker-compose up --build
```

## Verificación de Salud

```bash
# Backend health check
curl http://localhost:5000/health

# Frontend health check
curl http://localhost:5173/health

# Redis health check
docker-compose exec redis redis-cli ping
```

## Detener la Aplicación

```bash
# Detener pero mantener los datos
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener, eliminar contenedores y limpiar volúmenes
docker-compose down -v
```

## Próximos Pasos

- Lee el [README.md](README.md) completo para entender la arquitectura
- Revisa el código fuente en `backend/app/` y `frontend/src/`
- Modifica los estilos en `frontend/src/` (TailwindCSS)
- Agrega nuevas funcionalidades al backend en `backend/app/routes.py`
- Experimenta con la configuración de Redis en `database/redis.conf`

## Recursos Adicionales

- **Docker Docs:** https://docs.docker.com/
- **Flask Docs:** https://flask.palletsprojects.com/
- **React + Vite:** https://vitejs.dev/guide/
- **Redis Docs:** https://redis.io/docs/
- **TailwindCSS:** https://tailwindcss.com/docs
