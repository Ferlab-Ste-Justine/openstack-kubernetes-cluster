variable "namespace" {
  description = "Namespace to create the resources under"
  type = string
  default = ""
}

variable "masters_count" {
  description = "Number of master nodes"
  type = number
  default = 3
}

variable "masters_flavor_id" {
  description = "ID of the VM flavor of the master nodes"
  type = string
}

variable "masters_security_groups" {
  description = "Security groups of the master nodes"
  type = list(string)
  default = ["default"]
}

variable "workers_count" {
  description = "Number of worker nodes"
  type = number
  default = 3
}

variable "workers_flavor_id" {
  description = "ID of the VM flavor of the workers"
 type = string
}

variable "workers_security_groups" {
  description = "Security groups of the worker nodes"
  type = list(string)
  default = ["default"]
}

variable "load_balancer_flavor_id" {
  description = "ID of the VM flavor of the load balancer sitting in front of the masters"
  type = string
}

variable "load_balancer_security_groups" {
  description = "Security groups of the load balancer sitting in front of the masters"
  type = list(string)
  default = ["default"]
}

variable "image_id" {
    description = "Image id of the VMs"
    type = string
}

variable "network_name" {
  description = "Name of the network the cluster will be in"
  type = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the vms"
  type = string
}