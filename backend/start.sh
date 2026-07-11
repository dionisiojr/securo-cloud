#!/usr/bin/env bash

# Força o script a parar imediatamente se o Alembic der erro
set -e

# Executa as migrações do banco de dados
echo "Aplicando migrações do Alembic..."
alembic upgrade head

# Inicia o servidor FastAPI
echo "Iniciando o Uvicorn..."
uvicorn app.main:app --host 0.0.0.0 --port 8000
