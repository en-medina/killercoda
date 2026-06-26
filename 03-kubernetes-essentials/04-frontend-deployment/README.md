## 🎨 Parte 4: Desplegar Frontend

### Paso 4.1: Crear Frontend Deployment

Crea `~/code/manifests/09-frontend-deployment.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/09-frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: linkshortener
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: link-frontend:v1
        imagePullPolicy: Never
        env:
        - name: VITE_BACKEND_URL
          value: http://backend.linkshortener.svc.cluster.local:5000
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 10
EOF
```{{exec}}

**Diferencias con Backend:**
- **replicas: 2:** Solo 2 réplicas (frontend es más ligero)
- **Menos recursos:** Frontend estático consume menos CPU/memoria
- **No ConfigMap/Secret:** La configuración está en la imagen (build-time)

Aplicar:

```bash
kubectl apply -f ~/code/manifests/09-frontend-deployment.yaml

# Verificar
kubectl get deployment frontend -n linkshortener

# Ver pods
kubectl get pods -n linkshortener -l app=frontend
```{{exec}}

### Paso 4.2: Crear Frontend Service

Crea `~/code/manifests/10-frontend-service.yaml`:

```bash
cat << 'EOF' > ~/code/manifests/10-frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: linkshortener
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
EOF
```{{exec}}

Aplicar:

```bash
kubectl apply -f ~/code/manifests/10-frontend-service.yaml

# Verificar
kubectl get service frontend -n linkshortener
```{{exec}}

### Paso 4.3: Ver Todos los Recursos

```bash
# Ver todos los recursos en el namespace
kubectl get all -n linkshortener

# Ver de forma más detallada
kubectl get pods,svc,deploy -n linkshortener -o wide
```{{exec}}

### Paso 4.4: Verificar Comunicación Inter-Pods

```bash
# Desde un pod del frontend, probar conectividad al backend
FRONTEND_POD=$(kubectl get pods -n linkshortener -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Probar DNS interno
kubectl exec -n linkshortener $FRONTEND_POD -- nslookup backend

# Probar HTTP al backend (via Service)
kubectl exec -n linkshortener $FRONTEND_POD -- wget -qO- http://backend:5000/health
```{{exec}}

✅ El Service DNS funciona: `backend` resuelve a la IP del Service.

### Paso 4.5: Inspeccionar Labels y Selectors

```bash
# Ver labels de pods
kubectl get pods -n linkshortener --show-labels

# Filtrar por label
kubectl get pods -n linkshortener -l app=backend

# Ver labels en diferentes formatos
kubectl get pods -n linkshortener -o json | jq '.items[].metadata.labels'
```{{exec}}

## ✅ Conceptos Aprendidos

- **Labels:** Pares clave-valor para organizar recursos
- **Selectors:** Filtran recursos por labels
- **Service DNS:** Kubernetes proporciona DNS automático para Services
- **Inter-pod communication:** Pods se comunican via Service names

## 🎯 Próximo Paso

En el siguiente paso, probaremos la aplicación completa end-to-end.
