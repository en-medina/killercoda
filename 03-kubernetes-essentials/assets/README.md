# Kubernetes Essentials Lab Assets

This directory contains the application code and Kubernetes manifests for the lab.

## Structure

- **apps/backend**: Flask backend application
- **apps/frontend**: React/Vite frontend application
- **manifests/**: Kubernetes manifests (created during lab exercises)

## Application Components

The same Link Shortener application from Lab 02 (Docker Compose), now deployed to Kubernetes with:

- **Deployments** for managing Pods
- **Services** for networking
- **ConfigMaps** and **Secrets** for configuration
- **PersistentVolumeClaims** for storage

## Kubernetes Resources Created

During the lab, you will create these manifests:

1. `01-namespace.yaml` - Namespace for the application
2. `02-redis-pvc.yaml` - PersistentVolumeClaim for Redis
3. `03-redis-deployment.yaml` - Redis Deployment
4. `04-redis-service.yaml` - Redis Service (ClusterIP)
5. `05-backend-configmap.yaml` - Backend configuration
6. `06-backend-secret.yaml` - Backend secrets
7. `07-backend-deployment.yaml` - Backend Deployment (3 replicas)
8. `08-backend-service.yaml` - Backend Service (NodePort)
9. `09-frontend-deployment.yaml` - Frontend Deployment (2 replicas)
10. `10-frontend-service.yaml` - Frontend Service (NodePort)
11. `11-backend-hpa.yaml` - Horizontal Pod Autoscaler (optional)

## Usage in Lab

These assets are automatically copied to `~/code` in the Killercoda environment.
