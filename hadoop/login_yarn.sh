POD_NAME=$(kubectl get pods | grep yarn-nm-0 | awk '{print $1}')
kubectl exec -it "${POD_NAME}" -- bash
