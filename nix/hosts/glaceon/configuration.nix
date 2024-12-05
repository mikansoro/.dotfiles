{ config, pkgs, ... }:

# Description:
# Physical Workstation

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos-modules/nfs/client
      ../../nixos-modules/users
      ../../nixos-modules/audio
      ../../nixos-modules/nix
      ../../nixos-modules/1password
      ../../nixos-modules/fonts
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/606849d7-64ac-41a5-b3a3-1f2eb15fccb8"; # /dev/nvme0n1p2
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
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # hostname
  networking.domain = "int.mikansystems.com";
  networking.hostName = "glaceon"; # Define your hostname.

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

    nfs-utils

    steam-tui
    steam-run
    lutris
  ];

  # graphical environment
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # video
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = false;
  };

  services.openssh.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # required to run electron applications natively in wayland
  # instead of using xwayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # fix an nvidia bug that causes simpledrm to stay around as an
  # extra frame buffer that harms gpu render performance
  # https://github.com/NixOS/nixpkgs/issues/302059#issuecomment-2192598395
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

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
