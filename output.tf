
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
      id = var.load_balancer_flavor_id != "" ? openstack_compute_instance_v2.load_balancer.0.id : ""
      ip = var.load_balancer_flavor_id != "" ? openstack_compute_instance_v2.load_balancer.0.network.0.fixed_ip_v4 : ""
    }
}