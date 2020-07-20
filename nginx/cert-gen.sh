#!/bin/bash

function gen_extfile()
{
	domain=$1
	cat << EOF
		authorityKeyIdentifier=keyid,issuer\n
		basicConstraints=CA:FALSE\n
		keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\n
		subjectAltName = @alt_names\n
		[alt_names]\n
		DNS.1 = $domain
EOF
}


case "$1" in
	r*)
		[ -z "$2" ] && filename="rootCA" || filename="$2"
		openssl genrsa -des3 -passout pass:default -out "$filename.key" 4096
		openssl req -x509 -new -nodes -passin pass:default -key "$filename.key" -sha256 -days 20480 -subj "/C=GB/ST=London/L=London/O=Development/OU=IT Department/CN=Self Signed Certificate/emailAddress=info@example.com" -out rootCA.crt
		;;
	h*)
		host="$2"
		destination="$3"
		if [ -z $host ]; then
			echo "Host argument is required"
			exit 1
		fi
		extFile=$(gen_extfile $host)
		openssl req -new -sha256 -nodes  -out "$host.csr" -newkey rsa:2048 -days 20480 -subj "/C=GB/ST=London/L=London/O=$host/OU=IT Department/CN=$host Self Signed Certificate/emailAddress=info@$host"  -keyout "privkey.pem"
		openssl x509 -req -passin pass:default -in "$host.csr" -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out "fullchain.pem" -days 500 -sha256 -extfile <(printf "$extFile")
		if [ ! -z $destination ]; then
      mkdir -p $destination
			mv privkey.pem fullchain.pem $host.csr $destination
		fi
		;;
	*) cat << EOF
ssl-cert: Generates

Allowed options:
		root {?filename} {?destination} generates root certificate. Default cirtificate basename is rootCA
		host {host} {?destination}      generates domain certificate
EOF
esac
