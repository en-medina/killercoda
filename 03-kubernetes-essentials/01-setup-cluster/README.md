## 🚀 Parte 1: Setup del Cluster

### Paso 1.1: Verificar el Cluster

El cluster Kubernetes ya está iniciado. Vamos a verificar su estado:

```bash
# Ver información del cluster
kubectl cluster-info

# Ver nodos disponibles
kubectl get nodes

# Ver componentes del sistema
kubectl get pods -n kube-system
```{{exec}}

**Nota:** Este es un cluster de un solo nodo (control-plane) que también puede ejecutar workloads de aplicación.

### Paso 1.2: Explorar Namespaces

Los namespaces permiten organizar recursos en grupos lógicos:

```bash
# Listar namespaces existentes
kubectl get namespaces

# Ver recursos en el namespace default
kubectl get all
```{{exec}}

### Paso 1.3: Crear Namespace para la Aplicación

Crea `~/code/manifests/01-namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: linkshortener
  labels:
    app: linkshortener
    env: dev
```{{copy}}

Aplicar el namespace:

```bash
kubectl apply -f ~/code/manifests/01-namespace.yaml

# Verificar
kubectl get namespace linkshortener

# Ver detalles
kubectl describe namespace linkshortener
```{{exec}}

### Paso 1.4: Construir Imágenes Docker

Necesitamos construir las imágenes de nuestra aplicación en el cluster:

```bash
# Construir backend
cd ~/code/apps/backend
docker build -t link-backend:v1 .

# Construir frontend
cd ~/code/apps/frontend
docker build -t link-frontend:v1 .

# Verificar imágenes
docker images | grep link-
```{{exec}}

**Nota:** En un cluster Kubernetes real, usarías un container registry (Docker Hub, GCR, ECR). Para este lab, las imágenes están disponibles localmente.

### Paso 1.5: Conceptos Básicos de Kubectl

```bash
# Sintaxis general
# kubectl [command] [TYPE] [NAME] [flags]

# Comandos comunes
kubectl get       # Listar recursos
kubectl describe  # Mostrar detalles
kubectl apply     # Aplicar configuración
kubectl delete    # Eliminar recursos
kubectl logs      # Ver logs
kubectl exec      # Ejecutar comando en pod

# Ejemplos con namespace
kubectl get pods -n linkshortener
kubectl get all -n linkshortener
```

## ✅ Conceptos Aprendidos

- **Cluster:** Conjunto de nodos que ejecutan aplicaciones containerizadas
- **Node:** Máquina worker que ejecuta Pods
- **Namespace:** Aislamiento lógico de recursos
- **kubectl:** CLI para interactuar con Kubernetes

## 🎯 Próximo Paso

En el siguiente paso, desplegaremos Redis con almacenamiento persistente usando PersistentVolumeClaims.
