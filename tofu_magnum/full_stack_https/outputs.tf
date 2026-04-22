output "cluster_id" {
  description = "Magnum cluster ID"
  value       = module.kubernetes_cluster.cluster_id
}

output "kubeconfig_path" {
  description = "Local kubeconfig file path"
  value       = module.kubernetes_cluster.kubeconfig_path
}

output "jupyterhub_url" {
  description = "JupyterHub URL"
  value       = "https://${local.fqdn}"
}

output "ingress_fixed_ip" {
  description = "Fixed floating IP bound to ingress-nginx"
  value       = openstack_networking_floatingip_v2.ingress_fixed_ip.address
}
