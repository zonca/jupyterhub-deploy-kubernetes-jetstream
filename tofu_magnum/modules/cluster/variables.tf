variable "cluster_name" {
  description = "Name of the Magnum Kubernetes cluster"
  type        = string
  default     = "k8s"
}

variable "cluster_template_id" {
  description = "Magnum cluster template ID"
  type        = string
  default     = "ce4a54dd-7d3d-486c-ab61-71d7a02b3076" # kubernetes-1-33-jammy-fixed-labels
}

variable "master_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}

variable "master_flavor" {
  description = "Flavor for control plane nodes"
  type        = string
  default     = "m3.small"
}

variable "node_count" {
  description = "Initial number of worker nodes"
  type        = number
  default     = 2
}

variable "flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "m3.small"
}

variable "docker_volume_size" {
  description = "Root/docker disk size in GB"
  type        = number
  default     = 20
}

variable "ssh_public_key" {
  description = "OpenStack keypair name"
  type        = string
}

variable "labels" {
  description = "Additional labels for the cluster"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Enable Magnum autoscaling labels"
  type        = bool
  default     = true
}

variable "autoscaling_min_node_count" {
  description = "Minimum worker nodes for autoscaler"
  type        = number
  default     = 1
}

variable "autoscaling_max_node_count" {
  description = "Maximum worker nodes for autoscaler"
  type        = number
  default     = 5
}

variable "kubeconfig_filename" {
  description = "Local path to write kubeconfig"
  type        = string
  default     = "./kubeconfig"
}
