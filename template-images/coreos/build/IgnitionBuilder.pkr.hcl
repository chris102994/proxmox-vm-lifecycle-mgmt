source "null" "password" {
  communicator = "none"
}

build {
  name = "IgnitionBuilder-PasswordGenerator"

  sources = [
    "source.null.password"
  ]

  provisioner "shell-local" {
    inline = [
      "mkpasswd \"${var.default_password}\" | tr -d '\n' > ${var.gen_config_dir}/password.txt",
    ]
  }
}

locals {
  password = fileexists("${var.gen_config_dir}/password.txt") ? file("${var.gen_config_dir}/password.txt") : ""
  ssh_pub_key = fileexists(var.public_key_file) ? trimspace(file(var.public_key_file)) : ""
  butane_content = {
    "/installer.bu" = templatefile("${var.tpl_config_dir}/installer.bu.pkrtpl.hcl", {
        hostname = var.hostname,
        interface = var.interface,
        ip_address = var.ip_address,
        netmask = var.netmask,
        gateway = var.gateway,
        dns = join(";", var.dns),
        default_user = var.default_user,
        default_password = local.password,
        ssh_pub_key = local.ssh_pub_key
    })
  }
}

source "file" "butane" {
  content = local.butane_content["/installer.bu"]
  target = "${var.gen_config_dir}/installer.bu"
}

build {
  name = "IgnitionBuilder"

  sources = [
    "source.file.butane"
  ]

  provisioner "shell-local" {
    inline = [
      "[ -d $GEN_CONFIG_DIR ] || exit 1",
      "cat ${var.gen_config_dir}/installer.bu | butane --pretty --output ${var.gen_config_dir}/installer.ign",
      "chmod 644 ${var.gen_config_dir}/installer.bu",
      "chmod 644 ${var.gen_config_dir}/installer.ign",
    ]
  }

  post-processor "shell-local" {
    inline = [
      "butane --check ${var.gen_config_dir}/installer.bu",
    ]
  }
}