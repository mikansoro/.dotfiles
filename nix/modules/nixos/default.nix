{ lib, mLib, ... }:

{
  imports = mLib.importSubmodules ./.;

  time.timeZone = lib.mkDefault "America/Los_Angeles";
  networking.domain = lib.mkDefault "int.mikansystems.com";
}
