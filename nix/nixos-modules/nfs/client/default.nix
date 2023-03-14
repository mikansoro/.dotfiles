{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "nfs" "nfsv4" ];
  environment.systemPackages = [ pkgs.nfs-utils ];
}
