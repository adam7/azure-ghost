#!/bin/bash
gosu node ghost config --db="sqlite3" --dbpath="/home/site/wwwroot/data/ghost.db"
gosu node ghost config paths.contentPath "/home/site/wwwroot"
gosu node ghost config server.host 0.0.0.0
sh /bin/migrate_util.sh
/usr/bin/supervisord
