# letsencrypt-certbot-haproxy-mass-domains
Automatic LetsEncrypt SSL certificates multi domains with HaProxy
(https://blog.ikoula.com/fr/etude-deploiement-utilisation-certificats-lets-encrypt)

## Usage

To make executable these differents scripts, you must make the following changes:

file :

**03 - letsencrypt-final.sh** :

- specify your mail adress to recevie mail advertise (you must install mail server (ssmtp))

**testdig.sh** :

- specify the public adress IP of your server in the "dig -t a" test

- specify the domain name of your server in the "dig -t cname" test


Launch in this order :

**01 - create_files.sh** file_with_domains

**02 - create_inis.sh**

**03 - letsencrypt-final.sh**
