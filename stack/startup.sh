#!/bin/sh
set -ex # fail on any error & print commands as they're run
if [ "x$MANAGEPY_COLLECTSTATIC" = "xon" ]; then
	/venv/bin/python manage.py collectstatic --noinput
fi
if [ "x$MANAGEPY_COMPRESS" = "xon" ]; then
	/venv/bin/python manage.py compress --extension=".haml"
fi
if [ "x$MANAGEPY_INIT_DB" = "xon" ]; then
	set +x  # make sure the password isn't echoed to stdout
	echo "*:*:*:*:$(echo \"$DATABASE_URL\" | cut -d'@' -f1 | cut -d':' -f3)" > $HOME/.pgpass
	set -x
	chmod 0600 $HOME/.pgpass
	/venv/bin/python manage.py dbshell < init_db.sql
	rm $HOME/.pgpass
fi
if [ "x$MANAGEPY_MIGRATE" = "xon" ]; then
	/venv/bin/python manage.py migrate
fi
$STARTUP_CMD
