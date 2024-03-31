{ config, lib, pkgs, system, inputs, ... }:

let
  doom = {
    repoUrl = "https://github.com/doomemacs/doomemacs.git";
  };
  emacsConfigDir = "${config.xdg.configHome}/emacs";
in {

  #nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    ((emacsPackagesFor emacs29).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
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
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    libvterm
  ] ++ lib.optionals (pkgs.stdenv.isDarwin) [
    cmake               # for some reason the default make on macos 14 doesn't work for compiling vterm
  ];

  home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/.dotfiles/nix/home-modules/emacs/config";

  home.activation = {
    install-doom = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if ! [ -d "${config.xdg.configHome}/emacs" ]; then
        $DRY_RUN_CMD git clone $VERBOSE_ARG --depth=1 --single-branch "${doom.repoUrl}" "${emacsConfigDir}"
        $DRY_RUN_CMD "${emacsConfigDir}/bin/doom" sync
      fi
    '';
  };
}
