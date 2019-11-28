##### root/outputs.tf #####

output "virtual_machine_names" {
  value = "${module.virtual_machines.virtual_machine_names}"
}

output "virtual_machine_ids" {
  value = "${module.virtual_machines.virtual_machine_ids}"
}

output "virtual_machine_default_ips" {
  value = "${module.virtual_machines.virtual_machine_default_ips}"
}

