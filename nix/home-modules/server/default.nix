{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      kubectl
      kubernetes-helm
      p7zip
      unzip
    ];
}
