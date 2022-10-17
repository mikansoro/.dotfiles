{ config, pkgs, lib, ... }:
{

  home.packages = with pkgs; [
    dig
    fd
    gnused
    htop
    jq
    ripgrep
    tmux
    tree
    whois
    yq-go
  ];

  # add git config here?

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      format = lib.concatStrings [
        # TODO: make sure the escapes are correct. should end up as $kubernetes\ in final output
        "$directory$git_branch$git_state$git_status\\"
        "$kubernetes\\"
        "$cmake\\"
        "$dart\\"
        "$deno\\"
        "$dotnet\\"
        "$elixir\\"
        "$elm\\"
        "$erlang\\"
        "$golang\\"
        "$helm\\"
        "$java\\"
        "$julia\\"
        "$kotlin\\"
        "$nim\\"
        "$nodejs\\"
        "$ocaml\\"
        "$perl\\"
        "$php\\"
        "$purescript\\"
        "$python\\"
        "$red\\"
        "$ruby\\"
        "$rust\\"
        "$scala\\"
        "$swift\\"
        "$terraform\\"
        "$vlang\\"
        "$vagrant\\"
        "$zig\\"
        "$terraform"
        "$time $username$hostname $nix_shell$character"
      ];
      add_newline = false;
      directory = {
        truncation_length = 5;
        truncation_symbol = ".../";
        style = "bold bright-blue";
      };
      git_branch = {
        style = "bold green";
        format = "[\\[[$branch$tag](bold green)\\]](bold white)";
      };
      git_status.format = " ([\\[$conflicted$deleted$renamed$modified$staged$untracked$ahead_behind\\]]($style)) ";
      hostname = {
        ssh_only = true;
        format = "@[$hostname]($style)";
        style = "bold white"
      };
      kubernetes = {
        disabled = false;
        format = "on [\\($symbol$context:$namespace\\)](purple bold) ";
      };
      nix_shell = {
        disabled = false;
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        format = "[\\(nix: $state $name\\)](bold blue) ";
      };
      terraform = {
        format = "via [$symbol$version](bold 105) ";
      };
      time = {
        disabled = false;
        format = "[$time]($style)";
        time_format = "%H:%M";
      };
      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "bold white;"
      };
    };
  };

};
