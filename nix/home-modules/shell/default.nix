{ config, lib, ... }:

{
  imports = [
    ./clitools.nix
    ./zsh.nix
  ];

  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."wezterm/wezterm.lua".text = lib.mkForce null;
  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
}
