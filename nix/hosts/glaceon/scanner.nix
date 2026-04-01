{ config, lib, pkgs, ... }:

{
  hardware.sane = {
    enable = true;
    drivers.scanSnap.enable = true;
  };

  users.users.michael.extraGroups = [ "scanner" "lp" ];

  environment.systemPackages = with pkgs; [
    sane-backends
    gscan2pdf
    simple-scan
  ];
}
