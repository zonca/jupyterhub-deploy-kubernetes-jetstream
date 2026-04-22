variable "ssh_public_key" {
  description = "Name of the SSH public key in OpenStack"
  type        = string
  default     = ""
}

variable "cluster_template_id" {
  description = "The ID of the Magnum cluster template to use"
  type        = string
  default     = "ce4a54dd-7d3d-486c-ab61-71d7a02b3076"
}
