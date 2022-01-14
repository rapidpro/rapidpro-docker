FROM ghcr.io/praekeltfoundation/python-base:3.9.6 as builder

ENV PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

RUN apt-get-install.sh curl sudo && \
    curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - && \
    apt-get-install.sh build-essential openssl tar wget nodejs openssl tar && \
    npm install -g less

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

# Install configuration related dependencies
RUN /venv/bin/pip install --upgrade pip && poetry install --no-interaction --no-dev && poetry add \
        "django-getenv==1.3.2" \
        "django-cache-url==3.2.3" \
        "uwsgi==2.0.20" \
        "whitenoise==5.3.0" \
        "flower==1.0.0" \
        "tornado==6.1"

RUN cd /rapidpro && npm install npm@6.14.11 && npm install

FROM ghcr.io/praekeltfoundation/python-base:3.9.6
COPY --from=builder /venv /venv
COPY --from=builder /rapidpro /rapidpro

WORKDIR /rapidpro
ENV PATH="/venv/bin:${PATH}"
ENV VIRTUAL_ENV="/venv"

# Install `psql` command (needed for `manage.py dbshell` in stack/init_db.sql)
# Install `libmagic` (needed since rapidpro v3.0.64)
# Install `pcre` and `libxml2` for uwsgi
RUN apt-get-install.sh postgresql-client libmagic-dev libpcre3 libpcre3-dev libxml2-dev

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
