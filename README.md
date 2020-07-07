# About

This package is a terraform module to provision the machines for a kubernetes cluster on openstack (without the kubernetes installation).

This includes the masters, the workers and potentially a load balancer (a node with a dockerized haproxy, configured to load balance on the k8s api secure port across the masters) if there are more than a single master.

# Usage

## Variables

The module takes the following variables as input:

- namespace: A string to namespace all the vm names (ie, `<vm name>-<namespace>`). If this variable is omitted, a namespace suffix will not be added.
- masters_count: The number of masters to provision.
- masters_flavor_id: The id of the flavor the masters will have.
- masters_security_groups: List of security groups to assign to the masters. Defaults to `["default"]`
- workers_count: The number of workers to provision.
- workers_flavor_id: The id of the flavor the workers will have.
- workers_security_groups: List of security groups to assign to the workers. Defaults to `["default"]`
- load_balancer_flavor_id: The id of the flavor the load balancer will have. If you do not wish to provision a load balancer, leave this value at its blank default.
- load_balancer_security_groups: List of security groups to assign to the load balancer. Defaults to `["default"]`
- image_id: ID of the image to use to provision all vms
- network_name: Name of the network to connect all vms to
- keypair_name: Name of the keypair that will be used to ssh on the vms

## Output

The module outputs the following variables as output:
- masters: list of the masters with each entry having the following format...
```
{
  id: <id of the master>
  ip: <ip address of the master>
}
```
- workers: list of the workers with each entry having the following format...
```
{
  id: <id of the master>
  ip: <ip address of the master>
}
```
- load_balancer: id and ip of the load balancer taking the following format (if a load balancer is not provisioned, the values will be the empty string):
```
{
  id: <id of the master>
  ip: <ip address of the master>
}
```


## Example

Here is an example of how the module might be used:

```
module "reference_infra" {
  source = "./cqdg-reference-infra"
}

#Security groups we create for the various modules
module "security_groups" {
  source = "./security-groups"
}

#Default image we assign to all vms
module "ubuntu_bionic_image" {
  source = "./image"
  name = "Ubuntu-Bionic-2020-06-10"
  url = "https://cloud-images.ubuntu.com/releases/bionic/release-20200610.1/ubuntu-18.04-server-cloudimg-amd64.img"
}

#Ssh key that will be used to open an ssh session from the bastion to other machines
resource "openstack_compute_keypair_v2" "bastion_internal_keypair" {
  name = "bastion_internal_keypair"
}

resource "openstack_networking_floatingip_v2" "k8_api_lb_floating_ip" {
  pool = module.reference_infra.networks.external.name
}

module "kubernetes_cluster" {
  source = "git::https://github.com/Ferlab-Ste-Justine/openstack-kubernetes-cluster.git"
  masters_flavor_id = module.reference_infra.flavors.micro.id
  workers_flavor_id = module.reference_infra.flavors.small.id
  load_balancer_flavor_id = module.reference_infra.flavors.micro.id
  image_id = module.ubuntu_bionic_image.id
  keypair_name = openstack_compute_keypair_v2.bastion_internal_keypair.name
  network_name = module.reference_infra.networks.internal.name
  load_balancer_security_groups = [
    module.reference_infra.security_groups.default.name,
    module.security_groups.groups.k8_api_lb.name,
  ]
}

resource "openstack_compute_floatingip_associate_v2" "k8_api_lb_ip" {
  floating_ip = openstack_networking_floatingip_v2.k8_api_lb_floating_ip.address
  instance_id = module.kubernetes_cluster.load_balancer.id
}
```