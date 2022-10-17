{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    libvterm
  ];

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
