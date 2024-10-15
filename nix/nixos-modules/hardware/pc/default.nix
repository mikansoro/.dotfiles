{ config, lib, pkgs, ... }:

{
  services.libinput.enable = lib.mkDefault true;
}
