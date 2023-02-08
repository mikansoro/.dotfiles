{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/server
    ../../home-modules/shell
    ../../home-modules/git
    # ../../home-modules/gpg
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";
  };
}
