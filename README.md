# Geonetwork / GeoServer stack using docker-compose

## First run
Volumes are mounted from local folders. In order to get proper access rights on those folders, you should, before running the compo for the first time, create the folders with proper ACLs:
```
# Create the volumes
VOLUMES_PATH=volumes
mkdir -p $VOLUMES_PATH/geonetwork_data $VOLUMES_PATH/geoserver_datadir $VOLUMES_PATH/geoserver_geodata $VOLUMES_PATH/geoserver_tiles $VOLUMES_PATH/backups/database
# SET ACLs
sudo chown -R 999:999 $VOLUMES_PATH/geonetwork_data $VOLUMES_PATH/geoserver_datadir $VOLUMES_PATH/geoserver_geodata $VOLUMES_PATH/geoserver_tiles
```

## Configure

You shouldn't have much configuration to do. You can set the domain name in the .env file. It is used in different places in the docker-compose compo.

## Nginx SSL / Certbot configuration
I've followed the instructions on https://mindsers.blog/fr/post/configurer-https-nginx-docker-lets-encrypt/
It's not fully automated, but easy to set up manually, and I'm expected a paid SSL certificate from MNHN anyway

To start it from scratch, you need a temporary certificate, so that nginx acceptes to start:
```
# LOAD env vars
source .env
# Create some folders for volumes
mkdir -p {certbot,geonetwork_data}
sudo chown -R 999:999 geonetwork_data

# Start a temporary composition to create the first certificate
docker-compose -f docker-compose-init-certs.yml up -d
docker-compose -f docker-compose-init-certs.yml run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/  -d $FQDN
docker-compose -f docker-compose-init-certs.yml down

# start the compo
docker-compose up -d
```

Renewing later the certificate can be done using `docker-compose run --rm certbot renew`

## CAS config

### GN
On geonetwork, this is backed in the docker image: an entrypoint file makes the necessary configuration, so it is working directly.
The docker image used for thic composition is built out of the code from the following git repo: TODO

For users to be able to log in, they must preexist in the GN database. Use the Users' management interface in GN Admin console to create them.
You can define a set of predefined admin users by listing their ids in the ADMIN_USERS environment variable in docker-compose.yml.


### GS
On Geoserver, the CAS configuration is done after deployment, on the web UI. Follow https://docs.geoserver.org/latest/en/user/security/tutorials/cas/index.html and in the filter chains, put it always on the top (or follow the instructions from https://docs.geoserver.org/latest/en/user/extensions/cas/index.html#example-cas-configuration)

There is for now a bug when logout from geoserver: the redirect on the cas side will not work, because GS provides the wrong parameter (`url` instead of `service`). The bug is documented on jira: https://osgeo-org.atlassian.net/browse/GEOS-10342

## Thesauri management and flat form
The flat form is configured to use *local* thesauri, namely `opendata`, `datatype`, `politiquepublique`, `thematiques`, `dpsir`, `ebv`.
Having them as local thesauri allows them to be editable through the web UI. But when you download them then import them, they will be stored as external (we don't have the choice). So, if we do nothing, the thesauri selectors in the flat form won't work anymore.
Consequently, it is necessary to move them to the local folder. You can run the script `thesaurus-make-local.sh` for this. You should check that the DATADIR_PATH var is correct.
***It looks like it is not enough for GN: apparently it loads the thesauri on startup, so you'll also need to restart GN to get them seen as local thesauri.***
