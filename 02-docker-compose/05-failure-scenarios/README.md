## 🔥 Parte 5: Simulación de Fallos

### Paso 5.1: Preparar el Entorno

Si la stack no está corriendo desde el paso anterior:

```bash
cd ~/code
docker-compose -f docker-compose.complete.yml up -d
sleep 10
```{{exec}}

### Escenario 1: Redis Muere

#### Paso 5.2: Simular Fallo de Redis

```bash
# Verificar estado inicial
docker-compose -f docker-compose.complete.yml ps

# Detener Redis
echo ""
echo "🔴 Deteniendo Redis..."
docker-compose -f docker-compose.complete.yml stop redis

# Esperar un momento
sleep 3

# Ver estado
docker-compose -f docker-compose.complete.yml ps
```{{exec}}

#### Paso 5.3: Intentar Usar la Aplicación (Debe Fallar)

```bash
# Intentar crear URL corta (debe fallar con error 500)
echo "Intentando crear URL corta sin Redis..."
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}' || echo "❌ Esperado: Error porque Redis está caído"
```{{exec}}

#### Paso 5.4: Auto-Recuperación de Redis

```bash
# Reiniciar Redis (restart policy lo levantará automáticamente)
echo ""
echo "🟢 Reiniciando Redis..."
docker-compose -f docker-compose.complete.yml start redis

# Esperar a que el health check pase
echo "Esperando health check..."
sleep 15

# Verificar estado
docker-compose -f docker-compose.complete.yml ps

# Reintentar request (debe funcionar)
echo ""
echo "Reintentando request..."
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}' && echo "✅ Servicio recuperado!"
```{{exec}}

### Escenario 2: Backend Crashea

#### Paso 5.5: Simular Crash del Backend

```bash
# Matar el proceso principal del backend (PID 1 en el contenedor)
echo "🔴 Simulando crash del backend..."
docker-compose -f docker-compose.complete.yml exec -T backend sh -c "kill 1" || true

# Esperar un momento
sleep 3

# Verificar que Docker lo reinició automáticamente (restart: unless-stopped)
echo ""
echo "Verificando auto-restart..."
docker-compose -f docker-compose.complete.yml ps
```{{exec}}

#### Paso 5.6: Verificar Logs de Restart

```bash
# Ver logs recientes del backend
docker-compose -f docker-compose.complete.yml logs --tail=30 backend | grep -E "(Starting|Exiting|killed)"
```{{exec}}

#### Paso 5.7: Verificar que el Servicio Funciona

```bash
# Esperar a que el health check pase
sleep 10

# Probar endpoint
curl -f http://localhost:5000/health && echo "✅ Backend operacional después del restart"
```{{exec}}

### Escenario 3: Limitar Recursos (Stress Test)

#### Paso 5.8: Monitorear Uso de Recursos

```bash
# Ver límites configurados
echo "Límites de recursos del backend:"
docker inspect link-backend --format='Memory Limit: {{.HostConfig.Memory}} bytes (512M)'
docker inspect link-backend --format='CPU Limit: {{.HostConfig.NanoCpus}} nanocpus (0.5 CPU)'

echo ""
echo "Uso actual:"
docker stats --no-stream link-backend
```{{exec}}

#### Paso 5.9: Ver Estado de Health Checks Durante el Estrés

```bash
# Generar múltiples requests para estresar el backend
echo "Generando carga..."
for i in {1..20}; do
  curl -s -X POST http://localhost:5000/shorten \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"https://example.com/page$i\"}" &
done

# Esperar a que terminen
wait

echo ""
echo "Verificando health después de carga..."
docker-compose -f docker-compose.complete.yml ps
```{{exec}}

### Escenario 4: Fallo en Cadena

#### Paso 5.10: Recrear Toda la Stack

```bash
# Detener todo
echo "🔴 Deteniendo toda la stack..."
docker-compose -f docker-compose.complete.yml down

# Levantar de nuevo (observa el orden gracias a depends_on)
echo ""
echo "🟢 Levantando stack con orden controlado..."
docker-compose -f docker-compose.complete.yml up -d

# Monitorear el inicio secuencial
echo ""
echo "Monitoreando inicio secuencial..."
for i in {1..10}; do
  sleep 3
  docker-compose -f docker-compose.complete.yml ps
  echo "---"
done
```{{exec}}

**Observa:**
1. Redis inicia primero
2. Backend espera a que Redis esté "healthy"
3. Frontend espera a que Backend esté "healthy"

### Paso 5.11: Ver Historial de Health Checks

```bash
# Ver últimos health checks de cada servicio
echo "Redis health:"
docker inspect link-redis --format='{{range .State.Health.Log}}{{.Start}}: {{.ExitCode}}{{"\n"}}{{end}}' | tail -5

echo ""
echo "Backend health:"
docker inspect link-backend --format='{{range .State.Health.Log}}{{.Start}}: {{.ExitCode}}{{"\n"}}{{end}}' | tail -5

echo ""
echo "Frontend health:"
docker inspect link-frontend --format='{{range .State.Health.Log}}{{.Start}}: {{.ExitCode}}{{"\n"}}{{end}}' | tail -5
```{{exec}}

## ✅ Resiliencia Demostrada

- **Auto-restart:** Servicios se recuperan automáticamente de crashes
- **Health-based dependencies:** Servicios esperan a dependencias saludables
- **Resource limits:** Previenen que un servicio consuma todos los recursos
- **Graceful degradation:** La aplicación maneja fallos de dependencias
- **Startup order:** Inicialización controlada reduce errores de timing

## 📊 Lecciones Aprendidas

1. **Restart policies son críticas:** `unless-stopped` permite recuperación automática
2. **Health checks no son opcionales:** Detectan problemas que "docker ps" no ve
3. **Resource limits protegen el sistema:** Un servicio con memory leak no derriba todo
4. **Conditional depends_on es poderoso:** Evita race conditions en el startup

## 🧹 Limpieza

```bash
# Mantener la stack corriendo para el siguiente paso
# (tests de integración)
```

En el siguiente paso, crearemos scripts de test automatizados.
