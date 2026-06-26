## 📦 Parte 2: Desplegar Redis con Almacenamiento Persistente

### Paso 2.1: Entender PersistentVolumeClaims

En Kubernetes, los datos en Pods son efímeros por defecto. Para persistencia, usamos:
- **PersistentVolume (PV):** Almacenamiento físico en el cluster
- **PersistentVolumeClaim (PVC):** Solicitud de almacenamiento por parte de una aplicación

### Paso 2.2: Crear PersistentVolumeClaim

Crea `~/code/manifests/02-redis-pvc.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/02-redis-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: linkshortener
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
EOF
```{{exec}}

**Explicación:**
- **ReadWriteOnce:** El volumen puede ser montado como lectura-escritura por un solo nodo
- **storage: 1Gi:** Solicita 1GB de espacio
- **storageClassName:** Clase de almacenamiento (el cluster provisionará automáticamente)

Aplicar el PVC:

```bash
kubectl apply -f ~/code/manifests/02-redis-pvc.yaml

# Verificar
kubectl get pvc -n linkshortener

# Ver detalles
kubectl describe pvc redis-pvc -n linkshortener
```{{exec}}

### Paso 2.3: Crear Redis Deployment

Crea `~/code/manifests/03-redis-deployment.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/03-redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: linkshortener
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - name: redis-storage
          mountPath: /data
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "250m"
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-pvc
EOF
```{{exec}}

**Explicación:**
- **replicas: 1:** Solo una instancia de Redis (stateful, no necesitamos múltiples réplicas aquí)
- **livenessProbe:** Verifica si el contenedor está vivo (reinicia si falla)
- **readinessProbe:** Verifica si el contenedor está listo para recibir tráfico
- **resources:** Límites y requests de CPU/memoria

Aplicar el Deployment:

```bash
kubectl apply -f ~/code/manifests/03-redis-deployment.yaml

# Verificar estado del deployment
kubectl get deployment redis -n linkshortener

# Ver pods
kubectl get pods -n linkshortener -l app=redis

# Ver logs
kubectl logs -n linkshortener -l app=redis
```

### Paso 2.4: Crear Redis Service

Los Pods tienen IPs dinámicas. Un Service proporciona un punto de acceso estable:

Crea `~/code/manifests/04-redis-service.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/04-redis-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: linkshortener
spec:
  type: ClusterIP
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
    protocol: TCP
EOF
```{{exec}}

**Explicación:**
- **type: ClusterIP:** Solo accesible dentro del cluster (no necesitamos acceso externo a Redis)
- **selector:** Conecta el Service a Pods con label `app=redis`
- **port:** Puerto expuesto por el Service
- **targetPort:** Puerto en el contenedor

Aplicar el Service:

```bash
kubectl apply -f ~/code/manifests/04-redis-service.yaml

# Verificar
kubectl get service redis -n linkshortener

# Ver endpoints (IPs de pods)
kubectl get endpoints redis -n linkshortener
```

### Paso 2.5: Probar Conectividad a Redis

```bash
# Obtener nombre del pod de Redis
REDIS_POD=$(kubectl get pods -n linkshortener -l app=redis -o jsonpath='{.items[0].metadata.name}')

echo "Redis pod: $REDIS_POD"

# Ejecutar comando dentro del pod
kubectl exec -n linkshortener $REDIS_POD -- redis-cli ping

# Probar comando SET/GET
kubectl exec -n linkshortener $REDIS_POD -- redis-cli SET test "Hello Kubernetes"
kubectl exec -n linkshortener $REDIS_POD -- redis-cli GET test
```

### Paso 2.6: Verificar Persistencia

```bash
# Guardar dato en Redis
kubectl exec -n linkshortener $REDIS_POD -- redis-cli SET persistent-key "This should survive"

# Eliminar el pod (Deployment lo recreará)
kubectl delete pod $REDIS_POD -n linkshortener

# Esperar a que el nuevo pod esté listo
kubectl wait --for=condition=Ready pod -l app=redis -n linkshortener --timeout=60s

# Obtener nuevo pod
NEW_REDIS_POD=$(kubectl get pods -n linkshortener -l app=redis -o jsonpath='{.items[0].metadata.name}')

echo "New Redis pod: $NEW_REDIS_POD"

# Verificar que el dato persiste
kubectl exec -n linkshortener $NEW_REDIS_POD -- redis-cli GET persistent-key
```{{exec}}

✅ El dato persiste porque está almacenado en el PVC, no en el Pod efímero.

## ✅ Conceptos Aprendidos

- **Deployment:** Gestiona ReplicaSets y mantiene el estado deseado
- **PVC:** Solicitud de almacenamiento persistente
- **Service:** Abstracción para acceso de red a Pods
- **Probes:** Liveness (reinicio) y Readiness (tráfico)
- **Labels y Selectors:** Conectan Services y Deployments con Pods

## 🎯 Próximo Paso

En el siguiente paso, desplegaremos el Backend con ConfigMaps y Secrets.
