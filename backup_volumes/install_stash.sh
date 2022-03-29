helm upgrade stash appscode/stash          \
  --install \
  --version v2022.02.22                \
  --namespace kube-system                     \
  --set features.community=true               \
  --set-file global.license=license.txt
