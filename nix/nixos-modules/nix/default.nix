{ config, lib, pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
  nix.settings.trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
}
