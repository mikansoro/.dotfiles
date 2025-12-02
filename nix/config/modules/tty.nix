{ config, lib, pkgs, ... }:

{
  # https://github.com/NixOS/nixpkgs/issues/63322#issuecomment-506960445
  services.getty.helpLine = "IP Address: \\4";
  networking.dhcpcd.runHook = "${pkgs.util-linux}/bin/agetty --reload";

  users.motd = with config; ''

    ---------------------------------------------------------
             _ __                          __
      __ _  (_) /_____ ____  ___ __ _____ / /____ __ _  ___
     /  ' \/ /  '_/ _ `/ _ \(_-</ // (_-</ __/ -_)  ' \(_-<
    /_/_/_/_/_/\_\\_,_/_//_/___/\_, /___/\__/\__/_/_/_/___/
                               /___/

    ---------------------------------------------------------

    Welcome to ${networking.fqdnOrHostName}

    - This server is managed by NixOS
    - All changes are futile

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}

  '';
}
