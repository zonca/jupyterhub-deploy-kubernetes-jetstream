 while read f; do
     echo $f
     cd $f
     sudo runuser -l $f -c 'bash ../clean_one.sh'
     cd ..
 done < use.txt
