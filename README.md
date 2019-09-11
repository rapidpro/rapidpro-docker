Installing Pollsterpro
--------------------------

1. Clone the Pollsterpro rp-docker branch onto the target server.
2. Configure the .env file. (An example configuration is provided below).
    ```dockerfile
    #DJANGO ENV VARS
    DJANGO_DEBUG=on
    IS_PROD=on
    UWSGI_HARAKIRI=600
    UWSGI_WORKERS=12
    ADMIN_NAME=admin
    ADMIN_EMAIL=admin@istresearch.com
    ADMIN_PSWD=1zThIsh@rd2gu3ss?
    DOMAIN_NAME=ppro.dev.istresearch.com
    
    #Callback host, used for twilio, nexmo, etc.
    TEMBA_HOST=ppro.dev.istresearch.com
    
    #Host configs
    HOSTNAME=ppro.dev.istresearch.com
    HOSTPORT=8000
    IS_PROD=on
    SEND_CALLS=on
    SEND_EMAILS=on
    SEND_MESSAGES=on
    SEND_WEBHOOKS=on
    MANAGEPY_COLLECTSTATIC=on
    MANAGEPY_COMPRESS=on
    MANAGEPY_INIT_DB=on
    MANAGEPY_MIGRATE=on
    
    #SMTP configs
    EMAIL_HOST=smtp.gmail.com
    EMAIL_PORT=587
    EMAIL_HOST_USER=donotreply@istresearch.com
    DEFAULT_FROM_EMAIL=donotreply@istresearch.com
    EMAIL_HOST_PASSWORD=yeahNotReally
    EMAIL_USE_TLS=on
    SEND_EMAILS=on
    
    #AMAZON AWS S3 configs required for twilio and other service providers
    AWS_STORAGE_BUCKET_NAME=ist-dev-bucket
    AWS_ACCESS_KEY_ID=(required)
    AWS_SECRET_ACCESS_KEY=(required)
    COURIER_S3_REGION=us-east-1
    
    #Redis configs
    REDIS_HOST=redis
    REDIS_PORT=6379
    REDIS_DB_NUM=1
    ELASTICSEARCH_URL=https://user:password@elasticsearch.us-east-1.aws.found.io:9200
    
    #Postgres configs
    DBCONN_DBNAME=rapidpro
    DBCONN_NAME=postgres
    DBCONN_PSWD=postgres
    DBCONN_HOST=postgresql
    DBCONN_PORT=5432
    DATABASE_URL=postgres://postgres:postgres@postgresql/rapidpro?sslmode=disable
    SECRET_KEY=UUID-OR-RND-STRING_SHARED-KEY-WITH-WORKER
    
    #Org branding configs
    DEFAULT_BRAND=pulse
    BRANDING_NAME=pulse
    BRANDING_SLUG=pulse
    BRANDING_ORG=ist
    BRANDING_EMAIL=admin@istresearch.com
    BRANDING_SUPPORT_EMAIL=admin@istresearch.com
    BRANDING_LINK=https://ppro.dev.istresearch.com
    BRANDING_API_LINK=https://api.ppro.dev.istresearch.com
    BRANDING_DOCS_LINK=http://docs.ppro.dev.istresearch.com
    BRANDING_FAVICO=brands/rapidpro/rapidpro.ico
    BRANDING_SPLASH=/brands/rapidpro/splash.jpg
    BRANDING_LOGO=/brands/rapidpro/logo.png
    BRANDING_ALLOW_SIGNUPS=True
    ```
3. Configure the **server_name** in the nginx.conf file. ex:`server_name ppro.dev.istresearch.com;`
    ```javascript
    server {
            # the port your site will be served on
            listen      8001;
            # the domain name it will serve forproxy_set_header
            server_name ppro.dev.istresearch.com; # substitute your machine's IP address or FQDN
            charset     utf-8;
            # max upload size
            client_max_body_size 75M;   # adjust to taste
            # Finally, send all non-media requests to the Django server.
            location / {
                proxy_set_header Host $http_host;
                proxy_pass http://rapidpro:8000;
                proxy_read_timeout 600s;
                proxy_send_timeout 600s;
                break;
            }
       ...
    }
    ```

Running Pollsterpro Server.
------------------------
Once configured, you may run `docker-compose up -d` from the cloned repo’s directory.

Creating new Orgs
------------------------
1. To create an initial Org, the server must be configured to allow open signups. To enable open signups:
2. In the **.env** file (or in the Rapidpro service in the **docker-compose.yml** file) set the environment variable **BRANDING_ALLOW_SIGNUPS**=True.
3. Restart the Rapidpro docker container via docker-compose. (ex. `docker-compose stop rapidpro; docker-compose up -d rapidpro` OR `docker-compose restart rapidpro`)

Create (DJANGO) ADMIN
------------------------
1. Ensure that the **ADMIN_NAME**, **ADMIN_EMAIL**, **ADMIN_PSWD** environment variables have been set for the Rapidpro docker service, in either the **.env** file or **docker-compose.yml** file. 
(_You may ignore the first step and provide the credentials as direct parameters by simply replacing the entire **${VAR_NAME}** brace with the target credential_)
2. Execute `sudo docker-compose exec rapidpro sh`
3. Execute ```echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('${ADMIN_NAME}', '${ADMIN_EMAIL}', '${ADMIN_PSWD}')" | /venv/bin/python manage.py shell```

Notes and Troubleshooting:
--------------------------
**BRANDING_LINK** is used in email notifications. Links will  be invalid if the proper protocol is not specified. For example, if https is enabled then ppro.dev.istresearch.com would result in an invalid link http://ppro.dev.istresearch.com being sent in generated emails. The proper link should therefore be: https://ppro.dev.istresearch.com.

* Channel is configured, however messages are not being delivered to the message service.
  * Check the courier logs for configuration errors:
    > couriercourier_1      | time="2019-05-28T15:27:31Z" level=error msg="s3 bucket not reachable" comp=backend error="BadRequest: Bad Request\n\tstatus code: 400, request id: 545EE10EF02CD5DD, host id: XHIDHAHEIHER+VNWxcnbXHuae3283WXz77JvSCNBCBsgXH6hV3283u83DGHSJKW9ye83yr+de4V7Y=" state=starting
    * (Fixed by providing proper AWS S3 Credentials AWS_STORAGE_BUCKET_NAME, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  * Check the celery logs for misconfigured workers:
    > urllib3.exceptions.NewConnectionError: <urllib3.connection.HTTPConnection object at 0x7fee076cdac8>: Failed to establish a new connection: [Errno 111] Connection refused [celery_base_1    |ESC[0m [2019-05-19 19:06:43,826: WARNING/PoolWorker-5] GET http://localhost:9200/contacts/_search?size=1 [status:N/A request:0.001s]
    * (Fixed by adding the proper ELASTICSEARCH_URL to the .env file)

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
  Boolean for whether or not to allow signups, defaults to ``True``.

*RAVEN_DSN*
  The DSN for Sentry

*EXTRA_INSTALLED_APPS*
  Any extra apps to be appended to ``INSTALLED_APPS``.

*ROOT_URLCONF*
  The urlconf to use, defaults to ``temba.urls``.

*IS_PROD*
  If you want channel or trigger activation / deactivation
  callbacks handled set this to ``on``.
