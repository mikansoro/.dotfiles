{ config, pkgs, ... }:
let
  nixFlakes = (pkgs.writeScriptBin "nixFlakes" ''
      exec $(pkgs.nixUnstable)/bin/nix --experimental-features "nix-command flakes" "$@"
    '');
in {
  imports = [
    ../common.nix
  ];
};
