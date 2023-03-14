{ config, lib, pkgs, ... }:

# from https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix

{
  services.fstrim.enable = lib.mkDefault true;
}
