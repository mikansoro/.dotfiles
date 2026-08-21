{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  mikansoro = {
    machineUsage = "work";
    common.enable = true;
    shell.enable = true;
    git.enable = true;
    emacs.enable = true;
    firefox.enable = true;
    claude.enable = true;
    pi-coding-agent.enable = true;
  };

  programs.home-manager.enable = true;

  xdg = {
    enable = true;
  };

  programs.zsh = {
    initContent = lib.mkOrder 550 "eval $(${pkgs.wt} shell-init)";
  };

  home = {
    packages = with pkgs; [
      wt
    ];
    stateVersion = "25.11";
  };
}
