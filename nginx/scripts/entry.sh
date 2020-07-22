#!/bin/sh

# Start crond in background
crond -l 2 -b
cd /etc/letsencrypt/live

if [ ! -d /etc/nginx/sites-available ]; then
  mkdir /etc/nginx/sites-available
fi

function gencert {
  if [ ! -d "/etc/letsencrypt/live/$1" ]; then
    cert_loc=/etc/letsencrypt/live/$1/
    if [ ! -d $cert_loc ]; then
      mkdir -p $cert_loc
      cert-gen.sh host $1 $cert_loc
    fi
  fi
}

sed "s/\${URL}/${URL}/g; s/\${CONTAINER}/app/g"  /tmp/backend.template.conf > /etc/nginx/sites-available/${URL}.conf
gencert $URL

sed "s/\${URL}/phpmyadmin.test/g" /tmp/phpmyadmin.template.conf > /etc/nginx/sites-available/phpmyadmin.test.conf
gencert phpmyadmin.test

exec "$@"
