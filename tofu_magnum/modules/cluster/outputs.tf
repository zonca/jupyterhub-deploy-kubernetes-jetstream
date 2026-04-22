output "cluster_id" {
  description = "ID of the created Magnum cluster"
  value       = openstack_containerinfra_cluster_v1.cluster.id
}

output "cluster_name" {
  description = "Name of the created Magnum cluster"
  value       = openstack_containerinfra_cluster_v1.cluster.name
}

output "kubeconfig_path" {
  description = "Path to the written kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "kubeconfig_raw" {
  description = "Raw content of the kubeconfig file"
  value       = openstack_containerinfra_cluster_v1.cluster.kubeconfig.raw_config
  sensitive   = true
}
