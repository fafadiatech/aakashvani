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
python manage.py seed_dev_data

if python manage.py shell -c "
from apps.aakashvani.models import User
import sys
sys.exit(0 if User.objects.filter(email__endswith='@loadtest.aakashvani.local').exists() else 1)
" >/dev/null 2>&1; then
  echo "Load testing data already exists. Skipping load_testing_data."
else
  python manage.py load_testing_data
fi

exec "$@"
