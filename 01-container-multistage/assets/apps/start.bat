@echo off
echo ==================================
echo   Link Shortener Application
echo ==================================
echo.
echo Starting services with Docker Compose...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)

REM Stop any existing containers
echo Stopping any existing containers...
docker-compose down

REM Build and start services
echo Building and starting services...
docker-compose up --build -d

REM Wait for services to be healthy
echo.
echo Waiting for services to be healthy...
timeout /t 5 /nobreak >nul

REM Check service status
echo.
echo Service Status:
docker-compose ps

echo.
echo ==================================
echo   Application is ready!
echo ==================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:5000
echo Redis:    localhost:6379
echo.
echo To view logs: docker-compose logs -f
echo To stop:      docker-compose down
echo.
pause
