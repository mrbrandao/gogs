#!/bin/sh
# sync custom themes and templates

# adding s6 scan after sync
s6svscan() {
  exec /bin/s6-svscan /app/gogs/docker/s6/
}

sync() {
  echo "Syncing Custom Themes and Templates"
  cp -Rpavf /custom/theme/gogs/* /data/gogs
  chown -R git:git /data/gogs
}

main() {
  sync
  s6svscan
}

main
