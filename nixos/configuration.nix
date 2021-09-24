{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.systemd-boot.enable = true;
  services.openssh.enable = true;
  services.cloud-init.enable = true;
}
