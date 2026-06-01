# Step-by-Step Instructions

## Getting Started in 3 Steps

### Step 1: Verify Prerequisites ✅

Check that Docker is installed and running:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Verify Docker is running
docker ps
```

**Expected output:**
```
Docker version 20.10.x or higher
Docker Compose version 2.0.x or higher
CONTAINER ID   IMAGE   ...
```

If Docker is not installed, download it from: https://www.docker.com/get-started

---

### Step 2: Start the Application 🚀

**Option A: Automated (Recommended)**

Windows:
```bash
start.bat
```

Linux/Mac:
```bash
chmod +x start.sh
./start.sh
```

**Option B: Manual**

```bash
# Build and start all services in detached mode
docker-compose up --build -d

# Wait 10 seconds for services to initialize
# Then check status
docker-compose ps
```

**Expected output:**
```
NAME                          STATUS    PORTS
link-shortener-backend        Up        0.0.0.0:5000->5000/tcp
link-shortener-frontend       Up        0.0.0.0:5173->80/tcp
link-shortener-redis          Up        0.0.0.0:6379->6379/tcp
```

---

### Step 3: Test the Application ✨

**Option A: Web Browser (Visual)**

1. Open your browser
2. Go to: **http://localhost:5173**
3. You should see a clean UI with "Link Shortener" title
4. Paste this test URL:
   ```
   https://github.com/anthropics/claude-code
   ```
5. Click **"Shorten URL"**
6. You should see:
   - ✅ Success message
   - Short URL (e.g., `http://localhost:5000/Abc123`)
   - Copy button
7. Click **Copy** button
8. Open a new tab and paste the short URL
9. You should be redirected to the original GitHub page

**Option B: Command Line (API Test)**

```bash
# Test 1: Health Check
curl http://localhost:5000/health

# Expected: {"status":"healthy","redis":"connected"}

# Test 2: Shorten a URL
curl -X POST http://localhost:5000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.example.com"}'

# Expected: {"short_url":"http://localhost:5000/AbC123",...}

# Test 3: Test redirection (copy the short_code from above)
curl -L http://localhost:5000/AbC123

# Expected: Redirects to https://www.example.com
```

**Option C: Automated Test Suite**

```bash
./test.sh
```

This runs 9 automated tests and shows which passed ✅ or failed ✗.

---

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f redis
```

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Stop Services
```bash
# Stop but keep containers
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop, remove containers, and delete volumes (clean slate)
docker-compose down -v
```

### Rebuild After Changes
```bash
# Rebuild all services
docker-compose up --build -d

# Rebuild specific service
docker-compose up --build -d backend
```

---

## Troubleshooting Guide

### Issue 1: Port Already in Use

**Error:**
```
Error: Bind for 0.0.0.0:5173 failed: port is already allocated
```

**Solution:**

Edit `docker-compose.yml` and change the port mapping:

```yaml
frontend:
  ports:
    - "8080:80"  # Change from 5173:80
```

Then restart:
```bash
docker-compose up -d
```

Access at: http://localhost:8080

---

### Issue 2: Docker Not Running

**Error:**
```
Cannot connect to the Docker daemon
```

**Solution:**
- **Windows:** Open Docker Desktop from Start menu
- **Mac:** Open Docker Desktop from Applications
- **Linux:** `sudo systemctl start docker`

Wait 30 seconds, then retry.

---

### Issue 3: Services Not Healthy

**Error:**
Services show "unhealthy" or "starting" for more than 2 minutes

**Solution:**

```bash
# Check logs for errors
docker-compose logs

# Common fix: clean restart
docker-compose down -v
docker-compose up --build
```

---

### Issue 4: Frontend Shows Connection Error

**Error:**
"Failed to fetch" or "Network Error"

**Solution:**

1. Check backend is running:
   ```bash
   docker-compose ps backend
   curl http://localhost:5000/health
   ```

2. Check backend logs:
   ```bash
   docker-compose logs backend
   ```

3. Restart backend:
   ```bash
   docker-compose restart backend
   ```

---

### Issue 5: Redis Connection Failed

**Error:**
Backend logs show "Connection refused" to Redis

**Solution:**

```bash
# Check Redis is running
docker-compose ps redis

# Test Redis connection
docker-compose exec redis redis-cli ping
# Should return: PONG

# If not running, restart
docker-compose restart redis
```

---

## Architecture Overview

```
┌──────────────┐
│   Browser    │
│   (User)     │
└──────┬───────┘
       │ HTTP
       ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  Frontend    │────────▶│   Backend    │────────▶│    Redis     │
│  React +     │  REST   │   Flask +    │  TCP    │   Cache &    │
│  Nginx       │   API   │   Gunicorn   │  6379   │   Storage    │
│              │         │              │         │              │
│  Port: 5173  │         │  Port: 5000  │         │  Port: 6379  │
└──────────────┘         └──────────────┘         └──────────────┘
```

**Data Flow:**
1. User enters URL in browser
2. Frontend sends POST to `/shorten`
3. Backend validates and generates short code
4. Backend stores mapping in Redis
5. Backend returns short URL
6. User shares short URL
7. Visitor opens short URL
8. Backend looks up original URL in Redis
9. Backend redirects (HTTP 302) to original URL

---

## Project Structure

```
link-shortener-app/
├── backend/              # Python Flask API
│   ├── app/
│   │   ├── __init__.py  # App factory
│   │   ├── routes.py    # Endpoints
│   │   └── utils.py     # Helpers
│   ├── Dockerfile       # Multi-stage build
│   └── requirements.txt # Dependencies
│
├── frontend/            # React TypeScript App
│   ├── src/
│   │   ├── components/  # UI components
│   │   ├── App.tsx      # Main app
│   │   └── main.tsx     # Entry point
│   ├── Dockerfile       # Multi-stage build
│   └── package.json     # Dependencies
│
├── database/
│   └── redis.conf       # Redis config
│
├── docker-compose.yml   # Service orchestration
│
├── README.md            # Full documentation
├── QUICKSTART.md        # 5-minute guide
├── ARCHITECTURE.md      # C4 architecture
└── INSTRUCTIONS.md      # This file
```

---

## Next Steps

After successfully running the application:

1. ✅ **Understand the Code**
   - Read `backend/app/routes.py` for API logic
   - Read `frontend/src/App.tsx` for UI logic
   - Read `ARCHITECTURE.md` for design details

2. ✅ **Modify the Application**
   - Change colors in `frontend/src/components/` (TailwindCSS)
   - Add new endpoint in `backend/app/routes.py`
   - Modify Redis TTL in `routes.py` (line with `expire`)

3. ✅ **Deploy to Production**
   - Add authentication (JWT)
   - Add rate limiting
   - Set up HTTPS (Let's Encrypt)
   - Use managed Redis (AWS ElastiCache, GCP Memorystore)
   - Deploy to cloud (AWS ECS, GCP Cloud Run, Azure Container Instances)

4. ✅ **Convert to Kubernetes**
   - Create Deployment manifests
   - Create Service manifests
   - Create Ingress for HTTPS
   - Use StatefulSet for Redis

---

## Useful Links

- **Docker Docs:** https://docs.docker.com/
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Flask Tutorial:** https://flask.palletsprojects.com/tutorial/
- **React Tutorial:** https://react.dev/learn
- **Redis Tutorial:** https://redis.io/docs/getting-started/
- **TailwindCSS Docs:** https://tailwindcss.com/docs

---

## Support

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Review TROUBLESHOOTING section above
3. Clean restart: `docker-compose down -v && docker-compose up --build`
4. Read full documentation in `README.md`

---

**Happy Coding! 🚀**
