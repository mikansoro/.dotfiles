{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      _1password-cli
      dive # docker image inspector
      ipmitool
      kubectl
      kubectx
      jless
      pinniped
      kubernetes-helm
      kustomize
      minikube
      mosh
      nmap
      # TODO(mrowland): revert to stable after upgrade to 25.05
      # need https://github.com/NixOS/nixpkgs/pull/358620 for IME support in plasma
      unstable.obsidian
      p7zip
      pandoc
      pgcli
      stern # k8s log tailing that doesn't suck
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
      # TODO(mrowland): revert to stable after upgrade to 25.05
      # need https://github.com/NixOS/nixpkgs/pull/358620 for IME support in plasma
      unstable.chromium
      #firefox
      darktable
      mpv
      nextcloud-client
      spotify
      #yubioath-desktop
      yubioath-flutter
      yubikey-personalization-gui
      thunderbird
    ];
  };
}
