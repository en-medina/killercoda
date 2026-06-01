## 🚀 Parte 1: Construir Backend (Flask) - Enfoque Básico

### Paso 1.1: Examinar el Código del Backend

```bash
cd ~/code/apps/backend
ls -la
# Verás: app/ requirements.txt
```{{exec}}

### Paso 1.2: Crear Dockerfile Básico (Sin Optimizar)

Crea `Dockerfile.basic`:

```dockerfile
FROM python:3.11

# Copiar todo el código
COPY . /app
WORKDIR /app

# Instalar dependencias
RUN pip install -r requirements.txt

# Exponer puerto
EXPOSE 5000

# Comando de inicio
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:create_app()"]
```{{copy}}

### Paso 1.3: Construir y Verificar Tamaño

```bash
# Construir imagen
docker build -f Dockerfile.basic -t link-backend:basic .

# Verificar tamaño
docker images | grep link-backend

# Debería mostrar ~1 GB (muy pesado)
```

**❌ Problemas de este enfoque:**
- Imagen de ~1 GB
- Incluye herramientas de build innecesarias
- Cache no optimizado
- Se ejecuta como root (inseguro)
