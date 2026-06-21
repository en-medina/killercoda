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

### Paso 1.5 Cargar las imagenes al Container Runtime Interface
En Kubernetes, los contenedores no se ejecutan directamente desde Docker, sino desde un container runtime (en este caso normalmente containerd). Esto significa que, aunque hayas construido las imágenes con docker build, el cluster no siempre puede verlas automáticamente.

Para que el cluster pueda usar estas imágenes locales en este laboratorio, debemos importarlas al runtime del nodo.

```
# Exportar imágenes desde Docker
docker save link-backend:v1 -o backend.tar
docker save link-frontend:v1 -o frontend.tar

# Importarlas en containerd (Kubernetes runtime en KillerCoda)
sudo ctr -n=k8s.io images import backend.tar
sudo ctr -n=k8s.io images import frontend.tar

# Verificar que fueron cargadas
sudo ctr -n=k8s.io images ls | grep link
```{{exec}}


**Nota:** En un cluster Kubernetes real, usarías un container registry (Docker Hub, GCR, ECR). Para este lab, las imagenes estarán disponibles de manera local

### Paso 1.6: Conceptos Básicos de Kubectl

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
