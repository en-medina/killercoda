# Workshop de Contenedores y Kubernetes

## 🎯 Objetivo del Workshop

Aprender a containerizar, orquestar y gestionar aplicaciones en producción usando Docker y Kubernetes, aplicando prácticas SRE reales de confiabilidad, escalabilidad y observabilidad.

## 📋 Conocimientos Previos
- Comandos básicos de Linux (cd, ls, cat, grep)
- Conceptos básicos de redes (IP, puertos, HTTP)
- Conocimiento básico de Git

## 🗂️ Estructura de los Laboratorios

| Lab | Tema | Duración | Dificultad |
|-----|------|----------|------------|
| **Lab 1** | Docker Fundamentals | 60 min | ⭐ Básico |
| **Lab 2** | Docker Compose | 60 min | ⭐⭐ Intermedio |
| **Lab 3** | Kubernetes Essentials | 90 min | ⭐⭐⭐ Avanzado |
| **Lab 4** | SRE Troubleshooting | 75 min | ⭐⭐⭐ Avanzado |

## 🚀 Progresión de Aprendizaje

```
Lab 1: Docker Fundamentals
├─ Construir imágenes optimizadas
├─ Multi-stage builds
├─ Seguridad básica
└─ Escaneo de vulnerabilidades
         │
         ▼
Lab 2: Docker Compose
├─ Orquestar múltiples servicios
├─ Redes y volúmenes
├─ Health checks
└─ Gestión de dependencias
         │
         ▼
Lab 3: Kubernetes Essentials
├─ Deployments y Pods
├─ Services y balanceo
├─ ConfigMaps y Secrets
└─ Auto-healing y escalado
         │
         ▼
Lab 4: SRE Troubleshooting
├─ Debugging de contenedores
├─ Análisis de logs
├─ Probes (liveness/readiness)
└─ Resolución de incidentes reales
```

## 📚 Contenido de Cada Lab

### [Lab 1: Docker Fundamentals](lab-01-docker-fundamentals/README.md)
Aprende a construir imágenes Docker optimizadas para producción usando multi-stage builds y mejores prácticas de seguridad.

**Aprenderás:**
- Dockerfiles multi-stage
- Optimización de capas y cache
- Usuarios no-root
- Escaneo de vulnerabilidades con Trivy

### [Lab 2: Docker Compose](lab-02-docker-compose/README.md)
Orquesta la aplicación completa (Frontend + Backend + Redis) con Docker Compose, implementando redes aisladas, volúmenes persistentes y health checks.

**Aprenderás:**
- Definición de servicios multi-contenedor
- Redes personalizadas
- Volúmenes para persistencia
- Health checks y depends_on

### [Lab 3: Kubernetes Essentials](lab-03-kubernetes-essentials/README.md)
Migra la aplicación de Docker Compose a Kubernetes, implementando alta disponibilidad, auto-healing y gestión de configuración.

**Aprenderás:**
- Deployments con réplicas
- Services (ClusterIP, NodePort)
- ConfigMaps y Secrets
- Rolling updates y rollbacks

### [Lab 4: SRE Troubleshooting](lab-04-sre-troubleshooting/README.md)
Resuelve incidentes reales simulados: crashloops, fallos de conexión, OOM kills y problemas de readiness probes.

**Aprenderás:**
- Debugging con kubectl logs/exec
- Análisis de eventos del cluster
- Liveness y Readiness Probes
- Resource limits y requests

## 🎓 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)

---

**¡Comienza con el [Lab 1: Docker Fundamentals](lab-01-docker-fundamentals/README.md)!**
