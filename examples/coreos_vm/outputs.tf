output "vm" {
  value = module.proxmox_vm.this
  sensitive = true
}