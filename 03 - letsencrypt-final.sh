#!/bin/bash
# Path to the letsencrypt-auto tool
LE_TOOL=/usr/bin/certbot
HAPROXY=/usr/sbin/haproxy
CONFIG=/etc/haproxy/haproxy.cfg
TIMESTAMP=`date +'%Y%m%d_%H%M%S'`

check_haproxy_config()
{
        $HAPROXY -c -f "$CONFIG" >/dev/null
        if [ $? -eq 1 ]; then
                # TODO Log the configuration error
                echo "ERROR in the HAPROXY configuration file." | /usr/bin/mail -s "haproxy01 - Error during execution script Letsencrypt" mail@domain.tld
                exit 1
        fi
}


# Path to the letsencrypt config file

# Prepare haproxy destination path
if [ ! -d /etc/haproxy/ssl.old ]; then
	mkdir /etc/haproxy/ssl.old
	#TODO do a chown to secure the folder....
fi 

# Proceed to a backup before doing anything serious
if [ ! -d /root/BACKUPS ]; then
	mkdir /root/BACKUPS
fi 
mkdir /root/BACKUPS/$TIMESTAMP
tar cvfz /root/BACKUPS/$TIMESTAMP/haproxy_config.tar.gz /etc/haproxy

if  [ -d /etc/haproxy/ssl.old ]; then
	rm -rf /etc/haproxy/ssl.old/*.pem  # deleting ante previous iteration 
	mv /etc/haproxy/ssl/letsencrypt_*.pem /etc/haproxy/ssl.old/ # move previous iteration (just the letsencrypt files...)
fi

# send mail on start create / renewal SSL
echo "Start of creation / renewal Let's Encrypt SSL" | /usr/bin/mail -s "haproxy01 - Starting script Letsencrypt" mail@domain.tld


for le_conf_file in letsencrypt_*
do
	
	FIRST_DOMAIN=""

	LE_CONF=$le_conf_file

	# get first domain

	FIRST_DOMAIN=`cat $le_conf_file | grep domains | cut -d "," -f 1 | cut -d "=" -f 2 | tr -d ' '`
	
	echo "Premier domaine : $FIRST_DOMAIN"

	if [ ! -z "$FIRST_DOMAIN" ]; then 
		echo "Launching le process"
		# Directory where the acme client puts the generated certs
		LE_OUTPUT=/etc/letsencrypt/live

		#declare empty domains variable
		#DOMAINS=""
		
		#set all domains in this request
		#for DOM in "$@"
		#do
		#DOMAINS+=" -d $DOM"
		#done

		# Create or renew certificate for the domain(s) supplied for this tool
		$LE_TOOL certonly --expand -c $LE_CONF 
		#$DOMAINS

		# Cat the certificate chain and the private key together for haproxy
		if [ -d $LE_OUTPUT/$FIRST_DOMAIN ]; then
			if [[ -f $LE_OUTPUT/$FIRST_DOMAIN/fullchain.pem && -f $LE_OUTPUT/$FIRST_DOMAIN/privkey.pem ]]; then
				cat $LE_OUTPUT/$FIRST_DOMAIN/{fullchain.pem,privkey.pem} > /etc/haproxy/ssl/letsencrypt_$FIRST_DOMAIN.pem # We name the pem with a letsencrypt prefix
			fi
		fi
	fi

done

# look for correct haproxy conf and running
check_haproxy_config

# Committing changes because if we are there that's a sign that the files are correct
cd /etc/haproxy/
/usr/bin/git add .
/usr/bin/git commit -m "Renewal iteration : $TIMESTAMP"

# Reload the haproxy daemon to activate the cert
# systemctl reload haproxy.service
if
	ls /etc/haproxy/ssl/letsencrypt_* > /dev/null 2>&1 ; then
	service haproxy reload
	else
	echo "HAProxy not reloaded, because letsencrypt SSL NOT FOUND." | mail -s "haproxy01 - FATAL ERROR" mail@domain.tld
	exit 1
fi

echo "End of execution of script. Letsencrypt SSL done. HAProxy service reload" | /usr/bin/mail -s "haproxy01 - Creation / auto-renew DONE" mail@domain.tld

