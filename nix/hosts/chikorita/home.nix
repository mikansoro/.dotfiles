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
  };

  programs.home-manager.enable = true;

  xdg = {
    enable = true;
  };

  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      remmina

      ffmpeg
      unstable.yt-dlp
    ];
  };
}
