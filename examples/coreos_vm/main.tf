terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_username
    pm_api_token_secret = var.proxmox_token
}

module "proxmox_vm" {
  source = "../../tfmodules/proxmox-vm/"

  ansible_dir = var.ansible_dir
  private_key_file = var.private_key_file
  public_key_file = var.public_key_file
  template_name = var.template_name
  hostname = var.hostname
  interface = var.interface
  ip_address = var.ip_address
  netmask = var.netmask
  gateway = var.gateway
  dns = var.dns
  default_user = var.default_user
  default_password = var.default_password
  proxmox_node = var.proxmox_node
  vm_cores = var.vm_cores
  vm_memory = var.vm_memory
  vm_disk_size = var.vm_disk_size
  vm_disks_backup = var.vm_disks_backup
  vm_disks_replicate = var.vm_disks_replicate
}