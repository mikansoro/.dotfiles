{ config, lib, pkgs, ... }:

{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  config = lib.mkIf config.mikansoro.gpgAgent.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
      homedir = "${config.xdg.configHome}/gnupg";
    };
  };
}
