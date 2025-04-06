{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home-modules/common
    ../../home-modules/shell
    ../../home-modules/git
    #../../home-modules/gpg-agent
    # ../../home-modules/gpg
    ../../home-modules/emacs
  ];

  programs.home-manager.enable = true;

  home = {
    # username = "michael.rowland";
    # homeDirectory = "/Users/michael.rowland";
    stateVersion = "22.05";

    packages = with pkgs; [
      argocd
      awscli2
      devbox
      #conftest
      #eksctl
      # docker-machine-hyperkit #darwin-only - from brew installed list
      kind
      kubeconform
      # mongosh # unknown variable
      # mysql-shell # build fail, ld fatal warning - libs were build for newer macos version than linked (10.12 vs 10.10)
      #skaffold
      skopeo
      sqlite
      # upx #golang-tooling
      #pinentry_mac

      python312
      colima
      docker-client
      go
      unstable.granted
    ];
  };

  # gpg-agent with pinentry_mac workaround - START
  # inispiration: https://github.com/jwiegley/nix-config/blob/master/config/home.nix
  #
  # programs.gpg in module above
  # services.gpg-agent.enable = false;
  # gpg-agent with pinentry_mac workaround - END

  xdg = {
    enable = true;
  };

  programs.zsh = {
    shellAliases = {
      # kconftest = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy $1";
      # kconfcombined = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy --namespace combined --combine $1";
      # kconform = "kubeconform -summary -skip AnalysisTemplate,Application,AppProject,Kustomization,Rollout,TCPMapping -strict -schema-location default -schema-location '$HOME/git/foursquare/kubernetes-manifests/crd_schemas/{{ .ResourceKind }}-{{ .ResourceAPIVersion }}.json' -kubernetes-version 1.21.0";
      # ktestall = "kconform && kconftest && kconfcombined";

      # for pkgs.granted. Need to add the alias or the shell script errors out...
      assume = "source ${pkgs.unstable.granted}/bin/assume";
      flushdns = "sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder";
    };
    initExtraBeforeCompInit = "PATH='/Users/michael.rowland/bin':$PATH";
    envExtra = ''
    export STARTERVIEW="/Users/michael.rowland/git/zr-private/ziprecruiter/main"
    PATH=$PATH:$STARTERVIEW/bin
    '';
  };

  programs.git = {
    includes = [
      {
        condition = "gitdir:~/git/ziprecruiter/";
        contents = {
          user = {
            email = "michael.rowland@ziprecruiter.com";
            name = "Michael Rowland";
          };
        };
      }
      {
        condition = "gitdir:~/git/zr-private/";
        contents = {
          user = {
            email = "michael.rowland@ziprecruiter.com";
            name = "Michael Rowland";
          };
        };
      }
    ];
  };

  targets.darwin.defaults = {
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };
}
