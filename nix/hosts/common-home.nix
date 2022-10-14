{ config, pkgs, lib, ... }:
{
  home = {

    packages = with pkgs; [
      discord
      ffmpeg
      kubeseal
      plex-media-player
      signal-desktop
      steam
      steam-run
      steamPackages.steamcmd
      syncplay
      wally-cli
      # yt-dlp
    ];
  };

  programs.yt-dlp = {
    enable = true;
    # settings = {};
  }
  programs.gallery-dl = {
    enable = true;
    # settings = {};
  }

};
