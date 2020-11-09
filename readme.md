# Script to automate the process of generating letsencrypt acme-challenge for your dns

## how to start?
* Download the repository
* make the .sh scripts executable with ```chmod +x```
* Run the script with ```./run.sh arg1 arg2 arg3 arg4```

```
arg1: DOMAIN to be validated
arg2: E-Mail for letsencrypt
arg3: The path where you want to store the haproxy ssl file
arg4 (only if hurricane electric): if you use hurricane electric, your password for the txt
```
* if it works you can add an entry to ```crontab -e```

Entry example:
```1 1 1 */2 * sh /home/username/certbot/run.sh arg1 arg2 arg3 arg4```
