# TODO: From
# https://www.talos.dev/v1.8/talos-guides/install/cloud-platforms/hetzner/

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "this" {
  // proxmox configuration
  insecure_skip_tls_verify = true
  node = var.proxmox_node
  username = var.proxmox_username
  token = var.proxmox_token
  proxmox_url = var.proxmox_api_url

  boot_wait = "1m"
  #boot_command = [
  #  # Start the ISO
  #  "<enter>",
  #  # Set the password
  #  "passwd<enter><wait>${var.default_password}<enter><wait>${var.default_password}<enter>",
  #  # Set the IP address + route
  #  "ip address add ${var.ip_address} broadcast + dev ${var.interface}<enter><wait>",
  #  "ip route add 0.0.0.0/0 via ${var.gateway} dev ${var.interface}<enter><wait>"
  #]

  # Talos does not support CloudInit
  cloud_init = false
  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  cpu_type = "host"
  cores = "2"
  memory = "2048"
  os = "l26"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size         = "10G"
    storage_pool      = "local-lvm"
    type              = "virtio"
    format            = "raw"
  }

  boot_iso {
    iso_file = var.iso_file
    unmount = true
    type = "scsi"
  }

  #iso_file    = var.iso_file
  #unmount_iso = true
  template_name = var.template_name
  template_description = "Talos, generated on ${timestamp()}. (UN: ${var.default_user}, PW: ${var.default_password})"

  #ssh_username = var.default_user
  #ssh_password = var.default_password

  #ssh_private_key_file = var.private_key_file
  #ssh_timeout = "20m"
  #ssh_timeout = "1m"

  communicator = "none"
}

build {
  name = "TALOS"
  sources = ["source.proxmox-iso.this"]
}