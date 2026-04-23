{ config, lib, pkgs, ... }:

# from https://github.com/NixOS/nixos-hardware/blob/master/common/pc/laptop/acpi_call.nix

{
  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };
}
