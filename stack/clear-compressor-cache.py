import redis
from getenv import env
from urllib.parse import urlparse
from django.conf import settings
from django.core.cache import cache

settings.configure()

key_prefix = cache.make_key('django_compressor')

REDIS_URL = env('REDIS_URL', required=True)

up = urlparse(REDIS_URL)
redis_host = up.hostname
redis_port = int(up.port or 6379)
redis_db = int(up.path.lstrip('/'))

redis = redis.Redis(host=redis_host, port=redis_port, db=redis_db)
keys = redis.keys('%s.*' % (key_prefix,))
for key in keys:
    redis.delete(key)
    print('Cleared Django Compressor key: %s' % (key,))
