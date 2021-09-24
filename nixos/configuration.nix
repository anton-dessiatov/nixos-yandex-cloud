{ config, pkgs, ... }:

let unstable = import <nixpkgs-unstable> {
      config = config.nixpkgs.config;
    };
in {
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.overlays = [
    # cloud-init at stable 21.05 refuses to build :(
    (self: super: { cloud-init = unstable.cloud-init; })
  ];

  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.systemd-boot.enable = true;
  services.openssh.enable = true;
  services.cloud-init.enable = true;
}
