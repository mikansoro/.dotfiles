{ config, lib, pkgs, wezterm, ... }:

{
  programs.wezterm = {
    enable = true;
    package = wezterm.packages.${pkgs.system}.default;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."wezterm/wezterm.lua".text = lib.mkForce null;
  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;

  # nix.settings = {
  #   substituters = ["https://cache.nixos.org" "https://wezterm.cachix.org"];
  #   trusted-public-keys = ["wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="];
  # };
}
