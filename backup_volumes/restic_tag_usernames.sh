for id in $(restic snapshots --latest 12 --json | jq -r '.[]["id"]')
do
    echo "**** ID is $id ****"
    username=$(restic dump $id stash-data/.username)
    if [ $? -eq 0 ]; then
        restic tag --set $username $id
    fi
    echo $id $username
done
