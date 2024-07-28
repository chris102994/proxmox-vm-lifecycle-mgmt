output "vm" {
  value = module.proxmox_vm.this
  sensitive = true
}

output "vm_ip" {
  value = var.ip_address
}

output "vm_user" {
  value = var.default_user
}