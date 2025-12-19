{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      _1password-cli
      dive # docker image inspector
      gcrane # like skopeo, docker image copy tools
      gitu
      ipmitool
      jless
      kubectl
      kubectx
      k9s
      kubernetes-helm
      kustomize
      minikube
      moreutils # extra utilities
      mosh
      nmap
      # TODO(mrowland): revert to stable after upgrade to 25.05
      # need https://github.com/NixOS/nixpkgs/pull/358620 for IME support in plasma
      unstable.obsidian
      p7zip
      pandoc
      pgcli
      stern # k8s log tailing that doesn't suck
      #terraform
      unzip
      yubikey-personalization
      # yubikey-personalization-gui # marked as broken
      yubikey-manager
      # yubioath-desktop # error when trying to install pyscard, exit code 2
      zed-editor
      zip
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      #pinentry # disabled on upgrade to 25.11 (deprecated)
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
      #yubikey-personalization-gui # disabled on upgrade to 25.11 (deprecated upstream)
      thunderbird
    ];
  };
}
