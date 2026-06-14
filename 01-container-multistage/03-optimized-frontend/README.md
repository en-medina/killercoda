## 🖼️ Parte 3: Optimizar Frontend (React/Nginx)

### Paso 3.1: Ir al Directorio Frontend

```bash
cd ~/code/apps/frontend
```{{exec}}

### Paso 3.2: Crear Dockerfile Multi-Stage

Crea `Dockerfile.optimized`:

```dockerfile
# ============================================
# Stage 1: Builder (Build de React)
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package files primero (cache optimization)
COPY package.json package-lock.json ./
RUN npm ci --silent

# Copiar código fuente
COPY . .

# Build de producción
RUN npm run build

# ============================================
# Stage 2: Runtime (Nginx)
# ============================================
FROM nginx:alpine

# Copiar configuración custom de Nginx
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /health { \
        access_log off; \
        return 200 "healthy\n"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copiar assets buildeados desde el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:80/health || exit 1

# Nginx se ejecuta en foreground por defecto
CMD ["nginx", "-g", "daemon off;"]
```{{copy}}

### Paso 3.3: Crear .dockerignore

Crea `.dockerignore` para excluir archivos innecesarios:

```
node_modules/
dist/
.vite/
coverage/
.env.local
.env.*.local
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.git/
.gitignore
README.md
*.md
.DS_Store
```{{copy}}

### Paso 3.4: Construir y Verificar

```bash
# Construir
docker build -f Dockerfile.optimized -t link-frontend:optimized .

# Verificar tamaño
docker images | grep link-frontend

# Resultado esperado: ~50 MB (increíblemente pequeño)
```