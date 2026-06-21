# Lab 03: Kubernetes Essentials - Complete Summary

## Overview

Migrates the Link Shortener application from Docker Compose to Kubernetes, teaching fundamental Kubernetes concepts through hands-on exercises.

## Structure

```
03-kubernetes-essentials/
├── index.json                     # Killercoda config (kubernetes-kubeadm-1node backend)
├── README.md                      # Lab introduction
├── FINISH.md                      # Completion summary
├── 00-init/                       # Environment setup
├── 01-setup-cluster/              # Verify cluster, build images
├── 02-redis-deployment/           # PVC + Deployment + Service
├── 03-backend-deployment/         # ConfigMap + Secret + Deployment + Service
├── 04-frontend-deployment/        # Deployment + Service
├── 05-testing/                    # End-to-end testing
├── 06-rolling-updates/            # Updates and rollbacks
├── 07-auto-healing/               # Self-healing demonstrations
├── 08-scaling/                    # Manual and HPA (optional)
└── assets/
    ├── apps/                      # Backend + Frontend source
    └── manifests/                 # Empty (created during lab)
```

## Learning Path

### Part 1: Setup (10 min)
- Verify Kubernetes cluster
- Create namespace
- Build Docker images locally

### Part 2: Redis (15 min)
- PersistentVolumeClaim for storage
- Redis Deployment with health checks
- ClusterIP Service
- Test persistence

### Part 3: Backend (20 min)
- ConfigMap for configuration
- Secret for sensitive data
- Deployment with 3 replicas
- NodePort Service for external access

### Part 4: Frontend (15 min)
- Deployment with 2 replicas
- NodePort Service
- Verify inter-pod communication

### Part 5: Testing (15 min)
- Access application via NodePort
- Test API endpoints
- Verify load balancing
- Test data persistence

### Part 6: Rolling Updates (15 min)
- Build v2 image
- Perform rolling update
- Rollback to previous version
- Configure update strategy

### Part 7: Auto-Healing (15 min)
- Delete pods (auto-recreation)
- Kill container processes (auto-restart)
- Simulate health check failures
- Verify zero-downtime

### Part 8: Scaling (15 min, optional)
- Manual scaling
- Horizontal Pod Autoscaler
- Load testing
- Scale-up and scale-down policies

## Key Kubernetes Manifests

11 manifest files created during exercises:
1. Namespace
2. Redis PVC
3. Redis Deployment
4. Redis Service
5. Backend ConfigMap
6. Backend Secret
7. Backend Deployment
8. Backend Service
9. Frontend Deployment
10. Frontend Service
11. Backend HPA (optional)

## Technical Specifications

**Backend:**
- Image: link-backend:v1
- Replicas: 3
- Resources: 128Mi-512Mi memory, 100m-500m CPU
- Health checks: /health endpoint
- Service: NodePort 30500

**Frontend:**
- Image: link-frontend:v1
- Replicas: 2
- Resources: 64Mi-128Mi memory, 50m-200m CPU
- Service: NodePort 30080

**Redis:**
- Image: redis:7-alpine
- Replicas: 1
- Storage: 1Gi PVC
- Service: ClusterIP (internal only)

## Duration

- Minimum: 60 minutes (Parts 1-5)
- Recommended: 90 minutes (Parts 1-7)
- Complete: 120 minutes (All parts)

## Prerequisites

- Completed Lab 02 (Docker Compose) or equivalent knowledge
- Basic understanding of containers
- Familiarity with YAML syntax

## Success Metrics

- ✅ All deployments running with correct replicas
- ✅ Services accessible via NodePort
- ✅ Data persists across Redis pod restarts
- ✅ Rolling update performed without downtime
- ✅ Auto-healing demonstrated
- ✅ Application fully functional end-to-end
