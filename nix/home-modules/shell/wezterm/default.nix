{ config, lib, pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
    enableBashIntegration = true;
    enableZshIntegration = true;
    extraConfig = ''
      local config = {
        audible_bell = "Disabled",

        color_scheme = 'Rapture',
        font = wezterm.font('Source Code Pro'),
        font_size = ${ if pkgs.stdenv.isDarwin then "13.0" else "10.0" },
        front_end = "WebGpu",

        initial_cols = 120,
        initial_rows = 30,

        hide_tab_bar_if_only_one_tab = true,

        enable_wayland = true,
      }

      return config
    '';
  };

  # nix.settings = {
  #   substituters = ["https://cache.nixos.org" "https://wezterm.cachix.org"];
  #   trusted-public-keys = ["wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="];
  # };
}
