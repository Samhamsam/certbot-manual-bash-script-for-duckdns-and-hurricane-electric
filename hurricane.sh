#!/bin/bash
HURRICANE_PASSWORD="$1"
curl -4 "https://dyn.dns.he.net/nic/update?hostname=_acme-challenge.${CERTBOT_DOMAIN}&password=${HURRICANE_PASSWORD}&txt=${CERTBOT_VALIDATION}"
sleep 60;

echo $CERTBOT_DOMAIN
echo $CERTBOT_VALIDATION
echo $CERTBOT_TOKEN
