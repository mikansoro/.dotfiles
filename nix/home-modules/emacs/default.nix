{ config, lib, pkgs, system, inputs, ... }:

let
  doom = {
    repoUrl = "https://github.com/doomemacs/doomemacs.git";
  };
  emacsConfigDir = "${config.xdg.configHome}/emacs";
in {

  #nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    ((emacsPackagesFor emacs30).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
    emacsPackages.nerd-icons # doom-emacs switched from all-the-icons to nerd-icons https://github.com/doomemacs/doomemacs/issues/7379
    nixfmt-rfc-style
    binutils
    nodePackages.yaml-language-server
    pyright
    git
    (ripgrep.override {withPCRE2 = true;})
    gnutls              # for TLS connectivity
    fd                  # faster projectile indexing
    imagemagick         # for image-dired
    ispell
    python312Packages.grip
    gopls               # go language server
    delve
    gdlv
    cue
    lua-language-server
    docker-ls
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    libvterm
  ] ++ lib.optionals (pkgs.stdenv.isDarwin) [
    cmake               # for some reason the default make on macos 14 doesn't work for compiling vterm
  ];

  # home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/.dotfiles/nix/home-modules/emacs/config";

  home.activation = {
    install-doom = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if ! [ -d "${config.xdg.configHome}/emacs" ]; then
        PATH="${config.home.path}/bin:$PATH" $DRY_RUN_CMD git clone $VERBOSE_ARG --depth=1 --single-branch "${doom.repoUrl}" "${emacsConfigDir}"
        PATH="${config.home.path}/bin:$PATH" $DRY_RUN_CMD "${emacsConfigDir}/bin/doom" sync
      fi
    '';
  };
}
