{ config, lib, pkgs, system, ... }:

{
  # libvterm not avaialable on darwin, but needed on linux
  # TODO: how to make that happen?
  # home.packages = with pkgs; [ libvterm ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./config;
  };

  # TODO: probably should put in either per-system home manager config or nixos/nix-darwin config?
  # services.emacs = {
  #   enable = true;
  #   package = doom-emacs;
  # };
}
