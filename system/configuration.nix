# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
 #    grub = {
 #      enable = true;
 #      version = 2;
 #      device = "/dev/nvme0n1";
 #    };
  };

  boot.initrd.kernelModules = [ "nvidia" ];

  boot.initrd.luks = {
    devices = {
      luksroot = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
      };
    };
  };

  boot.tmpOnTmpfs = true;
 
  networking.hostName = "mkn-p-hq-desk01"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = true;
  networking = {
    interfaces.enp5s0.useDHCP = true;
    interfaces.wlp4s0.useDHCP = true;

    wireless = {
      interfaces = [ "wlp4s0" ];
      enable = true;
      networks = {
        mikansystems.pskRaw = ***REMOVED***;
      };
    };
  };

  # networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable nix flakes support
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.keyboard.zsa.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.michael = {
    isNormalUser = true;
    initialPassword = ***REMOVED***;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # nixpkgs.overlays = [
  #   (self: super: {
  #       steam = super.steam.overrideAttrs ( oldAttrs: rec {
  #         preConfigure = ''
  #           substituteInPlace share/applications/steam.desktop 'Exec=steam' "Exec=GDK_SCALE=1 steam"
  #         '';
  #       });
  #     }
  #   )
  # ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    git
    htop
    parted
    tree
    which
    whois
    pciutils
    parted
    gparted
    zip
    unzip
    p7zip
    clinfo
    gptfdisk
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh.enable = true;
  
  programs.steam.enable = false;

  hardware = {
    #steam-hardware.enable = false;

    opengl = {
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      driSupport = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      powerline-fonts
      source-code-pro
      source-sans-pro
      source-serif-pro
      
      source-han-code-jp
      source-han-sans-japanese
      source-han-serif-japanese
      source-han-sans-simplified-chinese
      source-han-serif-simplified-chinese
      source-han-sans-korean
      source-han-serif-korean  
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Source Code Pro" "Source Han Sans JP" ];
        sansSerif = [ "Source Sans Pro" "Source Han Sans JP Medium" "Source Han Sans KR Medium" "Source Han Sans CN Medium" ];
        serif = [ "Source Serif Pro" "Source Han Serif JP Medium" "Source Han Serif KR Medium" "Source Han Serif CN Medium" ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

