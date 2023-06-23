data "template_cloudinit_config" "k8_members_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = file("${path.module}/templates/k8-cloud_config.yaml")
  }
}

resource "openstack_networking_port_v2" "masters" {
  count           = var.masters_count
  name           = var.namespace == "" ? "k8-master-${count.index + 1}" : "k8-master-${count.index + 1}-${var.namespace}"
  network_id     = var.network_id
  security_group_ids = concat(var.masters_extra_security_group_ids, [openstack_networking_secgroup_v2.k8_master.id])
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "masters" {
  count           = var.masters_count
  name            = var.namespace == "" ? "k8-master-${count.index + 1}" : "k8-master-${count.index + 1}-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.masters_flavor_id
  key_pair        = var.keypair_name
  user_data       = data.template_cloudinit_config.k8_members_config.rendered

  network {
    port = openstack_networking_port_v2.masters[count.index].id
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "openstack_networking_port_v2" "workers" {
  count           = var.workers_count
  name           = var.namespace == "" ? "k8-worker-${count.index + 1}" : "k8-worker-${count.index + 1}-${var.namespace}"
  network_id     = var.network_id
  security_group_ids = concat(var.workers_extra_security_group_ids, [openstack_networking_secgroup_v2.k8_worker.id])
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "workers" {
  count           = var.workers_count
  name            = var.namespace == "" ? "k8-worker-${count.index + 1}" : "k8-worker-${count.index + 1}-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.workers_flavor_id
  key_pair        = var.keypair_name
  user_data       = data.template_cloudinit_config.k8_members_config.rendered

  network {
    port = openstack_networking_port_v2.workers[count.index].id
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

data "template_cloudinit_config" "load_balancer_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/lb-cloud_config.yaml", {
        haproxy_config = templatefile(
            "${path.module}/templates/lb-haproxy.cfg",
            {
              nameserver_ips = var.nameserver_ips
              internal_k8_domain = var.internal_k8_domain
              k8_ingress_http_timeout = var.workers_ingress_http_timeout
              k8_ingress_http_port = var.workers_ingress_http_port
              k8_ingress_max_http_connections = var.workers_ingress_max_http_connections
              k8_ingress_https_timeout = var.workers_ingress_https_timeout
              k8_ingress_https_port = var.workers_ingress_https_port
              k8_ingress_max_https_connections = var.workers_ingress_max_https_connections
              k8_api_timeout = var.masters_api_timeout
              k8_api_port = var.masters_api_port
              k8_max_api_connections = var.masters_max_api_connections
              k8_max_masters_count = var.k8_max_masters_count
              k8_max_workers_count = var.k8_max_workers_count
            }
        )
    })
  }
}

resource "openstack_networking_port_v2" "load_balancer" {
  name           = var.namespace == "" ? "k8-lb" : "k8-lb-${var.namespace}"
  network_id     = var.network_id
  security_group_ids = [openstack_networking_secgroup_v2.k8_load_balancer.id]
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "load_balancer" {
  name            = var.namespace == "" ? "k8-lb" : "k8-lb-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.load_balancer_flavor_id
  key_pair        = var.keypair_name
  user_data       = data.template_cloudinit_config.load_balancer_config.rendered

  network {
    port = openstack_networking_port_v2.load_balancer.id
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}