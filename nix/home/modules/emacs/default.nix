{ config, lib, pkgs, system, ... }:

{
  # libvterm not avaialable on darwin, but needed on linux
  home.packages = with pkgs; [
    nixfmt
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    libvterm
  ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./config;

    emacsPackagesOverlay = self: super: with pkgs.emacsPackages; {
      gitignore-mode = git-modes;
      gitconfig-mode = git-modes;
    };
  };

  # TODO: probably should put in either per-system home manager config or nixos/nix-darwin config?
  # services.emacs = {
  #   enable = true;
  #   package = doom-emacs;
  # };
}
