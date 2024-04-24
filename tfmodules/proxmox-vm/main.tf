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
    #pm_user = var.proxmox_username
    #pm_password = var.proxmox_token
}

resource "proxmox_vm_qemu" "this" {
  target_node = var.proxmox_node
  name = var.hostname
  clone = var.template_name
  full_clone = true
  agent = 1
  desc = "Terraform created VM for ${var.hostname}"

  bios = "seabios"
  vm_state = "running"

  boot = "order=virtio0"
  hotplug = "disk,network,usb"

  cpu = "host"
  cores = "2"
  memory = "2048"
  qemu_os = "l26"

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
    virtio {
      virtio0 {
        disk {
          storage = "local-lvm"
          size    = 10
          iothread = false
          discard = true
          backup = true
          replicate = true
        }
      }
    }
  }

  ssh_user = var.default_user
  ssh_private_key = fileexists(var.public_key_file) ? trimspace(file(var.public_key_file)) : ""
}