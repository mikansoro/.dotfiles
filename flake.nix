{
  description = "mikansoro system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        emacs-overlay.follows = "emacs-overlay";
      };
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    darwin,
    home-manager,
    nixpkgs-stable,
    nix-doom-emacs,
    nixos-generators,
    ...
  }:
    let
      lib = nixpkgs.lib;

      # left for compatibility w/ xen image builds for now
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };

      genPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      genPkgsStable = system: import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      hmConfig = hostName:
        let
          configPath = ./nix/hosts + "/${hostName}/home.nix";
        in
        lib.mkMerge [
          nix-doom-emacs.hmModule
          configPath
          {
            nixpkgs.overlays = [
              ./nix/overlays/terraform.nix
            ];
          }
        ];

      # inspired by github.com/thexyno/nixos-config
      darwinSystem = system: hostName:
        let
          pkgs = genPkgs system;
          configPath = ./nix/hosts + "/${hostName}/configuration.nix";
        in
          darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit pkgs self darwin; };
            modules = [
              {
                users.users.mrowland = {
                  name = "mrowland";
                  home = "/Users/mrowland";
                  shell = pkgs.zsh;
                };
              }
              home-manager.darwinModules.home-manager {
                home-manager.extraSpecialArgs = { inherit pkgs; };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.mrowland = hmConfig hostName;
              }
              configPath
            ];
          };

      processConfigurations = lib.mapAttrs (name: func: func name);

    in {
      darwinConfigurations = processConfigurations {
        workMac = darwinSystem "x86_64-darwin";
      };

      homeConfigurations = {
        # work-mac = home-manager.lib.homeManagerConfiguration {
        #   pkgs = genPkgs "x86_64-linux";
        #   modules = [
        #     nix-doom-emacs.hmModule
        #     ./nix/home/work-mac
        #     # {
        #     #   nixpkgs.overlays = [
        #     #     ./nix/overlays/terraform.nix
        #     #   ];
        #     # }
        #   ];
        # };
      };

      packages.x86_64-linux = {
        # generate a VMDK for import to xenorchestra, not vcenter
        # disables vmware guest settings, enables systemd uefi boot for xen, and xe guest utils for monitoring
        xenImage = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = genPkgsStable "x86_64-linux";
          modules = [
            "${inputs.nixpkgs-stable}/nixos/modules/virtualisation/xen-domU.nix"
            ./nix/config/modules/vmconfig.nix
            ./nix/config/modules/tty.nix
            ({ lib, ...} : {
              services.xe-guest-utilities.enable = true;
              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;
              virtualisation.vmware.guest.enable = lib.mkForce false;
            })
            # create a separate module to not have to wrap the options above in config = {}
            # best way? probably not. /shrug
            ({ config, ...} : {
              # same derivation name as upstream vmware-image, but replace vmware with xen
              vmware.vmDerivationName = "nixos-xen-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
            })
          ];
          format = "vmware";
        };
        proxmoxImage = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = genPkgsStable "x86_64-linux";
          modules = [
            ./nix/config/modules/vmconfig.nix
            ./nix/config/modules/tty.nix
          ];
          format = "proxmox";
        };
      };
    };
}
