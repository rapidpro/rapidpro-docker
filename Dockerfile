# python:2.7-alpine with GEOS, GDAL, and Proj installed (built as a separate image
# because it takes a long time to build)
FROM rapidpro/rapidpro-base
ARG RAPIDPRO_VERSION
ENV PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

# TODO determine if a more recent version of Node is needed
# TODO extract openssl and tar to their own upgrade/install line
RUN set -ex \
  && apk add --no-cache nodejs-lts openssl tar \
  && npm install -g coffee-script less bower

WORKDIR /rapidpro

ENV RAPIDPRO_VERSION=${RAPIDPRO_VERSION:-master}
RUN echo "Downloading RapidPro ${RAPIDPRO_VERSION} from https://github.com/nyaruka/rapidpro/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    wget "https://github.com/nyaruka/rapidpro/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    tar -xvf ${RAPIDPRO_VERSION}.tar.gz --strip-components=1 && \
    rm ${RAPIDPRO_VERSION}.tar.gz

# workaround for broken dependency to old Pillow version from django-quickblocks
RUN sed -i '/Pillow/c\Pillow==3.4.2' /rapidpro/pip-freeze.txt

# workaround: outdated dj-database-url does not work with sqlite://:memory: url
# which is needed for build mode.
RUN sed -i '/dj-database-url/c\dj-database-url==0.4.1' /rapidpro/pip-freeze.txt

# Build Python virtualenv
COPY requirements.txt /app/requirements.txt
RUN set -ex \
        && apk add --no-cache --virtual .build-deps \
                bash \
                patch \
                git \
                gcc \
                g++ \
                make \
                libc-dev \
                musl-dev \
                linux-headers \
                postgresql-dev \
                libjpeg-turbo-dev \
                libpng-dev \
                freetype-dev \
                libxslt-dev \
                libxml2-dev \
                zlib-dev \
                libffi-dev \
                readline \
                readline-dev \
                ncurses \
                ncurses-dev \
                libzmq \
        && pip install -U virtualenv \
        && virtualenv /venv \
        && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/venv/bin/pip install -r /app/requirements.txt" \
        && runDeps="$( \
                scanelf --needed --nobanner --recursive /venv \
                        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                        | sort -u \
                        | xargs -r apk info --installed \
                        | sort -u \
        )" \
        && apk add --virtual .python-rundeps $runDeps \
        && apk del .build-deps

# TODO should this be in startup.sh?
RUN cd /rapidpro && bower install --allow-root

# Install `psql` command (needed for `manage.py dbshell` in stack/init_db.sql)
RUN apk add --no-cache postgresql-client

RUN sed -i 's/sitestatic\///' /rapidpro/static/brands/rapidpro/less/style.less

ENV UWSGI_VIRTUALENV=/venv UWSGI_WSGI_FILE=temba/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_WORKERS=8 UWSGI_HARAKIRI=20
# Enable HTTP 1.1 Keep Alive options for uWSGI (http-auto-chunked needed when ConditionalGetMiddleware not installed)
# These options don't appear to be configurable via environment variables, so pass them in here instead
ENV STARTUP_CMD="/venv/bin/uwsgi --http-auto-chunked --http-keepalive"

# ENV MANAGEPY_INIT_DB=on
# ENV MANAGEPY_MIGRATE=on
# ENV MANAGEPY_COLLECTSTATIC=on
# ENV MANAGEPY_COMPRESS=on
# ENV DJANGO_DEBUG=on

COPY settings.py /rapidpro/temba/
# 500.html needed to keep the missing template from causing an exception during error handling
COPY stack/500.html /rapidpro/templates/
COPY stack/init_db.sql /rapidpro/

EXPOSE 8000
COPY stack/startup.sh /
CMD ["/startup.sh"]
