{ config, lib, pkgs, ... }:

{
  services.xserver.libinput.enable = lib.mkDefault true;
}
