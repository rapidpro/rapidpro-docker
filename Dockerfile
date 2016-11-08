FROM aldryn/base:3.19

ENV RAPIDPRO_VERSION=1d00704b116b54c52f346a28147bc3341a74a023 \
    NODE_VERSION=7.0.0 \
    PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

COPY stack/ /stack/
RUN /stack/node.sh
RUN npm install -g coffee-script less bower

RUN curl -fsSL "https://github.com/nyaruka/rapidpro/archive/${RAPIDPRO_VERSION}.tar.gz" | \
    tar -xzC /tmp/ && \
    mv /tmp/rapidpro-${RAPIDPRO_VERSION} /rapidpro && \
    rm -rf /tmp/rapidpro-${RAPIDPRO_VERSION}

# workaround for broken dependency to old Pillow version from django-quickblocks
RUN sed -i '/Pillow/c\Pillow==3.4.2' /rapidpro/pip-freeze.txt

# workaround: outdated dj-database-url does not work with sqlite://:memory: url
# which is needed for build mode.
RUN sed -i '/dj-database-url/c\dj-database-url==0.4.1' /rapidpro/pip-freeze.txt


WORKDIR /rapidpro
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

RUN cd /rapidpro && bower install --allow-root

COPY settings.py /rapidpro/temba/
RUN DJANGO_MODE=build python manage.py collectstatic --noinput

# TODO: enable compress once the setup works
#RUN DJANGO_MODE=build python manage.py compress
