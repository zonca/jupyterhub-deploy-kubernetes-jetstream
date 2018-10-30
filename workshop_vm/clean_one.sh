source openrc.sh
cd jetstream_kubespray/inventory/$(whoami)
echo $(pwd)
export CLUSTER=$(whoami)
nohup bash terraform_destroy.sh &
