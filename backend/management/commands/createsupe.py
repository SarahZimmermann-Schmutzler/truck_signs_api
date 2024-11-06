from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
import dotenv
import os

class Command(BaseCommand):
    help = 'Create a superuser non-interactively'

    def handle(self, *args, **options):
        # load .env-file
        dotenv.load_dotenv()

        # load values from .env-file
        username = os.environ.get('SUPERUSER_USERNAME')
        email = os.environ.get('SUPERUSER_EMAIL')
        password = os.environ.get('SUPERUSER_PASSWORD')

        if not username or not email or not password:
            self.stdout.write(self.style.ERROR('Superuser credentials are missing in the .env file.'))
            return

        if not User.objects.filter(username=username).exists():
            User.objects.create_superuser(username=username, email=email, password=password)
            self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" created successfully!'))
        else:
            self.stdout.write(self.style.WARNING(f'Superuser "{username}" already exists.'))