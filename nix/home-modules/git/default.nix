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
    # TODO: migrate settings during 25.11
    #settings = {
    #  alias = {
    #    
    #  };
    #};
    userName = "Michael Rowland";
    userEmail = "michael@mikansystems.com";
    ignores = [
      ".envrc"
      ".direnv"
    ];
    aliases = {
      a = "add";
      b = "branch";
      base = "rev-parse --show-toplevel";
      bl = "branch -vv";
      bd = "branch --delete --force";
      br = "branch --sort=-committerdate";
      c = "checkout";
      cl = "checkout -";
      cb = "!f() { git checkout -b \"$(date +'%Y%m%d')-$1\"; }; f";
      # cb = "!f() { git checkout -b \"mrowland/$(date +'%Y%m%d')/$1\"; }; f";
      cbfeat = "!f() { git checkout -b \"feat/$1\"; }; f";
      cbfix = "!f() { git checkout -b \"fix/$1\"; }; f";
      cbzip = "!f() { git checkout -b \"michaelr.$1\"; }; f";
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
      re = "reset";
    	reh = "reset --hard";
    	res = "reset --soft";
    	rq = "rebase --quit";
      rs = "rebase --skip";
      s = "status";
      st = "stash";
      stp = "stash pop";
      # TODO: make work with ssh proto origins (i.e. github:user/reop or git@github.com:user/repo)
      # TODO: improve cross-platform (linux/mac) operation
      # open = "!f() { URL=$(git config remote.${1:-origin}.url); xdg-open \"${URL%%.git}\" || open \"${URL%%.git}\"; }; f"
      rebase-branch = "!COMMITS=$(BRANCH=$(git rev-parse --abbrev-ref HEAD); git rev-list --count master..$BRANCH); git rebase -i HEAD^$COMMITS";
      # thanks https://zarino.co.uk/post/git-set-upstream/
      set-upstream = "!git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`";
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
