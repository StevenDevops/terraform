variable "network_name" {
  description = "The name of the network to be managed."
  type        = string
}

variable "cidr_block" {
  description = "The cidr for the vpc."
  type        = string
}

variable "subnets" {
  description = "A map of subnets to create."
  type        = map(map(list(number)))
}

variable "destinationCIDRblock" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type    = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "egressCIDRblock" {
  type    = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "eks_disk_size" {
  type    = number
  default = 20
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_cni_version" {
  type = string
}

variable "coredns_version" {
  type = string
}

variable "kube_proxy_version" {
  type = string
}

variable "user_name" {
  type    = string
}