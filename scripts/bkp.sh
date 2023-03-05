#!/bin/env bash
# This script is a demo to backup and restore gogs
# it can be used as an inspiration to create automate backups and restores
# Backup and restore should be easy but some tricks and clean-ups could apear
# this script demonstrates a working version of it with containers
# Some references of common issues can be found from bellow links:
# [Failed to restore in containers because of cross-device-link](https://github.com/gogs/gogs/issues/4339#issuecomment-358339037)
# [Backup and Restore rules](https://github.com/gogs/gogs/discussions/6876)

arg="$1"
file="$2"

case "$arg" in
  backup)
    podman exec --user git gogs_gogs_1 ./gogs backup --target /backup
  ;;
  restore)
    # some clean-ups must be done in order to full restore gogs
    # the actions are:
    # 1. create the tmp directory to extract the temp zip avoiding the cross-device-link error
    # 2. clean the gogs-repositories to avoid permissions errors
    # 3. restore the full compressed backup
    # 4. find and remove all .bak directories avoiding it to be backup in the next backup
    # 5. restart gogs daemon
    # 6. remove the temporary restoration directory 
    podman exec --user git gogs_gogs_1 bash -c "mkdir -p /data/tmp; \
      rm -rf /data/git/gogs-repositories; \
      /app/gogs/gogs restore --from "$file" -t /data/tmp/; \
      find /data -type d -name '*.bak' -exec rm -rf {} \+; \
      pkill -HUP gogs; \
      rm -rf /data/tmp"
  ;;
  *|help)
    echo -e "Usage:
    $0 backup \t\t\t\t\t- Creates a ziped backup file in the /backup volume directory
    $0 restore /backup/file.zip \t\t\t- Restore a backup from the specified path
    "
  ;;
esac
