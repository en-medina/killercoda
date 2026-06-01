## 🧪 Parte 5: Probar las Imágenes

### Paso 5.1: Despliega el backend
Despliega Redis y el backend: 

```bash
# Crear red para despliegue
docker network create test-network

# Iniciar Redis (dependencia del backend)
docker run -d --name redis-test \
    --network test-network \
    -p 6379:6379 redis:7-alpine

# Iniciar backend
docker run -d --name backend-test \
    --network test-network \
    -p 5000:5000 \
    -e REDIS_HOST=redis-test \
    -e REDIS_PORT=6379 \
    link-backend:optimized

# Verificar logs
docker logs backend-test
```{{copy}}

Dale un tiempo y luego prueba que el backend este respondiendo con `curl http://localhost:5000/health`

### Paso 5.2: Despliega el frontend

```bash
# Iniciar frontend
docker run -d --name frontend-test -p 8080:80 link-frontend:optimized

# Verificar logs
docker logs frontend-test

# Abrir en navegador
# http://localhost:8080
```{{copy}}

### Paso 5.3: Accede al escenario

Para acceder al escenario, debes acceder desde la opcion de Network Traffic de killercoda. 

De igual manera, puedes acceder dandole [click aqui]({{TRAFFIC_HOST1_8080}}) .
