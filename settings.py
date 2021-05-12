# -*- coding: utf-8 -*-
from __future__ import unicode_literals

# -----------------------------------------------------------------------------------
# RapidPro settings file for the docker setup
# -----------------------------------------------------------------------------------

from getenv import env
import dj_database_url
import django_cache_url
from datetime import datetime
from django.utils.translation import ugettext_lazy as _

from temba.settings_common import *  # noqa

INSTALLED_APPS = (
    INSTALLED_APPS +
    tuple(filter(None, env('EXTRA_INSTALLED_APPS', '').split(','))) +
    ('raven.contrib.django.raven_compat',))

ROOT_URLCONF = env('ROOT_URLCONF', 'temba.urls')

DEBUG = env('DJANGO_DEBUG', 'off') == 'on'

GEOS_LIBRARY_PATH = '/usr/local/lib/libgeos_c.so'
GDAL_LIBRARY_PATH = '/usr/local/lib/libgdal.so'

SECRET_KEY = env('SECRET_KEY', required=True)

DATABASE_URL = env('DATABASE_URL', required=True)

_default_database_config = dj_database_url.parse(DATABASE_URL)
_default_database_config['CONN_MAX_AGE'] = 60
_default_database_config['ATOMIC_REQUESTS'] = True
_default_database_config['ENGINE'] = 'django.contrib.gis.db.backends.postgis'

_direct_database_config = _default_database_config.copy()
_default_database_config['DISABLE_SERVER_SIDE_CURSORS'] = True

DATABASES = {
    'default': _default_database_config,
    'direct': _direct_database_config
}

REDIS_URL = env('REDIS_URL', required=True)
BROKER_URL = env('BROKER_URL', REDIS_URL)
CELERY_RESULT_BACKEND = env('CELERY_RESULT_BACKEND', REDIS_URL)
CACHE_URL = env('CACHE_URL', REDIS_URL)
CACHES = {'default': django_cache_url.parse(CACHE_URL)}
if CACHES['default']['BACKEND'] == 'django_redis.cache.RedisCache':
    if 'OPTIONS' not in CACHES['default']:
        CACHES['default']['OPTIONS'] = {}
    CACHES['default']['OPTIONS']['CLIENT_CLASS'] = 'django_redis.client.DefaultClient'

RAVEN_CONFIG = {
    'dsn': env('RAVEN_DSN'),
    'release': env('RAPIDPRO_VERSION'),
}

# -----------------------------------------------------------------------------------
# Used when creating callbacks for Twilio, Nexmo etc..
# -----------------------------------------------------------------------------------
HOSTNAME = env('DOMAIN_NAME', 'rapidpro.ngrok.com')
TEMBA_HOST = env('TEMBA_HOST', HOSTNAME)

INTERNAL_IPS = ('*',)
ALLOWED_HOSTS = env('ALLOWED_HOSTS', HOSTNAME).split(';')

LOGGING['root']['level'] = env('DJANGO_LOG_LEVEL', 'INFO')

STORAGE_URL = env("STORAGE_URL", "http://localhost:8000/media")

AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME', '')
AWS_BUCKET_DOMAIN = env('AWS_BUCKET_DOMAIN', AWS_STORAGE_BUCKET_NAME + '.s3.amazonaws.com')
CDN_DOMAIN_NAME = env('CDN_DOMAIN_NAME', '')
AWS_ACCESS_KEY_ID = env('AWS_ACCESS_KEY_ID', '')
AWS_SECRET_ACCESS_KEY = env('AWS_SECRET_ACCESS_KEY', '')
AWS_S3_REGION_NAME = env('AWS_S3_REGION_NAME', '')
AWS_DEFAULT_ACL = env('AWS_DEFAULT_ACL', '')
AWS_LOCATION = env('AWS_LOCATION', '')
AWS_STATIC = env('AWS_STATIC', False)
AWS_MEDIA = env('AWS_MEDIA', False)
AWS_S3_ENDPOINT_URL = env('AWS_S3_ENDPOINT_URL', None)

if AWS_STORAGE_BUCKET_NAME:
    # Tell django-storages that when coming up with the URL for an item in S3 storage, keep
    # it simple - just use this domain plus the path. (If this isn't set, things get complicated).
    # This controls how the `static` template tag from `staticfiles` gets expanded, if you're using it.
    # We also use it in the next setting.
    if CDN_DOMAIN_NAME:
        AWS_S3_DOMAIN = CDN_DOMAIN_NAME
    else:
        AWS_S3_DOMAIN = '%s.s3.amazonaws.com' % AWS_STORAGE_BUCKET_NAME

    if AWS_STATIC:
        # This is used by the `static` template tag from `static`, if you're using that. Or if anything else
        # refers directly to STATIC_URL. So it's safest to always set it.
        STATIC_URL = "https://%s/" % AWS_S3_DOMAIN

        # Tell the staticfiles app to use S3Boto storage when writing the collected static files (when
        # you run `collectstatic`).
        STATICFILES_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

        COMPRESS_STORAGE = STATICFILES_STORAGE

    if AWS_MEDIA:
        MEDIAFILES_LOCATION = 'media'
        MEDIA_URL = "https://%s/%s/" % (AWS_S3_DOMAIN, MEDIAFILES_LOCATION)

        DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

if not AWS_STATIC:
    STATIC_URL = '/sitestatic/'
    MIDDLEWARE = list(MIDDLEWARE) + ['whitenoise.middleware.WhiteNoiseMiddleware']

COMPRESS_ENABLED = env('DJANGO_COMPRESSOR', 'on') == 'on'
COMPRESS_OFFLINE = False

COMPRESS_URL = STATIC_URL
# Use MEDIA_ROOT rather than STATIC_ROOT because it already exists and is
# writable on the server. It's also the directory where other cached files
# (e.g., translations) are stored
COMPRESS_ROOT = STATIC_ROOT
COMPRESS_CSS_HASHING_METHOD = 'content'
COMPRESS_OFFLINE_MANIFEST = 'manifest-%s.json' % env('RAPIDPRO_VERSION', required=True)

MAGE_AUTH_TOKEN = env('MAGE_AUTH_TOKEN', None)
MAGE_API_URL = env('MAGE_API_URL', 'http://localhost:8026/api/v1')
SEND_MESSAGES = env('SEND_MESSAGES', 'off') == 'on'
SEND_WEBHOOKS = env('SEND_WEBHOOKS', 'off') == 'on'
SEND_EMAILS = env('SEND_EMAILS', 'off') == 'on'
SEND_AIRTIME = env('SEND_AIRTIME', 'off') == 'on'
SEND_CALLS = env('SEND_CALLS', 'off') == 'on'
IP_ADDRESSES = tuple(filter(None, env('IP_ADDRESSES', '').split(',')))

EMAIL_HOST = env('EMAIL_HOST', 'smtp.gmail.com')
EMAIL_HOST_USER = env('EMAIL_HOST_USER', 'server@temba.io')
EMAIL_PORT = int(env('EMAIL_PORT', 25))
DEFAULT_FROM_EMAIL = env('DEFAULT_FROM_EMAIL', 'server@temba.io')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD', 'mypassword')
EMAIL_USE_TLS = env('EMAIL_USE_TLS', 'on') == 'on'
SECURE_PROXY_SSL_HEADER = (
    env('SECURE_PROXY_SSL_HEADER', 'HTTP_X_FORWARDED_PROTO'), 'https')
IS_PROD = env('IS_PROD', 'off') == 'on'

BRANDING = {
    'rapidpro.io': {
        'slug': env('BRANDING_SLUG', 'rapidpro'),
        'name': env('BRANDING_NAME', 'RapidPro'),
        'org': env('BRANDING_ORG', 'RapidPro'),
        'colors': dict([rule.split('=') for rule in env('BRANDING_COLORS', 'primary=#0c6596').split(';')]),
        'styles': ['brands/rapidpro/font/style.css'],
        'welcome_topup': 1000,
        'email': env('BRANDING_EMAIL', 'join@rapidpro.io'),
        'support_email': env('BRANDING_SUPPORT_EMAIL', 'join@rapidpro.io'),
        'link': env('BRANDING_LINK', 'https://app.rapidpro.io'),
        'api_link': env('BRANDING_API_LINK', 'https://api.rapidpro.io'),
        'docs_link': env('BRANDING_DOCS_LINK', 'http://docs.rapidpro.io'),
        'domain': HOSTNAME,
        'favico': env('BRANDING_FAVICO', 'brands/rapidpro/rapidpro.ico'),
        'splash': env('BRANDING_SPLASH', '/brands/rapidpro/splash.jpg'),
        'logo': env('BRANDING_LOGO', '/brands/rapidpro/logo.png'),
        'allow_signups': env('BRANDING_ALLOW_SIGNUPS', 'on') == 'on',
        'tiers': dict(import_flows=0, multi_user=0, multi_org=0),
        'bundles': [],
        'welcome_packs': [dict(size=5000, name="Demo Account"), dict(size=100000, name="UNICEF Account")],
        'description': _("Visually build nationally scalable mobile applications from anywhere in the world."),
        'credits': _("Copyright &copy; 2012-%s UNICEF, Nyaruka, and individual contributors. All Rights Reserved." % (
            datetime.now().strftime('%Y')
        ))
    }
}
DEFAULT_BRAND = 'rapidpro.io'

# build up our offline compression context based on available brands
COMPRESS_OFFLINE_CONTEXT = []
for brand in BRANDING.values():
    context = dict(STATIC_URL=STATIC_URL, base_template='frame.html', debug=False, testing=False)
    context['brand'] = dict(slug=brand['slug'], styles=brand['styles'])
    COMPRESS_OFFLINE_CONTEXT.append(context)

REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'v2': env('API_THROTTLE_V2', '2500/hour'),
    'v2.contacts': env('API_THROTTLE_V2_CONTACTS', '2500/hour'),
    'v2.messages': env('API_THROTTLE_V2_MESSAGES', '2500/hour'),
    'v2.runs': env('API_THROTTLE_V2_RUNS', '2500/hour'),
    'v2.api': env('API_THROTTLE_V2_API', '2500/hour'),
    'v2.broadcasts': env('API_THROTTLE_V2_BROADCASTS', '2500/hour'),
}

MAILROOM_URL = env('MAILROOM_URL', '')
MAILROOM_AUTH_TOKEN = env('MAILROOM_AUTH_TOKEN', '')

FLOW_SESSION_TRIM_DAYS = env('FLOW_SESSION_TRIM_DAYS', 7)
MAX_ACTIVE_CONTACTFIELDS_PER_ORG = env('MAX_ACTIVE_CONTACTFIELDS_PER_ORG', 250)
