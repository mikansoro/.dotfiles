{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/common
    ../../home-modules/shell
    ../../home-modules/git
    ../../home-modules/emacs
  ];

  mikansoro.machineUsage = "personal";

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";

    packages = with pkgs; [
      ffmpeg
      filebot
      yt-dlp
    ];
  };
}
