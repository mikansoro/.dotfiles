{ config, lib, pkgs, system, inputs, ... }:

{

  nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    nixfmt
    binutils
    nodePackages.yaml-language-server
    nodePackages.pyright
    git
    (ripgrep.override {withPCRE2 = true;})
    gnutls              # for TLS connectivity
    fd                  # faster projectile indexing
    imagemagick         # for image-dired
    emacsPackages.vterm
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29;
  };
 #  # libvterm not avaialable on darwin, but needed on linux
 #  home.packages = with pkgs; [
 #    nixfmt
 #    nodePackages.yaml-language-server
 #    nodePackages.pyright
 #  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
 #    libvterm
 #  ];

 # # programs.emacs.package = lib.mkIf pkgs.stdenv.isDarwin ( lib.mkForce pkgs.emacsMacport );

 #  programs.doom-emacs = {
 #    enable = true;
 #    doomPrivateDir = ./config;
 #    # package = lib.mkIf pkgs.stdenv.isDarwin pkgs.emacsMacport;

 #    emacsPackagesOverlay = self: super: with pkgs.emacsPackages; {
 #      gitignore-mode = git-modes;
 #      gitconfig-mode = git-modes;
 #    };
 #  };

  # TODO: probably should put in either per-system home manager config or nixos/nix-darwin config?
  # services.emacs = {
  #   enable = true;
  #   # package = doom-emacs;
  # };
}
