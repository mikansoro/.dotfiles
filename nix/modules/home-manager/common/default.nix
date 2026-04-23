{ config, lib, pkgs, ... }:

{
  imports = [
    ./mpv.nix
  ];
  
  config = lib.mkIf config.mikansoro.common.enable {
    home = {
      packages = with pkgs; [
        _1password-cli
        dive # docker image inspector
        ffmpeg
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
        yubikey-manager
        zip
      ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        # TODO(mrowland): revert to stable after upgrade to 25.05
        # need https://github.com/NixOS/nixpkgs/pull/358620 for IME support in plasma
        unstable.chromium
        spotify
        yubioath-flutter
      ] ++ lib.optionals (config.mikansoro.machineUsage == "personal") [
        darktable
        nextcloud-client
        remmina
        filebot
        
        unstable.opencode
        
        unstable.discord
        signal-desktop
        unstable.vesktop
        webcord
        unstable.yt-dlp
      ];
    };
  };
}
  
