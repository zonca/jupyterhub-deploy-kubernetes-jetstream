for id in $(restic -r $RESTIC_REPO snapshots --json | jq -r '.[]["id"]')
do
    username=$(restic -r $RESTIC_REPO dump $id stash-data/.username)
    restic -r $RESTIC_REPO tag --set $username $id
    echo $id $username
done
