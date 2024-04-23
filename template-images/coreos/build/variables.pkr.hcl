###
# Variables will need to be created for the following variables
# In a file located at `<root>/state/coreos/variables.pkvars.hcl`
###


variable "iso_file" {
  description = "The path to the ISO file (on proxmox_node)"
  type        = string
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