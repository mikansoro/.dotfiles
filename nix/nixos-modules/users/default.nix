{ config, lib, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "cdrom" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$y$j9T$LhwP9FH9wiINgPhisrhRr/$PdVLLbxlavdm2Da2dEopvhcEH8Po7a1n6sQhwtNvy56";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPCKkMo4zEB0IVy4ojrLV2RPGl+1MBXoNuK2vZjMdJT mikans@localhost"
    ];
    shell = pkgs.zsh;
  };

  users.users.mikans = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    # TODO: look into agenix/other secret management scheme
    hashedPassword = "$y$j9T$LhwP9FH9wiINgPhisrhRr/$PdVLLbxlavdm2Da2dEopvhcEH8Po7a1n6sQhwtNvy56";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPCKkMo4zEB0IVy4ojrLV2RPGl+1MBXoNuK2vZjMdJT mikans@localhost"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # enable smartcard daemon so I can use yubikeys with yubico authenticator.
  # vaguely authentication related, dont have a better place for this right now.
  services.pcscd.enable = true;
}
