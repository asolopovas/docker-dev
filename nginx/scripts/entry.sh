#!/bin/sh

# Start crond in background
crond -l 2 -b
cd /etc/letsencrypt/live

if [ ! -d /etc/nginx/sites-available ]; then
  mkdir /etc/nginx/sites-available
fi

function gencert {
  location=/etc/letsencrypt/live/$1/
  if echo $1 | grep -Eq "\.test$" ; then
    if [ ! -d $location ] || [ ! -f $location/fullchain.pem ]; then
      mkdir -p $location
      cert-gen.sh host $1 $location
    fi
  fi
}

sed "s#\${APP_URL}#${APP_URL}#g;s#\${CONTAINER}#app#g;s#\${APP_PATH}#${APP_PATH}#g" /tmp/backend.template.conf > /etc/nginx/sites-available/${APP_URL}.conf
sed "s/\${URL}/phpmyadmin.test/g" /tmp/phpmyadmin.template.conf > /etc/nginx/sites-available/phpmyadmin.test.conf

gencert $APP_URL
gencert phpmyadmin.test

exec "$@"
