import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'temba.settings'
import django
django.setup()
from django.contrib.auth.management.commands.createsuperuser import get_user_model
if get_user_model().objects.filter(username=os.environ.get('ADMIN_NAME')): 
    print('Super user already exists. SKIPPING.')
elif os.environ.get('ADMIN_NAME') and os.environ.get('ADMIN_EMAIL') and os.environ.get('ADMIN_PSWD'):
    print('Creating super user...')
    get_user_model()._default_manager.db_manager('default').create_superuser(
            username=os.environ.get('ADMIN_NAME'),
            email=os.environ.get('ADMIN_EMAIL'),
            password=os.environ.get('ADMIN_PSWD')
    )
    print('Super user created.')
