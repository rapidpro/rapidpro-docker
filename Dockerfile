FROM ghcr.io/praekeltfoundation/python-base-nw:3.9-bullseye as builder

ENV PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

RUN apt-get-install.sh wget tar build-essential

WORKDIR /rapidpro

ARG RAPIDPRO_VERSION
ARG RAPIDPRO_REPO
ENV RAPIDPRO_VERSION=${RAPIDPRO_VERSION:-master}
ENV RAPIDPRO_REPO=${RAPIDPRO_REPO:-rapidpro/rapidpro}
RUN echo "Downloading RapidPro ${RAPIDPRO_VERSION} from https://github.com/$RAPIDPRO_REPO/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    wget -O rapidpro.tar.gz "https://github.com/$RAPIDPRO_REPO/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    tar -xf rapidpro.tar.gz --strip-components=1 && \
    rm rapidpro.tar.gz

RUN pip install -U pip && pip install -U poetry

# Build Python virtualenv
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
ENV VIRTUAL_ENV="/venv"

# Install configuration related dependencies
RUN /venv/bin/pip install --upgrade pip && poetry install --no-interaction --no-dev && poetry add \
        "django-getenv==1.3.2" \
        "django-cache-url==3.2.3" \
        "uwsgi==2.0.20" \
        "whitenoise==5.3.0" \
        "flower==1.0.0" \
        "tornado==6.1"

FROM ghcr.io/praekeltfoundation/python-base-nw:3.9-bullseye

ARG RAPIDPRO_VERSION
ENV RAPIDPRO_VERSION=${RAPIDPRO_VERSION:-master}

# Copy rapidpro and venv from builder
COPY --from=builder /rapidpro /rapidpro
COPY --from=builder /venv /venv
ENV PATH="/venv/bin:$PATH"
ENV VIRTUAL_ENV="/venv"

# Install `psql` for `manage.py dbshell`
# `magic` is needed since rapidpro v3.0.64
# `pcre` is needed for uwsgi
# `geos`, `gdal`, and `proj` are needed for `manage.py download_geojson` and `manage.py import_geojson`
# `npm` for static file generation
RUN apt-get-install.sh \
        postgresql-client \
        libmagic-dev \
        libpcre3 \
        libgeos-c1v5 \
        libgdal28 \
        libproj19 \
        npm

WORKDIR /rapidpro

RUN npm install -g less && npm install

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
