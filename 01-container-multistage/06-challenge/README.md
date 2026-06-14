## 🎓 Ejercicios Desafío (Opcional)

### Desafío 1: Agregar Build Args

Modifica el Dockerfile del backend para configurar la versión de Python en build time:

```dockerfile
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim AS builder
```{{copy}}

Construir con:
```bash
docker build --build-arg PYTHON_VERSION=3.12 -t link-backend:py312 -f Dockerfile.optimized .
```{{copy}}

### Desafío 2: Implementar Distroless

Intenta usar una imagen base [Distroless](https://github.com/GoogleContainerTools/distroless) para el backend (solo runtime, sin shell).

## 📚 Recursos Adicionales

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)