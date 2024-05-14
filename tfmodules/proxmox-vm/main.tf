terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
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
  cores = var.vm_cores
  memory = var.vm_memory

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
    virtio {
      virtio0 {
        disk {
          storage = "local-lvm"
          size    = "10"
          discard = true
          backup = var.vm_disks_backup
          replicate = var.vm_disks_replicate
        }
      }
      virtio1 {
        disk {
          storage = "local-lvm"
          size    = var.vm_disk_size
          discard = true
          backup = var.vm_disks_backup
          replicate = var.vm_disks_replicate
        }
      }
    }
  }

  ssh_user = var.default_user
  ssh_private_key = fileexists(var.public_key_file) ? trimspace(file(var.public_key_file)) : ""
}