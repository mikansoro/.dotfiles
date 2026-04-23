{ config, ...}: 

{
  boot = {
    kernelModules = [ "tp_smapi" ];
    extraModulePackages = with config.boot.kernelPackages; [ tp_smapi ];
  };
}
