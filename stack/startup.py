import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'temba.settings'
import django
django.setup()
from django.contrib.auth.management.commands.createsuperuser import get_user_model
from django.core.exceptions import ObjectDoesNotExist
from temba.orgs.models import Org

try:
    superuser = get_user_model().objects.get(username=os.getenv('ADMIN_EMAIL'))
    print('Super user already exists. SKIPPING.')
except ObjectDoesNotExist:
    if os.getenv('ADMIN_NAME') and os.getenv('ADMIN_EMAIL') and os.getenv('ADMIN_PSWD') and os.getenv('ADMIN_ORG'):
        print('Creating super user...')
        superuser = get_user_model()._default_manager.db_manager('default').create_superuser(
            username=os.getenv('ADMIN_EMAIL'),
            email=os.getenv('ADMIN_EMAIL'),
            first_name=os.getenv('ADMIN_NAME'),
            password=os.getenv('ADMIN_PSWD')
        )
        print('Super user created.')
    
if Org.objects.filter(name=os.getenv('ADMIN_ORG')):
    print('Admin org already exists. SKIPPING.')
elif superuser and os.getenv('ADMIN_ORG'):
    print('Creating admin org...')
    org = Org.objects.create(
        name=os.getenv('ADMIN_ORG'),
        timezone='UTC',
        created_by=superuser,
        modified_by=superuser
    )
    org.administrators.add(superuser)
    org.initialize()
    print('Admin org created.')

