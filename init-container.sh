#!/bin/bash
echo "************ Delete the azure placeholder html ***********"
[ -e "/home/site/wwwroot/hostingstart.html" ] && rm "/home/site/wwwroot/hostingstart.html"

echo "************ Configure ghost to point to the persistent content ***********"
gosu node ghost config --db="sqlite3" --dbpath="/home/site/wwwroot/content/data/ghost.db" --no-prompt
gosu node ghost config paths.contentPath "/home/site/wwwroot/content"
gosu node ghost config server.host 0.0.0.0

echo "************ Start migration ***********"
if [ ! -d "/home/site/wwwroot/content" ]; then
	echo "Info: Ghost content does not exist creating it"

	baseDir="$GHOST_INSTALL/current/content"

	mkdir -p /home/site/wwwroot/content
	mkdir -p /home/site/wwwroot/content/data

    # Copy the ghost content across from it's original location
	cp -R "$baseDir"/. /home/site/wwwroot/content	

    # Make sure node  owns the content folder so it can modify/setup etc.
    chown -R node:node /home/site/wwwroot/content

    # Setup the SQLite database
    gosu node knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
else
	echo "Info: Ghost content exists"
fi
echo "************ Migration finished ***********"

[ -e "/home/site/wwwroot/config.production.json" ] && cp "/home/site/wwwroot/config.production.json" "/var/lib/ghost/config.production.json"

/usr/bin/supervisord