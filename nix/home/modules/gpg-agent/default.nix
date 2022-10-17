{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = false;
    mutableKeys = true;
    mutableTrust = true;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableSshSupport = true;
    grabKeyboardAndMouse = true;
    # defaultCacheTtl = 60;
    # maxCacheTtl = 120;
    # pinentryFlavor =
  };
}
