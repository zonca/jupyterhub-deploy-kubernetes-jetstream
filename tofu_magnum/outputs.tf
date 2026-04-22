output "kubeconfig_path" {
  description = "Path to the written kubeconfig file"
  value       = module.kubernetes_cluster.kubeconfig_path
}

output "cluster_id" {
  description = "ID of the created Magnum cluster"
  value       = module.kubernetes_cluster.cluster_id
}
