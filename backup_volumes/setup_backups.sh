export HOUR=8
export MIN=0
export MINSPACING=10
while read USER; do
      echo "******** Setup $USER at $HOUR:$MIN"
      envsubst < stash_backupconfiguration_template.yaml | kubectl apply -f -
      export MIN=$((MIN + MINSPACING))
      if [ $MIN -ge 60 ]
      then
          export HOUR=$((HOUR+1))
          export MIN=$((MIN - 60))
      fi
done <users_to_backup.txt
