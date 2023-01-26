{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  system.stateVersion = "22.05";
  users.users.nixos = {
    createHome = true;
    group = "nixos";
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPCKkMo4zEB0IVy4ojrLV2RPGl+1MBXoNuK2vZjMdJT mikans@localhost"
    ];
  };
  users.groups.nixos = {};

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    git
  ];
}
