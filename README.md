RapidPro Docker
===============

[![Build Status](https://travis-ci.org/praekeltfoundation/rapidpro-docker.svg?branch=master)](https://travis-ci.org/praekeltfoundation/rapidpro-docker)
[![Docker Version](https://images.microbadger.com/badges/version/praekeltfoundation/rapidpro.svg)](https://hub.docker.com/r/praekeltfoundation/rapidpro/tags/ "Get the latest version from Docker Hub")

This repository's sole purpose is to build docker images versioned off of
git tags published in rapidpro/rapidpro and upload them to Docker Hub.

The idea is:

  1. Set up Travis Cron job to run every 24 hours
  3. The Travis build script should download the latest rapidpro/rapidpro
     tagged release matching `^v[0-9\.]$`
  4. Build the docker image and tag with the latest git tag.
  5. Push the docker image to Docker hub using credentials stored in
     Travis' secrets vault.

Running RapidPro in Docker
--------------------------

To run the latest cutting edge version:

> $ docker run --publish 8000:8000 rapidpro/rapidpro:master

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

*AWS_BUCKET_DOMAIN*
  The domain to use for serving statics from, defaults to 
  ``AWS_STORAGE_BUCKET_NAME`` + '.s3.amazonaws.com'

*CDN_DOMAIN_NAME*
  Defaults to `''`

*DJANGO_COMPRESSOR*
  Defaults to `on`.

*RAPIDPRO_VERSION*
  This is a build argument, use it to build a specific version of RapidPro.
  `docker build rapidpro/rapidpro --build-arg RAPIDPRO_VERSION=X.Y.Z`.
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

*MAGE_AUTH_TOKEN*
  The Auth token for Mage

*MAGE_API_URL*
  The URL for Mage, defaults to http://localhost:8026/api/v1

*SEND_MESSAGES*
  Set to ``on`` to enable, defaults to ``off``

*SEND_WEBHOOKS*
  Set to ``on`` to enable, defaults to ``off``

*SEND_EMAILS*
  Set to ``on`` to enable, defaults to ``off``

*SEND_AIRTIME*
  Set to ``on`` to enable, defaults to ``off``

*SEND_CALLS*
  Set to ``on`` to enable, defaults to ``off``

*IP_ADDRESSES*
  Comma separate list of IP addresses to white list for 3rd party channel
  integrations

*EMAIL_HOST*
  Defaults to ``smtp.gmail.com``

*EMAIL_PORT*
  DEfaults to ``25``

*EMAIL_HOST_USER*
  Defaults to ``server@temba.io``

*DEFAULT_FROM_EMAIL*
  Defaults to ``server@temba.io``

*EMAIL_HOST_PASSWORD*
  Defaults to ``mypassword``

*EMAIL_USE_TLS*
  Set to ``off`` to disable, defaults to ``on``

*SECURE_PROXY_SSL_HEADER*
  Defaults to ``HTTP_X_FORWARDED_PROTO``

*CLEAR_COMPRESSOR_CACHE*
  Sometimes after a redeploy the compressor cache needs to be cleared
  to make sure the static assets are rebuilt. Not set by default, set to ``on``
  if you want to clear the cache every redeploy.

*OSM_RELATION_IDS*
  The list of OSM Relation IDs that need to be downloaded for this
  deploy. Use spaces to separate the values.

*MANAGE_IMPORT_GEOJSON*
  Whether or not to import OSM GeoJSON boundary files. Not set by default,
  set to ``on`` to activate. Requires the ``OSM_RELATION_IDS`` environment
  variable to be set.

*BRANDING_SLUG*
  The URL slug of the brand, defaults to ``rapidpro``.

*BRANDING_NAME*
  The name of the brand, defaults to ``RapidPro``.

*BRANDING_ORG*
  The organisation of the brand, defaults to ``RapidPro``.

*BRANDING_COLORS*
  The color scheme of the brand. Semi-colon separated CSS rules.
  Defaults to ``primary=#0c6596``.

*BRANDING_EMAIL*
  Defaults to ``join@rapidpro.io``.

*BRANDING_SUPPORT_EMAIL*
  Defaults to ``join@rapidpro.io``.

*BRANDING_LINK*
  The URL for the brand, defaults to https://app.rapidpro.io.

*BRANDING_API_LINK*
  The API URL for the brand, defaults to https://api.rapidpro.io.

*BRANDING_DOCS_LINK*
  The docs URL for the brand, defaults to http://docs.rapidpro.io.

*BRANDING_FAVICO*
  The Favico for the brand, defaults to ``brands/rapidpro/rapidpro.ico``.

*BRANDING_SPLASH*
  The splash image for the brand, defaults to ``/brands/rapidpro/splash.jpg``.

*BRANDING_LOGO*
  The logo for the brand, defaults to ``/brands/rapidpro/logo.png``.

*BRANDING_ALLOW_SIGNUPS*
  Set to `off` to disable, defaults to `on`

*RAVEN_DSN*
  The DSN for Sentry

*EXTRA_INSTALLED_APPS*
  Any extra apps to be appended to ``INSTALLED_APPS``.

*ROOT_URLCONF*
  The urlconf to use, defaults to ``temba.urls``.

*IS_PROD*
  If you want channel or trigger activation / deactivation
  callbacks handled set this to ``on``.

Concourse CI
---------------------

To login and sync:

    > $ fly login --concourse-url https://concourse.example.com -t <target>
    > $ fly -t <target> sync

To add a pipeline:

    > $ fly validate-pipeline --config .ci/pipeline.yml
    > $ fly -t <target> set-pipeline --config .ci/pipeline.yml --pipeline <pipeline-name> --load-vars-from .ci/vars.yml
    > $ fly -t <target> unpause-pipeline -p <pipeline-name>

To trigger and watch a build:

    > $ fly -t <target> trigger-job -j <pipeline-name>/build-image -w
