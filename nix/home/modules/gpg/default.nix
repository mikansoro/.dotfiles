{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };
}
