#!/bin/sh
set -ex # fail on any error & print commands as they're run
if [ "x$DJANGO_COLLECTSTATIC" = "xon" ]; then
	/venv/bin/python manage.py collectstatic --noinput
fi
if [ "x$DJANGO_COMPRESS" = "xon" ]; then
	/venv/bin/python manage.py compress --extension=".haml" --settings=temba.settings_travis
fi
if [ "x$DJANGO_MIGRATE" = "xon" ]; then
	/venv/bin/python manage.py migrate
fi
$STARTUP_CMD
