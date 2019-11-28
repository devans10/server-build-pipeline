resource "vsphere_virtual_machine" "virtual_machine_linux" {
  count            = "${var.template_os_family == "linux" ? var.vm_count : 0}"
  name             = "${var.vm_name_prefix}${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool[0].id}"
  datastore_id     = "${data.vsphere_datastore.ds.id}"

  num_cpus = "${var.num_cpus}"
  memory   = "${var.memory}"
  guest_id = "${data.vsphere_virtual_machine.template[0].guest_id}"

  wait_for_guest_net_timeout = "${var.wait_for_guest_net_timeout}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${var.disk_size != "" ? var.disk_size : data.vsphere_virtual_machine.template[0].disks.0.size}"
    thin_provisioned = "${var.linked_clone == "true" ? data.vsphere_virtual_machine.template[0].disks.0.thin_provisioned : true}"
    eagerly_scrub    = "${var.linked_clone == "true" ? data.vsphere_virtual_machine.template[0].disks.0.eagerly_scrub: false}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template[0].id}"
    linked_clone  = "${var.linked_clone}"

    customize {
      linux_options {
        host_name = "${var.vm_name_prefix}${count.index + 1}"
        domain    = "${var.domain_name}"
        time_zone = "${var.time_zone != "" ? var.time_zone : "UTC"}"
      }

      network_interface {
        ipv4_address = "${var.ipv4_network_address != "0.0.0.0/0" ? cidrhost(var.ipv4_network_address, var.ipv4_address_start + count.index) : ""}"
        ipv4_netmask = "${var.ipv4_network_address != "0.0.0.0/0" ? element(split("/", var.ipv4_network_address), 1) : 0}"
      }

      ipv4_gateway    = "${var.ipv4_gateway}"
      dns_server_list = "${var.dns_servers}"
      dns_suffix_list = ["${var.domain_name}"]
    }
  }
}

# vim: filetype=terraform

