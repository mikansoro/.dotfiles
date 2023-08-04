{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/common
    ../../home-modules/shell
    ../../home-modules/git
    ../../home-modules/emacs
    ../../home-modules/gpg-agent

    # BUG: The option `home-manager.users.michael.home.file."/home/michael/.config/gnupg/gpg-agent.conf".text` is defined both null and not null, in `/mnt/nix/store/6zxkqbrcw5r5yi6hmk3xf17y6wqiqs0h-source/modules/misc/xdg.nix' and `/mnt/nix/store/6zxkqbrcw5r5yi6hmk3xf17y6wqiqs0h-source/modules/services/gpg-agent.nix'.
    #../../home-modules/gpg-agent
  ];

  programs.home-manager.enable = true;

  xdg = {
    enable = true;
  };

  home = {
    stateVersion = "22.11";

    packages = with pkgs; [
      discord
      signal-desktop

      ffmpeg
      filebot
      mpv
      yt-dlp
      qimgv
    ];
  };
}
