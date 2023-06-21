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
The flat form is configured to use *local* thesauri, namely for `opendata`, `datatype`, `politiquepublique`, `thematiques`, `dpsir`, `ebv`.
Having them as local thesauri allows them to be editable through the web UI. But when you import them into another catalog (for instance between test and prod), by default they are imported as *external* thesauri. There is now an option when importing a thesaurus to make it stored as a *local* one. ***Do select that option, if they are not imported as local thesauri, they will not be accessible from the flat form.***


## Upgrading GN
### Upgrade to 4.2.3

A new file has been added in the datadir, but if we already have initialized our datadir, it won't be copied automatically. So you'll have to copy it.
Run the following command, adapting the DEST_DATADIR value according to your config:
```
DEST_DATADIR=./volumes/geonetwork_data
# Create the destination folder since it probably won't exist, and give it to jetty user
sudo mkdir -p ${DEST_DATADIR}/data/resources/config/
sudo chown 999:999 ${DEST_DATADIR}/data/resources/config/
# Copy the file
docker-compose cp geonetwork:/var/lib/jetty/webapps/geonetwork/WEB-INF/data/data/resources/config/manual.json ${DEST_DATADIR}/data/resources/config/
```

You will also have to clear the GeoNetwork javascript cache: log in, go to admin / settings / tools and click "Clear JS & CSS cache".

### Upgrade to 4.2.4
There have been some changes in the way the search is configured. This is configured in the UI section (web UI -> Settings -> UI configuration).

To be sure to alter the less possible the default config, it is now possible to only override those sections that we need. We can indeed replace the whole json config by those few lines (CAS config)
```
{
  "mods": {
    "authentication": {
      "signinUrl": "../../{{node}}/{{lang}}/catalog.signin?casLogin"
    }
  }
}
```

You will also have to clear the GeoNetwork javascript cache: log in, go to admin / settings / tools and click "Clear JS & CSS cache".