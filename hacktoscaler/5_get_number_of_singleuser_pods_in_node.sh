kubectl -n jhub get pods -l "component=singleuser-server"  --field-selector spec.nodeName=$1 | wc -l
