{
  description = "timidtogekiss system config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs.url = "github:nixos/nixpkgs";
    # darwin.url "github:lnl7/nix-darwin";
    # darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };

  outputs = inputs@{
      nixpkgs,
      home-manager,
      # nixpkgs-unstable,
      nix-doom-emacs,
      ...
  }:
    let
      pkgs = import nixpkgs {
        # inherit system;
        system = "x86_64-darwin";
        config = {
          allowUnfree = true;
        };
      };
      overlays = [
        (self: super: {
          # found here: https://github.com/nubank/nixpkgs/blob/master/default.nix
          # cant just call overrideAttrs and replace version, since version is hard-coded in mkTerraform in nixpkgs
          # grab shas from the nixpkgs commits for upgrades to tf
          terraform = (pkgs.mkTerraform {
            version = "1.1.9";
            sha256 = "sha256-6dyP3Y5cK+/qLoC2QPZW3QNgqOeVXegC06Pa7pSv1iE=";
            vendorSha256 = "sha256-YI/KeoOIxgCAS3Q6SXaW8my0PyFD+pyksshQEAknsz4=";
          });
        })

        # kubectl direct binary grab overlay
        # found here: https://github.com/cideM/dotfiles/blob/9c304d36eddaebb9f8e2b2d10d48676df3e1d393/flake.nix
        # (self: super: {
        #   kubectl =
        #     let
        #       urls = {
        #         "x86_64-darwin" = "darwin_amd64";
        #         "x86_64-linux" = "linux_amd64";
        #       };
        #       shas = {
        #         "x86_64-darwin" = "c902b3c12042ac1d950637c2dd72ff19139519658f69290b310f1a5924586286";
        #         "x86_64-linux" = "9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a";
        #       };
        #     in
        #     super.stdenv.mkDerivation rec {
        #       name = "terraform";
        #       version = "1.1.9";
        #       src = super.fetchurl {
        #         url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${urls."${super.system}"}.zip";
        #         sha256 = shas."${super.system}";
        #       };
        #       nativeBuildInputs = [ pkgs.unzip ];
        #       dontConfigure = true;
        #       dontUnpack = false;
        #       dontBuild = true;
        #       installPhase = ''
        #         mkdir -p $out/bin
        #         cp $src $out/bin/terraform
        #         chmod +x $out/bin/terraform
        #       '';
        #     };
        # })
      ];
    in {
      homeConfigurations = {
        work-mac = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            nix-doom-emacs.hmModule
            ./nix/home/work-mac
            {
              nixpkgs.overlays = overlays;
            }
          ];
        };
      };
    };
}
