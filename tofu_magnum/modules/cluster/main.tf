data "openstack_networking_network_v2" "auto_allocated_network_lookup" {
  name = "auto_allocated_network"
}

resource "openstack_containerinfra_cluster_v1" "cluster" {
  name                = var.cluster_name
  cluster_template_id = var.cluster_template_id
  master_count        = var.master_count
  master_flavor       = var.master_flavor
  node_count          = var.node_count
  flavor              = var.flavor
  docker_volume_size  = var.docker_volume_size
  keypair             = var.ssh_public_key
  fixed_network       = data.openstack_networking_network_v2.auto_allocated_network_lookup.id
  fixed_subnet        = data.openstack_networking_network_v2.auto_allocated_network_lookup.subnets[0]

  labels = merge(
    var.enable_autoscaling ? {
      auto_scaling_enabled = "true"
      min_node_count       = tostring(var.autoscaling_min_node_count)
      max_node_count       = tostring(var.autoscaling_max_node_count)
    } : {},
    var.labels
  )

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "local_file" "kubeconfig" {
  filename = var.kubeconfig_filename
  content  = openstack_containerinfra_cluster_v1.cluster.kubeconfig.raw_config
}
