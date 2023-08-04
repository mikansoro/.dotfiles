{ config, lib, pkgs, ... }:

{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };
}
