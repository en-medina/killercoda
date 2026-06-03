# Architecture Documentation

## System Overview

Este documento describe la arquitectura de la aplicación Link Shortener siguiendo el modelo C4 (Context, Containers, Components).

## Level 1: System Context

```
                                   ┌─────────────────────┐
                                   │                     │
                                   │       User          │
                                   │   (Web Browser)     │
                                   │                     │
                                   └──────────┬──────────┘
                                              │
                                              │ HTTP/HTTPS
                                              │
                                   ┌──────────▼──────────┐
                                   │                     │
                                   │  Link Shortener     │
                                   │    Application      │
                                   │                     │
                                   └─────────────────────┘
```

## Level 2: Container Diagram

```
┌───────────────────────────────────────────────────────────────────┐
│                     Link Shortener Application                     │
│                                                                    │
│  ┌──────────────┐         ┌──────────────┐       ┌─────────────┐ │
│  │              │         │              │       │             │ │
│  │   Frontend   │────────▶│   Backend    │──────▶│    Redis    │ │
│  │   Container  │  REST   │   Container  │ TCP   │  Container  │ │
│  │              │   API   │              │ 6379  │             │ │
│  │  React +     │         │  Flask +     │       │   Cache &   │ │
│  │  Vite +      │         │  Gunicorn    │       │   Storage   │ │
│  │  TypeScript  │         │              │       │             │ │
│  │              │         │              │       │             │ │
│  │  Port: 5173  │         │  Port: 5000  │       │ Port: 6379  │ │
│  │  (80 nginx)  │         │              │       │             │ │
│  └──────────────┘         └──────────────┘       └─────────────┘ │
│                                                                    │
│  Network: link-shortener-network (bridge)                         │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘
```

## Level 3: Component Diagram

### Frontend Components

```
┌─────────────────────────────────────────────────────┐
│               Frontend Container                     │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │            App.tsx (Root)                  │    │
│  │  - State management (result, error)       │    │
│  │  - API communication logic                │    │
│  └───────────┬────────────────────────────────┘    │
│              │                                      │
│              │ Props                                │
│              │                                      │
│       ┌──────┴───────┐                             │
│       │              │                              │
│  ┌────▼──────┐  ┌───▼────────────┐                │
│  │           │  │                 │                │
│  │ UrlShort- │  │  ResultDisplay  │                │
│  │ enerForm  │  │                 │                │
│  │           │  │  - Display short│                │
│  │ - Input   │  │    URL          │                │
│  │ - Submit  │  │  - Copy button  │                │
│  │ - Loading │  │  - Stats        │                │
│  │           │  │  - Reset        │                │
│  └───────────┘  └─────────────────┘                │
│                                                      │
│  Styling: TailwindCSS                               │
│  Build: Vite                                        │
│  Server: Nginx (production)                         │
└─────────────────────────────────────────────────────┘
```

### Backend Components

```
┌───────────────────────────────────────────────────────┐
│              Backend Container                         │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │         __init__.py (Factory)                │    │
│  │  - Flask app creation                        │    │
│  │  - Redis client initialization               │    │
│  │  - CORS setup                                │    │
│  └───────────────┬──────────────────────────────┘    │
│                  │                                    │
│                  │ Registers                          │
│                  │                                    │
│  ┌───────────────▼──────────────────────────────┐    │
│  │           routes.py (Blueprint)              │    │
│  │                                              │    │
│  │  POST   /shorten                            │    │
│  │  GET    /<short_code>                       │    │
│  │  GET    /stats/<short_code>                 │    │
│  │  GET    /health                             │    │
│  │                                              │    │
│  └──────────────────────────────────────────────┘    │
│                  │                                    │
│                  │ Uses                               │
│                  │                                    │
│  ┌───────────────▼──────────────────────────────┐    │
│  │           utils.py (Helpers)                 │    │
│  │                                              │    │
│  │  - is_valid_url()                           │    │
│  │  - generate_short_code()                    │    │
│  │                                              │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
│  Dependencies:                                         │
│  - Flask (web framework)                              │
│  - flask-cors (CORS handling)                         │
│  - redis (Redis client)                               │
│  - gunicorn (WSGI server)                             │
└───────────────────────────────────────────────────────┘
```

## Data Flow

### Shortening a URL

```
┌──────┐     1. Enter URL      ┌──────────┐
│      │ ───────────────────▶  │          │
│      │                       │ Frontend │
│ User │                       │          │
│      │ ◀───────────────────  │          │
└──────┘     7. Display short  └────┬─────┘
                URL                 │
                                    │ 2. POST /shorten
                                    │    {"url": "..."}
                                    │
                                    ▼
                              ┌─────────┐
                              │         │
                              │ Backend │
                              │         │
                              └────┬────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
           3. Validate URL   4. Generate    5. Check
              (utils.py)      short_code     collision
                    │          (utils.py)        │
                    │              │              │
                    └──────────────┼──────────────┘
                                   │
                            6. Store mapping
                                   │
                                   ▼
                              ┌─────────┐
                              │  Redis  │
                              │         │
                              │ code:ABC -> url  │
                              │ url:... -> ABC   │
                              └─────────┘
```

### Redirecting from Short URL

```
┌──────┐    1. Visit short     ┌──────────┐
│      │       URL             │          │
│ User │ ───────────────────▶  │ Backend  │
│      │                       │          │
│      │                       └────┬─────┘
│      │                            │
│      │                            │ 2. GET /<short_code>
│      │                            │
│      │                            ▼
│      │                       ┌─────────┐
│      │    3. Fetch URL       │         │
│      │      from Redis       │  Redis  │
│      │                       │         │
│      │                       └────┬────┘
│      │                            │
│      │ ◀────────────────────────  │
└──────┘   4. HTTP 302 Redirect
           Location: original_url
```

## Technology Stack Details

### Frontend

| Technology    | Version | Purpose                                    |
|---------------|---------|-------------------------------------------|
| React         | 18.3    | UI library                                |
| TypeScript    | 5.5     | Type-safe JavaScript                      |
| Vite          | 5.3     | Build tool & dev server                   |
| TailwindCSS   | 3.4     | Utility-first CSS framework               |
| Nginx         | Alpine  | Production web server                     |

### Backend

| Technology    | Version | Purpose                                    |
|---------------|---------|-------------------------------------------|
| Python        | 3.11    | Programming language                      |
| Flask         | 3.0     | Web framework                             |
| Flask-CORS    | 4.0     | CORS handling                             |
| Redis-py      | 5.0     | Redis client                              |
| Gunicorn      | 22.0    | WSGI HTTP server                          |

### Database/Cache

| Technology    | Version | Purpose                                    |
|---------------|---------|-------------------------------------------|
| Redis         | 7       | In-memory data store (cache & storage)    |

## Docker Architecture

### Multi-Stage Builds

Tanto el frontend como el backend usan **multi-stage builds** para optimizar el tamaño de las imágenes:

#### Backend Dockerfile

```
Stage 1 (builder):
- Base: python:3.11-slim
- Install dependencies in virtual environment
- Size: ~500MB (discarded)

Stage 2 (runtime):
- Base: python:3.11-slim
- Copy only virtual environment
- Copy application code
- Final size: ~150MB
```

#### Frontend Dockerfile

```
Stage 1 (builder):
- Base: node:20-alpine
- Install dependencies
- Build production assets (npm run build)
- Size: ~1.2GB (discarded)

Stage 2 (runtime):
- Base: nginx:alpine
- Copy only /dist folder (built assets)
- Final size: ~25MB
```

### Docker Compose Architecture

```yaml
services:
  redis:      # Database/Cache layer
  backend:    # API layer (depends on redis)
  frontend:   # Presentation layer (depends on backend)

networks:
  link-shortener-network:  # Isolated bridge network

volumes:
  redis-data:  # Persistent storage for Redis
```

## Security Considerations

### Frontend
- Nginx security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
- Input validation for URLs
- No sensitive data stored in localStorage
- HTTPS ready (configure with reverse proxy)

### Backend
- URL validation (prevent injection)
- CORS configured for specific origins
- No authentication (add JWT/OAuth for production)
- Health checks for monitoring
- Non-root user in container
- Rate limiting recommended (not implemented)

### Redis
- No authentication in dev (set requirepass for production)
- Protected mode enabled
- Network isolated to Docker bridge
- LRU eviction policy for memory management

## Scalability Considerations

### Current Limitations
- Single backend instance (no load balancer)
- No database sharding
- No caching layer (beyond Redis)
- No CDN for static assets

### Recommended Improvements for Production
1. **Horizontal Scaling:** Multiple backend replicas behind load balancer (nginx/traefik)
2. **Redis Cluster:** Sharding for high availability
3. **CDN:** CloudFlare/Fastly for frontend assets
4. **Monitoring:** Prometheus + Grafana
5. **Logging:** ELK stack or Loki
6. **Authentication:** JWT + OAuth2
7. **Rate Limiting:** Redis-based rate limiter
8. **Analytics:** Track clicks, geolocation, user agents

## Performance Metrics

### Expected Performance
- **URL Shortening:** < 100ms (Redis write)
- **URL Redirection:** < 50ms (Redis read + redirect)
- **Frontend Load:** < 1s (static assets from Nginx)
- **Throughput:** ~1000 requests/sec (single backend instance)

### Bottlenecks
- Redis network latency (mitigate with local caching)
- Backend single-threaded (scale horizontally)
- No CDN (static assets served from same host)

## Deployment Options

### Development
```bash
docker-compose up
```

### Production (Simple)
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Production (Kubernetes)
- Create k8s manifests for each service
- Use StatefulSet for Redis
- Use Deployment for backend/frontend
- Add Ingress for HTTPS
- ConfigMaps for configuration
- Secrets for sensitive data

### Cloud Deployment
- **AWS:** ECS/Fargate + ElastiCache Redis + CloudFront
- **GCP:** Cloud Run + Memorystore Redis + Cloud CDN
- **Azure:** Container Instances + Azure Cache for Redis + Azure CDN

## Monitoring & Observability

### Health Checks
- **Frontend:** `GET /health` (Nginx)
- **Backend:** `GET /health` (Flask + Redis ping)
- **Redis:** `redis-cli ping`

### Logs
```bash
# Application logs
docker-compose logs -f backend

# Access logs (nginx)
docker-compose logs -f frontend

# Redis logs
docker-compose logs -f redis
```

### Metrics (Future)
- Request rate (req/sec)
- Error rate (4xx/5xx)
- Response time (p50, p95, p99)
- Redis hit rate
- URL creation rate
- Top URLs by clicks

## Cost Estimation (AWS Example)

### Development
- **Cost:** $0 (local Docker)

### Small Production (< 10k URLs/day)
- ECS Fargate: 2 tasks (0.25 vCPU, 0.5 GB) → ~$15/mo
- ElastiCache Redis (t4g.micro) → ~$12/mo
- ALB → ~$20/mo
- CloudFront (1 TB) → ~$85/mo
- **Total:** ~$132/mo

### Medium Production (< 1M URLs/day)
- ECS Fargate: 5 tasks (0.5 vCPU, 1 GB) → ~$75/mo
- ElastiCache Redis (m6g.large) → ~$110/mo
- ALB → ~$20/mo
- CloudFront (10 TB) → ~$850/mo
- **Total:** ~$1,055/mo

## References

- **C4 Model:** https://c4model.com/
- **Docker Best Practices:** https://docs.docker.com/develop/dev-best-practices/
- **Flask Design Patterns:** https://flask.palletsprojects.com/en/latest/patterns/
- **Redis Best Practices:** https://redis.io/docs/manual/patterns/
- **React Performance:** https://react.dev/learn/render-and-commit
