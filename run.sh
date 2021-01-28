#!/bin/bash

# INPUT DATA
DRYRUN=
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
GREEN='\033[0;32m'

help(){
	echo -e "${RED}"
	echo -e "Example:"
	echo -e "./run.sh -t duckdns -d duckdns.org -e my@email.com -l /home/some/folder/ -s mysecret -r nginx -sd cloud"
	echo -e "${NC}"

	echo -e "${GREEN}"
	echo -e "-h|--help	Help Message (optional)" ;
	echo -e "-t|--type	duckdns|hurricane|cloudflare (required)"
	echo -e "-d|--domain	only the domain name (required)"
	echo -e "-e|--email	Your E-Mail for certbot (required)"
	echo -e "-l|--location	Path where you want to store the nginx or hproxy cert files (required)"
	echo -e "-s|--secret	Your secret/password for the dns api (required)"
	echo -e "-r|--rproxy	nginx|haproxy (required)"
	echo -e "-sd|--subdomain	the subdomain or * for wildcard	(optional)"
	echo -e "-dy|--dryrun	Dry run (optional)"
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

testfunc() {
          certbot certonly \
	  --dry-run \
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

copycertfiles(){
        if [ "$PROXY" == "nginx" ]; then
                echo "Copying nginx cert files to \"${LOCATION}\".."
                create_nginx_cert
        elif [ "$TYPE" == "haproxy" ]; then
                echo "Copying haproxy cert file to \"${LOCATION}\".."
                create_haproxy_cert
        else
                help
        fi
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
		-h|--help) HELP="true"
		shift
		;;
		-dy|--dry) DRYRUN="true"
		shift
		;;
        esac
        shift
done

if [[ ! -z $HELP ]]; then
	help
	exit 0 ;
fi

if [ "$TYPE" == "duckdns" ]; then
	COMMAND="./duckdns.sh ${SECRET} ${SUBDOMAIN}"
elif [ "$TYPE" == "hurricane" ]; then
	COMMAND="./hurricane.sh ${SECRET}"
elif [ "$TYPE" == "cloudflare" ]; then
	COMMAND="./cloudflare.sh ${SECRET} ${DOMAIN} ${SUBDOMAIN}"
else
	help
fi

if [[ -z ${SUBDOMAIN} ]]; then
	FULLDOMAIN="${DOMAIN}"
else
	FULLDOMAIN="${SUBDOMAIN}.${DOMAIN}"
fi

CERTHOME="$(pwd)/letsencrypt" ;
echo "Creating letsencrypt folder.."
mkdir -p ${CERTHOME} # create certhome if not exist
CONFIGDIR="${CERTHOME}/config"
WORKDIR="${CERTHOME}/work"
LOGDIR="${CERTHOME}/logs"
CERTPATH="${CERTHOME}config/live/${FULLDOMAIN}"

echo "Creating with ${TYPE} for ${FULLDOMAIN} a certificate.."

if [[ -z $DRYRUN ]]; then
	mainfunc
	copycertfiles
else
	echo -e "${RED}DRY RUN${NC}"
	testfunc
fi
