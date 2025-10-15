{
  description = "mikansoro system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # handles .app bundle sync
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixos-hardware,
    darwin,
    home-manager,
    nixpkgs-unstable,
    #nix-doom-emacs,
    nixos-generators,
    disko,
    wezterm,
    mac-app-util,
    ...
  }:
    let
      lib = nixpkgs.lib;

      overlays = {
        unstable-packages = final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        };
      };
      # genPkgsStable = system: import nixpkgs-stable {
        # inherit system;
        # config.allowUnfree = true;
      # };

      hmConfig = hostName:
        let
          configPath = ./nix/hosts + "/${hostName}/home.nix";
        in
        lib.mkMerge [
          #nix-doom-emacs.hmModule
          configPath
        ];

      # inspired by github.com/thexyno/nixos-config
      darwinSystem = system: hostName:
        let
          configPath = ./nix/hosts + "/${hostName}/configuration.nix";
        in
          darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit self darwin; };
            modules = [
              # Configure nixpkgs with overlays
              {
                nixpkgs.overlays = [ overlays.unstable-packages ];
                nixpkgs.config.allowUnfree = true;
              }
              mac-app-util.darwinModules.default
              {
                users.users."michael.rowland" = {
                  name = "michael.rowland";
                  home = "/Users/michael.rowland";
                  shell = lib.mkDefault pkgs.zsh;
                };
              }
              home-manager.darwinModules.home-manager {
                home-manager.extraSpecialArgs = { inherit self wezterm; };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users."michael.rowland" = hmConfig hostName;

                home-manager.sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
              }
              configPath
            ];
          };

      # inspired by github.com/thexyno/nixos-config
      nixosServer = system: hostName:
        let
          configPath = ./nix/hosts + "/${hostName}/configuration.nix";
          specialArgs = {
            inherit self wezterm nixos-hardware;
          };
        in
          nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = [
              # Configure nixpkgs with overlays
              {
                nixpkgs.overlays = [ overlays.unstable-packages ];
                nixpkgs.config.allowUnfree = true;
              }
              ./nix/config/modules/tty.nix
              disko.nixosModules.disko
              configPath
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.michael = hmConfig hostName;
                home-manager.extraSpecialArgs = {
                  inherit self wezterm;
                };
              }
            ];
          };

      processConfigurations = lib.mapAttrs (name: func: func name);

    in {

      darwinConfigurations = processConfigurations {
        workMac = darwinSystem "aarch64-darwin";
      };

      nixosConfigurations = processConfigurations {
        monferno = nixosServer "x86_64-linux";
        nuzleaf = nixosServer "x86_64-linux";
        glaceon = nixosServer "x86_64-linux";
        togekiss = nixosServer "x86_64-linux";
        x220 = nixosServer "x86_64-linux";
      };

      homeConfigurations = {
        # work-mac = home-manager.lib.homeManagerConfiguration {
        #   pkgs = genPkgs "x86_64-linux";
        #   modules = [
        #     nix-doom-emacs.hmModule
        #     ./nix/home/work-mac
        #   ];
        # };
      };

      packages.x86_64-linux =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ overlays.unstable-packages ];
            config.allowUnfree = true;
          };
        in {
          # generate a VMDK for import to xenorchestra, not vcenter
          # disables vmware guest settings, enables systemd uefi boot for xen, and xe guest utils for monitoring
          xenImage = nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            inherit pkgs;
            modules = [
              {
                nixpkgs.overlays = [ overlays.unstable-packages ];
                nixpkgs.config.allowUnfree = true;
              }
              "${inputs.nixpkgs}/nixos/modules/virtualisation/xen-domU.nix"
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
              ({ config, pkgs, ...} : {
                # same derivation name as upstream vmware-image, but replace vmware with xen
                vmware.vmDerivationName = "nixos-xen-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
              })
            ];
            format = "vmware";
          };
          proxmoxImage = nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            inherit pkgs;
            modules = [
              {
                nixpkgs.overlays = [ overlays.unstable-packages ];
                nixpkgs.config.allowUnfree = true;
              }
              ./nix/config/modules/vmconfig.nix
              ./nix/config/modules/tty.nix
            ];
            format = "proxmox";
          };
        };
    };
}
