#!/bin/bash
DUCK_TOKEN=$(grep DUCK_TOKEN .env | cut -d '=' -f2)
DUCK_DOMAIN_NAME=$(grep DUCK_DOMAIN_NAME .env | cut -d '=' -f2)
curl -4 "https://www.duckdns.org/update?domains=${DUCK_DOMAIN_NAME}&token=${DUCK_TOKEN}&txt=${CERTBOT_VALIDATION}&verbose=true"

sleep 20 ;

echo $CERTBOT_DOMAIN
echo $CERTBOT_VALIDATION
echo $CERTBOT_TOKEN
