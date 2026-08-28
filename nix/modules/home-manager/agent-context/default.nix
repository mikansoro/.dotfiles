{ config, lib, pkgs, ... }:

let
  context = ''
    ${builtins.readFile ./global.md}
    ${if (config.mikansoro.machineUsage == "personal") then builtins.readFile ./home.md else ""}
  '';
in
{
  programs.claude-code.context = context;
  programs.opencode.context = context;
}
