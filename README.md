Gogs
------

This project configure and deploy gogs with postgresql database.  
Gogs is a painless self-hosted Git service written in go.
The project is available at https://gogs.io/

Here you can find the automation to deploy gogs using containers and create automated backup and restore for your repositories.

Usage
------

You can start this project in your local machine with the `podman-compose` commands e.g:  

Starting the gogs container and postgresql  
```bash
podman-compose up --build
```
This command will also create the local voulmes for gogs and postgres

Volumes
--------

Gogs and postgres are stateful application you will need to save or create volumes.  

##### gogs volumes

The gogs volumes are the following:  

* `/data` - all the gogs data will be saved here
* `/backup` - it's an optional volume you can declare and use to create gogs backups


##### postgresql volumes

The postgresql volumes are the following:

* `/var/lib/postgresql/data` - the default postgres volume


Ports
------

* `22` - gogs by default declare the default ssh port 22
_This port could be changed during the first run or in the admin.conf file._

* `3000` - this is the web UI http default port for gogs
* `5432` - this is the default TCP port for postgresql

Any port could be changes in the config files or can be exported with different values, check the [docker-compose](docker-compose.yml) to see the "run" example.


Environments
-------------

This project is based on the official [postgresql](...) from docker hub and it's possible to list all the configurations available there, however here goes a quick resume.  

* `POSTGRES_PASSWORD` - the default password for the `postgres` admin user  
* `GOGS_PASSWORD` - the password to be used by the gogs db admin user
* `GOGS_USER` - the gogs db administrator
* `POSTGRES_DB` - the database that will be created in the first run

Custom Scripts
--------------

In the scripts directory there are some useful scripts used to create and build this project.  

* `init-user-db.sh` - this script is resposable to initialize custom `sql` commands in the postgres first run. This will create the gogs user and grant admin permissions to it based on the `GOGS_*` environments.  
* `scripts/bkp.sh` - this script is a demonstration of how to use backup and restore with gogs
**The backup Usage:**  
Gogs backup and restore is a built-in functionality, however use it with containers can be trick regarding some clean-ups that should be done.
use `./scripts/bkp.sh help` to get the CLI usage help.

Deploy
-------

The `deployments` directory contains some basic examples on how to deploy this project on k8s.  
The `gogs-app` is a StatefulSet resource deploying the `gogs-app` and `postgresql` in the same pod. Postgres is working as a sidecar container for the gogs-app in order to minify and simplify the architecture.  
While there's no helm chart yet feel free to change the YAML's to suit your needs.
However the current set is designed to be deployed in k3s.

Deploy on your k3s with:  
```bash
kubectl apply -f deployments/pvc.yml
kubectl apply -f deployments/deployment.yml
```
  
**Containers:**  
* `gogs` - the main gogs app
* `gogsdb` - the postgresql database container
  
**PVC's:**  
* `gogs-pvc` - the main gogs data volume mounted in `/data`  
* `gogsbkp-pvc` - the backup volume mounted in gogs container `/backup` 
* `gogsdb-pvc` - the postgresql database volume mounted in `/var/lib/postgres/data`  
  
**Ports:**  
* `32222` - exported via nodePort to be used with ssh repos  
* `32300` - exported via nodePort to be used by the http UI

_the postgresql is running as a sidecar in the same pod with the gogs app_  

References
-----------

* [The main project gogs.io](https://gogs.io/)
* [Backup and Restore rules](https://github.com/gogs/gogs/discussions/6876)  
* [Failed to restore in containers because of cross-device-link](https://github.com/gogs/gogs/issues/4339#issuecomment-358339037)  

Author
-------

Igor Brandao @mrbrandao
