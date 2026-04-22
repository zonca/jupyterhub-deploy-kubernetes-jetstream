variable "cluster_name" {
  description = "Name of the Magnum Kubernetes cluster"
  type        = string
  default     = "k8s"
}

variable "cluster_template_id" {
  description = "Magnum cluster template ID"
  type        = string
}

variable "ssh_public_key" {
  description = "OpenStack keypair name"
  type        = string
}

variable "project_id" {
  description = "Jetstream allocation/project id in lowercase, e.g. cis230085"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for JupyterHub (prefix only)"
  type        = string
  default     = "k8s"
}

variable "letsencrypt_email" {
  description = "Email used by Let's Encrypt ACME account"
  type        = string
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

variable "worker_flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "m3.small"
}

variable "docker_volume_size" {
  description = "Root/docker disk size in GB"
  type        = number
  default     = 20
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
  default     = "./config"
}

variable "jhub_release_name" {
  description = "Helm release name for JupyterHub"
  type        = string
  default     = "jhub"
}

variable "jhub_namespace" {
  description = "Namespace for JupyterHub"
  type        = string
  default     = "jhub"
}

variable "jhub_chart_version" {
  description = "JupyterHub Helm chart version"
  type        = string
  default     = "4.3.1"
}

variable "jhub_values_file" {
  description = "Path to base JupyterHub values file"
  type        = string
  default     = "../../config_standard_storage.yaml"
}

variable "ingress_release_name" {
  description = "Helm release name for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_namespace" {
  description = "Namespace for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
}

variable "dns_zone_name" {
  description = "OpenStack DNS zone name. If null, defaults to <project_id>.projects.jetstream-cloud.org."
  type        = string
  default     = null
}
