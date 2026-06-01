# Laboratorio 1: Fundamentos de Docker: Construcción de Contenedores Listos para Producción

## 🎯 Objetivos de Aprendizaje

Al finalizar este laboratorio, serás capaz de:
- Construir imágenes Docker optimizadas con multi-stage builds
- Implementar mejores prácticas de seguridad (usuarios no-root)
- Optimizar el tamaño de imágenes y el cache de Docker
- Escanear vulnerabilidades con Trivy
- Comparar diferentes estrategias de construcción

## 📚 Conceptos Clave

### ¿Qué es un Dockerfile?
Un archivo de texto con instrucciones para construir una imagen Docker. Cada instrucción crea una **capa** (layer) que se cachea para acelerar futuras construcciones.

### ¿Qué es Multi-Stage Build?
Una técnica que usa múltiples `FROM` en un Dockerfile:
- **Stage 1 (Builder):** Compila el código, instala dependencias de desarrollo
- **Stage 2 (Runtime):** Copia solo los artefactos necesarios, sin herramientas de build

**Beneficio:** Imágenes finales 5-10x más pequeñas y seguras.

### Mejores Prácticas de Seguridad
1. **Usuarios no-root:** Evitar ejecutar procesos como root dentro del contenedor
2. **Imágenes base mínimas:** Usar variantes Alpine o Slim
3. **Escaneo de vulnerabilidades:** Detectar CVEs conocidos
4. **Secrets nunca en imágenes:** Usar Docker secrets o variables de entorno
