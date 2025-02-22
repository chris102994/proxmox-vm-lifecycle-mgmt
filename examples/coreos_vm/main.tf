terraform {
  required_providers {
    ansible = {
      source = "ansible/ansible"
      version = "1.3.0"
    }
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
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

resource "ansible_group" "nodes" {
  name = "nodes"

  variables = {
    ansible_connection = "ssh"
    ansible_python_interpreter = "/usr/bin/python3"
    ansible_config_file = "${var.ansible_dir}/ansible.cfg"
    ansible_ssh_private_key_file = var.private_key_file
    ansible_ssh_user = var.default_user
  }
}

resource "ansible_host" "proxmox_vm" {
  name = module.proxmox_vm.this.default_ipv4_address

  groups = [ansible_group.nodes.name]

  variables = {
    ansible_user = var.default_user
    ansible_host = module.proxmox_vm.this.default_ipv4_address
  }
}

resource "ansible_playbook" "expand_fs_playbook" {
  name = ansible_host.proxmox_vm.name
  groups = [ansible_group.nodes.name]
  playbook = "${var.ansible_dir}/expand-fs.yml"
  extra_vars = {
    ansible_ssh_user = var.default_user
    ansible_ssh_private_key_file = var.private_key_file
  }
}


# TODO: wait for https://github.com/ansible/terraform-provider-ansible/pull/109
# For some reason the group/host vars aren't being inherited when using the ansible_playbook resource
resource "ansible_playbook" "change_ip_playbook" {
  name = ansible_host.proxmox_vm.name
  groups = [ansible_group.nodes.name]
  playbook = "${var.ansible_dir}/change-ip.yml"
  extra_vars = {
    ansible_ssh_user = var.default_user
    ansible_ssh_private_key_file = var.private_key_file

    new_ip = var.ip_address
    new_netmask = var.netmask
    new_gateway = var.gateway
  }
}

resource "ansible_playbook" "install_rke2_playbook" {
  name = ansible_host.proxmox_vm.name
  groups = [ansible_group.nodes.name]
  playbook = "${var.ansible_dir}/install-rke2.yml"
  extra_vars = {
    ansible_ssh_user = var.default_user
    ansible_ssh_private_key_file = var.private_key_file

    state_dir = var.state_dir
  }
}




