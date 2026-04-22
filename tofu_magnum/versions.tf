terraform {
  required_version = ">= 1.8.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "openstack" {
  # Configuration options are usually set via environment variables (OS_*)
}
