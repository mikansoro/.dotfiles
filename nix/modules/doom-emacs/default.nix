{ pkgs, ... }:

{
  home.packages = [ 
    pkgs.libvterm
    pkgs.terraform
  ];
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../../../files/doom.d;
  };
}
