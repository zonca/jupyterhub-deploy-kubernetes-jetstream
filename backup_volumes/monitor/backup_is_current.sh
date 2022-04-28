#!/bin/sh
# exit when any command fails
set -e
current_unix_time=$(date +%s)
last_backup_date=$(restic snapshots --no-lock --latest 1 | grep stash | tr -s ' ' | cut -d" " -f2)
# The restic docker image doesn't have jq
# last_backup_unix_time=$(restic snapshots --json --latest 2 | jq -r '.[-1].time|strptime("%Y-%m-%dT%H:%M:%S.%Z")|mktime')
last_backup_unix_time=$(date -d $last_backup_date +%s)
hours_since_last_backup=$((current_unix_time-last_backup_unix_time))
hours_since_last_backup=$((hours_since_last_backup/3600))
echo Backup was executed $hours_since_last_backup hours ago
exit $(($hours_since_last_backup > 30))
