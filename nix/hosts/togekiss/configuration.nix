{ config, lib, pkgs, ... }:

# Description:
# Lenovo x13 Remote Workstation

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk.nix
      ../../nixos-modules/users
      ../../nixos-modules/nfs/client
      ../../nixos-modules/audio
      ../../nixos-modules/fonts
      ../../nixos-modules/nix
      ../../nixos-modules/1password
      ../../nixos-modules/hardware/devices/lenovo/x13
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    #type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # hostname
  networking.domain = "int.mikansystems.com";
  networking.hostName = "togekiss"; # Define your hostname.

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  services.mullvad-vpn.enable = false;

  # Set your time zone.
  services.automatic-timezoned.enable = true;

  environment.systemPackages = with pkgs; [
    refind

    vim
    wget
    curl
    git
    htop
    btop
    libsForQt5.bismuth
    firefox-esr
    ripgrep

    steam-tui
    steam-run
    lutris
  ];

  # graphical environment
  services.xserver = {
    enable = true;
  };

  services = { 
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # video
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam = {
    enable = false;
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  virtualisation.docker.enable = true;
  #services.openssh.enable = false;

  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 22 ];

  # Tailscale
  services.resolved.enable = true;
  #networking.networkmanager.dns = "systemd-resolved";
  networking.interfaces."tailscale0".useDHCP = lib.mkForce false;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    disableTaildrop = true;

    extraSetFlags = [
      "--accept-dns"
      "--accept-routes"
    ];
  };
  # End Tailscale

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
