FROM docker.io/library/postgres:10-alpine3.16
RUN mkdir -p /docker-entrypoint-initdb.d
COPY scripts/init-user-db.sh /docker-entrypoint-initdb.d/init-user-db.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-user-db.sh
