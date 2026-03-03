terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }
  }
}

provider "openstack" {
  # Configuration options
}

resource "openstack_containerinfra_cluster_v1" "cluster" {
  name                = "opentofu-testing"
  cluster_template_id = var.cluster_template_id
  master_count        = 1
  master_flavor       = "m3.small"
  node_count          = 2
  flavor              = "m3.small"
  docker_volume_size  = 20
  keypair             = var.ssh_public_key
  fixed_network       = data.openstack_networking_network_v2.auto_allocated_network_lookup.id
  fixed_subnet        = data.openstack_networking_network_v2.auto_allocated_network_lookup.subnets[0]
  labels = {
    auto_scaling_enabled = "true"
    min_node_count       = 1
    max_node_count       = 5
  }
}

data "openstack_networking_network_v2" "auto_allocated_network_lookup" {
  name = "auto_allocated_network"

}
resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = <<-EOT
    ${openstack_containerinfra_cluster_v1.cluster.kubeconfig.raw_config}
    EOT
}

output "kubeconfig" {
  description = "Path to kubeconfig file"
  value       = openstack_containerinfra_cluster_v1.cluster.kubeconfig
  sensitive   = true
}

variable "ssh_public_key" {
  default     = ""
  description = "name of ssh public key"
  type        = string
}

variable "cluster_template_id" {
  default = "ff32fc8d-23de-417f-b6cc-5f03f2aa6628"

}

# todo later: make a cluster template lookup so we don't have to
# hardcode the template id
# data "openstack_containerinfra_clustertemplate_v1" "ct_lookup" {
#     name = "kubernetes-1-33-jammy"

# }