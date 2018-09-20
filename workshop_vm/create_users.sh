for n in $(seq 41 80 )
do
    echo $n
    sudo adduser train$n --disabled-password --gecos ""
done
