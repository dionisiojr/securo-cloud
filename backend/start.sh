#!/usr/bin/env bash

# Force the script to exit immediately if any command fails
set -e

# Run database migrations
echo "Aplicando migrações do Alembic..."
alembic upgrade head

# Start the FastAPI server
echo "Iniciando o Uvicorn..."
uvicorn app.main:app --host 0.0.0.0 --port 8000
