#!/bin/sh
set -ex # fail on any error & print commands as they're run
if [ "x$MANAGEPY_COLLECTSTATIC" = "xon" ]; then
	/venv/bin/python manage.py collectstatic --noinput --no-post-process
fi
if [ "x$CLEAR_COMPRESSOR_CACHE" = "xon" ]; then
	/venv/bin/python clear-compressor-cache.py
fi
if [ "x$MANAGEPY_COMPRESS" = "xon" ]; then
	/venv/bin/python manage.py compress --extension=".haml" --force -v0
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
if [ -n "$MANAGE_IMPORT_GEOJSON" ]; then
	# NOTE: This file is only part of the `-posm` docker image.
  tar -xf posm-extracts.tar.gz --strip-components=1 && rm posm-extracts.tar.gz
	for i in $(echo $MANAGE_IMPORT_GEOJSON | sed "s/,/ /g")
	do
	    echo "Importing GeoJSON for $i"
			if [ -d "./geojson/" ]; then
				/venv/bin/python manage.py import_geojson "./geojson/R{$i}*_simplified.json"
			else
				echo "Unable to import $i, make sure to use the `-posm` docker image."
			fi
	done
	echo "Import done, Clearing GeoJSON"
	rm -rf ./geojson/
fi
$STARTUP_CMD
