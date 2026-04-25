{ config, lib, pkgs, nixos-hardware, ... }:

# Description:
# Lenovo x13 Remote Workstation

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen6
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  mikansoro.machineUsage = "work";
  networking.hostName = "michaelr-z";

  services.automatic-timezoned.enable = true;

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  environment.systemPackages = with pkgs; [
    refind
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
