{ config, pkgs, lib, ... }:
{
  imports = [
  ];
  home = {
    packages = with pkgs; [
      _1password
      _1password-gui
      #dig
      # fd
      #gnused
      helm
      #htop
      ipmitool
      #jq
      kubectl
            #kubectx
      minikube
      mpv
      nmap
      p7zip
      pinentry
      pgcli
      #ripgrep
      spotify
      terraform
      #tmux
      #tree
      unzip
      #vim
      #whois
      #yq-go
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      yubioath-desktop
      zip
    ];
  };

  programs.gpg = {
    enable = false;
    mutableKeys = true;
    mutableTrust = true;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableSSHSupport = true;
    grabKeyboardAndMouse = true;
    # defaultCacheTtl = 60;
    # maxCacheTtl = 120;
    # pinentryFlavor =
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Michael Rowland";
    userEmail = "michael@mikansystems.com";
    aliases = {
      a = "add";
      b = "branch"
      bl = "branch -vv";
      bd = "branch --delete --force";
      c = "checkout";
      cl = "checkout -";
      # cb = "!f() { checkout --branch $(date +'%Y%m%')-${1} }; f";
      cb = "!f() { git checkout -b \"mrowland/$(date +'%Y%m%d')/${1}\"; }; f";
      cbfeat = "!f() { git checkout -b \"feat/${1}\"; }; f";
      cbfix = "!f() { git checkout -b \"fix/${1}\"; }; f";
      cp = "cherry-pick";
      cpa = "cherry-pick --abort";
      cpc = "cherry-pick --continue";
      cpq = "cherry-pick --quit";
      cdate = "show -s --format=%cd --date=iso HEAD";
      chash = "rev-parse --short HEAD";
      chashf = "rev-parse HEAD";
      cm = "commit --message";
      cam = "commit --add --message";
      can = "commit --amend --no-edit";
      lg = "log --pretty=oneline --graph";
      p = "pull";
      pu = "push";
      puf = "push --force-with-lease";
      puff = "push --force";
      r = "rebase";
    	ra = "rebase --abort";
    	rc = "rebase --continue";
    	rq = "rebase --quit";
      rs = "rebase --skip";
      re = "reset";
    	res = "reset --soft";
    	reh = "reset --hard";
      s = "status";
      st = "stash";
      stp = "stash pop";
      # TODO: make work with ssh proto origins (i.e. github:user/reop or git@github.com:user/repo)
      # TODO: improve cross-platform (linux/mac) operation
      # open = "!f() { URL=$(git config remote.${1:-origin}.url); xdg-open \"${URL%%.git}\" || open \"${URL%%.git}\"; }; f"
      whoami = "!echo $(git config --get user.name) '<'$(git config --get user.email)'>'";
      git = "!git";
    };
    extraConfig = {
      color = {
        ui = true;
      };
      core = {
        pager = "delta";
      };
      delta = {
        # TODO: Check that this works
        line-numbers = true;
      };
      grep = {
        lineNumber = true;
      };
      init = {
        defaultBranch = "main";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      pull = {
        rebase = true;
      };
      push = {
        default = "current";
      };
      url."git@github.com:".insteadOf = "github:";
      url."https://github.com/".insteadOf = "githubh:";
      url."git@gitlab.com:".insteadOf = "gitlab:";
      url."https://gitlab.com/".insteadOf = "gitlabh:";
    };
  };

  # programs.starship = {
    # enable = true;
    # enableZshIntegration = true;
    # enableBashIntegration = true;
    # settings = {
      # format = lib.concatStrings [
        # # TODO: make sure the escapes are correct. should end up as $kubernetes\ in final output
        # "$directory$git_branch$git_state$git_status\\"
        # "$kubernetes\\"
        # "$cmake\\"
        # "$dart\\"
        # "$deno\\"
        # "$dotnet\\"
        # "$elixir\\"
        # "$elm\\"
        # "$erlang\\"
        # "$golang\\"
        # "$helm\\"
        # "$java\\"
        # "$julia\\"
        # "$kotlin\\"
        # "$nim\\"
        # "$nodejs\\"
        # "$ocaml\\"
        # "$perl\\"
        # "$php\\"
        # "$purescript\\"
        # "$python\\"
        # "$red\\"
        # "$ruby\\"
        # "$rust\\"
        # "$scala\\"
        # "$swift\\"
        # "$terraform\\"
        # "$vlang\\"
        # "$vagrant\\"
        # "$zig\\"
        # "$terraform"
        # "$time $username$hostname $nix_shell$character"
      # ];
      # add_newline = false;
      # directory = {
        # truncation_length = 5;
        # truncation_symbol = ".../";
        # style = "bold bright-blue";
      # };
      # git_branch = {
        # style = "bold green";
        # format = "[\\[[$branch$tag](bold green)\\]](bold white)";
      # };
      # git_status.format = " ([\\[$conflicted$deleted$renamed$modified$staged$untracked$ahead_behind\\]]($style)) ";
      # hostname = {
        # ssh_only = true;
        # format = "@[$hostname]($style)";
        # style = "bold white"
      # };
      # kubernetes = {
        # disabled = false;
        # format = "on [\\($symbol$context:$namespace\\)](purple bold) ";
      # };
      # nix_shell = {
        # disabled = false;
        # impure_msg = "[impure shell](bold red)";
        # pure_msg = "[pure shell](bold green)";
        # format = "[\\(nix: $state $name\\)](bold blue) ";
      # };
      # terraform = {
        # format = "via [$symbol$version](bold 105) ";
      # };
      # time = {
        # disabled = false;
        # format = "[$time]($style)";
        # time_format = "%H:%M";
      # };
      # username = {
        # show_always = true;
        # format = "[$user]($style)";
        # style_user = "bold white;"
      # };
    # };
  # };

};
