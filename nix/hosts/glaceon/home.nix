{ config, lib, pkgs, ... }:

{
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

  systemd.user.sessionVariables = {
    GDK_SCALE = "1";
  };

  # stop vulkan from crashing all the time on nvidia
  programs.mpv.config.hwdec = lib.mkForce "nvdec";
  
  home = {
    stateVersion = "22.11";

    packages = with pkgs; [
      unstable.discord
      unstable.vesktop
      webcord
      signal-desktop
      remmina

      makemkv
      losslesscut-bin
      mkvtoolnix
      handbrake

      ffmpeg
      filebot
      unstable.yt-dlp

      unstable.opencode
    ];
  };
}
