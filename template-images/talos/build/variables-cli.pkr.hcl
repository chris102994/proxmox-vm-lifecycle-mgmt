## CLI Variables handled by the Taskfile
#variable "tpl_config_dir" {
#    type = string
#    description = "The path to the directory where the template configuration files are"
#}

#variable "gen_config_dir" {
#  type = string
#  description = "The path to the directory where to place generated files"
#}

#variable "ansible_dir" {
#  type = string
#  description = "The path to the directory where the ansible assets are"
#}

variable "private_key_file" {
    type = string
    description = "The path to the private key file"
}

variable "public_key_file" {
    type = string
    description = "The path to the public key file"
}