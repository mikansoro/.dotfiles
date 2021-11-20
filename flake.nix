{
  description = "timidtogekiss system config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, nixpkgs-unstable, ... }:
  let
    system = "x86_64-linux";

    globalPkgsConfig = { allowUnfree = true; };

    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config = globalPkgsConfig;
      }; 
    };

    pkgs = import nixpkgs {
      inherit system;
      config = globalPkgsConfig;
      overlays = [ overlay-unstable ];
    };

  #  lib = nixpkgs.lib;

  in {
    homeManagerConfigurations = {
      michael = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "michael";
        homeDirectory = "/home/michael";
        stateVersion = "21.05";
        configuration = {
            imports = [
              ./nix/home/michael.nix
              ./nix/modules/doom-emacs
              ./nix/modules/zsh
            ];
          };
      };
    };

    nixosConfigurations = {
      mkn-p-hq-desk01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./system/configuration.nix
        ];
      };
    };
  };
}
