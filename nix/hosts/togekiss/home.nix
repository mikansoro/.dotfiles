{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/common
    ../../home-modules/shell
    ../../home-modules/git
    ../../home-modules/emacs
    ../../home-modules/firefox
    #../../home-modules/gpg-agent
  ];

  programs.home-manager.enable = true;

  xdg = {
    enable = true;
  };

  home = {
    stateVersion = "22.11";

    packages = with pkgs; [
      vesktop
      discord
      webcord
      signal-desktop

      remmina

      ffmpeg
      filebot
      mpv
      unstable.yt-dlp
      qimgv
    ];
  };
}
