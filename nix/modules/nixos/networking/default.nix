{ config, lib, pkgs, ... }:

{
  networking.firewall.enable = true;

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
}
