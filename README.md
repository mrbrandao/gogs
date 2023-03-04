Gogs
------

This project configure and deploy gogs with postgresql database.  

Usage
------

You can start with the `podman-compose` commands e.g:  

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

Any port could be changes in the config files or can be exported with different values, check the [docker-compose](docker-compose.yml) to see the run example.


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

Author
-------

Igor Brandao @ibrand
