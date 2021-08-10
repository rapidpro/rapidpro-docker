# python:2.7-alpine with GEOS, GDAL, and Proj installed (built as a separate image
# because it takes a long time to build)
FROM rapidpro/rapidpro-base:v4
ENV PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1 \
    PIP_EXTRA_INDEX_URL="https://alpine-3.wheelhouse.praekelt.org/simple"

# TODO determine if a more recent version of Node is needed
# TODO extract openssl and tar to their own upgrade/install line
RUN set -ex \
  && apk add --no-cache nodejs-lts nodejs-npm openssl tar \
  && npm install -g coffee-script less bower

WORKDIR /rapidpro

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
                pcre-dev \
                readline \
                readline-dev \
                ncurses \
                ncurses-dev \
                libzmq \
                curl \
                cargo

ARG RAPIDPRO_VERSION
ARG RAPIDPRO_REPO
ENV RAPIDPRO_VERSION=${RAPIDPRO_VERSION:-master}
ENV RAPIDPRO_REPO=${RAPIDPRO_REPO:-rapidpro/rapidpro}
RUN echo "Downloading RapidPro ${RAPIDPRO_VERSION} from https://github.com/$RAPIDPRO_REPO/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    wget -O rapidpro.tar.gz "https://github.com/$RAPIDPRO_REPO/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    tar -xf rapidpro.tar.gz --strip-components=1 && \
    rm rapidpro.tar.gz

# Install Rust, it's required to build poetry on this version of alpine
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install poetry
RUN pip install -U pip && pip install -U poetry

# Uninstall Rust
RUN rustup self uninstall -y

# Build Python virtualenv
RUN python3 -m venv /venv
ENV PATH="/venv/bin:${PATH}"
ENV VIRTUAL_ENV="/venv"

# Install configuration related dependencies
RUN /venv/bin/pip install --upgrade pip && poetry install --no-interaction && poetry add \
        "django-getenv==1.3.1" \
        "django-cache-url==1.3.1" \
        "uwsgi==2.0.14" \
        "whitenoise==4.0" \
        "flower==0.9.2" \
        "tornado<6.0.0"

RUN cd /rapidpro && npm install npm@6.14.11 && npm install \
    && apk del .build-deps

# Install `psql` command (needed for `manage.py dbshell` in stack/init_db.sql)
# Install `libmagic` (needed since rapidpro v3.0.64)
# Install `pcre` and `libxml2` for uwsgi
RUN apk add --no-cache postgresql-client libmagic pcre-dev libxml2-dev

ENV UWSGI_VIRTUALENV=/venv UWSGI_WSGI_FILE=temba/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_WORKERS=8 UWSGI_HARAKIRI=20
# Enable HTTP 1.1 Keep Alive options for uWSGI (http-auto-chunked needed when ConditionalGetMiddleware not installed)
# These options don't appear to be configurable via environment variables, so pass them in here instead
ENV STARTUP_CMD="/venv/bin/uwsgi --http-auto-chunked --http-keepalive"

COPY settings.py /rapidpro/temba/
# 500.html needed to keep the missing template from causing an exception during error handling
COPY stack/500.html /rapidpro/templates/
COPY stack/init_db.sql /rapidpro/
COPY stack/clear-compressor-cache.py /rapidpro/

EXPOSE 8000
COPY stack/startup.sh /

LABEL org.label-schema.name="RapidPro" \
      org.label-schema.description="RapidPro allows organizations to visually build scalable interactive messaging applications." \
      org.label-schema.url="https://www.rapidpro.io/" \
      org.label-schema.vcs-url="https://github.com/$RAPIDPRO_REPO" \
      org.label-schema.vendor="Nyaruka, UNICEF, and individual contributors." \
      org.label-schema.version=$RAPIDPRO_VERSION \
      org.label-schema.schema-version="1.0"

CMD ["/startup.sh"]
