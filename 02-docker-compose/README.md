# Laboratorio 2: Docker Compose: Orquestación de Aplicaciones Multi-Contenedor

## 🎯 Objetivos de Aprendizaje

Al finalizar este laboratorio, serás capaz de:
- Orquestar múltiples servicios (Frontend + Backend + Redis) con Docker Compose
- Configurar redes personalizadas para aislamiento de seguridad
- Implementar volúmenes persistentes para datos
- Configurar health checks y dependencias entre servicios
- Simular escenarios de fallo y recuperación automática
- Escribir tests de integración para stacks completos

## 📚 Conceptos Clave

### ¿Qué es Docker Compose?
Una herramienta para definir y ejecutar aplicaciones multi-contenedor usando archivos YAML. En lugar de ejecutar múltiples comandos `docker run`, defines toda tu infraestructura en un archivo.

### Beneficios de Docker Compose
1. **Un solo comando:** `docker-compose up` levanta toda la stack
2. **Networking automático:** Los servicios se descubren por nombre
3. **Gestión centralizada:** Volúmenes, redes y variables en un lugar
4. **Reproducible:** Funciona igual en cualquier máquina

### Arquitectura de Tres Capas
- **Frontend:** React/Vite servido por Nginx
- **Backend:** API Flask con Gunicorn
- **Database:** Redis para almacenamiento de datos

### Mejores Prácticas de Producción
1. **Redes aisladas:** Frontend no debe acceder directamente a la base de datos
2. **Health checks:** Detectar servicios no saludables automáticamente
3. **Resource limits:** Prevenir que un servicio consuma todos los recursos
4. **Restart policies:** Auto-recuperación ante fallos
