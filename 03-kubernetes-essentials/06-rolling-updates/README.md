## 🔄 Parte 6: Rolling Updates y Rollbacks

### Paso 6.1: Entender Rolling Updates

Kubernetes permite actualizar aplicaciones sin downtime mediante rolling updates:
- Reemplaza Pods gradualmente
- Mantiene réplicas mínimas disponibles
- Rollback automático si algo falla

### Paso 6.2: Ver Estrategia Actual

```bash
# Ver estrategia de update del backend
kubectl describe deployment backend -n linkshortener | grep -A 5 "Strategy"

# Ver en formato YAML
kubectl get deployment backend -n linkshortener -o yaml | grep -A 10 "strategy:"
```{{exec}}

**RollingUpdate default:**
- `maxUnavailable: 25%` - máximo 25% de pods pueden estar down durante update
- `maxSurge: 25%` - máximo 25% de pods extra durante update

### Paso 6.3: Simular Cambio en la Aplicación

Vamos a "actualizar" el backend construyendo una nueva versión:

```bash
# Simular cambio en código (agregar label a la imagen)
cd ~/code/apps/backend
docker build -t link-backend:v2 .

# Verificar nueva imagen
docker images | grep link-backend
```{{exec}}

### Paso 6.4: Actualizar el Deployment

Hay varias formas de actualizar:

**Opción 1: Usar kubectl set image**

```bash
# Actualizar imagen
kubectl set image deployment/backend \
  backend=link-backend:v2 \
  -n linkshortener

# Monitorear el rollout en tiempo real
kubectl rollout status deployment/backend -n linkshortener
```{{exec}}

**Observa:** Kubernetes reemplaza pods uno por uno, manteniendo la disponibilidad.

### Paso 6.5: Monitorear el Rolling Update

Abre otra terminal y observa los cambios:

```bash
# Observar pods en tiempo real
kubectl get pods -n linkshortener -l app=backend -w
```

En la terminal original:

```bash
# Ver estado del rollout
kubectl rollout status deployment/backend -n linkshortener

# Ver historia de revisiones
kubectl rollout history deployment/backend -n linkshortener
```{{exec}}

### Paso 6.6: Verificar Nueva Versión

```bash
# Ver imagen actual de los pods
kubectl get pods -n linkshortener -l app=backend -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# Ver detalles del deployment
kubectl describe deployment backend -n linkshortener | grep Image
```{{exec}}

### Paso 6.7: Rollback a Versión Anterior

Si la nueva versión tiene problemas, puedes hacer rollback:

```bash
# Rollback a versión anterior
kubectl rollout undo deployment/backend -n linkshortener

# Monitorear rollback
kubectl rollout status deployment/backend -n linkshortener

# Verificar versión
kubectl get pods -n linkshortener -l app=backend -o jsonpath='{.items[0].spec.containers[0].image}'
```{{exec}}

### Paso 6.8: Rollback a Revisión Específica

```bash
# Ver historial detallado
kubectl rollout history deployment/backend -n linkshortener

# Ver detalles de una revisión específica
kubectl rollout history deployment/backend -n linkshortener --revision=1

# Rollback a revisión específica
kubectl rollout undo deployment/backend --to-revision=1 -n linkshortener
```{{exec}}

### Paso 6.9: Pausar y Resumir un Rollout

```bash
# Actualizar y pausar inmediatamente
kubectl set image deployment/backend backend=link-backend:v2 -n linkshortener
kubectl rollout pause deployment/backend -n linkshortener

# Ver estado (algunos pods actualizados, otros no)
kubectl get pods -n linkshortener -l app=backend -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# Resumir rollout
kubectl rollout resume deployment/backend -n linkshortener
kubectl rollout status deployment/backend -n linkshortener
```{{exec}}

### Paso 6.10: Configurar Estrategia Personalizada

Edita el deployment para usar estrategia más conservadora:

```bash
kubectl edit deployment backend -n linkshortener
```

Cambia la estrategia a:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Solo 1 pod down a la vez
      maxSurge: 1        # Solo 1 pod extra a la vez
```

O aplica via patch:

```bash
kubectl patch deployment backend -n linkshortener -p '{"spec":{"strategy":{"rollingUpdate":{"maxUnavailable":1,"maxSurge":1}}}}'
```{{exec}}

### Paso 6.11: Probar Update Sin Downtime

```bash
# Terminal 1: Generar tráfico continuo
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

while true; do
  curl -s http://$NODE_IP:30500/health && echo " - $(date +%H:%M:%S)"
  sleep 1
done
```

En otra terminal:

```bash
# Terminal 2: Aplicar update
kubectl set image deployment/backend backend=link-backend:v2 -n linkshortener
```

**Observa:** El tráfico continúa sin interrupciones durante el update.

## ✅ Conceptos Aprendidos

- **Rolling Update:** Actualización gradual sin downtime
- **Rollback:** Revertir a versión anterior
- **Revision History:** Historial de cambios del deployment
- **maxUnavailable/maxSurge:** Control de velocidad del rollout
- **Pause/Resume:** Control manual del proceso de actualización

## 🎯 Próximo Paso

En el siguiente paso, probaremos las capacidades de auto-healing de Kubernetes.
