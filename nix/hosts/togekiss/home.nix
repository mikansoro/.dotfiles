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
    firefox.enable = true;
    claude.enable = true;
  };

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
      unstable.yt-dlp
      qimgv
    ];
  };
}
