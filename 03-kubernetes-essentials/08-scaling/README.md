## 📊 Parte 8: Escalado Manual y Automático (Opcional)

### Paso 8.1: Escalado Manual

El escalado manual ajusta el número de réplicas de un Deployment:

```bash
# Ver réplicas actuales
kubectl get deployment backend -n linkshortener

# Escalar a 5 réplicas
kubectl scale deployment backend --replicas=5 -n linkshortener

# Observar creación de nuevos pods
kubectl get pods -n linkshortener -l app=backend -w
```{{exec}}

```bash
# Verificar 5 réplicas corriendo
kubectl get pods -n linkshortener -l app=backend

# Volver a 3 réplicas
kubectl scale deployment backend --replicas=3 -n linkshortener
```{{exec}}

### Paso 8.2: Horizontal Pod Autoscaler (HPA)

HPA escala automáticamente basándose en métricas (CPU, memoria, custom):

```bash
# Verificar que metrics-server está corriendo
kubectl get deployment metrics-server -n kube-system
```{{exec}}

### Paso 8.3: Crear HPA basado en CPU

```bash
# Crear autoscaler para backend
kubectl autoscale deployment backend \
  --cpu=300m \
  --min=2 \
  --max=10 \
  -n linkshortener

# Verificar HPA
kubectl get hpa -n linkshortener
```{{exec}}

**Configuración:**
- Escala cuando CPU promedio > 50%
- Mínimo 2 réplicas
- Máximo 10 réplicas

### Paso 8.4: Ver Detalles del HPA

```bash
# Detalles del HPA
kubectl describe hpa backend -n linkshortener

# Ver en formato YAML
kubectl get hpa backend -n linkshortener -o yaml
```{{exec}}

### Paso 8.5: Generar Carga para Trigger Autoscaling

```bash
# Instalar herramienta de load testing
kubectl run -n linkshortener load-generator \
  --image=busybox \
  --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://backend:5000/health; done"

# Observar HPA en tiempo real
kubectl get hpa backend -n linkshortener -w
```

En otra terminal:

```bash
# Observar escalado de pods
kubectl get pods -n linkshortener -l app=backend -w
```

### Paso 8.6: Monitorear Uso de CPU

```bash
# Ver uso de CPU de pods
kubectl top pods -n linkshortener -l app=backend

# Ver métricas del HPA
kubectl get hpa backend -n linkshortener
```{{exec}}

**Observa:** Cuando el uso de CPU sube, HPA crea más réplicas.

### Paso 8.7: Detener Load y Ver Scale Down

```bash
# Eliminar generador de carga
kubectl delete pod load-generator -n linkshortener

# Esperar y observar scale down (toma varios minutos)
kubectl get hpa backend -n linkshortener -w
```{{exec}}

**Nota:** Scale down es más lento que scale up para evitar flapping.

### Paso 8.8: HPA con Manifiesto YAML

Crear `~/code/manifests/11-backend-hpa.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/11-backend-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: linkshortener
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
EOF
```{{exec}}

```bash
# Eliminar HPA anterior
kubectl delete hpa backend -n linkshortener

# Aplicar nuevo HPA con configuración avanzada
kubectl apply -f ~/code/manifests/11-backend-hpa.yaml

# Verificar
kubectl get hpa backend-hpa -n linkshortener
```{{exec}}

### Paso 8.9: Ver Historia de Escalado

```bash
# Ver eventos de escalado
kubectl get events -n linkshortener --field-selector involvedObject.name=backend-hpa --sort-by='.lastTimestamp'

# Ver logs del HPA controller
kubectl logs -n kube-system -l app=metrics-server --tail=50
```{{exec}}

### Paso 8.10: Limpieza y Resumen

```bash
# Eliminar HPA
kubectl delete hpa backend-hpa -n linkshortener

# Volver a 3 réplicas fijas
kubectl scale deployment backend --replicas=3 -n linkshortener

# Ver estado final
kubectl get all -n linkshortener
```{{exec}}

## ✅ Conceptos Aprendidos

- **kubectl scale:** Escalado manual declarativo
- **HPA:** Horizontal Pod Autoscaler para escalado automático
- **Metrics Server:** Proporciona métricas de CPU/memoria
- **Scale Up/Down Policies:** Control de velocidad de escalado
- **Stabilization Window:** Previene flapping (cambios frecuentes)
- **Multiple Metrics:** HPA puede usar CPU, memoria, y custom metrics

## 📊 Comparación Docker Compose vs Kubernetes - Resumen

| Feature | Docker Compose | Kubernetes |
|---------|---------------|------------|
| **Deployment** | `docker-compose up` | `kubectl apply -f` |
| **Scaling** | `--scale` manual | Manual + HPA automático |
| **Config** | `.env` + `environment:` | ConfigMaps + Secrets |
| **Storage** | `volumes:` | PVC + PV |
| **Networking** | `networks:` + DNS | Services + DNS + Ingress |
| **Health** | `healthcheck:` | livenessProbe + readinessProbe |
| **Updates** | Manual restart | Rolling updates automáticos |
| **Self-healing** | `restart:` policies | ReplicaSets automático |
| **Load Balancing** | Round-robin básico | Avanzado con Services |
| **Multi-host** | ❌ | ✅ |

## 🎉 ¡Laboratorio Completado!

Has migrado exitosamente una aplicación de Docker Compose a Kubernetes y aprendido los conceptos fundamentales de orquestación de contenedores.
