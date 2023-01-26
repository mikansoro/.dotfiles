{ config, lib, pkgs, ... }:

{

  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };

  # TODO: port this to nix-darwin, because it tries to create systemd services (not supported on macos)
  services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
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

  xdg.configFile."gnupg/gpg-agent.conf".text = lib.mkIf pkgs.stdenv.isDarwin ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
  programs.zsh.profileExtra = lib.mkIf pkgs.stdenv.isDarwin ''
    export GPG_TTY=$(tty)
    if ! pgrep -x "gpg-agent" > /dev/null; then
        ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    fi
  '';
  home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
    SSH_AUTH_SOCK = "$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)";
  };
}
