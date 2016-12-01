# -*- coding: utf-8 -*-
from __future__ import unicode_literals

# -----------------------------------------------------------------------------------
# RapidPro settings file for the docker setup
# -----------------------------------------------------------------------------------

from getenv import env
import dj_database_url
import django_cache_url

from temba.settings_common import *  # noqa

GEOS_LIBRARY_PATH = '/usr/local/lib/libgeos_c.so'
GDAL_LIBRARY_PATH = '/usr/local/lib/libgdal.so'

DJANGO_MODE = env('DJANGO_MODE')
if DJANGO_MODE == 'build':
    # While building the docker image we need fake values for some things so
    # management commands like collectstatic can be run.
    SECRET_KEY = 'fake-secret-key'
    DATABASE_URL = 'sqlite://:memory:'
    DATABASES = {'default': dj_database_url.parse(DATABASE_URL)}
    REDIS_URL = ''
    CACHE_URL = 'locmem://'
    BROKER_URL = ''
    CELERY_RESULT_BACKEND = ''
else:
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
HOSTNAME = env('DOMAIN', 'rapidpro.ngrok.com')
TEMBA_HOST = env('TEMBA_HOST', HOSTNAME)

# -----------------------------------------------------------------------------------
# Redis & Cache Configuration
# -----------------------------------------------------------------------------------
# TODO: make this an url
# TODO: separate urls for broker, cache and locks.

# -----------------------------------------------------------------------------------
# Need a PostgreSQL database on localhost with postgis extension installed.
# -----------------------------------------------------------------------------------
INTERNAL_IPS = ('*',)

COMPRESS_ENABLED = False
COMPRESS_OFFLINE = False
STATIC_URL = '/sitestatic/'
