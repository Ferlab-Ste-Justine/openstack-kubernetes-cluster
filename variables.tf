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

variable "masters_extra_security_group_ids" {
  description = "Extra security groups of the master nodes"
  type = list(string)
  default = []
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

variable "workers_extra_security_group_ids" {
  description = "Extra security groups of the worker nodes"
  type = list(string)
  default = []
}

variable "load_balancer_flavor_id" {
  description = "ID of the VM flavor of the load balancer sitting in front of the masters. If set to the empty string, a load balancer will not be provisioned."
  type = string
  default = ""
}

variable "image_id" {
    description = "Image id of the VMs"
    type = string
}

variable "network_id" {
  description = "id of the network the cluster will be in"
  type = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the vms"
  type = string
}

variable "k8_max_workers_count" {
  description = "Maximum expected number of k8 workers"
  type = number
  default = 100
}

variable "k8_max_masters_count" {
  description = "Maximum expected number of k8 masters"
  type = number
  default = 7
}

variable "nameserver_ips" {
  description = "Ips of the nameservers the load balance will use to resolve k8 masters and workers"
  type = list(string)
}

variable "internal_k8_domain" {
  description = "Domain that will resolve to the k8 masters and workers on the dns servers"
  type = string
}

variable "masters_api_timeout" {
  description = "Amount of time an api connection can remain idle before it times out"
  type = string
  default = "5000ms"
}

variable "masters_api_port" {
  description = "Http port of the api on the k8 masters"
  type = number
  default = 6443
}

variable "masters_max_api_connections" {
  description = "Max number of concurrent api connections on the masters"
  type = number
  default = 200
}

variable "workers_ingress_http_timeout" {
  description = "Amount of time an ingress http connection can remain idle before it times out"
  type = string
  default = "5000ms"
}

variable "workers_ingress_http_port" {
  description = "Http port of the ingress on the k8 workers"
  type = number
  default = 30000
}

variable "workers_ingress_max_http_connections" {
  description = "Max number of concurrent http connections the load balancer will allow on the workers"
  type = number
  default = 200
}

variable "workers_ingress_https_timeout" {
  description = "Amount of time an ingress https connection can remain idle before it times out"
  type = string
  default = "5000ms"
}

variable "workers_ingress_https_port" {
  description = "Https port of the ingress on the k8 workers"
  type = number
  default = 30001
}

variable "workers_ingress_max_https_connections" {
  description = "Max number of concurrent https connections the load balancer will allow on the workers"
  type = number
  default = 200
}
