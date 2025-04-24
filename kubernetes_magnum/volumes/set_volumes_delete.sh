#!/bin/bash

# Retrieve all PVCs across all namespaces
kubectl get pvc --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{";"}{.metadata.name}{"\n"}{end}' | while IFS=";" read -r namespace pvc; do
  # Get the associated PV name
  pv=$(kubectl get pvc "$pvc" -n "$namespace" -o jsonpath='{.spec.volumeName}')
  
  # Check if PV name is retrieved
  if [ -n "$pv" ]; then
    echo "Patching PV: $pv (from PVC $pvc in namespace $namespace)"
    kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
  else
    echo "PVC $pvc in namespace $namespace does not have an associated PV."
  fi
done

