POD_NAME=$(kubectl get pods | grep yarn-nm | awk '{print $1}')
kubectl exec -it "${POD_NAME}" -- bash
