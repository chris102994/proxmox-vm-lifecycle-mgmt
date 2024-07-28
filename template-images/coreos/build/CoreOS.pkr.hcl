packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
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


  # Commands packer enters to boot and start the auto install
  boot_wait = "1m"
  boot_command = [
    # Start the live ISO
    "<enter>",
    # Mount the CD-ROM containing the ignition config
    "sudo mount /dev/sr1 /mnt/",
    "<enter>",
    # Wait a few seconds. Sometimes it slices the next command's "sudo" off
    "<wait10s>",
    # Install CoreOS to disk using the ignition config
    "sudo coreos-installer install /dev/vda --ignition-file /mnt/installer.ign",
    "<enter>",
    "<wait2m>",
    # Reboot the system
    "reboot",
    "<enter>"
  ]


  additional_iso_files {
    cd_files = ["${var.gen_config_dir}/installer.ign"]
    iso_storage_pool = "local"
    unmount = true
  }

  # CoreOS does not support CloudInit
  cloud_init = false
  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  cpu_type = "host"
  cores = "2"
  memory = "2048"
  os = "l26"

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size = "10G"
    storage_pool = "local-lvm"
    type = "virtio"
  }

  disks {
    disk_size = "10G"
    storage_pool = "local-lvm"
    type = "virtio"
  }

  iso_file = var.iso_file
  unmount_iso = true
  template_name = var.template_name
  template_description = "Fedora CoreOS, generated on ${timestamp()}. (UN: ${var.default_user}, PW: ${var.default_password})"

  ssh_username = var.default_user
  ssh_password = var.default_password

  ssh_private_key_file = var.private_key_file
  ssh_timeout = "20m"
}

build {
  name = "FEDORACOREOS"

  sources = ["source.proxmox-iso.this"]

  provisioner "ansible" {
    user = var.default_user
    galaxy_file = "${var.ansible_dir}/requirements.yml"
    galaxy_force_with_deps = true
    playbook_file = "${var.ansible_dir}/post-install.yml"
    roles_path = "${var.ansible_dir}/roles"
    ssh_authorized_key_file = var.public_key_file
    use_proxy = false
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${var.ansible_dir}/ansible.cfg",
      "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3",
    ]
   }
}