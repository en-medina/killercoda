# Link Shortener Application

Una aplicación moderna de acortamiento de enlaces construida con React, Flask y Redis, totalmente containerizada con Docker.

## Arquitectura

### Stack Tecnológico

- **Frontend:** React 18 + Vite + TypeScript + TailwindCSS
- **Backend:** Python 3.11 + Flask + Gunicorn
- **Database/Cache:** Redis 7

### Estructura del Proyecto

```text
link-shortener-app/
├── backend/
│   ├── app/
│   │   ├── __init__.py       # Inicialización de Flask y Redis
│   │   ├── routes.py         # Endpoints de la API
│   │   └── utils.py          # Utilidades (validación, generación de códigos)
│   ├── requirements.txt      # Dependencias de Python
│   └── Dockerfile            # Multi-stage build para backend
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── UrlShortenerForm.tsx
│   │   │   └── ResultDisplay.tsx
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── Dockerfile            # Multi-stage build para frontend
├── database/
│   └── redis.conf            # Configuración de Redis
└── docker-compose.yml        # Orquestación de servicios
```

## Características

### Backend API

- **POST /shorten** - Acorta una URL y devuelve el código corto
- **GET /<short_code>** - Redirecciona a la URL original (HTTP 302)
- **GET /stats/<short_code>** - Obtiene estadísticas de un código (TTL, URL original)
- **GET /health** - Health check del servicio
- **GET /ping** - Health check del servicio sin DB
### Frontend

- Interfaz minimalista con diseño responsive
- Validación de URLs en tiempo real
- Copia al portapapeles con un clic
- Estados de carga y manejo de errores
- Diseño moderno con TailwindCSS

### Características Técnicas

- **Multi-stage builds** optimizados para producción
- **Health checks** configurados en todos los servicios
- **Networking** aislado con Docker networks
- **Persistencia** de datos con Docker volumes
- **TTL automático** de 30 días para URLs acortadas
- **Manejo de colisiones** en generación de códigos

## Cómo Ejecutar la Aplicación

### Requisitos Previos

- Docker Engine 20.10+
- Docker Compose 2.0+

### Instrucciones de Despliegue

1. **Clonar o descargar el proyecto:**

```bash
cd link-shortener-app
```

2. **Construir y levantar los servicios:**

```bash
docker-compose up --build
```

Este comando:
- Construye las imágenes Docker para frontend y backend
- Descarga la imagen de Redis
- Crea la red virtual `link-shortener-network`
- Levanta los tres servicios en orden (redis → backend → frontend)

3. **Acceder a la aplicación:**

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:5000
- **Redis:** localhost:6379

### Modo Desarrollo (con hot-reload)

Si quieres desarrollo con recarga automática, modifica el `docker-compose.yml`:

```yaml
# Para backend, agregar volumen:
volumes:
  - ./backend/app:/app/app

# Para frontend, cambiar el build y agregar volumen:
command: npm run dev
volumes:
  - ./frontend/src:/app/src
```

### Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f backend

# Detener los servicios
docker-compose down

# Detener y eliminar volúmenes (limpieza completa)
docker-compose down -v

# Reconstruir solo un servicio
docker-compose up -d --build frontend

# Verificar salud de los servicios
docker-compose ps
```

## Pruebas

### Probar el Backend directamente

```bash
# Health check
curl http://localhost:5000/health

# Acortar una URL
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com/anthropics/claude-code"}'

# Obtener estadísticas (reemplaza ABC123 con tu código)
curl http://localhost:5000/stats/ABC123
```

### Probar el Frontend

1. Abre http://localhost:5173 en tu navegador
2. Pega una URL larga (ej: https://www.youtube.com/watch?v=dQw4w9WgXcQ)
3. Haz clic en "Shorten URL"
4. Copia el enlace corto generado
5. Prueba el enlace corto en una nueva pestaña

## Solución de Problemas

### El frontend no puede conectarse al backend

**Problema:** Error de CORS o "Failed to fetch"

**Solución:** Verifica que el backend esté corriendo y que la variable `VITE_BACKEND_URL` apunte a `http://localhost:5000`

### Redis no se conecta

**Problema:** "Connection refused" en logs del backend

**Solución:**
```bash
# Verificar que Redis esté healthy
docker-compose ps

# Si no está healthy, revisar logs
docker-compose logs redis
```

### Puerto ya en uso

**Problema:** "Bind for 0.0.0.0:5173 failed: port is already allocated"

**Solución:** Cambia los puertos en `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # En lugar de 5173:80
```

## Arquitectura C4

### Nivel de Contenedor

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Frontend   │─────▶│   Backend   │─────▶│    Redis    │
│  (React)    │      │   (Flask)   │      │   (Cache)   │
│   :5173     │      │    :5000    │      │    :6379    │
└─────────────┘      └─────────────┘      └─────────────┘
```

### Flujo de Datos

1. Usuario ingresa URL larga en el frontend
2. Frontend envía POST a `/shorten`
3. Backend genera código corto (SHA-256 truncado)
4. Backend verifica colisiones en Redis
5. Backend almacena mapeo bidireccional en Redis
6. Backend devuelve URL corta al frontend
7. Usuario copia y comparte el enlace corto
8. Cuando alguien visita el enlace corto, backend redirecciona (302) a la URL original

## Mejoras Futuras

- [ ] Agregar autenticación de usuarios
- [ ] Dashboard de analítica (clicks, geolocalización)
- [ ] Custom short codes (slugs personalizados)
- [ ] QR code generation
- [ ] Rate limiting con Redis
- [ ] Integración con CDN
- [ ] Tests automatizados (Jest, Pytest)

## Licencia

Proyecto académico - Uso libre para fines educativos.
