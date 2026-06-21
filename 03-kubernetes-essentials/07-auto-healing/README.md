## 🛠️ Parte 7: Auto-Healing

### Paso 7.1: Entender Auto-Healing

Kubernetes proporciona auto-healing automático:
- Si un Pod muere, el ReplicaSet crea uno nuevo
- Si un contenedor crashea, kubelet lo reinicia
- Si un nodo falla, los Pods se reprograman en otros nodos
- Health checks permiten detección proactiva de problemas

### Paso 7.2: Ver Estado Inicial

```bash
# Listar pods del backend
kubectl get pods -n linkshortener -l app=backend

# Ver número de reinicios
kubectl get pods -n linkshortener -l app=backend -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[0].restartCount}{"\n"}{end}'
```{{exec}}

### Paso 7.3: Eliminar un Pod (Auto-Recreation)

```bash
# Obtener nombre de un pod
BACKEND_POD=$(kubectl get pods -n linkshortener -l app=backend -o jsonpath='{.items[0].metadata.name}')
echo "Deleting pod: $BACKEND_POD"

# En una terminal, observar en tiempo real
# kubectl get pods -n linkshortener -l app=backend -w

# Eliminar el pod
kubectl delete pod $BACKEND_POD -n linkshortener

# Inmediatamente listar pods
kubectl get pods -n linkshortener -l app=backend
```{{exec}}

**Observa:** Kubernetes inmediatamente crea un nuevo pod para mantener 3 réplicas.

### Paso 7.4: Verificar Que el Service Sigue Funcionando

```bash
# Durante la recreación, el service sigue funcionando
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

# Hacer múltiples requests
for i in {1..10}; do
  curl -s http://$NODE_IP:30500/health && echo " - Request $i OK"
  sleep 0.5
done
```{{exec}}

✅ No hubo downtime, las otras 2 réplicas manejaron el tráfico.

### Paso 7.5: Simular Crash de Contenedor

```bash
# Matar el proceso principal dentro del contenedor
BACKEND_POD=$(kubectl get pods -n linkshortener -l app=backend -o jsonpath='{.items[0].metadata.name}')

echo "Killing process in pod: $BACKEND_POD"

# Matar proceso PID 1 (esto crashea el contenedor)
kubectl exec -n linkshortener $BACKEND_POD -- kill 1
```{{exec}}

### Paso 7.6: Observar Reinicio Automático

```bash
# Ver eventos del pod
kubectl describe pod $BACKEND_POD -n linkshortener | grep -A 10 "Events:"

# Ver conteo de reinicios
kubectl get pods -n linkshortener -l app=backend

# Ver logs del contenedor anterior (antes del crash)
kubectl logs $BACKEND_POD -n linkshortener --previous
```{{exec}}

**Observa:** El pod NO se elimina, el contenedor se reinicia in-place.

### Paso 7.7: Simular Fallo en Health Check

Vamos a modificar temporalmente el deployment para que el health check falle:

```bash
# Cambiar liveness probe a un path inexistente
kubectl patch deployment backend -n linkshortener --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/livenessProbe/httpGet/path",
    "value": "/nonexistent"
  }
]'

# Observar pods en tiempo real
kubectl get pods -n linkshortener -l app=backend -w
```{{exec}}

**Observa:** Después de varios fallos del liveness probe, Kubernetes reinicia el contenedor.

### Paso 7.8: Restaurar Health Check

```bash
# Volver a health check correcto
kubectl patch deployment backend -n linkshortener --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/livenessProbe/httpGet/path",
    "value": "/health"
  }
]'

# Esperar a que los pods estén ready
kubectl wait --for=condition=Ready pod -l app=backend -n linkshortener --timeout=120s
```{{exec}}

### Paso 7.9: Probar Resiliencia con Múltiples Fallos

```bash
# Eliminar múltiples pods simultáneamente
kubectl delete pod -l app=backend -n linkshortener --wait=false

# Observar recreación
kubectl get pods -n linkshortener -l app=backend -w
```

En otra terminal:

```bash
# Continuar haciendo requests durante el caos
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

for i in {1..30}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$NODE_IP:30500/health)
  echo "Request $i: HTTP $STATUS - $(date +%H:%M:%S)"
  sleep 1
done
```{{exec}}

**Resultado:** Puede haber algunos errores 503 temporales, pero el servicio se recupera automáticamente.

### Paso 7.10: Ver Estadísticas de Reinicios

```bash
# Ver reinicios por pod
kubectl get pods -n linkshortener -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount,STATUS:.status.phase

# Ver eventos de reinicios
kubectl get events -n linkshortener --field-selector reason=Killing --sort-by='.lastTimestamp' | tail -10
```{{exec}}

### Paso 7.11: Configurar Readiness vs Liveness

**Diferencia importante:**
- **Liveness Probe:** Si falla, reinicia el contenedor
- **Readiness Probe:** Si falla, quita el Pod del Service (no reinicia)

Ver configuración actual:

```bash
kubectl get deployment backend -n linkshortener -o yaml | grep -A 6 "livenessProbe:"
kubectl get deployment backend -n linkshortener -o yaml | grep -A 6 "readinessProbe:"
```{{exec}}

## ✅ Conceptos Aprendidos

- **ReplicaSet:** Mantiene número deseado de réplicas
- **Auto-recreation:** Pods eliminados se recrean automáticamente
- **Container restart:** Contenedores crasheados se reinician in-place
- **Liveness Probe:** Detecta contenedores "vivos" pero rotos
- **Readiness Probe:** Controla cuándo un Pod recibe tráfico
- **Zero-downtime:** Múltiples réplicas permiten mantenimiento sin impacto

## 🎯 Próximo Paso

En el siguiente paso (opcional), aprenderemos sobre escalado manual y automático con HPA.
