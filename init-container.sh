#!/bin/bash
gosu node ghost config --db="sqlite3" --dbpath="/home/site/wwwroot/content/data/ghost.db"
gosu node ghost config paths.contentPath "/home/site/wwwroot/content"
gosu node ghost config server.host 0.0.0.0

# allow the container to be started with `--user`
if [[ "$*" == node*current/index.js* ]] && [ "$(id -u)" = '0' ]; then
	chown -R node "$GHOST_CONTENT"
	exec gosu node "$BASH_SOURCE" "$@"
fi

if [[ "$*" == node*current/index.js* ]]; then
	baseDir="$GHOST_INSTALL/content.orig"
	for src in "$baseDir"/*/ "$baseDir"/themes/*; do
		src="${src%/}"
		target="/home/site/wwwroot/${src#$baseDir/}"
		mkdir -p "$(dirname "$target")"
		if [ ! -e "$target" ]; then
			tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
		fi
	done

	knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
fi


# if [ ! -d "/home/site/wwwroot/content" ]; then
# 	echo "Info: Ghost content does not exist creating it"

# 	baseDir="$GHOST_INSTALL/current/content"

# 	mkdir -p /home/site/wwwroot/content
# 	mkdir -p /home/site/wwwroot/content/data

#     # Copy the ghost content across it's original location
# 	cp -R "$baseDir"/. /home/site/wwwroot/content	

#     # Make sure node  owns the content folder so it can modify/setup etc.
#     chown -R node:node /home/site/wwwroot/content

#     # Setup the SQLite database
#     gosu node knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
# else
# 	echo "Info: Ghost content exists"
# fi

/usr/bin/supervisord