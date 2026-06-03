# Link Shortener Application

This directory contains the source code for the Link Shortener application used in the Docker Compose lab.

## Structure

- **apps/backend**: Flask backend API
- **apps/frontend**: React/Vite frontend
- **configs/**: Configuration files for services
- **scripts/**: Testing and automation scripts

## Application Overview

The Link Shortener is a three-tier application:

1. **Frontend (React + Vite + Nginx)**: User interface for creating and managing short URLs
2. **Backend (Flask + Gunicorn)**: REST API for URL shortening logic
3. **Database (Redis)**: Key-value store for URL mappings

## Features

- Create short URLs from long URLs
- Redirect from short codes to original URLs
- Track click statistics
- Health check endpoints
- Production-ready configuration

## Usage in Lab

These assets are automatically copied to the Killercoda environment and used throughout the lab exercises to demonstrate Docker Compose orchestration.
