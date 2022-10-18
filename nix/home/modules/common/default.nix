{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      _1password
      # _1password-gui
      ipmitool
      kubectl
      kubernetes-helm
            #kubectx
      minikube
      mpv
      nmap
      p7zip
      pinentry
      pgcli
      # spotify # only available on x86_64-linux
      terraform
      unzip
      yubikey-personalization
      # yubikey-personalization-gui # marked as broken
      yubikey-manager
      # yubioath-desktop # error when trying to install pyscard, exit code 2
      zip
    ];
  };
}
