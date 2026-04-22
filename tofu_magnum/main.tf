module "kubernetes_cluster" {
  source = "./modules/cluster"

  cluster_name = "k8s-tofu-only-test"
  cluster_template_id = var.cluster_template_id
  ssh_public_key      = var.ssh_public_key

  node_count = 2
  flavor     = "m3.small"

  enable_autoscaling         = true
  autoscaling_min_node_count = 1
  autoscaling_max_node_count = 5

  kubeconfig_filename = "kubeconfig"
}
