{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../cpu/amd
    ../../../pc/laptop
    ../../../pc/laptop/acpi_call.nix
    ../../../pc/ssd
  ];

  # Somehow psmouse does not load automatically on boot for me
  boot.initrd.kernelModules = [ "psmouse" ];

  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  }
}
