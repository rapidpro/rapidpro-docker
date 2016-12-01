FROM python:2.7-alpine

# Build geo libraries. Run this separately and first since it takes a long time.
COPY stack/geolibs.sh /
RUN set -ex \
        && apk add --no-cache --virtual .build-deps \
                gcc \
                g++ \
                make \
                libc-dev \
                musl-dev \
                linux-headers \
        && sh /geolibs.sh \
        && apk del .build-deps


ENV RAPIDPRO_VERSION=v2.0.496-nexmo_voice_with_new_api \
    PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

# TODO determine if a more recent version of Node is needed
# TODO extract openssl and tar to their own upgrade/install line
RUN set -ex \
  && apk add --no-cache nodejs-lts openssl tar \
  && npm install -g coffee-script less bower

WORKDIR /rapidpro

RUN wget "https://github.com/nyaruka/rapidpro/archive/${RAPIDPRO_VERSION}.tar.gz" && \
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

RUN cd /rapidpro && bower install --allow-root

ENV UWSGI_VIRTUALENV=/venv UWSGI_WSGI_FILE=temba/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_WORKERS=8 UWSGI_HTTP_AUTO_CHUNKED=1 UWSGI_KEEPALIVE=1 UWSGI_HARAKIRI=20

COPY settings.py /rapidpro/temba/
RUN DJANGO_MODE=build /venv/bin/python manage.py collectstatic --noinput

# TODO: enable compress once the setup works
#RUN DJANGO_MODE=build python manage.py compress
EXPOSE 8000
CMD ["/venv/bin/uwsgi"]
