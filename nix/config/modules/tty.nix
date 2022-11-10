{ config, lib, pkgs, ... }:

{
  services.getty.helpLine = "IP Address: \\4";

  users.motd = with config; ''

    ---------------------------------------------------------
             _ __                          __
      __ _  (_) /_____ ____  ___ __ _____ / /____ __ _  ___
     /  ' \/ /  '_/ _ `/ _ \(_-</ // (_-</ __/ -_)  ' \(_-<
    /_/_/_/_/_/\_\\_,_/_//_/___/\_, /___/\__/\__/_/_/_/___/
                               /___/

    ---------------------------------------------------------

    Welcome to ${networking.hostName}

    - This server is managed by NixOS
    - All changes are futile

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}

  '';
}
