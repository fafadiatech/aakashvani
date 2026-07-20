# Backend Development Notes

## Migrations with Docker Compose

The backend container runs migrations automatically on startup through `entrypoint.sh`:

- `python manage.py migrate --noinput`
- `python manage.py seed_dev_data`
- conditional `python manage.py load_testing_data`

Because migrations were recently regenerated, run this once if you already have an older local database volume:

```bash
docker compose down -v
docker compose up --build
```

## Model Change Workflow

When you change Django models, generate and commit migrations from source control:

```bash
cd backend/aakashvani
python manage.py makemigrations aakashvani
python manage.py migrate
git add apps/aakashvani/migrations/
git commit
```

Do not run `makemigrations` automatically in container startup.
