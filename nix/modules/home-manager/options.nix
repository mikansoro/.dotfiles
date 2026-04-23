{ lib, ... }:

{
  options.mikansoro = {
    common.enable = lib.mkEnableOption "common packages and mpv";
    shell.enable = lib.mkEnableOption "shell (zsh, wezterm, CLI tools)";
    git.enable = lib.mkEnableOption "git with delta, gh, aliases";
    emacs.enable = lib.mkEnableOption "Doom Emacs with language servers";
    claude.enable = lib.mkEnableOption "Claude Code settings and MCP servers";
    firefox.enable = lib.mkEnableOption "Firefox with policies";
    gpgAgent.enable = lib.mkEnableOption "GPG agent";
    server.enable = lib.mkEnableOption "minimal server packages";
  };
}
