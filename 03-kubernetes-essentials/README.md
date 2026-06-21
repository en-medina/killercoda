# Laboratorio 3: Kubernetes Essentials: De Docker Compose a Kubernetes

## 🎯 Objetivos de Aprendizaje

Al finalizar este laboratorio, serás capaz de:
- Migrar una aplicación de Docker Compose a Kubernetes
- Crear Deployments con réplicas y auto-healing
- Configurar Services para networking interno y externo
- Gestionar configuración con ConfigMaps y Secrets
- Implementar rolling updates y rollbacks
- Escalar aplicaciones manual y automáticamente
- Comprender las diferencias fundamentales entre Docker Compose y Kubernetes

## 📚 Conceptos Clave

### ¿Qué es Kubernetes?
Un sistema de orquestación de contenedores que automatiza el despliegue, escalado y gestión de aplicaciones containerizadas. A diferencia de Docker Compose (single-host), Kubernetes puede gestionar contenedores across múltiples nodos.

### Componentes Fundamentales de Kubernetes

**Pods:** La unidad más pequeña de despliegue en Kubernetes. Contiene uno o más contenedores que comparten red y almacenamiento.

**Deployments:** Gestiona ReplicaSets y permite rolling updates declarativos. Define el estado deseado de tu aplicación.

**Services:** Abstracción que expone Pods como un servicio de red. Permite service discovery y load balancing.

**ConfigMaps:** Almacena configuración no confidencial en pares clave-valor.

**Secrets:** Similar a ConfigMaps pero diseñado para datos sensibles (passwords, tokens).

**PersistentVolumeClaims (PVC):** Solicitud de almacenamiento persistente.

### Arquitectura de la Aplicación

```
┌──────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                  │
│                                                        │
│  ┌─────────────────┐        ┌─────────────────┐     │
│  │   Frontend      │        │    Backend      │     │
│  │   (2 replicas)  │───────▶│   (3 replicas)  │     │
│  │   NodePort      │        │    NodePort     │     │
│  └─────────────────┘        └─────────────────┘     │
│                                      │                │
│                                      ▼                │
│                             ┌─────────────────┐      │
│                             │     Redis       │      │
│                             │   (1 replica)   │      │
│                             │    ClusterIP    │      │
│                             │      + PVC       │      │
│                             └─────────────────┘      │
└──────────────────────────────────────────────────────┘
```

### Docker Compose vs. Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|---------------|------------|
| **Scope** | Single host | Multi-host cluster |
| **Scaling** | Manual | Manual + Auto (HPA) |
| **Self-healing** | Restart policies | Built-in (ReplicaSets) |
| **Load Balancing** | Basic | Advanced (Services) |
| **Rolling Updates** | Manual | Declarative |
| **Service Discovery** | DNS | DNS + Labels/Selectors |
| **Config Management** | .env files | ConfigMaps + Secrets |
| **Storage** | Volumes | PV + PVC |

## ⏱️ Duración Estimada

- **Minimum:** 60 minutos (Parts 1-5)
- **Recommended:** 90 minutos (Parts 1-7)
- **Complete:** 120 minutos (All parts including scaling)
