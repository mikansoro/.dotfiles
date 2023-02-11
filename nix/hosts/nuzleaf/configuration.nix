{ config, pkgs, ... }:

# Description:
# Virtual Workstation

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos-modules/users
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "nfs" "nfsv4" ];

  networking.domain = "int.mikansystems.com";
  networking.hostName = "nuzleaf"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    btop
    libsForQt5.bismuth
    firefox

    nfs-utils
  ];

  services.xserver = {
    desktopManager.plasma5.enable = true;
  };

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "startplasma-x11";
  };
  nixpkgs.config.permittedInsecurePackages = [
    "xrdp-0.9.9"
  ];

  # TODO: enable autofs to automatically mount nas shares

  services.xe-guest-utilities.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
