{
  description = "mikansoro system config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    # darwin.url "github:lnl7/nix-darwin";
    # darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs@{
      nixpkgs,
      home-manager,
      nixpkgs-stable,
      nix-doom-emacs,
      nixos-generators,
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
      pkgs-stable = import nixpkgs-stable {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };
      overlays = [
        # TODO: use the file instead of defining inline
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
      packages.x86_64-linux = {
        # generate a VMDK for import to xenorchestra, not vcenter
        # disables vmware guest settings, enables systemd uefi boot for xen, and xe guest utils for monitoring
        xenImage = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = pkgs-stable;
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
          pkgs = pkgs-stable;
          modules = [
            ./nix/config/modules/vmconfig.nix
            ./nix/config/modules/tty.nix
          ];
          format = "proxmox";
        };
      };
    };
}
