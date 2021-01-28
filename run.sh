#!/bin/bash

# INPUT DATA
DOMAIN=
TYPE=
EMAIL=
LOCATION=
SECRET=
PROXY=
SUBDOMAIN=

# AUTO DATA
#SUBDOMAIN= #For duckdns
COMMAND=
FULLDOMAIN=

RED='\033[0;31m'
NC='\033[0m'

help(){
	echo -e "${RED}"
	echo -e "Example:"
	echo -e "./run.sh -t duckdns -d duckdns.org -e my@email.com -l /home/some/folder/ -s mysecret -r nginx -sd cloud"
	echo -e "${NC}"
}


mainfunc() {
	certbot certonly \
 	--noninteractive \
 	--manual \
 	--preferred-challenges dns \
 	--agree-tos \
 	--manual-public-ip-logging-ok \
 	--email="${EMAIL}" \
 	-d "${FULLDOMAIN}" \
 	--config-dir ${CONFIGDIR} \
 	--work-dir ${WORKDIR} \
 	--logs-dir ${LOGDIR} \
 	--manual-auth-hook "${COMMAND}" ;
}

create_haproxy_cert(){
	cat "${CERTPATH}/fullchain.pem" "${CERTPATH}/privkey.pem" | tee "${LOCATION}/${FULLDOMAIN}.pem"
}

create_nginx_cert(){
	cp "${CONFIGDIR}/live/${FULLDOMAIN}/cert.pem" "${LOCATION}/${FULLDOMAIN}.crt"
	cp "${CONFIGDIR}/live/${FULLDOMAIN}/privkey.pem" "${LOCATION}/${FULLDOMAIN}.key"
}


while [[ "$#" -gt 0 ]]; do
	case $1 in
		-t|--type) TYPE=$2
                shift
                ;;
		-d|--domain) DOMAIN=$2
		shift
		;;
		-e|--email) EMAIL=$2
		shift
		;;
		-l|--path) LOCATION=$2
		shift
		;;
		-s|--secret) SECRET=$2
		shift
		;;
		-r|--rproxy) PROXY=$2
		shift
		;;
		-sd|--subdomain) SUBDOMAIN=$2
		shift
		;;
        esac
        shift
done

if [ "$TYPE" == "duckdns" ]; then
	COMMAND="./duckdns.sh ${SECRET} ${SUBDOMAIN}"
elif [ "$TYPE" == "hurricane" ]; then
	COMMAND="./hurricane.sh ${SECRET}"
elif [ "$TYPE" == "cloudflare" ]; then
	COMMAND="./cloudflare.sh ${SECRET} ${DOMAIN} ${SUBDOMAIN}"
else
	help
fi

FULLDOMAIN="${SUBDOMAIN}.${DOMAIN}"
CERTHOME="$(pwd)/letsencrypt" ;
echo "Creating letsencrypt folder.."
mkdir -p ${CERTHOME} # create certhome if not exist
CONFIGDIR="${CERTHOME}/config"
WORKDIR="${CERTHOME}/work"
LOGDIR="${CERTHOME}/logs"
CERTPATH="${CERTHOME}config/live/${FULLDOMAIN}"


help

#certbot
echo "Creating with ${TYPE} for ${FULLDOMAIN} a certificate.."

mainfunc

if [ "$PROXY" == "nginx" ]; then
	echo "Copying nginx cert files to \"${LOCATION}\".."
        create_nginx_cert
elif [ "$TYPE" == "hurricane" ]; then
	echo "Copying hurricane cert file to \"${LOCATION}\".."
        create_haproxy_cert
else
        help
fi

