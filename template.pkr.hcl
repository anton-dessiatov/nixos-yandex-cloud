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
}

source "qemu" "primary" {
  boot_command   = [
    "sudo -s<enter>",
    "sgdisk -o /dev/vda<enter><wait>",
    "sgdisk -n 1:0:0 /dev/vda<enter><wait>",
    "mkfs.ext4 -U ${local.root_partition_uuid} /dev/vda1<enter><wait5>",
    "mount -U ${local.root_partition_uuid} /mnt<enter><wait>",
    "nixos-generate-config --root /mnt<enter><wait>",
    "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/configuration.nix > /mnt/etc/nixos/configuration.nix<enter><wait>",
    "nix-channel --add ${var.update_channel} nixos<enter><wait>",
    "nix-channel --update<enter><wait30>",
    "nixos-install && reboot<enter>",
  ]
  boot_wait      = "30s"
  communicator   = "none"
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

}
