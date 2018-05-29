#!/bin/sh
echo "Database : $DATABASE_NAME"
DATABASE_FILE=/var/www/data/${DATABASE_NAME}.sqlite

chown www-data:www-data /var/www/html/images 
chown www-data:www-data /var/www/data

#Fix latence problem
rm -rf /var/www/data/locks

#update extensions, 
#TODO retest in Dockerfile
#php composer.phar update --no-dev

#Init database
if [ -e ${DATABASE_FILE} ]
then 
  echo "Database already initialized" 
else 
  #Copy the "empty" database
  cp /tmp/my_wiki.sqlite ${DATABASE_FILE}
  #Allow to write on database
  chmod 644 ${DATABASE_FILE} && chown www-data:www-data ${DATABASE_FILE}
  
  #Sync page
  #web serveur must be lauch to sync pages
  #service apache2 start
  #lauch sync script
  #wikimedia_sync wikifundi.json
  #Mediawik init database 
  #service apache2 stop
  
  #cd maintenance \ && ./update.php --quick \ && cd ..
fi

#maintenance
cd maintenance \ && ./update.php --quick \ && cd ..

echo "Starting Persoid ..."
nodejs parsoid/bin/server.js 2>> /var/log/parsoid &

service memcached start 

echo "Starting Apache 2 ..."
apache2ctl -D FOREGROUND

# for debug
#if [ -z "$1" ]
#then
#  echo "Starting Apache 2 ..."
#  apache2ctl -D FOREGROUND
#else
#service apache2 start
#exec "$@"
#fi

