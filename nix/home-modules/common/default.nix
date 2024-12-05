{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      _1password
      ipmitool
      kubectl
      kubectx
      pinniped
      kubernetes-helm
      kustomize
      minikube
      mosh
      nmap
      obsidian
      p7zip
      pgcli
      # spotify # only available on x86_64-linux
      terraform
      unzip
      yubikey-personalization
      # yubikey-personalization-gui # marked as broken
      yubikey-manager
      # yubioath-desktop # error when trying to install pyscard, exit code 2
      zip
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      pinentry
      chromium
      #firefox
      darktable
      mpv
      nextcloud-client
      spotify
      #yubioath-desktop
      yubioath-flutter
      yubikey-personalization-gui
    ];
  };
}
