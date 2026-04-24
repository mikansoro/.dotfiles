{ config, lib, mLib, ... }:

{
  imports = mLib.importSubmodules ./.;

  time.timeZone = lib.mkDefault "America/Los_Angeles";
  networking.domain = lib.mkIf (config.mikansoro.machineUsage == "personal") "int.mikansystems.com";

  home-manager.backupFileExtension = "hmbak";
}
