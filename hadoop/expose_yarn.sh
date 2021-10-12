# NEVER EXPOSE ON PUBLIC PORT https://tolisec.com/yarn-botnet/
kubectl get pods | grep yarn-rm | awk '{print $1}' | xargs -i kubectl port-forward -n default {} 8088:8088
