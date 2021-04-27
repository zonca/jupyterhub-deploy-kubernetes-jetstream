#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $DIR/jetstream-openrc.sh

OPENSTACK=/home/zonca/miniconda3/envs/openstack/bin/openstack
VAR=$($OPENSTACK volume list -f value -c ID -c Status | grep -i reserved | wc -l)

if [[ $VAR -gt 0 ]]
then
    echo $(date) >> $DIR/volume_reserved.log
    $OPENSTACK volume list | grep -i reserved >> $DIR/volume_reserved.log
    $OPENSTACK volume list -f value -c ID -c Status | grep -i reserved | awk \
        '{ print $1 }' | xargs -n1 $OPENSTACK volume set --state available
fi
