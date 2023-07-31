resource "openstack_networking_secgroup_v2" "k8_master" {
  name                 = var.namespace == "" ? "k8-master" : "k8-master-${var.namespace}"
  description          = "Security group for kubernetes master"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_worker" {
  name                 = var.namespace == "" ? "k8-worker" : "k8-worker-${var.namespace}"
  description          = "Security group for kubernetes workers"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_load_balancer" {
  name                 = var.namespace == "" ? "k8-lb" : "k8-lb-${var.namespace}"
  description          = "Security group for kubernetes load balancer"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_master_client" {
  name                 = var.namespace == "" ? "k8-master-client" : "k8-master-client-${var.namespace}"
  description          = "Security group for direct client of kubernetes workers"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_worker_client" {
  name                 = var.namespace == "" ? "k8-worker-client" : "k8-worker-client-${var.namespace}"
  description          = "Security group for direct client of kubernetes masters"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_bastion" {
  name                 = var.namespace == "" ? "k8-bastion" : "k8-bastion-${var.namespace}"
  description          = "Security group for cluster's bastion"
  delete_default_rules = true
}

//Allow all outbound traffic for masters, workers, load balancer and bastion
resource "openstack_networking_secgroup_rule_v2" "k8_master_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_load_balancer_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_load_balancer_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_bastion_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.k8_bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_bastion_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.k8_bastion.id
}

//Allow all traffic between masters and workers
resource "openstack_networking_secgroup_rule_v2" "k8_master_peer_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_master.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_worker_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_worker.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_peer_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_worker.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_master_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_master.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

#Allow icmp traffic from the load balancer and bastion
resource "openstack_networking_secgroup_rule_v2" "k8_worker_lb_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_lb_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_lb_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_lb_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_bastion_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_bastion_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_bastion_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_master_bastion_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

#Allow api traffic from the load balancer
resource "openstack_networking_secgroup_rule_v2" "lb_api_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.masters_api_port
  port_range_max    = var.masters_api_port
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

#Allow ingress http and https traffic from the load balancer
resource "openstack_networking_secgroup_rule_v2" "lb_ingress_http_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_http_port
  port_range_max    = var.workers_ingress_http_port
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_https_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_https_port
  port_range_max    = var.workers_ingress_https_port
  remote_group_id  = openstack_networking_secgroup_v2.k8_load_balancer.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

#Allow external traffic on the load balancer for the api, ingress and icmp
resource "openstack_networking_secgroup_rule_v2" "lb_api_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_http_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_https_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

#Allow all master inbound traffic from master clients
resource "openstack_networking_secgroup_rule_v2" "k8_master_client_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_master_client.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

#Allow all worker inbound traffic from worker clients
resource "openstack_networking_secgroup_rule_v2" "k8_worker_client_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = openstack_networking_secgroup_v2.k8_worker_client.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

#Allow ssh traffic from the bastion
resource "openstack_networking_secgroup_rule_v2" "bastion_lb_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_master_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_worker_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

#Allow external traffic to the bastion for ssh and icmp
resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_external_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_external_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.k8_bastion.id
}

#Allow direct api access from the bastion
resource "openstack_networking_secgroup_rule_v2" "bastion_master_api_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.masters_api_port
  port_range_max    = var.masters_api_port
  remote_group_id  = openstack_networking_secgroup_v2.k8_bastion.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}