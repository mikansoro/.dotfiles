{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/common
    ../../home-modules/shell
    ../../home-modules/git
    ../../home-modules/emacs
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";
  };
}
