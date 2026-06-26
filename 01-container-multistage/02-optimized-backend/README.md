## 🔧 Parte 2: Optimizar con Multi-Stage Build

### Paso 2.1: Crear Dockerfile Optimizado

Crea `Dockerfile.optimized`:

```bash
cat << 'EOF' > Dockerfile.optimized
# ============================================
# Stage 1: Builder (Instalar dependencias)
# ============================================
FROM python:3.11-slim AS builder

# Instalar dependencias de compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Crear virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copiar solo requirements primero (optimización de cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ============================================
# Stage 2: Runtime (Imagen final mínima)
# ============================================
FROM python:3.11-slim

# Crear usuario no-root
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copiar virtualenv desde el builder
COPY --from=builder /opt/venv /opt/venv

# Copiar código de la aplicación
WORKDIR /app
COPY app/ ./app/

# Configurar variables de entorno
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health').read()"

# Comando de inicio
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:create_app()"]
EOF
```{{exec}}

### Paso 2.2: Crear .dockerignore

Crea `.dockerignore` para excluir archivos innecesarios:

```bash
cat << 'EOF' > .dockerignore
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info/
.pytest_cache/
.coverage
htmlcov/
.venv/
venv/
ENV/
.git/
.gitignore
README.md
*.md
.DS_Store
EOF
```{{exec}}

### Paso 2.3: Construir y Comparar

```bash
docker build -f Dockerfile.optimized -t link-backend:optimized . # Construir imagen optimizada
docker images | grep link-backend # Comparar tamaños
```
**Resultado esperado:**
- link-backend:basic      ~1000 MB
- link-backend:optimized  ~180 MB

**✅ Mejoras logradas:**
- Reducción de tamaño: ~82%
- Usuario no-root (más seguro)
- Cache optimizado (rebuilds más rápidos)
- Health check incluido