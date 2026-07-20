#!/bin/sh
set -e

cd /app/aakashvani

echo "Waiting for PostgreSQL..."
until python -c "
import os
import psycopg

psycopg.connect(
    dbname=os.environ.get('POSTGRES_DB', 'aakashvani'),
    user=os.environ.get('POSTGRES_USER', 'aakashvani'),
    password=os.environ.get('POSTGRES_PASSWORD', 'aakashvani'),
    host=os.environ.get('POSTGRES_HOST', 'db'),
    port=os.environ.get('POSTGRES_PORT', '5432'),
    connect_timeout=3,
)
" 2>/dev/null; do
  sleep 1
done
echo "PostgreSQL is ready."

python manage.py migrate --noinput

exec "$@"
