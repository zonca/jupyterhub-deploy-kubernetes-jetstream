for f in *.yaml
do
    kubectl delete -f $f &
done
