#!/bin/bash

FULLDOMAIN=
ACME_DOMAIN=
DOMAIN=$2
SECRET=$1
SUBDOMAIN=$3
CONTENT="${CERTBOT_VALIDATION}"


if [[ -z $SUBDOMAIN ]]; then
	FULLDOMAIN=$DOMAIN
	ACME_DOMAIN="_acme-challenge"
else
	FULLDOMAIN="${SUBDOMAIN}.${DOMAIN}"
	ACME_DOMAIN="_acme-challenge.${SUBDOMAIN}"
fi

zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" -H "Authorization: Bearer ${SECRET}" -H "Content-Type: application/json" | sed 's/,/\n/g' | awk -F'"' '/id/{print $6}' | head -1)

record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records?type=txt&name=${ACME_DOMAIN}" -H "Authorization: Bearer ${SECRET}" -H "Content-Type: application/json" | sed 's/,/\n/g' | awk -F'"' '/id/{print $6}' | head -1)

if [[ -z $record_identifier ]]; then
echo "create.."
create=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/" \
         -H "Authorization: Bearer ${SECRET}" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"TXT\",\"name\":\"${ACME_DOMAIN}\",\"content\":\"${CONTENT}\"}")

else
echo "update.."
update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier}" \
	-H "Authorization: Bearer ${SECRET}" \
	-H "Content-Type: application/json" \
	--data "{\"type\":\"TXT\",\"name\":\"${ACME_DOMAIN}\",\"content\":\"${CONTENT}\"}")
fi

echo $record_identifier
echo $update
echo $create

sleep 30 ;
