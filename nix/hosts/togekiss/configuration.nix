{ config, pkgs, ... }:

# Description:
# Lenovo x13 Remote Workstation

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos-modules/users
      ../../nixos-modules/nfs/client
      ../../nixos-modules/audio
      ../../nixos-modules/fonts
      ../../nixos-modules/hardware/devices/lenovo/x13
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e3adb61b-5d71-4d5a-9487-7f70646e17ff"; # /dev/nvme0n1p6
      preLVM = true;
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # hostname
  networking.domain = "int.mikansystems.com";
  networking.hostName = "togekiss"; # Define your hostname.

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    refind

    vim
    wget
    curl
    git
    htop
    btop
    libsForQt5.bismuth
    firefox
    ripgrep

    steam-tui
    steam-run
    lutris
  ];

  # graphical environment
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  # video
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  programs.steam = {
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  virtualisation.docker.enable = true;
  #services.openssh.enable = false;

  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 22 ];

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.254.253.3/32" ];
      dns = [ "10.254.253.0" ];
      privateKeyFile = "/root/wireguard-keys/togekiss.key";
      mtu = 1280;

      peers = [
        {
          publicKey = "9AKkas/9C1Ih/Z3WFl5pdvNxwvY6uxqrpZ7xcZgj8xM=";
          presharedKeyFile = "/root/wireguard-keys/preshared.key";
          allowedIPs = [ "172.16.0.0/16" "10.254.253.0/23" "10.10.0.0/16" ];
          endpoint = "159.65.105.164:51820";
          persistentKeepalive = 16;
        }
      ];
    };
  };

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
