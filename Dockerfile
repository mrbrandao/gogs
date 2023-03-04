FROM golang:alpine3.14 AS builder
RUN apk --no-cache --no-progress add --virtual \
  build-deps \
  build-base \
  git \
  linux-pam-dev

WORKDIR /gogs.io/gogs
RUN git clone --depth 1 --branch v0.12.9 https://github.com/gogs/gogs.git .
RUN make build TAGS="cert pam"

FROM alpine:3.14 as gogs
RUN if [ `uname -m` == "aarch64" ] ; then \
      export arch="arm64" ; \
  elif [ `uname -m` == "armv7l" ] ; then \
      export arch="armhf"; \
  else \
      export arch="amd64" ; \
  fi \
  && wget https://github.com/tianon/gosu/releases/download/1.11/gosu-$arch -O /usr/sbin/gosu \
  && chmod +x /usr/sbin/gosu \
  && echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories \
  && apk --no-cache --no-progress add \
  bash \
  ca-certificates \
  curl \
  git \
  linux-pam \
  openssh \
  s6 \
  shadow \
  socat \
  tzdata \
  rsync

ENV GOGS_CUSTOM /data/gogs

# Customizing templates
RUN mkdir -p /data/gogs/public/img ;\
    mkdir -p /data/gogs/public/css ;\
    mkdir -p /templates/inject
COPY custom/public/css/dark-theme-evang.css /data/gogs/public/css/custom.css
COPY custom/templates/inject/head.tmpl /data/gogs/templates/inject/head.tmpl
COPY custom/public/img/gopher-forest-reduce.png /data/gogs/public/img/gogs-hero.png
COPY custom/public/img/gopher-classic.png /data/gogs/public/img/favicon.png

WORKDIR /app/gogs
COPY --from=builder /gogs.io/gogs/docker ./docker
COPY --from=builder /gogs.io/gogs/gogs .

# Configure LibC Name Service
RUN cp ./docker/nsswitch.conf /etc/nsswitch.conf
RUN ./docker/finalize.sh

# Configure Docker Container
VOLUME ["/data", "/backup"]
EXPOSE 22 3000
HEALTHCHECK CMD (curl -o /dev/null -sS http://localhost:3000/healthcheck) || exit 1
ENTRYPOINT ["/app/gogs/docker/start.sh"]
CMD ["/bin/s6-svscan", "/app/gogs/docker/s6/"]
