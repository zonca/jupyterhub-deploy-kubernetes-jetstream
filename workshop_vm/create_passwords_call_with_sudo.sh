PASSWORD="samepassword"
for n in $(seq 41 80 )
do
    echo $n
    echo "train$n:$PASSWORD"|chpasswd
done
