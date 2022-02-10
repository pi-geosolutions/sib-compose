# Geonetwork / GeoServer stack using docker-compose

## First run
Volumes are mounted from local folders. In order to get proper access rights on those folders, you should, before running the compo for the first time, create the folders with proper ACLs:
```
# Create the volumes
mkdir -p volumes/geonetwork_data volumes/geoserver_datadir volumes/geoserver_geodata volumes/geoserver_tiles volumes/backups/database
# SET ACLs
sudo chown -R 999:999 volumes/geonetwork_data volumes/geoserver_datadir volumes/geoserver_geodata volumes/geoserver_tiles
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
