{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    btop
    firefox-esr
    nfs-utils
    ripgrep
  ] ++ lib.optionals (config.mikansoro.machineUsage == "personal") [
    libimobiledevice
    ifuse
  ];
}
