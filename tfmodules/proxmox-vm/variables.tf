variable "ansible_dir" {
  type = string
  description = "The path to the directory where the ansible assets are"
}

variable "private_key_file" {
    type = string
    description = "The path to the private key file"
}

variable "public_key_file" {
    type = string
    description = "The path to the public key file"
}

variable "template_name" {
  description = "The name of the template"
  type        = string
}

## VM Variables
variable "hostname" {
  description = "The hostname for the system"
  type        = string
}

variable "interface" {
  description = "The network interface to be used"
  type        = string
}

variable "ip_address" {
  description = "The IP address for the system"
  type        = string
}

variable "netmask" {
  description = "The netmask for the system"
  type        = string
}

variable "gateway" {
  description = "The gateway for the system"
  type        = string
}

variable "dns" {
  description = "The DNS for the system"
  type        = list(string)
}

variable "default_user" {
  description = "The default user for the system"
  type        = string
}

variable "default_password" {
  description = "The default password for the system"
  type        = string
}

variable "proxmox_node" {
  type = string
  description = "The node name to deploy the VM on"
}

# TODO: Remove
variable "proxmox_username" {
  type = string
  description = "The username to authenticate with"
}

variable "proxmox_token" {
  type = string
  description = "The token to authenticate with"
}

variable "proxmox_api_url" {
  type = string
  description = "The URL of the Proxmox API"
}