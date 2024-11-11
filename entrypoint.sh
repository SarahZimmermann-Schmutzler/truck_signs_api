#!/usr/bin/env bash

# aborts the script on errors
set -e

echo "Waiting for postgres to connect ..."

# verifys that the database connection is ready (every second)
# name of database container: truck_signs_db
while ! nc -z truck_signs_db 5432; do
  sleep 1
done

echo "PostgreSQL is active"

# collects static files (media, templates)
python manage.py collectstatic --noinput

# performs database migrations
python manage.py makemigrations
python manage.py migrate

echo "Postgresql migrations finished"

# automatic creation of a superuser. password, user and email are pulled from the .env
# path: /backend/management/commands/createsupe.py
python manage.py createsupe

# run application on container port 5000
# python manage.py runserver 0.0.0.0:5000

# run app with gunicorn for better performance in productive use 
gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:5000