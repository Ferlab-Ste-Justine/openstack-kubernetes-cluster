
output "masters" {
  value = [
    for node in openstack_compute_instance_v2.masters : { 
      id = node.id 
      ip = node.network.0.fixed_ip_v4
    } 
  ]
}

output "workers" {
  value = [
    for node in openstack_compute_instance_v2.workers : {
      id = node.id
      ip = node.network.0.fixed_ip_v4 
    }
  ]
}

output "load_balancer" {
    value = {
      id = openstack_compute_instance_v2.load_balancer.id
      ip = openstack_compute_instance_v2.load_balancer.network.0.fixed_ip_v4
    }
}

output "groups" {
  value = {
    bastion = openstack_networking_secgroup_v2.k8_bastion
    master_client = openstack_networking_secgroup_v2.k8_master_client
    worker_client = openstack_networking_secgroup_v2.k8_master_client
    worker = openstack_networking_secgroup_v2.k8_worker
  }
}