##### root/main.tf #####

terraform {
    backend "s3" {
        bucket  = "terraform-backend-store"
        encrypt = true
        key     = "terraform.tfstate"
        region  = "us-east-2"
    }
}

provider "vsphere" {
  user = ""
  password = ""
  vsphere_server = ""

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "virtual_machines" {
  source               = "./modules/virtual-machine"
  datacenter           = var.datacenter
  datastore            = var.datastore
  domain_name          = var.domain_name
  ipv4_address_start   = var.ipv4_address_start
  ipv4_gateway         = var.ipv4_gateway
  ipv4_network_address = var.ipv4_network_address
  linked_clone         = var.linked_clone
  network              = var.network
  resource_pool        = var.resource_pool
  template_name        = var.template_name
  template_os_family   = var.template_os_family
  vm_count             = var.vm_count
  vm_name_prefix       = var.vm_name_prefix
  memory               = var.memory
  num_cpus             = var.num_cpus
}


resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/files/hosts.tmpl", { domain = var.domain_name, vms = module.virtual_machines.virtual_machine_names })
  filename = "${path.module}/outputs/hosts"
  file_permission = "0775"
}

