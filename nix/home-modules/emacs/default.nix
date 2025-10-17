{ config, lib, pkgs, system, inputs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./config;
    extraPackages = epkgs: with pkgs; [
      # emacs modes
      emacsPackages.gitconfig

      # package dependencies
      emacsPackages.nerd-icons

      binutils
      fd              # faster projectile indexing
      git
      gnutls          # for TLS connectivity
      imagemagick     # for image-dired
      ispell
      python313Packages.grip
      (ripgrep.override {withPCRE2 = true;})

      # language support
      cue
      nixfmt-rfc-style

      # language servers
      docker-ls
      gopls
      lua-language-server
      pyright
      nodePackages.yaml-language-server
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      libvterm
      wl-clipboard
      xclip
    ] ++ lib.optionals (pkgs.stdenv.isDarwin) [
      cmake               # for some reason the default make on macos 14 doesn't work for compiling vterm
    ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    startWithUserSession = "graphical";
  };

  programs.zsh.shellAliases = {
    editor = "f(){ ${lib.getBin config.services.emacs.package}/bin/emacsclient \"\${@:--c}\" };f";
  };

  home.packages = with pkgs; [
    delve
    gdlv
  ];
}
