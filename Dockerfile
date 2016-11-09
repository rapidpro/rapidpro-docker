FROM aldryn/base:3.19

ENV RAPIDPRO_VERSION=v2.0.478 \
    NODE_VERSION=7.0.0 \
    PIP_RETRIES=120 \
    PIP_TIMEOUT=400 \
    PIP_DEFAULT_TIMEOUT=400 \
    C_FORCE_ROOT=1

COPY stack/ /stack/
RUN /stack/node.sh
RUN npm install -g coffee-script less bower

WORKDIR /rapidpro

RUN wget "https://github.com/nyaruka/rapidpro/archive/${RAPIDPRO_VERSION}.tar.gz" && \
    tar -xvf ${RAPIDPRO_VERSION}.tar.gz --strip 1 && \
    rm ${RAPIDPRO_VERSION}.tar.gz

# workaround for broken dependency to old Pillow version from django-quickblocks
RUN sed -i '/Pillow/c\Pillow==3.4.2' /rapidpro/pip-freeze.txt

# workaround: outdated dj-database-url does not work with sqlite://:memory: url
# which is needed for build mode.
RUN sed -i '/dj-database-url/c\dj-database-url==0.4.1' /rapidpro/pip-freeze.txt


COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

RUN cd /rapidpro && bower install --allow-root

COPY settings.py /rapidpro/temba/
RUN DJANGO_MODE=build python manage.py collectstatic --noinput

# TODO: enable compress once the setup works
#RUN DJANGO_MODE=build python manage.py compress
EXPOSE 80
CMD python manage.py runserver 0.0.0.0:80
