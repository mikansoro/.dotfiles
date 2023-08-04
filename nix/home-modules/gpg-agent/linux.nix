{ config, lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # TODO: port this to nix-darwin, because it tries to create systemd services (not supported on macos)
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableSshSupport = true;
    grabKeyboardAndMouse = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentryFlavor = "curses";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
