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

resource "null_resource" "install_ingress" {
  depends_on = [module.kubernetes_cluster]

  triggers = {
    cluster_id    = module.kubernetes_cluster.cluster_id
    ingress_chart = "ingress-nginx"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      /usr/local/bin/helm upgrade --install ${var.ingress_release_name} ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ${var.ingress_namespace} --create-namespace
    EOT
  }
}

resource "time_sleep" "wait_for_ingress_lb" {
  depends_on      = [null_resource.install_ingress]
  create_duration = "60s"
}

resource "null_resource" "bind_fixed_ip_to_ingress_lb" {
  depends_on = [time_sleep.wait_for_ingress_lb, openstack_networking_floatingip_v2.ingress_fixed_ip]

  triggers = {
    fixed_ip        = openstack_networking_floatingip_v2.ingress_fixed_ip.address
    ingress_release = var.ingress_release_name
    ingress_ns      = var.ingress_namespace
    cluster_id      = module.kubernetes_cluster.cluster_id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"

      INGRESS_IP=""
      for _ in $(seq 1 30); do
        INGRESS_IP=$(/home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl get svc -n ${var.ingress_namespace} ${var.ingress_release_name}-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)
        if [ -n "$INGRESS_IP" ]; then
          break
        fi
        sleep 10
      done

      if [ -z "$INGRESS_IP" ]; then
        echo "ingress-nginx external IP was not assigned" >&2
        exit 1
      fi

      VIP_PORT_ID=$(/home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack floating ip list --floating-ip-address "$INGRESS_IP" -f value -c Port)
      if [ -z "$VIP_PORT_ID" ]; then
        echo "could not find VIP port for ingress external IP: $INGRESS_IP" >&2
        exit 1
      fi

      EXISTING_FIP_ID=$(/home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack floating ip list --port "$VIP_PORT_ID" -f value -c ID | head -n1 || true)
      if [ -n "$EXISTING_FIP_ID" ]; then
        /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack floating ip unset --port "$EXISTING_FIP_ID"
      fi

      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack floating ip set --port "$VIP_PORT_ID" "${openstack_networking_floatingip_v2.ingress_fixed_ip.address}"
    EOT
  }
}

resource "null_resource" "manage_jhub_dns_record" {
  depends_on = [null_resource.bind_fixed_ip_to_ingress_lb]

  triggers = {
    ip    = openstack_networking_floatingip_v2.ingress_fixed_ip.address
    fqdn  = local.fqdn
    zone  = data.openstack_dns_zone_v2.project_zone.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      
      RECORD_ID=$(/home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack recordset list ${data.openstack_dns_zone_v2.project_zone.id} -f json | jq -r ".[] | select(.name == \"${local.fqdn}.\") | .id")
      
      if [ -n "$RECORD_ID" ]; then
        echo "Updating existing DNS record: $RECORD_ID"
        /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack recordset set --record "${openstack_networking_floatingip_v2.ingress_fixed_ip.address}" ${data.openstack_dns_zone_v2.project_zone.id} "$RECORD_ID"
      else
        echo "Creating new DNS record for ${local.fqdn}"
        /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/openstack recordset create --type A --record "${openstack_networking_floatingip_v2.ingress_fixed_ip.address}" ${data.openstack_dns_zone_v2.project_zone.id} "${local.fqdn}."
      fi
    EOT
  }
}

resource "null_resource" "install_cert_manager" {
  depends_on = [null_resource.bind_fixed_ip_to_ingress_lb]

  triggers = {
    cluster_id = module.kubernetes_cluster.cluster_id
    version    = "v1.16.2"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl -n cert-manager rollout status deployment/cert-manager --timeout=5m
      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=5m
      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=5m
    EOT
  }
}

resource "null_resource" "install_cluster_issuer" {
  depends_on = [null_resource.install_cert_manager, local_file.cluster_issuer]

  triggers = {
    cluster_id     = module.kubernetes_cluster.cluster_id
    cluster_issuer = sha256(local.issuer_yml)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"
      /home/zonca/zonca/p/software/jupyterhub-deploy-kubernetes-jetstream/.venv/bin/kubectl apply -f "${local_file.cluster_issuer.filename}"
    EOT
  }
}

resource "null_resource" "install_jupyterhub" {
  depends_on = [
    null_resource.manage_jhub_dns_record,
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
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      export KUBECONFIG="${module.kubernetes_cluster.kubeconfig_path}"

      /usr/local/bin/helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
      /usr/local/bin/helm repo update

      /usr/local/bin/helm upgrade --install ${var.jhub_release_name} jupyterhub/jupyterhub \
        --namespace ${var.jhub_namespace} \
        --create-namespace \
        --version ${var.jhub_chart_version} \
        --values "${var.jhub_values_file}" \
        --values "${local_file.jhub_secrets.filename}"
    EOT
  }
}
