##### root/variables.tf #####

variable "datacenter" {
  type = string
}

variable "resource_pool" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "vm_name_prefix" {
  type = string
}

variable "vm_count" {
  type = string
}

variable "template_name" {
  type = string
}

variable "linked_clone" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ipv4_network_address" {
  type = string
}

variable "ipv4_address_start" {
  type = string
}

variable "ipv4_gateway" {
  type = string
}

variable "template_os_family" {
  default = "linux"
}

variable "memory" {
  type = string
}

variable "num_cpus" {
  type = string
}

variable "activationkey" {
  type = string
}

