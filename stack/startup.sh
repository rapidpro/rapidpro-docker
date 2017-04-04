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
if [ -n "$MANAGEPY_IMPORT_GEOJSON" ]; then
	GEO_JSON_SHA=$(wget -qO- https://api.github.com/repos/nyaruka/posm-extracts/git/trees/master | jq -r '.tree | .[] | select(.path == "geojson").sha')
	mkdir -p ./geojson
	for RELATION_ID in $(echo $MANAGEPY_IMPORT_GEOJSON | sed "s/,/ /g")
		do
		FILES=$(wget -qO- https://api.github.com/repos/nyaruka/posm-extracts/git/trees/$GEO_JSON_SHA | jq -r ".tree | .[] | select(.path | test(\"R$RELATION_ID.*_simplified.json\")) | .path")
		for FILE in $FILES
		do
			wget -O ./geojson/$FILE https://raw.githubusercontent.com/nyaruka/posm-extracts/master/geojson/$FILE
	    echo "Importing ./geojson/$FILE for relation id $RELATION_ID"
			echo /venv/bin/python manage.py import_geojson "./geojson/$FILE"
		done
	done
	echo "Import done, Clearing GeoJSON"
	echo rm -rf ./geojson/
fi
$STARTUP_CMD
