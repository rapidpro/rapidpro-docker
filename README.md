RapidPro Docker
===============

This repository's sole purpose is to build docker images versioned off of
git tags published in nyaruka/rapidpro and upload them to Docker Hub.

The idea is:

  1. Set up a GitHub commit webhook from nyaruka/rapidpro
  2. Kick off a Travis build when the webhook fires.
  3. The Travis build script should download the latest nyaruka/rapidpro
     tagged release
  4. Build the docker image and tag with the latest git tag.
  5. Push the docker image to Docker hub using credentials stored in
     Travis' secrets vault.

Running RapidPro in Docker
--------------------------

To run the latest cutting edge version:

> $ docker run --publish 8000:8000 rapidpro/rapidpro

To run a specific version:

> $ docker run --publish 8000:8000 rapidpro/rapidpro:v2.0.478

Environment variables
---------------------

*SECRET_KEY*
  Required

*DATABASE_URL*
  Required

*REDIS_URL*
  Required

*DJANGO_DEBUG*
  Defaults to `off`, set to `on` to enable `DEBUG`

*MANAGEPY_COLLECTSTATIC*
  Set to `on` to run the `collectstatic` management command when the container
  starts up.

*MANAGEPY_COMPRESS*
  Set to `on` to run the `compress` management command when the container
  starts up.

*MANAGEPY_INIT_DB*
  Set to `on` to initialize the postgresql database.

*MANAGEPY_MIGRATE*
  Set to `on` to run the `migrate` management command when the container
  starts up.

*BROKER_URL*
  Defaults to `REDIS_URL` if not set.

*CELERY_RESULT_BACKEND*
  Defaults to `REDIS_URL` if not set.

*CACHE_URL*
  Defaults to `REDIS_URL` if not set.

*DOMAIN_NAME*
  Defaults to `rapidpro.ngrok.io`

*TEMBA_HOST*
  Defaults to `DOMAIN_NAME` if not set.

*ALLOWED_HOSTS*
  Defaults to `DOMAIN_NAME` if not set, split on `;`.

*DJANGO_LOG_LEVEL*
  Defaults to `INFO`

*AWS_STORAGE_BUCKET_NAME*
  If set RapidPro will use S3 for static file storage. If not it will
  default to using whitenoise.

*CDN_DOMAIN_NAME*
  Defaults to `''`

*DJANGO_COMPRESSOR*
  Defaults to `on`.

*RAPIDPRO_VERSION*
  This is a build argument, use it to build a specific version of RapidPro.
  `docker build rapidpro/rapidpro --built-arg RAPIDPRO_VERSION=X.Y.Z`.
  This environment variable is available at run time but is only used for
  namespacing the django compressor manifest.

*UWSGI_WSGI_FILE*
  Defaults to `temba/wsgi.py`

*UWSGI_MASTER*
  Defaults to `1`

*UWSGI_WORKERS*
  Defaults to `8`

*UWSGI_HARAKIRI*
  Defaults to `20`
