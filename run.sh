#!/bin/bash


DOMAIN="$1"
EMAIL="$2"
HAPROXY_CERT_PATH="$3"
HURRICANE_PASSW="$4"
CERT_FOR=""

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ] || [ -z "$HAPROXY_CERT_PATH" ]; then
   echo "Please enter:"
   echo "Argument 1: DOMAIN to be validated"
   echo "Argument 2: E-Mail for letsencrypt"
   echo "Argument 3: The path where you want to store the haproxy ssl file"
   echo "Argument 4: if you use hurricane electric, your password for the txt"
   echo "Example: ./run.sh example.com examle@mx.de /home/example/haproxy/certs/ example_hurricane_password" 
   exit 1
fi

echo "DOMAIN = $DOMAIN"
echo "EMAIL = $EMAIL"
echo "HAPROXY CERT PATH = $HAPROXY_CERT_PATH"

if [[ "$DOMAIN" == *"duckdns"* ]]; then
    CERT_FOR="duckdns"
    echo "Add certificate for duckdns"
else
   CERT_FOR="hurricane"
   echo "Add certificate for Hurricane Electric"
fi

CERTHOME="$(pwd)/letsencrypt/"
mkdir -p $CERTHOME # create certhome if not exist

CONFIGDIR="${CERTHOME}/config"
WORKDIR="${CERTHOME}/work"
LOGDIR="${CERTHOME}/logs"

if [ ! -z "${CONFIGDIR}" ]; then
  rm -rf "${CONFIGDIR}/*";
else
  echo "CONFIGDIR ist leer."
  exit 1
fi

if [ "$CERT_FOR" == "duckdns" ]; then
certbot certonly \
 --noninteractive \
 --manual \
 --preferred-challenges dns \
 --agree-tos \
 --manual-public-ip-logging-ok \
 --email="${EMAIL}" \
 -d "${DOMAIN}" \
 --config-dir ${CONFIGDIR} \
 --work-dir ${WORKDIR} \
 --logs-dir ${LOGDIR} \
 --manual-auth-hook "./duckdns.sh" ;
else
certbot certonly \
 --noninteractive \
 --manual \
 --preferred-challenges dns \
 --agree-tos \
 --manual-public-ip-logging-ok \
 --email="${EMAIL}" \
 -d "${DOMAIN}" \
 --config-dir ${CONFIGDIR} \
 --work-dir ${WORKDIR} \
 --logs-dir ${LOGDIR} \
 --manual-auth-hook "./hurricane.sh ${HURRICANE_PASSW}" ;
fi

CERTPATH="${CERTHOME}config/live/${DOMAIN}"

cat "${CERTPATH}/fullchain.pem" "${CERTPATH}/privkey.pem" | tee "${HAPROXY_CERT_PATH}/${DOMAIN}.pem" 
