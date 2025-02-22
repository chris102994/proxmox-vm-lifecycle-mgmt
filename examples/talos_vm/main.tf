# https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.7.0-alpha.0"
    }
     local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_username
  pm_api_token_secret = var.proxmox_token
}

resource "proxmox_vm_qemu" "this" {
  target_node = var.proxmox_node
  name = var.hostname
  iso = var.iso_file
  agent = 1
  desc = "Terraform created VM for ${var.hostname}"


  bios = "seabios"
  vm_state = "running"

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
}

resource "talos_machine_secrets" "this" {
  depends_on = [proxmox_vm_qemu.this]
}

data "talos_machine_configuration" "this" {
  cluster_name     = "proxmox-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${proxmox_vm_qemu.this.default_ipv4_address}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "1.31"
  talos_version = "1.8.2"
}

data "talos_client_configuration" "this" {
  cluster_name         = data.talos_machine_configuration.this.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [proxmox_vm_qemu.this.default_ipv4_address]
}

data "talos_machine_disks" "this_install_disk" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = proxmox_vm_qemu.this.default_ipv4_address
  filters = {
    size = "> 9GB"
    type = "hdd"
  }
}

data "talos_machine_disks" "this_data_disk" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = proxmox_vm_qemu.this.default_ipv4_address
  filters = {
    size = "> 19GB"
    type = "hdd"
  }
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = proxmox_vm_qemu.this.default_ipv4_address
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = data.talos_machine_disks.this_install_disk.disks[0].name
          wipe = false
        }
        kubelet = {
          extraMounts = [
            {
              destination = "/var/mnt/storage"
              type        = "bind"
              source      = "/var/mnt/storage"
              options = [
                "bind",
                "rshared",
                "rw"
              ]
            }
          ]
        }
        disks = [
          {
            device = data.talos_machine_disks.this_data_disk.disks[0].name
            partitions = [
              {
                mountpoint = "/var/mnt/storage"
              }
            ]
          }
        ]
        features = {
          kubernetesTalosAPIAccess = {
            enabled = true
            allowedRoles = [
              "os:reader"
            ]
            allowedKubernetesNamespaces = [
              "kube-system"
            ]
          }
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  node                 = proxmox_vm_qemu.this.default_ipv4_address
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [
    talos_machine_configuration_apply.this
  ]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = proxmox_vm_qemu.this.default_ipv4_address

  depends_on = [
    talos_machine_bootstrap.this
  ]
}


resource "local_file" "this_kubeconfig" {
  content = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${var.config_dir}/kubeconfig-${proxmox_vm_qemu.this.name}.yaml"
}

# TODO: Enable QEMU Plugin
# https://www.talos.dev/v1.8/reference/configuration/extensions/extensionserviceconfig/
# https://github.com/siderolabs/extensions/blob/main/guest-agents/qemu-guest-agent/README.md
#