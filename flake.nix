{
  description = "timidtogekiss system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
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
    in {
      homeConfigurations = {
        work-mac = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # system = "x86_64-darwin";
          # username = "mrowland";
          # homeDirectory = "/Users/mrowland";
          # stateVersion = "22.05";
          modules = [
            nix-doom-emacs.hmModule
            ./nix/home/work-mac
          ];
        };
      };
    };
}
