## 🔧 Parte 3: Desplegar Backend con ConfigMap y Secrets

### Paso 3.1: Crear ConfigMap para Configuración

ConfigMaps almacenan configuración no sensible que puede ser inyectada en Pods:

Crea `~/code/manifests/05-backend-configmap.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/05-backend-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: linkshortener
data:
  REDIS_HOST: "redis"
  REDIS_PORT: "6379"
  FLASK_ENV: "production"
  LOG_LEVEL: "info"
EOF
```{{exec}}

Aplicar:

```bash
kubectl apply -f ~/code/manifests/05-backend-configmap.yaml

# Verificar
kubectl get configmap backend-config -n linkshortener

# Ver contenido
kubectl describe configmap backend-config -n linkshortener
```{{exec}}

### Paso 3.2: Crear Secret para Datos Sensibles

Secrets son similares a ConfigMaps pero para información confidencial:

Crea `~/code/manifests/06-backend-secret.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/06-backend-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
  namespace: linkshortener
type: Opaque
data:
  # base64 encoded values
  # echo -n "supersecretkey" | base64
  SECRET_KEY: c3VwZXJzZWNyZXRrZXk=
EOF
```{{exec}}

**Nota:** Los valores en Secrets deben estar codificados en base64.

Aplicar:

```bash
kubectl apply -f ~/code/manifests/06-backend-secret.yaml

# Verificar
kubectl get secret backend-secret -n linkshortener

# Ver (valores ocultos por defecto)
kubectl describe secret backend-secret -n linkshortener
```{{exec}}

### Paso 3.3: Crear Backend Deployment

Crea `~/code/manifests/07-backend-deployment.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/07-backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: linkshortener
  labels:
    app: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: link-backend:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 5000
          name: http
        envFrom:
        - configMapRef:
            name: backend-config
        env:
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: SECRET_KEY
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
EOF
```{{exec}}

**Características clave:**
- **replicas: 3:** Tres instancias para alta disponibilidad
- **envFrom:** Inyecta todas las variables del ConfigMap
- **env:** Inyecta variables específicas del Secret
- **imagePullPolicy: Never:** Usa imagen local (no intenta descargar)

Aplicar:

```bash
kubectl apply -f ~/code/manifests/07-backend-deployment.yaml

# Verificar deployment
kubectl get deployment backend -n linkshortener

# Ver pods (deberían ser 3)
kubectl get pods -n linkshortener -l app=backend

# Ver logs de un pod
kubectl logs -n linkshortener -l app=backend --tail=20
```

### Paso 3.4: Verificar Variables de Entorno

```bash
# Obtener nombre de un pod del backend
BACKEND_POD=$(kubectl get pods -n linkshortener -l app=backend -o jsonpath='{.items[0].metadata.name}')

echo "Backend pod: $BACKEND_POD"

# Ver variables de entorno
kubectl exec -n linkshortener $BACKEND_POD -- env | grep -E "REDIS_HOST|FLASK_ENV|SECRET_KEY"
```{{exec}}

✅ Las variables del ConfigMap y Secret están inyectadas correctamente.

### Paso 3.5: Crear Backend Service

Crea `~/code/manifests/08-backend-service.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/08-backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: linkshortener
spec:
  type: NodePort
  selector:
    app: backend
  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30500
    protocol: TCP
EOF
```{{exec}}

**Explicación:**
- **type: NodePort:** Expone el servicio externamente en un puerto del nodo
- **nodePort: 30500:** Puerto específico en el nodo (rango 30000-32767)

Aplicar:

```bash
kubectl apply -f ~/code/manifests/08-backend-service.yaml

# Verificar
kubectl get service backend -n linkshortener

# Ver endpoints (debería mostrar 3 IPs, una por cada réplica)
kubectl get endpoints backend -n linkshortener
```{{exec}}

### Paso 3.6: Probar el Backend

```bash
# Obtener IP del nodo
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

# Probar health endpoint
curl http://$NODE_IP:30500/health

# Crear URL corta
curl -X POST http://$NODE_IP:30500/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://kubernetes.io"}'
```{{exec}}

### Paso 3.7: Ver Distribución de Pods

```bash
# Ver en qué nodos están los pods
kubectl get pods -n linkshortener -o wide

# Ver detalles de un pod
kubectl describe pod $BACKEND_POD -n linkshortener | grep -A 5 "Containers:"
```{{exec}}

## ✅ Conceptos Aprendidos

- **ConfigMap:** Configuración no sensible desacoplada del código
- **Secret:** Datos sensibles codificados en base64
- **envFrom:** Inyectar múltiples variables de una vez
- **NodePort:** Tipo de Service para acceso externo
- **Réplicas:** Múltiples instancias para disponibilidad y escalabilidad

## 🎯 Próximo Paso

En el siguiente paso, desplegaremos el Frontend y completaremos la aplicación.
