{ config, lib, pkgs, ... }:

let
  mpvCut = builtins.fetchGit {
    url = "https://github.com/familyfriendlymikey/mpv-cut";
    ref = "main";
    rev = "3b18f1161ffb2ff822c88cb97e099772d4b3c26d";
  };
in
{
  programs.mpv = {
    enable = true;
    package = pkgs.unstable.mpv-unwrapped;
    config = {
      #autofit = "60%x45%";
       
      #screenshots
      screenshot-format = "png";
      screenshot-png-compression = 8;
      screenshot-directory = "~/Pictures/mpv";
      screenshot-template = "%F ($p) - %n";

      # language
      alang = "jpn,jp,ja,eng,en";
      slang = "eng,en,en_US,enUS";
      demuxer-mkv-subtitle-preroll = true;
      sub-auto = "fuzzy";
      sub-file-paths = "ass:srt:sub:subs:subtitles";

      # audio
      volume = 80;
      volume-max = 150;
      # TODO: make this conditional on wayland somehow?
      ao = "pulse";

      # video
      vo = "gpu-next";
      profile = "high-quality";
      hwdec = "auto";

      deband = true;
      deband-iterations = 2;
      deband-range = 12;
      
    };
    profiles = {
      "protocol.https" = {
        cache = true;
        cache-secs = 100;
        #cache-default = 500000;
        #cache-backbuffer = 250000;
      };
      "protocol.http" = {
        cache = true;
        cache-secs = 100;
        #cache-default = 500000;
        #cache-backbuffer = 250000;
      };
      "protocol.ftp" = {
        cache = true;
        cache-secs = 100;
        #cache-default = 500000;
        #cache-backbuffer = 250000;
      };
      "extension.webm" = {
        loop-file = "inf";
      };
      "extension.gif" = {
        loop-file = "inf";
      };
      "extension.flac" = {
        volume = 50;
      };
      "extension.mp3" = {
        volume = 50;
      };
    };
  };

  home.file.".config/mpv/scripts/mpv-cut".source = mpvCut;
}
