locals {
  vm_prefix = var.k8_annotation != "" ? "k8-${var.k8_annotation}" : "k8"
}

data "template_cloudinit_config" "k8_members_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = file("${path.module}/templates/k8-cloud_config.yaml")
  }
}

resource "openstack_compute_instance_v2" "masters" {
  count           = var.masters_count
  name            = var.namespace == "" ? "${local.vm_prefix}-master-${count.index + 1}" : "${local.vm_prefix}-master-${count.index + 1}-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.masters_flavor_id
  key_pair        = var.keypair_name
  security_groups = var.masters_security_groups
  user_data       = data.template_cloudinit_config.k8_members_config.rendered

  network {
    name = var.network_name
  }
}

resource "openstack_compute_instance_v2" "workers" {
  count           = var.workers_count
  name            = var.namespace == "" ? "${local.vm_prefix}-worker-${count.index + 1}" : "${local.vm_prefix}-worker-${count.index + 1}-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.workers_flavor_id
  key_pair        = var.keypair_name
  security_groups = var.workers_security_groups
  user_data       = data.template_cloudinit_config.k8_members_config.rendered

  network {
    name = var.network_name
  }
}

data "template_cloudinit_config" "load_balancer_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/lbl-cloud_config.yaml", {
        master_ips = [for node in openstack_compute_instance_v2.masters: node.network.0.fixed_ip_v4]
    })
  }
}

resource "openstack_compute_instance_v2" "load_balancer" {
  count           = var.load_balancer_flavor_id != "" ? 1 : 0
  name            = var.namespace == "" ? "${local.vm_prefix}-masters-lb" : "${local.vm_prefix}-masters-lb-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.load_balancer_flavor_id
  key_pair        = var.keypair_name
  security_groups = var.load_balancer_security_groups
  user_data       = data.template_cloudinit_config.load_balancer_config.rendered

  network {
    name = var.network_name
  }
}