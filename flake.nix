{
  description = "timidtogekiss system config";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-21.05";
    # nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nixpkgs.url = "github:nixos/nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
  };

  outputs = inputs@{ 
      nixpkgs,
      home-manager,
      # nixpkgs-unstable,
      nix-doom-emacs, 
      ...
  }: 
  let

    workMac = darwin.lib.darwinSystem {
      system = "x86-64-darwin";
      modules = [
        ./macos.nix
        home-manager.darwinModules.home-manager {
          home-manager.users.mrowland = import ./home.nix
        }
      ];
      specialArgs = { inherit nixpkgs; };
    };

    fedoraLaptop = home-manager.lib.homeManagerConfiguration {
      configuration = [];
      system = "x86-64-linux";
      homeDirectory = "/home/michael";
      username = "michael"
    }

    darwinConfig = {
      system = "x86-64-darwin";
      username = "mrowland";
      homeDirectory = "/Users/${username}";
    };

    linuxConfig = {
      system = "x86-64-linux";
      username = "michael";
      homeDirectory = "/home/${username}";
    };

    # globalPkgsConfig = import ./nix/config/nixpkgs/config.nix;

    # overlay-unstable = final: prev: {
    #   unstable = import nixpkgs-unstable {
    #     inherit system;
    #     config = globalPkgsConfig;
    #   };
    # };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      #config = globalPkgsConfig;
      # overlays = [ overlay-unstable ];
    };

  in {
    homeManagerConfigurations = {
      michael = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "michael";
        homeDirectory = "/home/michael";
        # stateVersion = "21.05";
        configuration = {
            imports = [
              nix-doom-emacs.hmModule
              ./nix/home/michael.nix
              ./nix/modules/doom-emacs
              ./nix/modules/zsh
            ];
          };
      };
    };

    nixosConfigurations = {
      mkn-p-hq-desk01 = nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        modules = [
          ./nix/system/configuration.nix
        ];
      };
    };
  };
}
