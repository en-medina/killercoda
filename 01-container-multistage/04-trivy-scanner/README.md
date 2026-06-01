## 🔒 Parte 4: Escaneo de Vulnerabilidades

### Paso 4.1: Escanear Backend

```bash
# Escanear imagen optimizada
trivy image link-backend:optimized

# Ver solo vulnerabilidades HIGH y CRITICAL
trivy image --severity HIGH,CRITICAL link-backend:optimized
```

**Interpretación:**
- **LOW:** Informativas, baja prioridad
- **MEDIUM:** Revisar en próximas actualizaciones
- **HIGH:** Parchear pronto
- **CRITICAL:** Requiere acción inmediata

### Paso 4.2: Escanear Frontend

```bash
trivy image link-frontend:optimized
```

**Nota:** Alpine suele tener menos vulnerabilidades que imágenes Debian/Ubuntu.

### Paso 4.3: Generar Reporte en JSON

```bash
# Backend
trivy image --format json --output /opt/backend-scan.json link-backend:optimized

# Frontend
trivy image --format json --output /opt/frontend-scan.json link-frontend:optimized

# Ver resumen
cat backend-scan.json | jq '.Results[].Vulnerabilities | length'
```