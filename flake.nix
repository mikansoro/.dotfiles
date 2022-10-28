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
