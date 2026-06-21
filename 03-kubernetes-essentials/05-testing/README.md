## 🧪 Parte 5: Probar la Aplicación

### Paso 5.1: Obtener URLs de Acceso

```bash
# Obtener IP del nodo
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

echo "Node IP: $NODE_IP"
echo "Frontend URL: http://$NODE_IP:30080"
echo "Backend URL: http://$NODE_IP:30500"
```{{exec}}

### Paso 5.2: Probar Backend API

```bash
# Health check
curl http://$NODE_IP:30500/health

# Crear URL corta
RESPONSE=$(curl -s -X POST http://$NODE_IP:30500/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://kubernetes.io/docs"}')

echo "Response: $RESPONSE"

# Extraer short_code
SHORT_CODE=$(echo $RESPONSE | jq -r '.short_code')
echo "Short code: $SHORT_CODE"

# Probar redirect
curl -I http://$NODE_IP:30500/$SHORT_CODE | grep Location
```{{exec}}

### Paso 5.3: Probar Frontend

```bash
# Acceder al frontend
curl http://$NODE_IP:30080

# Ver headers
curl -I http://$NODE_IP:30080
```{{exec}}

**Nota:** Para ver la interfaz gráfica completa, accede a la URL en tu navegador.

### Paso 5.4: Load Balancing del Backend

Kubernetes automáticamente balancea carga entre las 3 réplicas del backend:

```bash
# Crear múltiples URLs y ver qué pod las maneja
for i in {1..10}; do
  RESPONSE=$(curl -s -X POST http://$NODE_IP:30500/shorten \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"https://example.com/page$i\"}")
  echo "Request $i: $(echo $RESPONSE | jq -r '.short_code')"
done
```{{exec}}

Ver logs de diferentes pods para confirmar distribución:

```bash
# Ver logs de todos los pods del backend
kubectl logs -n linkshortener -l app=backend --tail=5 --prefix=true
```{{exec}}

### Paso 5.5: Probar Persistencia de Datos

```bash
# Crear URL corta
RESPONSE=$(curl -s -X POST http://$NODE_IP:30500/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://persistent-test.com"}')

SHORT_CODE=$(echo $RESPONSE | jq -r '.short_code')
echo "Created: $SHORT_CODE"

# Eliminar el pod de Redis
REDIS_POD=$(kubectl get pods -n linkshortener -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $REDIS_POD -n linkshortener

# Esperar a que el nuevo pod esté listo
echo "Waiting for new Redis pod..."
kubectl wait --for=condition=Ready pod -l app=redis -n linkshortener --timeout=60s

# Verificar que los datos persisten
curl -I http://$NODE_IP:30500/$SHORT_CODE | grep Location
echo "✅ Data persisted across Redis pod restart!"
```{{exec}}

### Paso 5.6: Ver Estadísticas del Cluster

```bash
# Ver uso de recursos
kubectl top nodes
kubectl top pods -n linkshortener

# Ver eventos recientes
kubectl get events -n linkshortener --sort-by='.lastTimestamp' | tail -10
```{{exec}}

### Paso 5.7: Inspeccionar un Pod Específico

```bash
BACKEND_POD=$(kubectl get pods -n linkshortener -l app=backend -o jsonpath='{.items[0].metadata.name}')

# Ver detalles completos
kubectl describe pod $BACKEND_POD -n linkshortener

# Ver configuración en YAML
kubectl get pod $BACKEND_POD -n linkshortener -o yaml | head -50
```{{exec}}

## ✅ Validación Completa

Verifica que tu aplicación tiene:

- ✅ 3 réplicas de backend corriendo
- ✅ 2 réplicas de frontend corriendo
- ✅ 1 réplica de Redis con PVC
- ✅ Services expuestos correctamente
- ✅ Load balancing funcionando
- ✅ Datos persistentes en Redis
- ✅ Health checks pasando

```bash
# Comando para verificar todo
kubectl get all,pvc,configmap,secret -n linkshortener
```{{exec}}

## 🎯 Próximo Paso

En el siguiente paso, aprenderemos sobre rolling updates y rollbacks.
