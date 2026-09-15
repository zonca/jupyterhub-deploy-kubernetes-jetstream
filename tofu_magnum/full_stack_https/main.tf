module "kubernetes_cluster" {
  source = "../modules/cluster"

  cluster_name        = var.cluster_name
  cluster_template_id = var.cluster_template_id
  master_count        = var.master_count
  master_flavor       = var.master_flavor
  node_count          = var.node_count
  flavor              = var.worker_flavor
  docker_volume_size  = var.docker_volume_size
  ssh_public_key      = var.ssh_public_key

  enable_autoscaling         = var.enable_autoscaling
  autoscaling_min_node_count = var.autoscaling_min_node_count
  autoscaling_max_node_count = var.autoscaling_max_node_count

  kubeconfig_filename = var.kubeconfig_filename
}

resource "openstack_networking_floatingip_v2" "ingress_fixed_ip" {
  pool = "public"

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  fqdn     = "${var.subdomain}.${var.project_id}.projects.jetstream-cloud.org"
  dns_zone = coalesce(var.dns_zone_name, "${var.project_id}.projects.jetstream-cloud.org.")
  issuer_yml = templatefile("${path.module}/templates/https_cluster_issuer.yml.tftpl", {
    letsencrypt_email = var.letsencrypt_email
  })
  jhub_secrets_yml = templatefile("${path.module}/templates/jhub_secrets.yaml.tftpl", {
    host          = local.fqdn
    cookie_secret = random_id.jhub_cookie_secret.hex
    proxy_token   = random_id.jhub_proxy_secret.hex
  })
}

data "openstack_dns_zone_v2" "project_zone" {
  name = local.dns_zone
}

resource "random_id" "jhub_cookie_secret" {
  byte_length = 32
}

resource "random_id" "jhub_proxy_secret" {
  byte_length = 32
}

resource "local_file" "jhub_secrets" {
  filename = "${path.module}/rendered-secrets.yaml"
  content  = local.jhub_secrets_yml
}

resource "local_file" "cluster_issuer" {
  filename = "${path.module}/rendered-https-cluster-issuer.yml"
  content  = local.issuer_yml
}

resource "null_resource" "install_traefik" {
  depends_on = [module.kubernetes_cluster]

  triggers = {
    cluster_id    = module.kubernetes_cluster.cluster_id
    traefik_chart = var.traefik_chart_version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      helm repo add traefik https://traefik.github.io/charts
      helm repo update
      helm upgrade --install ${var.traefik_release_name} traefik/traefik \
        --version ${var.traefik_chart_version} \
        --namespace ${var.traefik_namespace} --create-namespace
    EOT
  }
}

resource "time_sleep" "wait_for_traefik_lb" {
  depends_on      = [null_resource.install_traefik]
  create_duration = "60s"
}

resource "null_resource" "bind_fixed_ip_to_traefik_lb" {
  depends_on = [time_sleep.wait_for_traefik_lb, openstack_networking_floatingip_v2.ingress_fixed_ip]

  triggers = {
    fixed_ip        = openstack_networking_floatingip_v2.ingress_fixed_ip.address
    traefik_release = var.traefik_release_name
    traefik_ns      = var.traefik_namespace
    cluster_id      = module.kubernetes_cluster.cluster_id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"

      INGRESS_IP=""
      for _ in $(seq 1 30); do
        INGRESS_IP=$(kubectl get svc -n ${var.traefik_namespace} ${var.traefik_release_name} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)
        if [ -n "$INGRESS_IP" ]; then
          break
        fi
        sleep 10
      done

      if [ -z "$INGRESS_IP" ]; then
        echo "traefik external IP was not assigned" >&2
        exit 1
      fi

      VIP_PORT_ID=$(openstack floating ip list --floating-ip-address "$INGRESS_IP" -f value -c Port)
      if [ -z "$VIP_PORT_ID" ]; then
        echo "could not find VIP port for traefik external IP: $INGRESS_IP" >&2
        exit 1
      fi

      EXISTING_FIP_ID=$(openstack floating ip list --port "$VIP_PORT_ID" -f value -c ID | head -n1 || true)
      if [ -n "$EXISTING_FIP_ID" ]; then
        openstack floating ip unset --port "$EXISTING_FIP_ID"
      fi

      openstack floating ip set --port "$VIP_PORT_ID" "${openstack_networking_floatingip_v2.ingress_fixed_ip.address}"
    EOT
  }
}

resource "openstack_dns_recordset_v2" "jhub_record" {
  depends_on = [null_resource.bind_fixed_ip_to_traefik_lb]

  zone_id  = data.openstack_dns_zone_v2.project_zone.id
  name     = "${local.fqdn}."
  type     = "A"
  records  = [openstack_networking_floatingip_v2.ingress_fixed_ip.address]
  ttl      = 3600
}

resource "null_resource" "install_cert_manager" {
  depends_on = [null_resource.bind_fixed_ip_to_traefik_lb]

  triggers = {
    cluster_id = module.kubernetes_cluster.cluster_id
    version    = var.certmanager_version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${var.certmanager_version}/cert-manager.yaml
      kubectl -n cert-manager rollout status deployment/cert-manager --timeout=5m
      kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=5m
      kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=5m
    EOT
  }
}

resource "null_resource" "pin_certmanager_to_control_plane" {
  depends_on = [null_resource.install_cert_manager]

  triggers = {
    cluster_id = module.kubernetes_cluster.cluster_id
    patch_hash = filesha256("${path.module}/templates/deploymentPatch.yml")
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      for DEPLOYMENT in cert-manager cert-manager-cainjector cert-manager-webhook; do
        kubectl -n cert-manager patch deployment "$DEPLOYMENT" --patch-file "${path.module}/templates/deploymentPatch.yml"
        kubectl -n cert-manager rollout status deployment "$DEPLOYMENT" --timeout=5m
      done
    EOT
  }
}

resource "null_resource" "install_cluster_issuer" {
  depends_on = [null_resource.pin_certmanager_to_control_plane, local_file.cluster_issuer]

  triggers = {
    cluster_id     = module.kubernetes_cluster.cluster_id
    cluster_issuer = sha256(local.issuer_yml)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      kubectl apply -f "${local_file.cluster_issuer.filename}"
    EOT
  }
}

resource "null_resource" "install_jupyterhub" {
  depends_on = [
    openstack_dns_recordset_v2.jhub_record,
    null_resource.install_cluster_issuer,
    local_file.jhub_secrets,
  ]

  triggers = {
    cluster_id         = module.kubernetes_cluster.cluster_id
    jhub_values_hash   = filesha256(var.jhub_values_file)
    jhub_secret_hash   = sha256(local.jhub_secrets_yml)
    jhub_chart_version = var.jhub_chart_version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"

      helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
      helm repo update

      helm upgrade --install ${var.jhub_release_name} jupyterhub/jupyterhub \
        --namespace ${var.jhub_namespace} \
        --create-namespace \
        --version ${var.jhub_chart_version} \
        --values "${var.jhub_values_file}" \
        --values "${local_file.jhub_secrets.filename}"
    EOT
  }
}
