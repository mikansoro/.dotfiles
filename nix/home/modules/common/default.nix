{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      _1password
      _1password-gui
      helm
      ipmitool
      kubectl
            #kubectx
      minikube
      mpv
      nmap
      p7zip
      pinentry
      pgcli
      spotify
      terraform
      unzip
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      yubioath-desktop
      zip
    ];
  };


  programs.gpg = {
    enable = false;
    mutableKeys = true;
    mutableTrust = true;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableSSHSupport = true;
    grabKeyboardAndMouse = true;
    # defaultCacheTtl = 60;
    # maxCacheTtl = 120;
    # pinentryFlavor =
  };
}
