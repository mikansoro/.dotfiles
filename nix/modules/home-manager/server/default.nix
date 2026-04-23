{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mikansoro.server.enable {
    home = {
      packages = with pkgs; [
        kubectl
        kubernetes-helm
        p7zip
        unzip
      ];
    };
  };
}
