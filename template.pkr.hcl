variable "iso_checksum" {
  type    = string
  default = "864f5b24c0af81d29e54318e33b6d6bccf698f7bf6641dd490c80cfeffa2fa43"
}

variable "iso_url" {
  type    = string
  default = "https://channels.nixos.org/nixos-21.05/latest-nixos-minimal-x86_64-linux.iso"
}

variable "update_channel" {
  type = string
  default = "https://nixos.org/channels/nixos-21.05"
}

locals {
  root_partition_uuid = uuidv4()
  install_root_password = uuidv4()
}

source "qemu" "primary" {
  boot_command   = [
    "sudo passwd<enter><wait>",
    "${local.install_root_password}<enter><wait>",
    "${local.install_root_password}<enter><wait5>",
  ]
  boot_wait      = "30s"
  communicator   = "ssh"
  ssh_username   = "root"
  ssh_password   = "${local.install_root_password}"
  disk_interface = "virtio"
  disk_size      = "4096M"
  format         = "qcow2"
  memory         = "2048"
  http_directory = "nixos"
  iso_checksum   = "sha256:${var.iso_checksum}"
  iso_url        = "${var.iso_url}"
}

build {
  sources = ["source.qemu.primary"]
  provisioner "shell" {
    inline = [
      "sgdisk -o /dev/vda",
      "sgdisk -n 1:0:0 /dev/vda",
      "mkfs.ext4 -U ${local.root_partition_uuid} /dev/vda1",
      "mount -U ${local.root_partition_uuid} /mnt",
    ]
  }
  provisioner "shell" {
    inline = [
      "nixos-generate-config --root /mnt",
      "curl http://$PACKER_HTTP_IP:$PACKER_HTTP_PORT/configuration.nix > /mnt/etc/nixos/configuration.nix",
      "nix-channel --add ${var.update_channel} nixos",
      "nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable",
      "nix-channel --update",
      "nixos-install && reboot",
    ]
  }
}
