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

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";
  # Grow root partition up to maximum size on boot. This is to be able to
  # utilize extra disk space that might have been provided to us by user.
  boot.growPartition = true;

  boot.kernelParams = [ "console=ttyS0" ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  # Cloud Init and Nix sometimes tend to solve the same problems. We need to
  # use Cloud Init to be compatible with Yandex Cloud, but please be aware
  # that there is a delicate dance involved with occastional stepping on one
  # another's toes.
  services.cloud-init.enable = true;
  security.sudo.extraConfig = ''
  # Respect condifuration made by cloud-init
  #includedir /etc/sudoers.d
  '';

  # We need to have a /bin/bash symlink because Yandex Cloud explicitly sets /bin/bash
  # as a shell for the user created by cloud-init. If there is no /bin/bash present in
  # the system, that user will be unable to log in making an instance inaccessible.
  system.activationScripts.binbash = ''
    mkdir -m 0755 -p /bin
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';
}
