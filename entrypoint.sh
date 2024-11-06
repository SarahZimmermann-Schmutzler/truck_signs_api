#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect ..."

while ! nc -z db 5432; do
  sleep 0.1
done

echo "PostgreSQL is active"

python manage.py collectstatic --noinput
# python manage.py migrate
python manage.py makemigrations
python manage.py migrate

# gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:8000

echo "Postgresql migrations finished"

gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:5000

# automatic creation of a superuser. password, user and email are pulled from the .env
# /backend/management/commands/createsupe.py
python manage.py createsupe

python manage.py runserver