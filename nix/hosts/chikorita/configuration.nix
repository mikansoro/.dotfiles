{ config, lib, pkgs, nixos-hardware, ... }:

# Description:
# Lenovo x220 Remote Workstation

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
      nixos-hardware.nixosModules.lenovo-thinkpad-x220
      nixos-hardware.nixosModules.common-pc-laptop-ssd
    ];

  # ---------------
  # ssh/networking
  # ---------------
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
  };

  networking.firewall.allowedTCPPorts = config.services.openssh.ports ++ [
  ];

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "startplasma-x11";
  };

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # -------------------
  # end ssh/networking
  # -------------------


  # -------------------
  # hardware
  # -------------------

  #powerManagement = {
    #enable = true;
  #};
   
  services.upower.ignoreLid = true;
  
  services.logind = {
    powerKey = "ignore";
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  # -------------------
  # end hardware
  # -------------------

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  # hostname
  networking.domain = "int.mikansystems.com";
  networking.hostName = "chikorita"; # Define your hostname.

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
    firefox-esr
    ripgrep
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
    disableTaildrop = false;

    extraSetFlags = [
      "--accept-dns"
      "--accept-routes"
    ];
  };
  # End Tailscale

  services.yubikey-agent.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
