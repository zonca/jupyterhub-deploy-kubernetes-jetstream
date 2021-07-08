for id in $(restic -r $RESTIC_REPO snapshots --json | jq -r '.[]["id"]')
do
    echo "**** ID is $id ****"
    username=$(restic -r $RESTIC_REPO dump $id stash-data/.username)
    if [ $? -eq 0 ]; then
        restic -r $RESTIC_REPO tag --set $username $id
    fi
    echo $id $username
done
