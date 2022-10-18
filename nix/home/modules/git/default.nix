{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        line-numbers = true;
      };
    };
    userName = "Michael Rowland";
    userEmail = "michael@mikansystems.com";
    aliases = {
      a = "add";
      b = "branch";
      base = "rev-parse --show-toplevel";
      bl = "branch -vv";
      bd = "branch --delete --force";
      c = "checkout";
      cl = "checkout -";
      # cb = "!f() { checkout --branch $(date +'%Y%m%')-${1} }; f";
      cb = "!f() { git checkout -b \"mrowland/$(date +'%Y%m%d')/$1\"; }; f";
      cbfeat = "!f() { git checkout -b \"feat/$1\"; }; f";
      cbfix = "!f() { git checkout -b \"fix/$1\"; }; f";
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
      # core = {
      #   pager = "delta";
      # };
      # delta = {
      #   line-numbers = true;
      # };
      grep = {
        lineNumber = true;
      };
      init = {
        defaultBranch = "main";
      };
      # interactive = {
      #   diffFilter = "delta --color-only";
      # };
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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}