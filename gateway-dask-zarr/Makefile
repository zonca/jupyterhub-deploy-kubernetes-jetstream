I=zonca/gateway-dask-zarr
C=gateway
N=jhub
build:
	docker build . -t $I:latest
start:
	docker run -d --name $C -p 80:8000 $I
stop:
	docker rm -f $C
rerun: stop build start

log :
	docker logs $C
push :
	docker push $I
deprun :
	kubectl -n $N create -f deploy_gateway.yaml
depdelete :
	kubectl -n $N delete -f deploy_gateway.yaml
deprerun : depdelete deprun
