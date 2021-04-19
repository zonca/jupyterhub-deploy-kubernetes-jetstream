helm install stash appscode/stash          \
  --version v2021.03.17                \
  --namespace kube-system                     \
  --set features.community=true               \
  --set-file global.license=license.txt
