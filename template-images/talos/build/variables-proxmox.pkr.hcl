## Core Variables for proxmox
variable "proxmox_node" {
  type = string
  description = "The node name to deploy the VM on"
}

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