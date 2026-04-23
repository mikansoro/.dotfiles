{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  mikansoro = {
    machineUsage = "personal";
    common.enable = true;
    shell.enable = true;
    git.enable = true;
    emacs.enable = true;
  };

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
