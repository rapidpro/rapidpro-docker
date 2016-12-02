# -*- coding: utf-8 -*-
from __future__ import unicode_literals

# -----------------------------------------------------------------------------------
# RapidPro settings file for the docker setup
# -----------------------------------------------------------------------------------

from getenv import env
import dj_database_url
import django_cache_url

from temba.settings_common import *  # noqa

DEBUG = env('DJANGO_DEBUG', 'off') == 'on'

GEOS_LIBRARY_PATH = '/usr/local/lib/libgeos_c.so'
GDAL_LIBRARY_PATH = '/usr/local/lib/libgdal.so'

SECRET_KEY = env('SECRET_KEY', required=True)
DATABASE_URL = env('DATABASE_URL', required=True)
DATABASES = {'default': dj_database_url.parse(DATABASE_URL)}
DATABASES['default']['CONN_MAX_AGE'] = 60
DATABASES['default']['ATOMIC_REQUESTS'] = True
DATABASES['default']['ENGINE'] = 'django.contrib.gis.db.backends.postgis'
REDIS_URL = env('REDIS_URL', required=True)
BROKER_URL = env('BROKER_URL', REDIS_URL)
CELERY_RESULT_BACKEND = env('CELERY_RESULT_BACKEND', REDIS_URL)
CACHE_URL = env('CACHE_URL', REDIS_URL)
CACHES = {'default': django_cache_url.parse(CACHE_URL)}
if CACHES['default']['BACKEND'] == 'django_redis.cache.RedisCache':
    if 'OPTIONS' not in CACHES['default']:
        CACHES['default']['OPTIONS'] = {}
    CACHES['default']['OPTIONS']['CLIENT_CLASS'] = 'django_redis.client.DefaultClient'

# -----------------------------------------------------------------------------------
# Used when creating callbacks for Twilio, Nexmo etc..
# -----------------------------------------------------------------------------------
HOSTNAME = env('DOMAIN_NAME', 'rapidpro.ngrok.com')
TEMBA_HOST = env('TEMBA_HOST', HOSTNAME)

INTERNAL_IPS = ('*',)
ALLOWED_HOSTS = env('ALLOWED_HOSTS', HOSTNAME).split(';')

LOGGING['root']['level'] = 'INFO'

AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME', '')

if AWS_STORAGE_BUCKET_NAME:
    # Tell django-storages that when coming up with the URL for an item in S3 storage, keep
    # it simple - just use this domain plus the path. (If this isn't set, things get complicated).
    # This controls how the `static` template tag from `staticfiles` gets expanded, if you're using it.
    # We also use it in the next setting.
    AWS_S3_CUSTOM_DOMAIN = '%s.s3.amazonaws.com' % AWS_STORAGE_BUCKET_NAME

    # This is used by the `static` template tag from `static`, if you're using that. Or if anything else
    # refers directly to STATIC_URL. So it's safest to always set it.
    STATIC_URL = "https://%s/" % AWS_S3_CUSTOM_DOMAIN

    # Tell the staticfiles app to use S3Boto storage when writing the collected static files (when
    # you run `collectstatic`).
    STATICFILES_STORAGE = 'storages.backends.s3boto.S3BotoStorage'
    COMPRESS_STORAGE = STATICFILES_STORAGE
else:
    STATIC_URL = '/sitestatic/'

COMPRESS_ENABLED = env('DJANGO_COMPRESSOR', 'on') == 'on'
COMPRESS_OFFLINE = COMPRESS_ENABLED

COMPRESS_URL = STATIC_URL
# Use MEDIA_ROOT rather than STATIC_ROOT because it already exists and is
# writable on the server. It's also the directory where other cached files
# (e.g., translations) are stored
COMPRESS_ROOT = STATIC_ROOT
COMPRESS_OFFLINE_MANIFEST = 'manifest.json'
